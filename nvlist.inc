
struct NVList
  List		dd ?
  Heap		dd ?
  _Count	dd ?
  _Capacity	dd ?
  _IsStringList db ?
ends

; First parameter is always SelfPtr
;
; (proc-macro is used to make FASM omit)
; (those functions, which are not used.)
;
;  NVList* Create(void)
;     Constructor
;  void Free()
;     Destructor
;
; properties
;
;  int Count()
;     Gets the count of items
;  void SetCount(NewCount)
;     Sets the new count of items
;  int Capacity()
;     Gets the capacity of the list
;  void SetCapacity(NewCapacity)
;     Sets the new capacity of the list
;  bool IsStringList()
;     Returns true if the list copies strings
;  bool ToStringList(Bool)
;     Items will be allocated and freed (Only works with strings)
;     List must be empty
;
; methods
;
;  void Clear()
;     Empties the list
;  void Expand()
;     Increments the list's capacity if needed
;  void Add(NewName, NewValue)
;     Adds a new item
;  void Insert(Index, NewName, NewValue)
;     Inserts a new item
;  void Exchange(Index1, Index2)
;     Exchanges both items
;  void Delete(Index)
;     Deletes an item
;  void* Item(Index)
;     Gets an item's name/value [eax/edx]
;  void SetItem(Index, NewName, NewValue)
;     Sets an item's name/value
;  void* Name(Index)
;     Gets an item's name
;  void SetName(Index, NewName)
;     Sets an item's name
;  void* Value(Index)
;     Gets an item's value
;  void SetValue(Index, NewValue)
;     Sets an item's value
;  void* First()
;     Gets the first item's name/value
;  void* Last()
;     Gets the last item's name/value
;  void* FirstN()
;     Gets the first item's name
;  void* LastN()
;     Gets the last item's name
;  void* FirstV()
;     Gets the first item's value
;  void* LastV()
;     Gets the last item's value
;  int IndexOfN(Name)
;     Gets the index of the first item
;     whose name is equal to Name
;  int IndexOfV(Value)
;     Gets the index of the first item
;     whose value is equal to Value
;  void* ValueFromName(Name)
;     Gets the value of the first item
;     whose name is equal to Name
;  void SetValueFromName(Name, NewValue)
;     Sets the value of the first item
;     whose name is equal to Name
;
; private
;
;  void Grow()
;     Increments the list's capacity
;  int* GetItem(Index)
;     Calculates the address of an item
;  void* AllocItem(Name, Value)
;     Creates copies - if IsStringList
;     Otherwise it just returns the two args [eax/edx]
;  void FreeItem(Item, NameOrValue)
;     Frees either Name [NameOrValue=1], Value [2] or Both [0] - if IsStringList
;
; KERNEL32.DLL
;  GetProcessHeap
;  HeapAlloc
;  HeapFree
;  HeapReAlloc
;
; MSVCRT.DLL
;  strlen
;  strcmp

proc NVList.Create
	call	[GetProcessHeap]
	push	eax
	push	sizeof.NVList
	push	HEAP_ZERO_MEMORY
	push	eax
	call	[HeapAlloc]
	mov	ecx,[esp]
	push	eax
	push	0
	push	HEAP_ZERO_MEMORY
	push	ecx
	call	[HeapAlloc]
	pop	ecx
	pop	edx
	mov	[ecx+NVList.List],eax
	and	[ecx+NVList._Count],0
	and	[ecx+NVList._Capacity],0
	mov	[ecx+NVList.Heap],edx
	mov	[ecx+NVList._IsStringList],0
	xchg	eax,ecx
	ret
endp

proc NVList.Free this
	push	[this]
	call	NVList.Clear
	mov	ecx,[this]
	push	[ecx+NVList.List]
	push	0
	push	[ecx+NVList.Heap]
	call	[HeapFree]
	mov	ecx,[this]
	push	ecx
	push	0
	push	[ecx+NVList.Heap]
	call	[HeapFree]
	ret
endp

; private

macro prep_first
 { push 0
   push [this] }

macro prep_last
 { mov eax,[this]
   mov ecx,[eax+NVList._Count]
   dec ecx
   push ecx
   push eax }

macro index_of mode
 { push ebx esi edi
   mov esi,[this]
   mov edi,[to_cmp]
   cmp [esi+NVList._Count],0
   je .err
   xor ebx,ebx
   cmp [esi+NVList._IsStringList],1
   je .str_loop
  .loop:
   push ebx
   push esi
   match =name,mode
   \{ call NVList.Name \}
   match =value,mode
   \{ call NVList.Value \}
   cmp eax,edi
   je .fin
   inc ebx
   cmp ebx,[esi+NVList._Count]
   jb .loop
   or ebx,-1
   jmp .fin
  .str_loop:
   push ebx
   push esi
   match =name,mode
   \{ call NVList.Name \}
   match =value,mode
   \{ call NVList.Value \}
   push eax
   push edi
   call [strcmp]
   add esp,8
   test eax,eax
   je .fin
   inc ebx
   cmp ebx,[esi+NVList._Count]
   jb .str_loop
  .err:
   or ebx,-1
  .fin:
   mov eax,ebx
   pop edi esi ebx }

proc NVList.Grow this
	mov	eax,[this]
	mov	ecx,[eax+NVList._Capacity]
	cmp	ecx,64
	jbe	.16or4
	mov	edx,ecx
	shr	edx,2
	jmp	.enlarge
    .16or4:
	mov	edx,16
	cmp	ecx,8
	ja	.enlarge
	mov	edx,4
    .enlarge:
	add	ecx,edx
	push	ecx
	push	eax
	call	NVList.SetCapacity
	mov	eax,[this]
	ret
endp

proc NVList.GetItem this,index
	mov	edx,[this]
	mov	ecx,[index]
	xor	eax,eax
	test	ecx,ecx
	js	.fin
	cmp	ecx,[edx+NVList._Count]
	jnb	.fin
	mov	eax,[edx+NVList.List]
	lea	eax,[eax+ecx*8]
    .fin:
	ret
endp

proc NVList.AllocItem this,name,value
	mov	ecx,[this]
	cmp	[ecx+NVList._IsStringList],1
	jnz	.fin
	push	ebx esi edi
	lea	ebx,[name]
	mov	ecx,2
    .loop:
	mov	esi,[ebx]
	push	ecx
	test	esi,esi
	js	.next
	je	.empty
	push	esi
	call	[strlen]
	add	esp,4
	test	eax,eax
	je	.empty
	inc	eax
	mov	ecx,[this]
	push	eax
	mov	ecx,[ecx+NVList.Heap]
	push	eax
	push	0
	push	ecx
	call	[HeapAlloc]
	mov	[ebx],eax
	pop	ecx
	xchg	eax,edi
	rep	movsb
    .next:
	add	ebx,4
	pop	ecx
	loop	.loop
	pop	edi esi ebx
    .fin:
	mov	eax,[name]
	mov	edx,[value]
	ret
    .empty:
	mov	ecx,[this]
	mov	ecx,[ecx+NVList.Heap]
	push	1
	push	HEAP_ZERO_MEMORY
	push	ecx
	call	[HeapAlloc]
	mov	[ebx],eax
	jmp	.next
endp

proc NVList.FreeItem this,item,mode
	mov	ecx,[this]
	cmp	[ecx+NVList._IsStringList],1
	jnz	.fin
	push	ebx edi
	mov	edi,[item]
	mov	edx,[mode]
	mov	ebx,[ecx+NVList.Heap]
	cmp	edx,2
	je	.value
	push	dword [edi]
	push	0
	push	ebx
	call	[HeapFree]
	cmp	edx,1
	je	.fin
    .value:
	push	dword [edi+4]
	push	0
	push	ebx
	call	[HeapFree]
	pop	edi ebx
    .fin:
	mov	eax,[item]
	ret
endp

; properties

proc NVList.Count this
	mov	eax,[this]
	mov	eax,[eax+NVList._Count]
	ret
endp

proc NVList.SetCount this,count
	push	edi
	mov	edi,[this]
	mov	ecx,[count]
	mov	edx,[edi+NVList._Capacity]
	test	ecx,ecx
	js	.err
	cmp	ecx,edx
	jbe	.enough
	push	ecx
	push	edi
	call	NVList.SetCapacity
    .enough:
	mov	ecx,[count]
	mov	edx,[edi+NVList._Count]
	cmp	ecx,edx
	jbe	.delete
	mov	eax,[edi+NVList.List]
	sub	ecx,edx
	push	edi
	lea	edi,[eax+edx*8-8]
	shl	ecx,1
	xor	eax,eax
	rep	stosd
	pop	edi
	jmp	.fin
    .delete:
	cmp	[edi+NVList._IsStringList],1
	jnz	.fin
	dec	edx
	cmp	edx,ecx
	jl	.fin
	push	ecx edx
	push	edx
	push	edi
	call	NVList.Delete
	pop	edx ecx
	jmp	.delete
    .fin:
	mov	eax,[count]
	mov	[edi+NVList._Count],eax
    .err:
	pop	edi
	ret
endp

proc NVList.Capacity this
	mov	eax,[this]
	mov	eax,[eax+NVList._Capacity]
	ret
endp

proc NVList.SetCapacity this,capacity
	mov	eax,[this]
	mov	ecx,[capacity]
	mov	edx,[eax+NVList._Count]
	cmp	ecx,edx
	jl	.fin
	mov	edx,[eax+NVList._Capacity]
	cmp	ecx,edx
	je	.fin
	mov	[eax+NVList._Capacity],ecx
	shl	ecx,3
	push	ecx
	push	[eax+NVList.List]
	push	HEAP_ZERO_MEMORY
	push	[eax+NVList.Heap]
	call	[HeapReAlloc]
	mov	ecx,[this]
	mov	[ecx+NVList.List],eax
    .fin:
	ret
endp

proc NVList.IsStringList this
	mov	eax,[this]
	movzx	eax,[eax+NVList._IsStringList]
	ret
endp

proc NVList.ToStringList this,bool
	mov	eax,[this]
	mov	edx,[bool]
	mov	ecx,[eax+NVList._Count]
	lea	eax,[eax+NVList._IsStringList]
	test	ecx,ecx
	jnz	.fin
	mov	[eax],dl
    .fin:
	movzx	eax,byte [eax]
	ret
endp

; methods

proc NVList.Clear this
	push	0
	push	[this]
	call	NVList.SetCount
	push	0
	push	[this]
	call	NVList.SetCapacity
	ret
endp

proc NVList.Expand this
	mov	eax,[this]
	mov	ecx,[eax+NVList._Count]
	cmp	ecx,[eax+NVList._Capacity]
	jnz	.fin
	push	eax
	call	NVList.Grow
    .fin:
	ret
endp

proc NVList.Add this,name,value
	mov	eax,[this]
	mov	ecx,[eax+NVList._Count]
	cmp	ecx,[eax+NVList._Capacity]
	jnz	.dontgrow
	push	ecx
	push	eax
	call	NVList.Grow
	pop	ecx
    .dontgrow:
	inc	[eax+NVList._Count]
	mov	eax,[eax+NVList.List]
	lea	eax,[eax+ecx*8]
	push	eax
	push	[value]
	push	[name]
	push	[this]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
	mov	[ecx+4],edx
	ret
endp

proc NVList.Insert this,index,name,value
	push	esi edi
	mov	eax,[this]
	mov	ecx,[eax+NVList._Count]
	cmp	ecx,[eax+NVList._Capacity]
	jnz	.dontgrow
	push	ecx
	push	eax
	call	NVList.Grow
	pop	ecx
    .dontgrow:
	inc	[eax+NVList._Count]
	mov	eax,[eax+NVList.List]
	mov	edx,[index]
	test	edx,edx
	js	.fin
	cmp	edx,ecx
	jnb	.fin
	lea	edi,[eax+ecx*8]
	lea	esi,[eax+edx*8]
	sub	ecx,edx
	push	esi
	shl	ecx,1
	std
	rep	movsd
	cld
	push	[value]
	push	[name]
	push	[this]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
	mov	[ecx+4],edx
    .fin
	pop	edi esi
	ret
endp

proc NVList.Exchange this,index1,index2
	mov	eax,[this]
	mov	ecx,[index1]
	mov	edx,[index2]
	test	ecx,ecx
	js	.fin
	test	edx,edx
	js	.fin
	cmp	ecx,[eax+NVList._Count]
	jnb	.fin
	cmp	edx,[eax+NVList._Count]
	jnb	.fin
	mov	eax,[eax+NVList.List]
	push	ebx esi edi
	lea	esi,[eax+ecx*8]
	lea	edi,[eax+edx*8]
	mov	ecx,[esi]
	mov	edx,[esi+4]
	mov	eax,[edi]
	mov	ebx,[edi+4]
	mov	[edi],ecx
	mov	[edi+4],edx
	mov	[esi],eax
	mov	[esi+4],ebx
	pop	edi esi ebx
    .fin:
	ret
endp

proc NVList.Delete this,index
	mov	ecx,[index]
	mov	edx,[this]
	test	ecx,ecx
	js	.fin
	cmp	ecx,[edx+NVList._Count]
	jnb	.fin
	push	ecx
	push	edx
	call	NVList.GetItem
	push	0
	push	eax
	push	[this]
	call	NVList.FreeItem
	mov	ecx,[this]
	mov	edx,[index]
	dec	[ecx+NVList._Count]
	mov	ecx,[ecx+NVList._Count]
	cmp	edx,ecx
	jnb	.fin
	push	esi edi
	mov	edi,eax
	lea	esi,[eax+8]
	sub	ecx,edx
	shl	ecx,1
	rep	movsd
	pop	edi esi
    .fin:
	ret
endp

proc NVList.Item this,index
	push	[index]
	push	[this]
	call	NVList.GetItem
	xor	edx,edx
	test	eax,eax
	je	.fin
	mov	edx,[eax+4]
	mov	eax,[eax]
    .fin:
	ret
endp

proc NVList.SetItem this,index,name,value
	push	[index]
	push	[this]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	push	0
	push	eax
	push	[this]
	call	NVList.FreeItem
	push	eax
	push	[value]
	push	[name]
	push	[this]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
	mov	[ecx+4],edx
    .fin:
	ret
endp

proc NVList.Name this,index
	push	[index]
	push	[this]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	mov	eax,[eax]
    .fin:
	ret
endp

proc NVList.SetName this,index,name
	push	[index]
	push	[this]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	push	1
	push	eax
	push	[this]
	call	NVList.FreeItem
	push	eax
	push	-1
	push	[name]
	push	[this]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
    .fin:
	ret
endp

proc NVList.Value this,index
	push	[index]
	push	[this]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	mov	eax,[eax+4]
    .fin:
	ret
endp

proc NVList.SetValue this,index,value
	push	[index]
	push	[this]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	push	2
	push	eax
	push	[this]
	call	NVList.FreeItem
	push	eax
	push	[value]
	push	-1
	push	[this]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx+4],edx
    .fin:
	ret
endp

proc NVList.First this
	prep_first
	call	NVList.Item
	ret
endp

proc NVList.Last this
	prep_last
	call	NVList.Item
	ret
endp

proc NVList.FirstN this
	prep_first
	call	NVList.Name
	ret
endp

proc NVList.LastN this
	prep_last
	call	NVList.Name
	ret
endp

proc NVList.FirstV this
	prep_first
	call	NVList.Value
	ret
endp

proc NVList.LastV this
	prep_last
	call	NVList.Value
	ret
endp

proc NVList.IndexOfN this,to_cmp
	index_of name
	ret
endp

proc NVList.IndexOfV this,to_cmp
	index_of value
	ret
endp

proc NVList.ValueFromName this,name
	push	[name]
	push	[this]
	call	NVList.IndexOfN
	push	eax
	push	[this]
	call	NVList.Value
	ret
endp

proc NVList.SetValueFromName this,name,value
	push	[name]
	push	[this]
	call	NVList.IndexOfN
	push	[value]
	push	eax
	push	[this]
	call	NVList.SetValue
	ret
endp
