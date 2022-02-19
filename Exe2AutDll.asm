
format PE GUI 4.0 DLL at 10000000h
entry start

include 'win32a.inc'

BUFFER_SIZE = 3052

section '.code' code readable executable

  start:
	cmp	byte [esp+8],DLL_PROCESS_ATTACH
	jnz	.fin
	mov	eax,[esp+4]
	mov	[hmodule],eax
	push	eax
	call	[DisableThreadLibraryCalls]
	push	_loaded
	call	IsMutex
	test	eax,eax
	jnz	.decompile
	push	_armadillo
	call	IsMutex
	test	eax,eax
	jnz	.armadillo
    .decompile:
	push	_nofiles
	call	IsMutex
	mov	[file_err],al
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
	jmp	.fin
    .armadillo:
	push	_loaded
	call	IsMutex
	push	_kernel32
	call	[GetModuleHandle]
	push	_cpw
	push	eax
	call	[GetProcAddress]
	call	.size
	push	ecx
	push	MyCreateProcessW
	push	eax
	call	DetourFunc
	mov	[_CreateProcessW],eax
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

  MyCreateProcessW:
	mov	ecx,10
    .push:
	push	dword [esp+28h]
	loop	.push
	call	[_CreateProcessW]
	test	eax,eax
	je	.fin
	push	BUFFER_SIZE
	push	dummy
	push	[hmodule]
	call	[GetModuleFileName]
	mov	ecx,[esp+28h]
	mov	ecx,[ecx+PROCESS_INFORMATION.dwProcessId]
	push	dummy
	push	ecx
	call	InjectDll
	mov	eax,1
    .fin:
	retn	28h

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
	push	_ws2_32
	call	[GetModuleHandle]
	push	eax
	push	dword [esp+4]
	call	alloc_base
	pop	ecx
	cmp	ecx,eax
	je	.already
	cmp	[already],1
	je	.already
	call	filename
	push	.handler
	push	dword [fs:0]
	mov	[fs:0],esp
	mov	eax,[esp+8]
	push	_size_3_3_0_0
	push	_mask_3_3_0_0
	push	_ptrn_3_3_0_0
	push	20000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_3_0_0
	mov	eax,[esp+8]
	push	_size_3_3_7_7
	push	_mask_3_3_7_7
	push	_ptrn_3_3_7_7
	push	20000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_3_7_7
	mov	eax,[esp+8]
	push	_size_3_3_7_0
	push	_mask_3_3_7_0
	push	_ptrn_3_3_7_0
	push	58000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.3_3_7_0
	mov	eax,[esp+8]
	push	_size_3_2_10_0
	push	_mask_3_2_10_0
	push	_ptrn_3_2_10_0
	push	58000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.3_2_10_0
	mov	eax,[esp+8]
	push	_size_3_2_8_0
	push	_mask_3_2_8_0
	push	_ptrn_3_2_8_0
	push	58000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.3_2_8_0
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
    .3_3_0_0:
	mov	cl,[eax+_modrm_3_3_0_0]
	add	eax,_count_3_3_0_0
	jmp	.fin
    .3_3_7_7:
	mov	cl,[eax+_modrm_3_3_7_7]
	add	eax,_count_3_3_7_7
	jmp	.fin
    .3_3_7_0:
	mov	cl,[eax+_modrm_3_3_7_0]
	add	eax,_count_3_3_7_0
	jmp	.fin
    .3_2_10_0:
	mov	cl,[eax+_modrm_3_2_10_0]
	add	eax,_count_3_2_10_0
	jmp	.fin
    .3_2_8_0:
	mov	cl,[eax+_modrm_3_2_8_0]
	add	eax,_count_3_2_8_0
    .fin:
	mov	[modrm],cl
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	cmp	[file_err],1
	je	.done
	mov	eax,[esp+8]
	push	_size_open2
	push	_mask_open2
	push	_ptrn_open2
	push	8000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.try
	mov	eax,[esp+8]
	push	_size_open
	push	_mask_open
	push	_ptrn_open
	push	4D000h
	push	eax
	call	RFindPattern
	test	eax,eax
	jnz	.try
	mov	[file_err],1
	jmp	.done
    .try:
	mov	[EXEArc_Open],eax
	mov	eax,[esp+8]
	push	ebx esi edi
	push	.catch
	push	dword [fs:0]
	mov	[fs:0],esp
	push	_size_extract
	push	_mask_extract
	push	_ptrn_extract
	push	3D000h
	push	eax
	call	FindPattern
	jmp	.finally
      .catch:
	mov	esp,[esp+8]
	xor	eax,eax
      .finally:
	pop	dword [fs:0]
	add	esp,4
	pop	edi esi ebx
	test	eax,eax
	jnz	.done
	mov	eax,[esp+8]
	push	_size_extract
	push	_mask_extract
	push	_ptrn_extract
	push	4D000h
	push	eax
	call	RFindPattern
	mov	[exearc_v2],1
	test	eax,eax
	jnz	.done
	mov	[file_err],1
    .done:
	mov	[EXEArc_Extract],eax
	pop	dword [fs:0]
	add	esp,4
	mov	[already],1
    .already:
	jmp	[_GetCommandLineW]

  MySystemParametersInfoA:
	mov	eax,[esp]
	cmp	word [eax-2],0D6FFh
	jnz	.already
	cmp	[already],1
	je	.already
	call	filename
	push	.handler
	push	dword [fs:0]
	mov	[fs:0],esp
	mov	eax,[esp+8]
	push	_size_3_2_10_0
	push	_mask_3_2_10_0
	push	_ptrn_3_2_10_0
	push	10000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_2_10_0
	mov	eax,[esp+8]
	push	_size_3_2_8_0
	push	_mask_3_2_8_0
	push	_ptrn_3_2_8_0
	push	10000h
	push	eax
	call	FindPattern
	test	eax,eax
	jnz	.3_2_8_0
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
    .3_2_10_0:
	mov	cl,[eax+_modrm_3_2_10_0]
	add	eax,_count_3_2_10_0
	jmp	.fin
    .3_2_8_0:
	mov	cl,[eax+_modrm_3_2_8_0]
	add	eax,_count_3_2_8_0
    .fin:
	mov	[modrm],cl
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	cmp	[file_err],1
	je	.done
	mov	eax,[esp+8]
	push	_size_open
	push	_mask_open
	push	_ptrn_open
	push	12000h
	push	eax
	call	FindPattern
	test	eax,eax
	je	.error
	mov	[EXEArc_Open],eax
	mov	eax,[esp+8]
	push	_size_extract
	push	_mask_extract
	push	_ptrn_extract
	push	12000h
	push	eax
	call	FindPattern
	test	eax,eax
	je	.error
	mov	[EXEArc_Extract],eax
	jmp	.done
    .error:
	mov	[file_err],1
    .done:
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
	call	[strcpy]
	add	esp,8
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

  capitalize:
	cmp	al,33h
	je	.err
	cmp	al,35h
	je	.err
	cmp	al,36h
	je	.err
	cmp	al,37h
	je	.prepr
	movzx	ecx,[dummy]
	cmp	ecx,'a'
	jb	.err
	cmp	ecx,'z'
	ja	.err
	sub	ecx,'a'
	mov	edx,[_macros+ecx*4]
	cmp	al,32h
	je	.start
	mov	edx,[_keywords+ecx*4]
	cmp	al,30h
	je	.start
	mov	edx,[_funcs+ecx*4]
    .start:
	test	edx,edx
	je	.err
	push	eax esi edi
	mov	esi,dummy
	mov	edi,edx
    .loop:
	push	edi
	push	esi
	call	[stricmp]
	add	esp,8
	test	eax,eax
	je	.equal
	push	edi
	call	[strlen]
	add	esp,4
	lea	edi,[edi+eax+1]
	cmp	byte [edi],0
	je	.fin
	jmp	.loop
    .prepr:
	push	eax esi edi
	mov	esi,dummy
	mov	edi,_preprocessor
    .loop2:
	push	edi
	call	[strlen]
	mov	[esp],eax
	push	edi
	push	esi
	call	[strnicmp]
	add	esp,8
	pop	ecx
	test	eax,eax
	je	.equal2
	lea	edi,[edi+ecx+1]
	cmp	byte [edi],0
	je	.fin
	jmp	.loop2
    .equal:
	push	edi
	push	esi
	call	[strcpy]
	add	esp,8
	jmp	.fin
    .equal2:
	push	ecx
	push	edi
	push	esi
	call	[strncpy]
	add	esp,0Ch
    .fin:
	pop	edi esi eax
    .err:
	retn

  extract_file:
	cmp	[file_err],1
	je	.err
	cmp	[oRead.m_fEXE],0
	jnz	.opened
	push	BUFFER_SIZE
	push	buf
	push	0
	call	[GetModuleFileNameW]
	push	edi
	mov	edi,oRead
	push	buf
	call	[EXEArc_Open]
	pop	edi
    .opened:
	push	ebx esi edi
	mov	edi,dummy
	cmp	byte [edi+1],':'
	jnz	.pathok
	add	edi,3
    .pathok:
	push	edi
	call	MakeDir
	mov	esi,path
	xchg	esi,edi
	call	.unicode
	mov	esi,dummy
	mov	edi,buf
	call	.unicode
	mov	ebx,oRead
	push	path
	push	buf
	cmp	[exearc_v2],1
	je	.ebxptr
	push	oRead
      .ebxptr:
	call	[EXEArc_Extract]
	pop	edi esi ebx
    .err:
	retn
    .unicode:
	lodsb
	stosw
	test	al,al
	jnz	.unicode
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
	call	[sprintf]
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
	call	[sprintf]
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
	cmp	[file_mod],1
	jnz	.empty
	call	extract_file
	mov	[file_mod],0
      .empty:
	mov	al,[esi-1]
	cmp	al,36h
	je	.string
	push	eax
	push	dummy
	call	[CharLower]
	pop	eax
	call	capitalize
	cmp	al,30h
	je	.keyword
	mov	[enum_mod],0
	cmp	al,31h
	je	.callwp
	mov	ecx,1
	mov	edx,_macro
	cmp	al,32h
	je	.ustr_write
	mov	edx,_var
	cmp	al,33h
	je	.ustr_write
	mov	edx,_prop
	cmp	al,35h
	je	.ustr_write
      .other:
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
      .callwp:
	push	dummy
	push	_FileInstall
	call	[strcmp]
	add	esp,8
	test	eax,eax
	jnz	.other
	mov	[file_mod],1
	jmp	.other
      .keyword:
	mov	word [dummy+ebx],' '
	cmp	dword [dummy],'If '
	je	.itabs
	cmp	dword [dummy+1],'lse '
	je	.else
	cmp	dword [dummy+1],'lseI'
	je	.mtabs
	cmp	dword [dummy],'EndI'
	je	.dtabs
	cmp	dword [dummy],'Whil'
	je	.itabs
	cmp	dword [dummy],'WEnd'
	je	.dtabs
	cmp	dword [dummy],'Do '
	je	.itabs
	cmp	dword [dummy],'Unti'
	je	.dtabs
	cmp	dword [dummy],'For '
	je	.itabs
	cmp	dword [dummy],'Next'
	je	.dtabs
	cmp	dword [dummy],'Sele'
	je	.titabs
	cmp	dword [dummy],'Swit'
	je	.titabs
	cmp	dword [dummy],'EndS'
	je	.tdtabs
	cmp	dword [dummy],'Case'
	je	.mtabs
	cmp	dword [dummy],'Func'
	je	.itabs
	cmp	dword [dummy],'EndF'
	je	.dtabs
	cmp	dword [dummy],'With'
	je	.itabs
	cmp	dword [dummy],'EndW'
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
	cmp	dword [dummy],'AND '
	je	.leading_space
	cmp	dword [dummy],'OR '
	je	.leading_space
	cmp	dword [dummy],'Then'
	je	.then
	cmp	dword [dummy],'To '
	je	.leading_space
	cmp	dword [dummy],'In '
	je	.leading_space
	cmp	dword [dummy],'Func'
	je	.newline
	cmp	dword [dummy],'EndF'
	je	.tnewline
	cmp	dword [dummy+1],'lse '
	je	.neither
	cmp	dword [dummy],'EndI'
	je	.neither
	cmp	dword [dummy],'WEnd'
	je	.neither
	cmp	dword [dummy],'Do '
	je	.neither
	cmp	dword [dummy],'Next'
	je	.neither
	cmp	dword [dummy],'EndS'
	je	.neither
	cmp	dword [dummy],'EndW'
	je	.neither
	cmp	dword [dummy],'True'
	je	.neither
	cmp	dword [dummy],'Fals'
	je	.neither
	cmp	dword [dummy],'Enum'
	je	.enum
	cmp	dword [dummy],'Step'
	jnz	.trailing_space
	mov	[step_mod],1
	cmp	[enum_mod],1
	jnz	.leading_space
	mov	[enum_mod],0
	push	1
	push	-1
	push	edi
	call	[_llseek]
	xor	edx,edx
	jmp	.leading_space
      .enum:
	mov	[enum_mod],1
	jmp	.trailing_space
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
	call	[sprintf]
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

  VERSION equ 'Exe2Autv4'

  _kernel32 db 'kernel32.dll',0
  _user32 db 'user32.dll',0
  _ws2_32 db 'ws2_32.dll',0
  _kernelbase db 'kernelbase.dll',0
  _gclw db 'GetCommandLineW',0
  _spia db 'SystemParametersInfoA',0
  _cpw db 'CreateProcessW',0
  _armadillo db VERSION,':Armadillo',0
  _loaded db VERSION,':Armadillo_OK',0
  _nofiles db VERSION,':NoFileInstall',0

  ;=====================================================================================
  ;     3_3_7_18
  ;     3_3_7_17
  ;     3_3_7_15
  ;     3_3_7_14
  ;     3_3_7_13
  ;     3_3_7_12
  ;     3_3_7_11
  ;     3_3_7_10
  ;     3_3_7_9
  ;     3_3_7_8
  _ptrn_3_3_7_7  db 032h,0C0h,0E9h,000h,000h,000h,0FFh,08Bh,000h,000h,08Bh  ;2.(forward)
  ;     3_3_7_6
  ;     3_3_7_5
  ;     3_3_7_4
  ;     3_3_7_3
  ;     3_3_7_2
  ;     3_3_7_1
  ;   + 3_2_10_0
  ;   + 3_2_6_0
  _ptrn_3_3_7_0  db 059h,0EBh,000h,08Bh,000h,010h,08Bh,000h,08Bh	    ;3.(reverse)
  ;     3_3_6_1
  ;     3_3_6_0
  ;     3_3_4_0
  ;     3_3_2_0
  _ptrn_3_3_0_0  db 0FFh,08Bh,000h,000h,000h,08Bh,000h,000h,000h,00Fh,0B6h  ;1.(forward)
  ;     3_2_12_1
  ;     3_2_12_0
  ;   + 3_2_6_0
  _ptrn_3_2_10_0 db 059h,0EBh,000h,08Bh,000h,000h,08Bh,000h,08Bh	    ;4.(reverse)
  ;     3_2_8_1
  _ptrn_3_2_8_0  db 059h,0EBh,000h,08Bh,000h,000h,000h,08Bh,000h,08Bh	    ;5.(reverse)
  ;=====================================================================================
  _mask_3_3_7_7  db 1,2,4,6,6,6,1,7,6,6,0  ;'xxx...xx..x'
  _size_3_3_7_7  =  $-_mask_3_3_7_7
  _mask_3_3_7_0  db 5,4,6,1,6,9,3,6,7	   ;'xx.x.xx.x'
  _size_3_3_7_0  =  $-_mask_3_3_7_0
  _mask_3_3_0_0  db 9,3,6,6,6,4,6,6,6,1,8  ;'xx...x...xx'
  _size_3_3_0_0  =  $-_mask_3_3_0_0
  _mask_3_2_10_0 db 3,0,6,7,6,6,5,6,9	   ;'xx.x..x.x'
  _size_3_2_10_0 =  $-_mask_3_2_10_0
  _mask_3_2_8_0  db 7,2,6,1,6,6,6,0,6,5    ;'xx.x...x.x'
  _size_3_2_8_0  =  $-_mask_3_2_8_0
  ;=====================================================================================
  _modrm_3_3_7_7  =  8
  _count_3_3_7_7  =  10
  _modrm_3_3_7_0  =  4
  _count_3_3_7_0  =  6
  _modrm_3_3_0_0  =  6
  _count_3_3_0_0  =  9
  _modrm_3_2_10_0 =  4
  _count_3_2_10_0 =  6
  _modrm_3_2_8_0  =  4
  _count_3_2_8_0  =  7
  ;=====================================================================================
  _ptrn_open	db 055h,08Bh,0ECh,083h,0E4h,0F8h,081h,0ECh,000h,001h,000h,000h,053h,056h
  _ptrn_open2	db 055h,08Bh,0ECh,083h,0E4h,0F8h,081h,0ECh,000h,001h,000h,000h,056h,068h
  _ptrn_extract db 055h,08Bh,0ECh,083h,0E4h,0F8h,0B8h,000h,000h,001h,000h,0E8h
  _mask_open	db 5,3,8,1,9,8,3,7,6,1,3,2,1,4	;'xxxxxxxx.xxxxx'
  _size_open	=  $-_mask_open
  _mask_open2	db 9,8,3,8,1,5,3,2,6,7,3,7,9,2	;'xxxxxxxx.xxxxx'
  _size_open2	=  $-_mask_open2
  _mask_extract db 9,8,5,2,7,4,3,6,6,8,4,1	;'xxxxxxx..xxx'
  _size_extract =  $-_mask_extract
  ;=====================================================================================

  _corrupt db 13,10,'..corrupted [%Xh]',0

  _int32 db '%d',0
  _int64 db '%I64d',0
  _float db '%.15g',0

  _macro db '@%s',0
  _var db '$%s',0
  _prop db '.%s',0
  _str db '"%s"',0
  _str2 db '''%s''',0
  _space db ' %s',0
  _eol db 13,10

  include 'func_table.inc'

  hmodule rd 1
  _GetCommandLineW rd 1
  _SystemParametersInfoA rd 1
  _CreateProcessW rd 1
  already rb 1

  include 'exearc_read.inc'
  oRead HS_EXEArc_Read
  EXEArc_Open rd 1
  EXEArc_Extract rd 1

  file_err rb 1
  file_mod rb 1
  exearc_v2 rb 1
  path rb MAX_PATH

  modrm rb 1
  newline rb 1
  unary_mod rb 1
  enum_mod rb 1
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
	 CharLower,'CharLowerA'

  import msvcrt,\
	 sprintf,'sprintf',\
	 strcmp,'strcmp',\
	 strcpy,'strcpy',\
	 strlen,'strlen',\
	 strncpy,'strncpy',\
	 stricmp,'_stricmp',\
	 strnicmp,'_strnicmp'

section '.reloc' fixups data discardable
