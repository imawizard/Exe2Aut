
struct NVList
  List		dd ?
  Heap		dd ?
  EmptyStr	dd ?
  _Count	dd ?
  _Capacity	dd ?
  _IsStringList db ?
ends

; First parameter
; is always SelfPtr
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
;  void* AllocItem(String, String)
;     Copies two Strings if IsStringList
;     Otherwise it just returns the two args [eax/edx]
;  void FreeItem(Item, NameOrValue)
;     Frees either Name [NameOrValue=1], Value [2] or Both [0] if IsStringList
;
; used API functions
;
;  GetProcessHeap
;  HeapAlloc
;  HeapFree
;  HeapReAlloc
;  lstrlen
;  lstrcmp

NVList.Create:
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
	push	ecx
	push	1
	push	HEAP_ZERO_MEMORY
	push	edx
	call	[HeapAlloc]
	pop	ecx
	mov	[ecx+NVList.EmptyStr],eax
	xchg	eax,ecx
	retn

NVList.Free:
	push	dword [esp+4]
	call	NVList.Clear
	mov	ecx,[esp+4]
	push	[ecx+NVList.List]
	push	0
	push	[ecx+NVList.Heap]
	call	[HeapFree]
	mov	ecx,[esp+4]
	push	ecx
	push	0
	push	[ecx+NVList.Heap]
	call	[HeapFree]
	retn	4

; private

macro prep_first
 { push 0
   push dword [esp+8] }

macro prep_last
 { mov eax,[esp+4]
   mov ecx,[eax+NVList._Count]
   dec ecx
   push ecx
   push eax }

macro index_of mode
 { push ebx esi edi
   mov esi,[esp+10h]
   mov edi,[esp+14h]
   xor ebx,ebx
  .loop:
   push ebx
   push esi
   match =name,mode
   \{ call NVList.Name \}
   match =value,mode
   \{ call NVList.Value \}
   push eax
   push edi
   call [lstrcmp]
   test eax,eax
   je .found
   inc ebx
   cmp ebx,[esi+NVList._Count]
   jb .loop
   or ebx,-1
  .found:
   mov eax,ebx
   pop edi esi ebx }

NVList.Grow:
	mov	eax,[esp+4]
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
	retn	4

NVList.GetItem:
	mov	edx,[esp+4]
	mov	ecx,[esp+8]
	xor	eax,eax
	test	ecx,ecx
	js	.fin
	cmp	ecx,[edx+NVList._Count]
	jnb	.fin
	mov	eax,[edx+NVList.List]
	lea	eax,[eax+ecx*8]
    .fin:
	retn	8

NVList.AllocItem:
	mov	ecx,[esp+4]
	cmp	[ecx+NVList._IsStringList],1
	jnz	.fin
	push	ebx esi edi
	lea	ebx,[esp+14h]
	mov	ecx,2
    .loop:
	mov	esi,[ebx]
	push	ecx
	push	esi
	call	[lstrlen]
	mov	ecx,[esp+14h]
	test	eax,eax
	je	.empty
	inc	eax
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
	mov	eax,[esp+8]
	mov	edx,[esp+0Ch]
	retn	0Ch
    .empty:
	mov	eax,[ecx+NVList.EmptyStr]
	mov	[ebx],eax
	jmp	.next

NVList.FreeItem:
	mov	ecx,[esp+4]
	cmp	[ecx+NVList._IsStringList],1
	jnz	.fin
	push	ebx edi
	mov	edi,[esp+10h]
	mov	edx,[esp+14h]
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
	mov	eax,[esp+8]
	retn	0Ch

; properties

NVList.Count:
	mov	eax,[esp+4]
	mov	eax,[eax+NVList._Count]
	retn	4

NVList.SetCount:
	push	edi
	mov	edi,[esp+8]
	mov	ecx,[esp+0Ch]
	mov	edx,[edi+NVList._Capacity]
	test	ecx,ecx
	js	.err
	cmp	ecx,edx
	jbe	.enough
	push	ecx
	push	edi
	call	NVList.SetCapacity
    .enough:
	mov	ecx,[esp+0Ch]
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
	mov	eax,[esp+0Ch]
	mov	[edi+NVList._Count],eax
    .err:
	pop	edi
	retn	8

NVList.Capacity:
	mov	eax,[esp+4]
	mov	eax,[eax+NVList._Capacity]
	retn	4

NVList.SetCapacity:
	mov	eax,[esp+4]
	mov	ecx,[esp+8]
	mov	edx,[eax+NVList._Count]
	cmp	ecx,edx
	jl	.fin
	mov	edx,[eax+NVList._Capacity]
	cmp	ecx,edx
	je	.fin
	mov	[eax+NVList._Capacity],ecx
	shl	ecx,3
	push	ecx
	push	dword [eax+NVList.List]
	push	HEAP_ZERO_MEMORY
	push	dword [eax+NVList.Heap]
	call	[HeapReAlloc]
	mov	ecx,[esp+4]
	mov	[ecx+NVList.List],eax
    .fin:
	retn	8

NVList.IsStringList:
	mov	eax,[esp+4]
	movzx	eax,[eax+NVList._IsStringList]
	retn	4

NVList.ToStringList:
	mov	eax,[esp+4]
	mov	edx,[esp+8]
	mov	ecx,[eax+NVList._Count]
	lea	eax,[eax+NVList._IsStringList]
	test	ecx,ecx
	jnz	.fin
	mov	[eax],dl
    .fin:
	movzx	eax,byte [eax]
	retn	8

; methods

NVList.Clear:
	push	0
	push	dword [esp+8]
	call	NVList.SetCount
	push	0
	push	dword [esp+8]
	call	NVList.SetCapacity
	retn	4

NVList.Expand:
	mov	ecx,[esp+4]
	mov	edx,[ecx+NVList._Count]
	cmp	edx,[ecx+NVList._Capacity]
	jnz	.fin
	push	ecx
	call	NVList.Grow
    .fin:
	mov	eax,[esp+4]
	retn	4

NVList.Add:
	push	dword [esp+4]
	call	NVList.Expand
	mov	ecx,[eax+NVList._Count]
	inc	[eax+NVList._Count]
	mov	eax,[eax+NVList.List]
	lea	eax,[eax+ecx*8]
	push	eax
	push	dword [esp+10h]
	push	dword [esp+10h]
	push	dword [esp+10h]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
	mov	[ecx+4],edx
	retn	0Ch

NVList.Insert:
	retn	10h

NVList.Delete:
	mov	ecx,[esp+8]
	mov	edx,[esp+4]
	test	ecx,ecx
	js	.fin
	cmp	ecx,[edx+NVList._Count]
	jnb	.fin
	push	ecx
	push	edx
	call	NVList.GetItem
	push	0
	push	eax
	push	dword [esp+0Ch]
	call	NVList.FreeItem
	mov	ecx,[esp+4]
	mov	edx,[esp+8]
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
	retn	8

NVList.Item:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.GetItem
	xor	edx,edx
	test	eax,eax
	je	.fin
	mov	edx,[eax+4]
	mov	eax,[eax]
    .fin:
	retn	8

NVList.SetItem:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	push	0
	push	eax
	push	dword [esp+0Ch]
	call	NVList.FreeItem
	push	eax
	push	dword [esp+14h]
	push	dword [esp+14h]
	push	dword [esp+10h]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
	mov	[ecx+4],edx
    .fin:
	retn	10h

NVList.Name:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	mov	eax,[eax]
    .fin:
	retn	8

NVList.SetName:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	push	1
	push	eax
	push	dword [esp+0Ch]
	call	NVList.FreeItem
	push	eax
	push	0
	push	dword [esp+14h]
	push	dword [esp+10h]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx],eax
    .fin:
	retn	0Ch

NVList.Value:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	mov	eax,[eax+4]
    .fin:
	retn	8

NVList.SetValue:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.GetItem
	test	eax,eax
	je	.fin
	push	2
	push	eax
	push	dword [esp+0Ch]
	call	NVList.FreeItem
	push	eax
	push	0
	push	dword [esp+14h]
	push	dword [esp+10h]
	call	NVList.AllocItem
	pop	ecx
	mov	[ecx+4],eax
    .fin:
	retn	0Ch

NVList.First:
	prep_first
	call	NVList.Item
	retn	4

NVList.Last:
	prep_last
	call	NVList.Item
	retn	4

NVList.FirstN:
	prep_first
	call	NVList.Name
	retn	4

NVList.LastN:
	prep_last
	call	NVList.Name
	retn	4

NVList.FirstV:
	prep_first
	call	NVList.Value
	retn	4

NVList.LastV:
	prep_last
	call	NVList.Value
	retn	4

NVList.IndexOfN:
	index_of name
	retn	8

NVList.IndexOfV:
	index_of value
	retn	8

NVList.ValueFromName:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.IndexOfN
	push	eax
	push	dword [esp+8]
	call	NVList.Value
	retn	8

NVList.SetValueFromName:
	push	dword [esp+8]
	push	dword [esp+8]
	call	NVList.IndexOfN
	push	dword [esp+0Ch]
	push	eax
	push	dword [esp+0Ch]
	call	NVList.SetValue
	retn	0Ch
