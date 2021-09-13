
format PE GUI 4.0 DLL at 10000000h
entry start

include 'win32a.inc'

BUFFER_SIZE = 3052

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
	call	.size
	push	ecx
	push	MyGetCommandLineW
	push	eax
	call	DetourFunc
	mov	[_GetCommandLineW],eax
	push	_user32
	call	[GetModuleHandle]
	push	_spia
	push	eax
	call	[GetProcAddress]
	call	.size
	push	ecx
	push	MySystemParametersInfoA
	push	eax
	call	DetourFunc
	mov	[_SystemParametersInfoA],eax
    .fin:
	mov	eax,TRUE
	retn	0Ch
    .size:
	push	eax
	xchg	eax,edx
	xor	ecx,ecx
      .loop:
	push	edx
	call	mlde32
	add	esp,4
	add	ecx,eax
	add	edx,eax
	cmp	ecx,5
	jb	.loop
	pop	eax
	retn

  filename:
	push	esi edi
	push	BUFFER_SIZE
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
	mov	esi,edi
	dec	edi
	std
	mov	al,'.'
	mov	ecx,edx
	repnz	scasb
	cld
	lea	eax,[edi+1]
	je	.found
	mov	eax,esi
    .found:
	mov	dword [eax],'_.au'
	mov	word [eax+4],'3'
	pop	edi esi
	retn

  MyGetCommandLineW:
	cmp	[already],1
	je	.already
	call	filename
	push	.handler
	push	dword [fs:0]
	mov	[fs:0],esp
	mov	eax,[esp+8]
	push	_size_3_3_6
	push	_mask_3_3_6
	push	_ptrn_3_3_6
	push	20000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_3_6
	mov	eax,[esp+8]
	push	_size_3_3_7
	push	_mask_3_3_7
	push	_ptrn_3_3_7
	push	20000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_3_7
	mov	eax,[esp+8]
	push	_size_3_3_0
	push	_mask_3_3_0
	push	_ptrn_3_3_0
	push	20000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_3_0
	mov	eax,[esp+8]
	push	_size_3_2_12
	push	_mask_3_2_12
	push	_ptrn_3_2_12
	push	57000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.3_2_12
	mov	eax,[esp+8]
	push	_size_3_2_8
	push	_mask_3_2_8
	push	_ptrn_3_2_8
	push	57000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.3_2_8
    .err:
	pop	dword [fs:0]
	add	esp,4
	push	buf
	call	[DeleteFile]
	push	0
	call	[ExitProcess]
    .handler:
	mov	esp,[esp+8]
	jmp	.err
    .3_3_6:
	mov	cl,[eax+_modrm_3_3_6]
	mov	[modrm],cl
	add	eax,_count_3_3_6
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	jmp	.fin
    .3_3_7:
	mov	cl,[eax+_modrm_3_3_7]
	mov	[modrm],cl
	add	eax,_count_3_3_7
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	jmp	.fin
    .3_3_0:
	mov	cl,[eax+_modrm_3_3_0]
	mov	[modrm],cl
	add	eax,_count_3_3_0
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	jmp	.fin
    .3_2_12:
	mov	cl,[eax+_modrm_3_2_12]
	mov	[modrm],cl
	add	eax,_count_3_2_12
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	jmp	.fin
    .3_2_8:
	mov	cl,[eax+_modrm_3_2_8]
	mov	[modrm],cl
	add	eax,_count_3_2_8
	push	5
	push	decompile
	push	eax
	call	DetourFunc
    .fin:
	pop	dword [fs:0]
	add	esp,4
	mov	[already],1
    .already:
	jmp	[_GetCommandLineW]

  MySystemParametersInfoA:
	cmp	[already],1
	je	.already
	call	filename
	push	.handler
	push	dword [fs:0]
	mov	[fs:0],esp
	mov	eax,[esp+8]
	push	_size_3_2_12
	push	_mask_3_2_12
	push	_ptrn_3_2_12
	push	10000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_2_12
	mov	eax,[esp+8]
	push	_size_3_2_8
	push	_mask_3_2_8
	push	_ptrn_3_2_8
	push	10000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_2_8
    .err:
	pop	dword [fs:0]
	add	esp,4
	push	buf
	call	[DeleteFile]
	push	0
	call	[ExitProcess]
    .handler:
	mov	esp,[esp+8]
	jmp	.err
    .3_2_12:
	mov	cl,[eax+_modrm_3_2_12]
	mov	[modrm],cl
	add	eax,_count_3_2_12
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	jmp	.fin
    .3_2_8:
	mov	cl,[eax+_modrm_3_2_8]
	mov	[modrm],cl
	add	eax,_count_3_2_8
	push	5
	push	decompile
	push	eax
	call	DetourFunc
    .fin:
	pop	dword [fs:0]
	add	esp,4
	mov	[already],1
    .already:
	jmp	[_SystemParametersInfoA]

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
	and	[modrm],00111000b
	shr	[modrm],3
	cmp	[modrm],2
	je	.found
	mov	edx,eax
	cmp	[modrm],0
	je	.found
	mov	edx,ecx
	cmp	[modrm],1
	je	.found
	mov	edx,ebx
	cmp	[modrm],3
	je	.found
	mov	edx,esi
	cmp	[modrm],6
	je	.found
	mov	edx,edi
    .found:
	mov	eax,[edx]
	mov	[lines],eax
	lea	esi,[edx+4]
	push	0
	push	buf
	call	[_lcreat]
	mov	edi,eax
    .loop:
	cmp	[newline],1
	jnz	.read
	push	2
	push	_eol
	push	edi
	call	[_lwrite]
	mov	[newline],0
      .read:
	mov	al,[esi]
	inc	esi
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
	cmp	al,7Fh
	je	.eol
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
	mov	al,[esi+4]
	mov	[step_mod],0
	cmp	al,7Fh
	je	.nospace
	mov	byte [buf],' '
	push	1
	push	buf
	push	edi
	call	[_lwrite]
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
	push	dword [esi+4]
	push	dword [esi]
	push	_float
	push	buf
	call	[sprintf]
	add	esp,10h
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
	cmp	dword [dummy+1],'lse '
	je	.else
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
      .else:
	cmp	byte [esi-2],7Fh
	je	.mtabs
	jmp	.ltabs
      .titabs:
	inc	[tabs]
      .itabs:
	inc	[tabs]
	jmp	.ltabs
      .tdtabs:
	dec	[tabs]
	push	1
	push	-1
	push	edi
	call	[_llseek]
      .dtabs:
	dec	[tabs]
      .mtabs:
	push	1
	push	-1
	push	edi
	call	[_llseek]
      .ltabs:
	xor	edx,edx
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
	cmp	dword [dummy+1],'lse '
	je	.neither
	cmp	dword [dummy],'endi'
	je	.neither
	cmp	dword [dummy],'wend'
	je	.neither
	cmp	dword [dummy],'do '
	je	.neither
	cmp	dword [dummy],'next'
	je	.neither
	cmp	dword [dummy],'ends'
	je	.neither
	cmp	dword [dummy],'endw'
	je	.neither
	cmp	dword [dummy],'true'
	je	.neither
	cmp	dword [dummy],'fals'
	je	.neither
	cmp	dword [dummy],'enum'
	je	.neither
	cmp	dword [dummy],'step'
	jnz	.trailing_space
	mov	[step_mod],1
	jmp	.leading_space
      .tnewline:
	mov	[newline],1
      .neither:
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
      .trailing_space:
	lea	ecx,[ebx+1]
	mov	edx,dummy
	jmp	.write_keyword
      .then:
	lea	edx,[ebx+ebx+4]
	cmp	byte [esi+edx],7Fh
	je	.leading_space
	xor	edx,edx
	dec	[tabs]
      .leading_space:
	push	edx
	push	dummy
	push	_space
	push	buf
	call	[sprintf]
	add	esp,0Ch
	pop	edx
	mov	eax,2
	test	edx,edx
	je	.with_trailing
	dec	eax
      .with_trailing:
	lea	ecx,[ebx+eax]
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
	call	[sprintf]
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
	inc	[line]
	mov	eax,[lines]
	cmp	[line],eax
	je	.eos
	push	2
	push	_eol
	push	edi
	call	[_lwrite]
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
	movzx	ecx,al
	push	ecx
	push	_corrupt
	push	buf
	call	[wsprintf]
	add	esp,0Ch
	push	eax
	push	buf
	push	edi
	call	[_lwrite]
    .eos:
	push	edi
	call	[_lclose]
	push	0
	call	[ExitProcess]

	include 'mlde32.inc'
	include 'misc.inc'

section '.data' data readable writeable

  _kernel32 db 'kernel32.dll',0
  _user32 db 'user32.dll',0
  _kernelbase db 'kernelbase.dll',0
  _gclw db 'GetCommandLineW',0
  _spia db 'SystemParametersInfoA',0

  ;===========================================================================
  _ptrn_3_3_6	db 0FFh,08Bh,000h,000h,000h,08Bh,000h,000h,000h,00Fh,0B6h
; _ptrn_3_3_2   db 0FFh,08Bh,000h,000h,000h,08Bh,000h,083h,000h,0FFh
  _ptrn_3_3_7	db 032h,0C0h,0E9h,000h,000h,000h,0FFh,08Bh,000h,000h,08Bh
  _ptrn_3_3_0	db 032h,0C0h,0E9h,000h,000h,000h,0FFh,08Bh,000h,000h,000h,08Bh
  _ptrn_3_2_12	db 059h,0EBh,000h,08Bh,000h,000h,08Bh,000h,08Bh
  _ptrn_3_2_8	db 059h,0EBh,000h,08Bh,000h,000h,000h,08Bh,000h,08Bh
  ;===========================================================================
  _mask_3_3_6	db 9,3,6,6,6,4,6,6,6,1,8   ;'xx...x...xx'
  _size_3_3_6	=  $-_mask_3_3_6
; _mask_3_3_2   db 2,2,6,6,6,1,6,1,6,8     ;'xx...x.x.x'
; _size_3_3_2   =  $-_mask_3_3_2
  _mask_3_3_7	db 1,2,4,6,6,6,1,7,6,6,0   ;'xxx...xx..x'
  _size_3_3_7	=  $-_mask_3_3_7
  _mask_3_3_0	db 9,9,9,6,6,6,8,8,6,6,6,4 ;'xxx...xx...x'
  _size_3_3_0	=  $-_mask_3_3_0
  _mask_3_2_12	db 3,0,6,7,6,6,5,6,9	   ;'xx.x..x.x'
  _size_3_2_12	=  $-_mask_3_2_12
  _mask_3_2_8	db 7,2,6,1,6,6,6,0,6,5	   ;'xx.x...x.x'
  _size_3_2_8	=  $-_mask_3_2_8
  ;===========================================================================
  _modrm_3_3_6	=  6
  _count_3_3_6	=  9
; _modrm_3_3_2  =  2
; _count_3_3_2  =  5
  _modrm_3_3_7	=  8
  _count_3_3_7	=  10
  _modrm_3_3_0	=  8
  _count_3_3_0	=  11
  _modrm_3_2_12 =  4
  _count_3_2_12 =  6
  _modrm_3_2_8	=  4
  _count_3_2_8	=  7
  ;===========================================================================

  _corrupt db 13,10,'..corrupted [%Xh]',0

  _int32 db '%d',0
  _int64 db '%I64d',0
  _float db '%.15g',0

  _const db '@%s',0
  _var db '$%s',0
  _prop db '.%s',0
  _str db '"%s"',0
  _str2 db '''%s''',0
  _space db ' %s',0
  _eol db 13,10

  _GetCommandLineW rd 1
  _SystemParametersInfoA rd 1
  already rb 1
  modrm rb 1
  newline rb 1
  unary_mod rb 1
  step_mod rb 1
  tabs rd 1
  line rd 1
  lines rd 1
  buf rb BUFFER_SIZE
  dummy rb BUFFER_SIZE

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  msvcrt,'MSVCRT.DLL'

  include 'api\kernel32.inc'

  import user32,\
	 CharLower,'CharLowerA',\
	 wsprintf,'wsprintfA'

  import msvcrt,\
	 sprintf,'sprintf'

section '.reloc' fixups data discardable
