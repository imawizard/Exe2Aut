
format PE GUI 4.0 DLL at 10000000h
entry start

include 'win32a.inc'

section '.code' code readable executable

  start:
	cmp	byte [esp+8],DLL_PROCESS_ATTACH
	jnz	.fin
	push	dword [esp+4]
	call	[DisableThreadLibraryCalls]
	push	_kernelbase
	call	[GetModuleHandle]
	test	eax,eax
	jnz	.already
	push	_kernel32
	call	[GetModuleHandle]
    .already:
	push	_gclw
	push	eax
	call	[GetProcAddress]
	push	5
	push	MyGetCommandLineW
	push	eax
	call	DetourFunc
	mov	[_GetCommandLineW],eax
    .fin:
	mov	eax,TRUE
	retn	0Ch

  MyGetCommandLineW:
	mov	eax,[esp]
	push	ptrn_size
	push	_ptrn_mask
	push	_ptrn
	push	30000h
	push	eax
	call	FindPattern
	test	eax,eax
	je	.err
	add	eax,8
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	jmp	[_GetCommandLineW]
    .err:
	push	MB_OK
	push	_title
	push	_error
	push	0
	call	[MessageBox]
	push	0
	call	[ExitProcess]

  sanitize_string:
	push	esi edi ecx
	mov	ecx,ebx
	mov	al,'"'
	mov	edi,dummy
	repnz	scasb
	jnz	.ok
	mov	ecx,ebx
	mov	al,''''
	mov	edi,dummy
	repnz	scasb
	jnz	.single
	push	edx
	push	dummy
	push	buf
	call	[lstrcpy]
	xor	esi,esi
	mov	ecx,dummy
	mov	edx,buf
    .loop:
	mov	al,[edx]
	mov	[ecx],al
	cmp	al,'"'
	jnz	.next
	mov	[ecx+1],al
	inc	esi
	inc	ecx
    .next:
	inc	edx
	inc	ecx
	test	al,al
	jnz	.loop
	pop	edx
	pop	ecx
	add	ecx,esi
	jmp	.fin
    .single:
	mov	edx,_str2
    .ok:
	pop	ecx
    .fin:
	pop	edi esi
	retn

  decompile:
	lea	eax,[edx+4]
	push	eax
	push	200h
	push	buf
	push	0
	call	[GetModuleFileName]
	xchg	eax,edx
	std
	or	ecx,-1
	mov	al,'\'
	lea	edi,[buf+edx-1]
	repnz	scasb
	add	edi,2
	cld
	neg	ecx
	mov	esi,edi
	sub	ecx,2
	sub	edi,edx
	add	edi,ecx
	mov	edx,ecx
	rep	movsb
	mov	al,'.'
	mov	ecx,edx
	sub	edi,edx
	repnz	scasb
	mov	eax,edi
	jnz	.file
	dec	eax
    .file:
	mov	dword [eax],'_.au'
	mov	word [eax+4],'3'
	push	0
	push	buf
	call	[_lcreat]
	mov	edi,eax
	pop	esi
	;push    2
	;push    _eol
	;push    edi
	;call    [_lwrite]
    .loop:
	cmp	[tnl],1
	jnz	.read
	push	2
	push	_eol
	push	edi
	call	[_lwrite]
	mov	[tnl],0
      .read:
	mov	al,[esi]
	inc	esi
	test	al,al
	je	.eos
	cmp	al,7Fh
	je	.eol
	mov	[eos],0
	cmp	al,0Fh
	jng	.int32
	cmp	al,1Fh
	jng	.int64
	cmp	al,2Fh
	jng	.float
	cmp	al,3Fh
	jng	.ustr
	cmp	al,56h
	jng	.ops
	jmp	.corrupt
    .int32:
	push	dword [esi]
	push	_int32
	push	buf
	call	[wsprintf]
	add	esp,0Ch
	push	eax
	push	buf
	push	edi
	call	[_lwrite]
	cmp	[step_mod],1
	jnz	.nospace
	mov	byte [buf],' '
	push	1
	push	buf
	push	edi
	call	[_lwrite]
	mov	[step_mod],0
      .nospace:
	mov	ebx,4
	jmp	.next
    .int64:
	push	dword [esi+4]
	push	dword [esi]
	push	_int64
	push	buf
	call	[wsprintf]
	add	esp,10h
	push	eax
	push	buf
	push	edi
	call	[_lwrite]
	mov	ebx,8
	jmp	.next
    .float:
	;fld qword [esi]
	push	dword [esi+4]
	push	dword [esi]
	push	_float
	push	buf
	call	[sprintf]
	add	esp,10h
       ; cinvoke sprintf, buf, "fp number %Lf", double [esi]
	push	eax
	push	buf
	push	edi
	call	[_lwrite]
	mov	ebx,8
	jmp	.next
    .ustr:
	lea	eax,[esi+4]
	mov	ebx,[esi]
	mov	ecx,[esi]
	test	ebx,ebx
	jnz	.decrypt
	mov	[dummy],0
	jmp	.empty
      .decrypt:
	xor	word [eax],bx
	add	eax,2
	loop	.decrypt
	push	esi edi
	add	esi,4
	mov	edi,dummy
	mov	ecx,ebx
      .copy:
	lodsw
	stosb
	loop	.copy
	pop	edi esi
	mov	[dummy+ebx],cl
      .empty:
	mov	al,[esi-1]
	cmp	al,36h
	je	.string
	push	eax
	push	dummy
	call	[CharLower]
	pop	eax
	cmp	al,30h
	je	.keyword
	mov	ecx,1
	mov	edx,_const
	cmp	al,32h
	je	.ustr_write
	mov	edx,_var
	cmp	al,33h
	je	.ustr_write
	mov	edx,_prop
	cmp	al,35h
	je	.ustr_write
	push	ebx
	push	dummy
	push	edi
	call	[_lwrite]
	jmp	.ustr_fin
      .string:
	mov	ecx,2
	mov	edx,_str
	call	sanitize_string
	jmp	.ustr_write
      .keyword:
	mov	word [dummy+ebx],' '
	cmp	dword [dummy],'if '
	je	.itabs
	cmp	dword [dummy],'else'
	je	.mtabs
	cmp	dword [dummy+1],'lsei'
	je	.mtabs
	cmp	dword [dummy+1],'ndif'
	je	.dtabs
	cmp	dword [dummy],'whil'
	je	.itabs
	cmp	dword [dummy],'wend'
	je	.dtabs
	cmp	dword [dummy],'do '
	je	.itabs
	cmp	dword [dummy],'unti'
	je	.dtabs
	cmp	dword [dummy],'for '
	je	.itabs
	cmp	dword [dummy],'next'
	je	.dtabs
	cmp	dword [dummy],'sele'
	je	.titabs
	cmp	dword [dummy+1],'ndse'
	je	.tdtabs
	cmp	dword [dummy],'swit'
	je	.titabs
	cmp	dword [dummy+1],'ndsw'
	je	.tdtabs
	cmp	dword [dummy],'case'
	je	.mtabs
	cmp	dword [dummy],'func'
	je	.itabs
	cmp	dword [dummy+1],'ndfu'
	je	.dtabs
	cmp	dword [dummy],'with'
	je	.itabs
	cmp	dword [dummy+1],'ndwi'
	je	.dtabs
	jmp	.ltabs
      .titabs:
	inc	[tabs]
      .itabs:
	inc	[tabs]
	jmp	.ltabs
      .tdtabs:
	dec	[tabs]
      .dtabs:
	dec	[tabs]
      .mtabs:
	push	1
	push	-1
	push	edi
	call	[_llseek]
      .ltabs:
	cmp	dword [dummy],'and '
	je	.leading_space
	cmp	dword [dummy],'or '
	je	.leading_space
	cmp	dword [dummy],'then'
	je	.then
	cmp	dword [dummy],'to '
	je	.leading_space
	cmp	dword [dummy],'in '
	je	.leading_space
	cmp	dword [dummy],'func'
	je	.newline
	cmp	dword [dummy+1],'ndfu'
	je	.tnewline
	cmp	dword [dummy],'enum'
	je	.enum
	cmp	dword [dummy],'step'
	jnz	.trailing_space
	mov	[step_mod],1
	jmp	.leading_space
      .enum:
	mov	ecx,ebx
	mov	edx,dummy
	jmp	.write_keyword
      .newline:
	push	1
	push	-4
	push	edi
	call	[_llseek]
	push	4
	push	buf
	push	edi
	call	[_lread]
	cmp	dword [buf],0A0D0A0Dh
	je	.trailing_space
	push	2
	push	_eol
	push	edi
	call	[_lwrite]
	jmp	.trailing_space
      .tnewline:
	mov	[tnl],1
      .trailing_space:
	lea	ecx,[ebx+1]
	mov	edx,dummy
	jmp	.write_keyword
      .then:
	lea	edx,[ebx+ebx+4]
	cmp	byte [esi+edx],7Fh
	je	.leading_space
	dec	[tabs]
      .leading_space:
	push	dummy
	push	_space
	push	buf
	call	[wsprintf]
	add	esp,0Ch
	lea	ecx,[ebx+2]
	mov	edx,buf
      .write_keyword:
	push	ecx
	push	edx
	push	edi
	call	[_lwrite]
	jmp	.ustr_fin
      .ustr_write:
	push	ecx
	push	dummy
	push	edx
	push	buf
	call	[wsprintf]
	add	esp,0Ch
	pop	ecx
	lea	edx,[ebx+ecx]
	push	edx
	push	buf
	push	edi
	call	[_lwrite]
      .ustr_fin:
	lea	ebx,[ebx+ebx+4]
    .next:
	mov	[unary_mod],0
	add	esi,ebx
	jmp	.loop
    .ops:
	xor	ebx,ebx
	mov	cx,'('
	cmp	al,47h
	je	.ops_fin
	mov	cx,')'
	cmp	al,48h
	je	.ops_fin
	mov	cx,'['
	cmp	al,4Eh
	je	.ops_fin
	mov	cx,']'
	cmp	al,4Fh
	je	.ops_fin
	mov	ebx,1
	mov	cx,','
	cmp	al,40h
	je	.ops_fin
	push	eax
	mov	byte [buf],' '
	push	1
	push	buf
	push	edi
	call	[_lwrite]
	pop	eax
	mov	cx,'='
	cmp	al,41h
	je	.ops_fin
	mov	cx,'>'
	cmp	al,42h
	je	.ops_fin
	mov	cx,'<'
	cmp	al,43h
	je	.ops_fin
	mov	cx,'<>'
	cmp	al,44h
	je	.ops_fin
	mov	cx,'>='
	cmp	al,45h
	je	.ops_fin
	mov	cx,'<='
	cmp	al,46h
	je	.ops_fin
	mov	cx,'+'
	cmp	al,49h
	je	.ops_step
	mov	cx,'-'
	cmp	al,4Ah
	je	.ops_unary
	mov	cx,'/'
	cmp	al,4Bh
	je	.ops_fin
	mov	cx,'*'
	cmp	al,4Ch
	je	.ops_step
	mov	cx,'&'
	cmp	al,4Dh
	je	.ops_fin
	mov	cx,'=='
	cmp	al,50h
	je	.ops_fin
	mov	cx,'^'
	cmp	al,51h
	je	.ops_fin
	mov	cx,'+='
	cmp	al,52h
	je	.ops_fin
	mov	cx,'-='
	cmp	al,53h
	je	.ops_fin
	mov	cx,'/='
	cmp	al,54h
	je	.ops_fin
	mov	cx,'*='
	cmp	al,55h
	je	.ops_fin
	mov	cx,'&='
	jmp	.ops_fin
      .ops_unary:
	cmp	[unary_mod],1
	je	.nospaces
      .ops_step:
	cmp	[step_mod],1
	jnz	.ops_fin
      .nospaces:
	push	ecx
	push	1
	push	-1
	push	edi
	call	[_llseek]
	pop	ecx
	xor	ebx,ebx
      .ops_fin:
	xor	edx,edx
	mov	word [buf],cx
	test	ch,ch
	je	.ops_len
	inc	edx
      .ops_len:
	inc	edx
	test	ebx,ebx
	je	.no_trailing_space
	mov	[buf+edx],' '
	inc	edx
      .no_trailing_space:
	push	edx
	push	buf
	push	edi
	call	[_lwrite]
	mov	[unary_mod],1
	jmp	.loop
    .eol:
    push esi
    push _lol
    push buf
    call [wsprintf]
    add esp,0Ch
    push 0
    push 0
    push buf
    push 0
    call [MessageBox]
	cmp	[eos],1
	je	.eos
	mov	[eos],1
	push	1
	push	-4
	push	edi
	call	[_llseek]
	push	4
	push	buf
	push	edi
	call	[_lread]
	cmp	dword [buf],0A0D0A0Dh
	je	.already
	push	2
	push	_eol
	push	edi
	call	[_lwrite]
      .already:
	mov	ecx,[tabs]
	mov	edx,[tabs]
	test	ecx,ecx
	je	.loop
      .tabs:
	mov	[buf+ecx-1],9
	loop	.tabs
	push	edx
	push	buf
	push	edi
	call	[_lwrite]
	jmp	.loop
    .corrupt:
	push	MB_OK
	push	_title
	push	_error
	push	0
	call	[MessageBox]
    .eos:
	push	edi
	call	[_lclose]
	push	0
	call	[ExitProcess]

	include 'misc.inc'

section '.data' data readable writeable

  _kernel32 db 'kernel32.dll',0
  _kernelbase db 'kernelbase.dll',0
  _gclw db 'GetCommandLineW',0

  _ptrn db 08Bh,04Ch,000h,000h,08Bh,054h,000h,000h,00Fh,0B6h
  _ptrn_mask db 'ab..ef..ij'
  ptrn_size = $-_ptrn_mask

_lol db '%x',0

  _title db 'Exe2Aut',0
  _error db 'aww, it''s not working..',0

  _int32 db '%d',0
  _int64 db '%I64d',0
  _float db '%Lf',0

  _const db '@%s',0
  _var db '$%s',0
  _prop db '.%s',0
  _str db '"%s"',0
  _str2 db '''%s''',0
  _space db ' %s',0
  _eol db 13,10

  _GetCommandLineW rd 1
  tabs rd 1
  eos rb 1
  tnl rb 1
  unary_mod rb 1
  step_mod rb 1
  buf rb 200h
  dummy rb 200h

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  msvcrt,'MSVCRT.DLL'

  include 'api\kernel32.inc'

  import user32,\
	 CharLower,'CharLowerA',\
	 MessageBox,'MessageBoxA',\
	 wsprintf,'wsprintfA'

  import msvcrt,\
	 sprintf,'sprintf'

section '.reloc' fixups data discardable
