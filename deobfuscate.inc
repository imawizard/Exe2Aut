
;deobfu=0 -> don't try to deobfuscate
;      =1 -> try it
;rename=0 -> rename symbols if script got deobfuscated
;      =1 -> always rename symbols
;      =2 -> never rename symbols
;filein=0 -> don't adjust FileInstall
;      =1 -> do it
;compil=0 -> don't replace @Compiled
;      =1 -> do it

proc deobfuscate _source,_length,_deobfu:byte,_rename:byte,_filein:byte,_compil:byte
	push	esi
	mov	eax,[_source]
	mov	ecx,[_length]
	mov	[source],eax
	mov	[length],ecx
	xchg	eax,esi
	mov	cl,[_deobfu]
	mov	ch,[_rename]
	mov	dl,[_filein]
	mov	dh,[_compil]
	mov	[deobfu],cl
	mov	[rename],ch
	mov	[filein],dl
	mov	[compil],dh
	call	alloc_buffer
	call	_deobfuscate
	call	rename_symbols
	mov	esi,[newsrc]
	call	adjust_fileinstall
	call	adjust_@compiled
	push	esi
	call	[strlen]
	add	esp,4
	mov	edx,eax
	mov	ecx,0A0D0A0Dh
	lea	eax,[esi+edx-4]
	cmp	[eax],ecx
	jnz	.fin
	xor	cl,cl
	sub	edx,2
	mov	[eax+2],cl
    .fin:
	xchg	eax,esi
	movzx	ecx,[compm_found]
	pop	esi
	ret
endp

_deobfuscate:
	cmp	[deobfu],0
	je	.err
	cmp	[tblbuf],0
	je	.err
	call	deobfuscate_JvdZ_1_0_29
	test	eax,eax
	je	.err
	mov	[deobfu_done],1
	jmp	.fin
    .err:
	mov	[deobfu_done],0
	push	[source]
	push	[newsrc]
	call	[strcpy]
	add	esp,8
    .fin:
	retn

deobfuscate_JvdZ_1_0_29:
	push	ebx esi edi
	mov	esi,[source]
	call	get_tblsep
	test	eax,eax
	je	.err
	call	split_tbl
	cmp	eax,1
	jna	.err
	call	get_obfu_fns
	call	NVList.Create
	mov	[fns],eax
	call	NVList.Create
	mov	[fnnames],eax
	push	1
	push	eax
	call	NVList.ToStringList
	call	NVList.Create
	mov	[globals],eax
	push	esi
	call	rename_init
	push	_fnsep
	push	esi
	call	Split
	push	eax
	mov	edi,[eax]
	push	edi
	call	Dupe
	push	eax
	call	cut_obfu_header
	xchg	eax,esi
    .next_global_line:
	push	_globalline
	push	edi
	push	_var
	call	strscan
	mov	edi,eax
	test	ecx,ecx
	je	.globals_fin
	push	0
	push	_var
	push	esi
	call	Replace
	push	_globalvar
	push	_var
	push	_var
	call	strscan
	push	_varsep
	push	_var
	call	Split
	push	eax
	mov	ebx,eax
    .next_global_var:
	push	ebx
	mov	ebx,[ebx]
	test	ebx,ebx
	je	.free_global_var
	push	_varname
	push	ebx
	push	varname
	call	strscan
	push	_varindex
	push	ebx
	push	varindex
	call	strscan
	push	edx
	call	[atoi]
	add	esp,4
	push	eax
	call	get_tblitem
	push	eax
	push	eax
	push	varname
	call	Dupe
	push	eax
	push	[globals]
	call	NVList.Add
	push	varname
	push	esi
	call	replace_var
	mov	esi,eax
	pop	ebx
	add	ebx,4
	jmp	.next_global_var
    .free_global_var:
	add	esp,4
	call	[LocalFree]
	jmp	.next_global_line
    .globals_fin:
	push	0
	push	esi
	push	[fns]
	call	NVList.Add
	mov	eax,[esp]
	lea	esi,[eax+4]
    .next_func:
	push	esi
	mov	esi,[esi]
	test	esi,esi
	je	.done
	push	_fnname
	push	esi
	push	fnname
	call	strscan
	call	is_obfu_fn
	test	eax,eax
	je	.drop_func
	push	0
	push	fnname
	push	[fnnames]
	call	NVList.Add
	push	esi
	call	Dupe
	mov	esi,eax
	push	_obfusec
	push	esi
	push	_buf
	call	strscan
	test	ecx,ecx
	je	.got_func
	mov	edi,edx
	push	0
	push	edx
	push	esi
	call	Replace
    .next_line:
	push	_varline
	push	edi
	push	_var
	call	strscan
	mov	edi,eax
	test	ecx,ecx
	je	.got_func
	push	_varsep
	push	_var
	call	Split
	push	eax
	mov	ebx,eax
    .next_var:
	push	ebx
	mov	ebx,[ebx]
	test	ebx,ebx
	je	.free_var
	push	_varname
	push	ebx
	push	varname
	call	strscan
	push	_varindex
	push	ebx
	push	varindex
	call	strscan
	push	edx
	call	[atoi]
	add	esp,4
	push	eax
	call	get_tblitem
	push	eax
	push	varname
	push	esi
	call	replace_var
	mov	esi,eax
	pop	ebx
	add	ebx,4
	jmp	.next_var
    .free_var:
	add	esp,4
	call	[LocalFree]
	jmp	.next_line
    .got_func:
	cmp	[rename],2
	je	.skip_params
	push	esi
	call	rename_params
	push	eax
	call	rename_locals
	mov	esi,eax
    .skip_params:
	push	esi
	call	[strlen]
	add	esp,4
	cmp	dword [esi+eax-11],'EndF'
	je	.add_func
	push	[globals]
	call	NVList.Count
	lea	ebx,[eax-1]
    .replace_globals:
	push	ebx
	push	[globals]
	call	NVList.Item
	push	edx
	push	eax
	push	esi
	call	replace_var
	mov	esi,eax
	dec	ebx
	jns	.replace_globals
    .add_func:
	push	0
	push	esi
	push	[fns]
	call	NVList.Add
    .drop_func:
	pop	esi
	add	esi,4
	jmp	.next_func
    .done:
	add	esp,4
	call	[LocalFree]
	push	[fns]
	call	NVList.Count
	mov	[fnsnum],eax
	mov	edi,[newsrc]
	xor	ebx,ebx
    .save_new_code:
	push	ebx
	push	[fns]
	call	NVList.Name
	push	eax
	mov	esi,eax
      .copy:
	mov	al,[esi]
	mov	[edi],al
	inc	esi
	inc	edi
	test	al,al
	jnz	.copy
	call	[LocalFree]
	dec	edi
	push	_fnsep
	push	edi
	call	[strcpy]
	add	esp,8
	inc	ebx
	add	edi,5
	cmp	ebx,[fnsnum]
	jnz	.save_new_code
	mov	byte [edi-5],0
	push	[fns]
	call	NVList.Free
	cmp	[rename],2
	je	.skip_funcs
	dec	[fnsnum]
	push	[newsrc]
	call	rename_funcs
	push	eax
	call	rename_globals
	mov	[newsrc],eax
    .skip_funcs:
	push	[fnnames]
	call	NVList.Free
	call	rename_free
	push	[globals]
	call	NVList.Count
	test	eax,eax
	je	.skip_globals
	lea	ebx,[eax-1]
    .free_globals:
	push	ebx
	push	[globals]
	call	NVList.Name
	push	eax
	call	[LocalFree]
	dec	ebx
	jns	.free_globals
    .skip_globals:
	push	[globals]
	call	NVList.Free
	push	[tblbuf]
	call	[LocalFree]
	mov	eax,1
	jmp	.fin
    .err:
	xor	eax,eax
    .fin:
	pop	edi esi ebx
	retn

proc replace_var src,name,value
	push	ebx esi edi
	mov	ebx,[value]
	mov	esi,[name]
	mov	edi,_varnumbuf
	call	.copy
	mov	word [edi-1],')'
	push	_varnum
	push	[src]
	call	[strstr]
	add	esp,8
	test	eax,eax
	jnz	.number
	mov	esi,[name]
	mov	edi,_varexecbuf
	call	.copy
	mov	word [edi-1],')'
	push	_varexec
	push	[src]
	call	[strstr]
	add	esp,8
	test	eax,eax
	je	.string
	cmp	dword [eax-5],'Shel'
	je	.string
	mov	[name],_varexec
	mov	edx,_trimmacro
	jmp	.trim
    .number:
	mov	[name],_varnum
	mov	edx,_trimnum
    .trim:
	cmp	byte [ebx],' '
	jnz	.decorate
	mov	esi,_var
	push	edx
	push	ebx
	push	esi
	call	strscan
	test	ecx,ecx
	cmovnz	ebx,esi
	jmp	.decorate
    .copy:
	mov	al,[esi]
	mov	[edi],al
	inc	esi
	inc	edi
	test	al,al
	jnz	.copy
	retn
    .string:
	push	ebp
	mov	ebp,_var+1
	mov	esi,ebx
	mov	edi,ebp
	call	.copy
	push	'"'
	push	ebx
	call	[strchr]
	add	esp,8
	mov	edx,'"'
	test	eax,eax
	je	.str_fin
	push	''''
	push	ebx
	call	[strchr]
	add	esp,8
	mov	edx,''''
	test	eax,eax
	je	.str_fin
	mov	byte [ebp-1],'"'
	push	_quotes_twice
	push	_quotes
	push	ebp
	call	Replace
	xor	al,al
	or	ecx,-1
	repnz	scasb
	mov	word [edi-1],'"'
	mov	ebx,_var
	pop	ebp
	jmp	.fin
    .str_fin:
	mov	ebx,_var
	mov	[edi-1],dx
	mov	[ebx],dl
	pop	ebp
    .fin:
	push	ebx
	push	[name]
	push	[src]
	call	Replace
	pop	edi esi ebx
	ret
    .decorate:
	push	ebx
	call	[atoi]
	add	esp,4
	cmp	eax,-15
	jl	.negate
	cmp	eax,15
	jg	.hex
	jmp	.fin
    .negate:
	test	eax,7FFFFFFFh
	je	.hex
	neg	eax
	mov	ebx,_var
	lea	ecx,[ebx+3]
	push	8
	push	eax
	push	ecx
	call	pad_hex
	mov	word [ebx],'-0'
	mov	byte [ebx+2],'x'
	jmp	.fin
    .hex:
	mov	ebx,_var
	lea	ecx,[ebx+2]
	push	8
	push	eax
	push	ecx
	call	pad_hex
	mov	word [ebx],'0x'
	jmp	.fin
endp

rename_symbols:
	cmp	[rename],0
	je	.fin
	cmp	[rename],2
	je	.fin
	cmp	[deobfu_done],1
	je	.fin
	push	ebx esi edi
	mov	esi,[newsrc]
	call	NVList.Create
	mov	[fns],eax
	call	NVList.Create
	mov	[fnnames],eax
	push	1
	push	eax
	call	NVList.ToStringList
	push	esi
	call	rename_init
	push	_fnsep
	push	esi
	call	Split
	push	eax
	mov	edi,[eax]
	push	edi
	call	Dupe
	push	0
	push	eax
	push	[fns]
	call	NVList.Add
	mov	eax,[esp]
	lea	esi,[eax+4]
    .next_func:
	push	esi
	mov	esi,[esi]
	test	esi,esi
	je	.done
	push	_fnname
	push	esi
	push	fnname
	call	strscan
	push	0
	push	fnname
	push	[fnnames]
	call	NVList.Add
	push	esi
	call	Dupe
	push	eax
	call	rename_params
	push	eax
	call	rename_locals
	push	0
	push	eax
	push	[fns]
	call	NVList.Add
	pop	esi
	add	esi,4
	jmp	.next_func
    .done:
	add	esp,4
	call	[LocalFree]
	push	[fns]
	call	NVList.Count
	mov	[fnsnum],eax
	mov	edi,[newsrc]
	xor	ebx,ebx
    .save_new_code:
	push	ebx
	push	[fns]
	call	NVList.Name
	push	eax
	mov	esi,eax
      .copy:
	mov	al,[esi]
	mov	[edi],al
	inc	esi
	inc	edi
	test	al,al
	jnz	.copy
	call	[LocalFree]
	dec	edi
	push	_fnsep
	push	edi
	call	[strcpy]
	add	esp,8
	inc	ebx
	add	edi,5
	cmp	ebx,[fnsnum]
	jnz	.save_new_code
	mov	byte [edi-5],0
	push	[fns]
	call	NVList.Free
	dec	[fnsnum]
	push	[newsrc]
	call	rename_funcs
	push	eax
	call	rename_globals
	mov	[newsrc],eax
	push	[fnnames]
	call	NVList.Free
	call	rename_free
	pop	edi esi ebx
    .fin:
	retn

proc rename_init src
  local comma:WORD
	push	esi
	call	NVList.Create
	mov	[dims],eax
	push	1
	push	eax
	call	NVList.ToStringList
	call	NVList.Create
	mov	[ignored],eax
	push	1
	push	eax
	call	NVList.ToStringList
	push	_ignorefuncs
	push	[src]
	push	_buf
	call	strscan
	test	ecx,ecx
	je	.fin
	lea	eax,[comma]
	mov	word [eax],','
	push	eax
	push	_buf
	call	Split
	push	eax
	mov	esi,eax
    .loop:
	push	esi
	mov	esi,[esi]
	test	esi,esi
	je	.free
	push	0
	push	esi
	push	[ignored]
	call	NVList.Add
	pop	esi
	add	esi,4
	jmp	.loop
    .free:
	add	esp,4
	call	[LocalFree]
    .fin:
	pop	esi
	ret
endp

proc rename_free
	push	[dims]
	call	NVList.Free
	push	[ignored]
	call	NVList.Free
	ret
endp

proc rename_funcs src
	push	ebx esi edi
	mov	esi,[src]
	xor	ebx,ebx
    .loop:
	lea	eax,[ebx+1]
	push	4
	push	eax
	push	_funcbuf
	call	pad_number
	push	ebx
	push	[fnnames]
	call	NVList.Name
	inc	ebx
	mov	edi,eax
	push	_onautoitstart
	push	edi
	call	[stricmp]
	add	esp,8
	test	eax,eax
	je	.next
	push	_onautoitexit
	push	edi
	call	[stricmp]
	add	esp,8
	test	eax,eax
	je	.next
	push	edi
	push	[ignored]
	call	NVList.IndexOfN
	test	eax,eax
	jns	.next
	push	_func
	push	edi
	push	esi
	call	iReplace
	mov	esi,eax
    .next:
	cmp	ebx,[fnsnum]
	jnz	.loop
	xchg	eax,esi
	pop	edi esi ebx
	ret
endp

macro cut_delimited src,char1,char2
 { local .next,.loop,.inc,.dec,.fin
  .next:
   push char1
   push src
   call [strchr]
   add esp,8
   test eax,eax
   je .fin
   cmp byte [eax+1],char2
   je .fin
   push eax
   inc eax
   mov ecx,1
  .loop:
   mov dl,[eax]
   cmp dl,char1
   je .inc
   cmp dl,char2
   je .dec
   inc eax
   jmp .loop
  .inc:
   inc eax
   inc ecx
   jmp .loop
  .dec:
   inc eax
   dec ecx
   jnz .loop
   pop edx
   push eax
   push edx
   call [strcpy]
   add esp,8
   jmp .next
  .fin: }

proc rename_globals src
  local pos:DWORD
	push	ebx esi edi
	mov	esi,[src]
	mov	[pos],0
	mov	edi,1
    .loop:
	mov	eax,[pos]
	add	eax,esi
	push	_fnlocals
	push	eax
	push	_var
	call	strscan
	test	ecx,ecx
	je	.fin
	sub	eax,esi
	sub	eax,ecx
	mov	[pos],eax
	lea	eax,[edx+1]
	lea	ebx,[edx+1]
	cut_delimited eax,'(',')'
	cut_delimited ebx,'[',']'
	push	_fnlocalsep
	push	ebx
	call	Split
	push	eax
	mov	ebx,eax
    .next:
	push	ebx
	mov	ebx,[ebx]
	test	ebx,ebx
	je	.free
	push	_fnlocal
	push	ebx
	push	varname
	call	strscan
	cmp	dword [edx],IS_LOCAL
	je	.skip
	push	_global
	push	edx
	push	esi
	push	4
	push	edi
	push	_globalbuf
	call	pad_number
	call	iReplace
	mov	esi,eax
	inc	edi
    .skip:
	pop	ebx
	add	ebx,4
	jmp	.next
    .free:
	add	esp,4
	call	[LocalFree]
	jmp	.loop
    .fin:
	mov	eax,esi
	pop	edi esi ebx
	ret
endp

proc rename_locals src
  local pos:DWORD
	push	ebx esi edi
	mov	esi,[src]
	mov	[pos],0
	mov	edi,1
	push	_fnend
	push	esi
	call	[strstr]
	add	esp,8
	push	eax
	push	_buf
	call	[strcpy]
	add	esp,4
	pop	eax
	mov	byte [eax],0
    .loop:
	mov	eax,[pos]
	add	eax,esi
	push	_fnlocals
	push	eax
	push	_var
	call	strscan
	test	ecx,ecx
	je	.fin
	sub	eax,esi
	sub	eax,ecx
	mov	[pos],eax
	cmp	byte [edx],'G'
	je	.loop
	lea	eax,[edx+1]
	lea	ebx,[edx+1]
	cut_delimited eax,'(',')'
	cut_delimited ebx,'[',']'
	push	_fnlocalsep
	push	ebx
	call	Split
	push	eax
	mov	ebx,eax
    .next:
	push	ebx
	mov	ebx,[ebx]
	test	ebx,ebx
	je	.free
	push	_fnlocal
	push	ebx
	push	varname
	call	strscan
	cmp	dword [edx],IS_LOCAL
	je	.skip
	push	_local
	push	edx
	push	esi
	push	4
	push	edi
	push	_localbuf
	call	pad_number
	call	iReplace
	mov	esi,eax
	inc	edi
    .skip:
	pop	ebx
	add	ebx,4
	jmp	.next
    .free:
	add	esp,4
	call	[LocalFree]
	jmp	.loop
    .fin:
	push	esi
	call	[strlen]
	add	esp,4
	lea	eax,[esi+eax]
	push	_buf
	push	eax
	call	[strcat]
	add	esp,8
	mov	eax,esi
	pop	edi esi ebx
	ret
endp

proc rename_params src
	push	ebx esi edi
	mov	esi,[src]
	push	_fnparams
	push	esi
	push	_buf
	call	strscan
	test	ecx,ecx
	je	.fin
	mov	edi,1
	push	_fnparamsep
	push	edx
	call	Split
	push	eax
	mov	ebx,eax
    .next:
	push	ebx
	mov	ebx,[ebx]
	test	ebx,ebx
	je	.free
	push	2
	push	edi
	push	_parambuf
	call	pad_number
	inc	edi
	push	_fnparam
	push	ebx
	push	_buf
	call	strscan
	push	_param
	push	edx
	push	esi
	call	Replace
	mov	esi,eax
	pop	ebx
	add	ebx,4
	jmp	.next
    .free:
	add	esp,4
	call	[LocalFree]
    .fin:
	mov	eax,esi
	pop	edi esi ebx
	ret
endp

get_tblitem:
	mov	eax,[esp+4]
	mov	edx,[tblbuf]
	mov	eax,[edx+eax*4-4]
	retn	4

cut_obfu_header:
	push	esi
	mov	esi,[esp+8]
	push	_obfu_header
	push	esi
	push	_buf
	call	strscan
	test	ecx,ecx
	jnz	.fin
	push	_obfu_header_old
	push	esi
	push	_buf
	call	strscan
	test	ecx,ecx
	je	.err
    .fin:
	push	0
	push	edx
	push	esi
	call	Replace
    .err:
	xchg	eax,esi
	pop	esi
	retn	4

is_obfu_fn:
	push	esi
	mov	esi,fnname
	push	fnobfu1
	push	esi
	call	[strcmp]
	add	esp,8
	test	eax,eax
	je	.fin
	push	fnobfu2
	push	esi
	call	[strcmp]
	add	esp,8
	test	eax,eax
	je	.fin
	push	fnobfu3
	push	esi
	call	[strcmp]
	add	esp,8
	test	eax,eax
	je	.fin
	mov	eax,1
    .fin:
	pop	esi
	retn

get_obfu_fns:
	push	esi
	mov	esi,[source]
	push	_fnobfu1
	push	esi
	push	fnobfu1
	call	strscan
	test	ecx,ecx
	jnz	.got1st
	push	_fnobfu1_old
	push	esi
	push	fnobfu1
	call	strscan
      .got1st:
	push	_fnobfu2
	push	esi
	push	fnobfu2
	call	strscan
	test	ecx,ecx
	jnz	.got2nd
	push	_fnobfu2_old
	push	esi
	push	fnobfu2
	call	strscan
      .got2nd:
	push	_fnobfu3
	push	esi
	push	fnobfu3
	call	strscan
	pop	esi
	retn

split_tbl:
	push	esi
	push	tblsep
	push	[tblbuf]
	call	Split
	mov	esi,eax
	mov	[tblnum],edx
	push	[tblbuf]
	call	[LocalFree]
	mov	[tblbuf],esi
    .loop:
	mov	eax,[esi]
	test	eax,eax
	je	.fin
	push	eax
	push	eax
	call	hextoa
	add	esi,4
	jmp	.loop
    .fin:
	mov	eax,[tblnum]
	pop	esi
	retn

get_tblsep:
	mov	eax,[tblpos]
    .loop:
	push	_tblcode
	push	eax
	push	tblsep
	call	strscan
	test	ecx,ecx
	je	.found
	push	tblsep
	push	_buf
	call	hextoa
	jmp	.loop
    .found:
	cmp	[_buf],0
	je	.err
	push	_tblsep
	push	_buf
	push	tblsep
	call	strscan
	test	ecx,ecx
	jnz	.fin
    .err:
	xor	eax,eax
    .fin:
	retn

adjust_fileinstall:
	push	esi
	cmp	[filein],1
	jnz	.fin
	mov	esi,[newsrc]
    .loop:
	push	_fileinstall
	push	esi
	push	_buf
	call	strscan
	test	ecx,ecx
	je	.fin
	mov	esi,eax
	cmp	byte [edx+1],':'
	jnz	.loop
	sub	eax,ecx
	lea	ecx,[eax+3]
	push	ecx
	push	eax
	call	[strcpy]
	add	esp,8
	jmp	.loop
    .fin:
	pop	esi
	retn

proc adjust_@compiled
  local compiled:WORD
	push	_@compiled
	push	[newsrc]
	call	stristr
	add	esp,8
	test	eax,eax
	je	.fin
	cmp	[compil],1
	jnz	.fin
	lea	eax,[compiled]
	mov	word [eax],'1'
	push	eax
	push	_@compiled
	push	[newsrc]
	call	iReplace
	xor	eax,eax
      .fin:
	setnz	[compm_found]
	ret
endp

alloc_buffer:
	cmp	[deobfu],0
	je	.twice
	call	read_table
	mov	ecx,eax
	add	ecx,[length]
	test	eax,eax
	jnz	.alloc
    .twice:
	mov	edx,[length]
	mov	ecx,[length]
	shr	edx,1
	add	ecx,edx
    .alloc:
	push	ecx
	push	0
	call	[LocalAlloc]
	mov	[newsrc],eax
	retn

read_table:
	push	ebx edi
	push	_tblfile
	push	[source]
	push	tblname
	call	strscan
	test	ecx,ecx
	je	.err
	mov	[tblpos],eax
	push	OF_READ
	push	tblname
	call	[_lopen]
	test	eax,eax
	js	.err
	mov	edi,eax
	push	2
	push	0
	push	edi
	call	[_llseek]
	mov	ebx,eax
	push	0
	push	0
	push	edi
	call	[_llseek]
	lea	eax,[ebx+1]
	push	eax
	push	0
	call	[LocalAlloc]
	mov	byte [eax+ebx],0
	mov	[tblbuf],eax
	push	ebx
	push	eax
	push	edi
	call	[_lread]
	push	edi
	call	[_lclose]
	push	tblname
	call	[DeleteFile]
	mov	eax,ebx
	jmp	.fin
    .err:
	xor	eax,eax
    .fin:
	pop	edi ebx
	retn

proc pad_number dest,num,pad
	push	ebx edi
	mov	ebx,[pad]
	mov	edi,[dest]
	push	10
	push	edi
	push	[num]
	call	[itoa]
	push	edi
	call	[strlen]
	add	esp,10h
	cmp	eax,ebx
	jae	.fin
	sub	ebx,eax
	lea	edx,[edi+ebx]
	inc	eax
	push	eax
	push	edi
	push	edx
	call	[memmove]
	push	ebx
	push	'0'
	push	edi
	call	[memset]
	add	esp,18h
    .fin:
	pop	edi ebx
	ret
endp

proc pad_hex dest,num,pad
	push	ebx edi
	mov	ebx,[pad]
	mov	edi,[dest]
	push	16
	push	edi
	push	[num]
	call	[itoa]
	push	edi
	call	[strlen]
	add	esp,10h
	cmp	eax,ebx
	jae	.fin
	sub	ebx,eax
	lea	edx,[edi+ebx]
	inc	eax
	push	eax
	push	edi
	push	edx
	call	[memmove]
	push	ebx
	push	'0'
	push	edi
	call	[memset]
	add	esp,18h
    .fin:
	pop	edi ebx
	ret
endp

macro deobfus_idata
 {
  _fnobfu1 db '|$Global$[^\n]+[[:space:]]*$#OnAutoItStartRegister$ "|[^"]+',0
  _fnobfu1_old db '|$Global$[^\n]+[[:space:]]*|[^(]+',0
  _fnobfu2 db '|$Func $[^\n]+[[:space:]]*Global[^\n]+[[:space:]]*For[^\n]+$= $|[^(]+|[^\n]+[[:space:]]*FileInstall|',0
  _fnobfu2_old db '|$Func $[^\n]+[[:space:]]*For[^\n]+$= $|[^(]+|[^\n]+[[:space:]]*FileInstall|',0
  _fnobfu3 db '|$Global$ \$[^=\n]+= |[^(]+|(\$[^\[\n]+\[',0

  _obfu_header db 'If NOT IsDeclared("[[:word:]]+") Then Global \$[[:word:]]+[[:space:]]+\#OnAutoItStartRegister "[[:word:]]+"[[:space:]]+',0
  _obfu_header_old db 'Global \$[[:word:]]+[[:space:]]+[[:word:]]+()[[:space:]]*',0

  _tblfile db '|$FileInstall$[^(]*("|[^"]+|[^\n]+[[:space:]]*Global[^E]+Execute|',0
  _tblcode db '|#BinaryToString#[^(]*(["'']0x|[^"'']+',0
  _tblsep db '|["'']|[^"'']+',0

  _fnsep db 'Func ',0
  _fnend db 'EndFunc',0
  _fnname db '[^(]+',0
  _fnparams db '|(|[^)]*',0
  _fnlocals db '[CGL]|[lo][noc][sba][tal][l]? [C]?[o]?[n]?[s]?[t]?[ ]?\$|[[:word:]]+[^\r\n]*',0
  _fnparamsep db ', ',0
  _fnlocalsep db ', $',0
  _fnparam db '\$'
  _fnlocal db '[[:word:]]+',0
  _obfusec db '|)|[[:space:]]+If NOT IsDeclared$EndIf$',0

  _ignorefuncs db '|$#Obfuscator_Ignore_Funcs=$|[^\r\n]*',0
  _onautoitstart db 'OnAutoItStart',0
  _onautoitexit db 'OnAutoItExit',0

  IS_PARAM = '__'
  IS_LOCAL = 'locV'
  _func db 'Fn'
  _funcbuf db 11 dup (0)
  _param db '$__'
  _parambuf db 11 dup (0)
  _global db 'Var'
  _globalbuf db 11 dup (0)
  _local db 'locVar'
  _localbuf db 11 dup (0)

  _globalline db 'Global \$[[:word:]]+ = [[:word:]]+(\$[[:word:]]+\[[^\r\n]+[[:space:]]*',0
  _globalvar db '|$Global $|[^\r\n]+',0
  _varline db '|$Global $|\$[[:word:]]+ = [[:word:]]+(\$[[:word:]]+\[[^\r\n]+',0
  _varsep db ', ',0

  _varname db '\$[^ ]+',0
  _varindex db '|\[|[^\]]+',0

  _varexec db 'Execute('
  _varexecbuf db 21 dup (0)
  _varnum db 'Number('
  _varnumbuf db 21 dup (0)

  _quotes_twice db '""',0
  _quotes db '"',0
  _trimmacro db '|[[:space:]]*|@[[:word:]]+',0
  _trimnum db '|[[:space:]]*|[.[:digit:]]+',0

  _fileinstall db '|$FileInstall$[^(]*(["'']|[^"'']+["''],',0
  _@compiled db '@Compiled',0
 }

macro deobfus_udata
 {
  newsrc rd 1
  source rd 1
  length rd 1
  deobfu rb 1
  rename rb 1
  filein rb 1
  compil rb 1
  deobfu_done rb 1
  compm_found rb 1

  globals rd 1
  fns rd 1
  fnnames rd 1
  fnsnum rd 1

  dims rd 1
  ignored rd 1

  tblbuf rd 1
  tblnum rd 1
  tblpos rd 1

  varname rb 20h
  varindex rb 10h

  fnobfu1 rb 30h
  fnobfu2 rb 30h
  fnobfu3 rb 30h
  fnname rb 30h
  tblname rb 256
  tblsep rb 600

  _buf rb 8000h
  _var rb 3000
 }
