
format PE GUI 4.0 DLL at 10000000h
entry start

include 'Exe2AutDll.inc'

section '.code' code readable executable

  start:
	cmp	byte [esp+8],DLL_PROCESS_ATTACH
	jnz	.fin
	mov	eax,[esp+4]
	mov	[hmodule],eax
	push	eax
	call	[DisableThreadLibraryCalls]
	push	_kernelbase
	call	[GetModuleHandle]
	test	eax,eax
	jnz	.already
	push	_kernel32
	call	[GetModuleHandle]
      .already:
	mov	[hkernel],eax
	push	_loaded
	call	IsMutex
	test	eax,eax
	jnz	.decompile_armadillo
	push	_armadillo
	call	IsMutex
	test	eax,eax
	jnz	.prepare_armadillo
    .decompile:
	push	_nofiles
	call	IsMutex
	mov	[file_err],al
	hookapi [hkernel],,_gclw,MyGetCommandLineW
	mov	[_GetCommandLineW],eax
	hookapi ,_user32,_spia,MySystemParametersInfoA
	mov	[_SystemParametersInfoA],eax
	jmp	.fin
    .decompile_armadillo:
	mov	[armadillo],1
	jmp	.decompile
    .prepare_armadillo:
	push	_loaded
	push	0
	push	0
	call	[CreateMutex]
	hookapi ,_kernel32,_cpw,MyCreateProcessW
	mov	[_CreateProcessW],eax
	hookapi [hkernel],,_rpm,MyReadProcessMemory
	mov	[_ReadProcessMemory],eax
	push	0
	push	0
	push	0
	push	readaddr
	push	0
	push	0
	call	[CreateThread]
    .fin:
	mov	eax,TRUE
	retn	0Ch

	include 'fde32.inc'

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
	mov	eax,[ecx+PROCESS_INFORMATION.hProcess]
	mov	ecx,[ecx+PROCESS_INFORMATION.dwProcessId]
	mov	[process],eax
	push	dummy
	push	ecx
	call	InjectDll
	mov	eax,1
    .fin:
	retn	28h

proc MyReadProcessMemory hProcess,lpBaseAddress,lpBuffer,nSize,lpNumberOfBytesRead
	mov	eax,[hProcess]
	cmp	eax,[process]
	jnz	.ignore
	cmp	[address],0
	je	.ignore
	mov	eax,[lpBaseAddress]
	cmp	eax,[address]
	ja	.ignore
	add	eax,[nSize]
	cmp	eax,[address]
	jb	.ignore
	mov	eax,0
	jmp	.fin
    .ignore:
	push	[lpNumberOfBytesRead]
	push	[nSize]
	push	[lpBuffer]
	push	[lpBaseAddress]
	push	[hProcess]
	call	[_ReadProcessMemory]
    .fin:
	ret
endp

  readaddr:
	push	100
	call	[Sleep]
	push	_address
	push	0
	push	SEMAPHORE_ALL_ACCESS
	call	[OpenSemaphore]
	test	eax,eax
	je	readaddr
	push	address
	push	1
	push	eax
	call	[ReleaseSemaphore]
	push	_ready
	push	0
	push	0
	call	[CreateMutex]
	retn	4

  hook_critical_part:
	cmp	[armadillo],0
	je	.hook
	push	eax
	mov	eax,[esp]
	lea	ecx,[eax+1]
	push	_address
	push	ecx
	push	eax
	push	0
	call	[CreateSemaphore]
    .wait:
	push	100
	call	[Sleep]
	push	_ready
	push	0
	push	MUTEX_ALL_ACCESS
	call	[OpenMutex]
	test	eax,eax
	je	.wait
	pop	eax
    .hook:
	push	5
	push	decompile
	push	eax
	call	DetourFunc
	mov	[already],1
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
	cmovnz	eax,esi
	mov	dword [eax],'_.au'
	mov	word [eax+4],'3'
	pop	edi esi
	retn

  get_frwrd_bckwrd_range:
	cmp	[armadillo],1
	je	.fin
	push	ebx
	mov	ecx,edx
	mov	ebx,edx
	sub	ecx,eax
	mov	[bckwrd_range],ecx
	push	ebx
	call	get_alloc_size
	sub	ebx,edx
	sub	eax,ebx
	mov	[frwrd_range],eax
	pop	ebx
    .fin:
	retn

proc cave_explorer addr
  local f32s:fde32s,range:DWORD,found_2:BYTE
	push	ebx esi edi
	cmp	[armadillo],1
	je	.err
	mov	eax,[frwrd_range]
	mov	[range],eax
	mov	esi,[addr]
    .loop1:
	push	_size_cmp_ebx
	push	_mask_cmp_ebx
	push	_ptrn_cmp_ebx
	push	[range]
	push	esi
	call	FindPattern
	test	eax,eax
	je	.err
	add	eax,3
	mov	ecx,eax
	sub	eax,esi
	mov	esi,ecx
	sub	[range],eax
	mov	edi,.loop2
	mov	ebx,10
	lea	edx,[f32s]
    .loop2:
	call	decode
	movzx	eax,[edx+fde32s.len]
	add	ecx,eax
	mov	eax,[edx+fde32s.imm32]
	cmp	[edx+fde32s.opcode2],085h
	jnz	.not_found
	test	[edx+fde32s.flags],F_IMM32
	je	.not_found
	test	eax,eax
	js	.found1
    .not_found:
	cmp	[edx+fde32s.opcode],0E9h
	je	.follow
	cmp	[edx+fde32s.opcode],0EBh
	jnz	.no_follow
      .follow:
	add	ecx,eax
      .no_follow:
	dec	ebx
	je	.loop1
	jmp	edi
    .found1:
	add	ecx,eax
	mov	edi,.loop3
	mov	ebx,40
    .loop3:
	call	decode
	movzx	eax,[edx+fde32s.len]
	add	ecx,eax
	mov	eax,[edx+fde32s.imm32]
	cmp	[edx+fde32s.opcode],08Bh
	jnz	.not_found
	cmp	[edx+fde32s.modrm.mod],MOD_DISP8
	jnz	.not_found
	test	[edx+fde32s.disp8],80h
	js	.not_found
	cmp	[edx+fde32s.modrm.rm],REG_ESP
	je	.found2
	cmp	[edx+fde32s.modrm.rm],REG_EBP
	jnz	.not_found
    .found2:
	cmp	[found_2],1
	je	.found!
	mov	[found_2],1
	jmp	.loop3
    .found!:
	xchg	eax,ecx
	mov	cl,[edx+fde32s.modrm]
	jmp	.fin
    .err:
	xor	eax,eax
    .fin:
	pop	edi esi ebx
	ret
endp

  MyGetCommandLineW:
	push	_ws2_32
	call	[GetModuleHandle]
	push	eax
	push	dword [esp+4]
	call	get_alloc_base
	pop	ecx
	cmp	ecx,eax
	je	.already
	cmp	[already],1
	je	.already
	mov	edx,[esp]
	call	get_frwrd_bckwrd_range
	call	filename
	push	.handler
	push	dword [fs:0]
	mov	[fs:0],esp
	findsig +20000h,3_3_0_0
	findsig +20000h,3_3_7_7
	findsig -58000h,3_3_7_0
	findsig -58000h,3_2_10_0
	findsig -58000h,3_2_8_0
	push	dword [esp+8]
	call	cave_explorer
	test	eax,eax
	jnz	.hook
    .err:
	pop	dword [fs:0]
	add	esp,4
	push	buf
	call	[DeleteFile]
	push	0
	call	[ExitProcess]
    .handler:
	mov	esp,[esp+8]
	cmp	[already],0
	je	.err
	mov	[file_err],1
	jmp	.done
    .3_3_7_7:
	mov	cl,[eax+_modrm_3_3_7_7]
	add	eax,_count_3_3_7_7
	jmp	.hook
    .3_3_7_0:
	mov	cl,[eax+_modrm_3_3_7_0]
	add	eax,_count_3_3_7_0
	jmp	.hook
    .3_3_0_0:
	mov	cl,[eax+_modrm_3_3_0_0]
	add	eax,_count_3_3_0_0
	jmp	.hook
    .3_2_10_0:
	mov	cl,[eax+_modrm_3_2_10_0]
	add	eax,_count_3_2_10_0
	jmp	.hook
    .3_2_8_0:
	mov	cl,[eax+_modrm_3_2_8_0]
	add	eax,_count_3_2_8_0
    .hook:
	mov	[modrm],cl
	call	hook_critical_part
	cmp	[file_err],1
	je	.done
	findsig -4D000h,open_A8 , .exearc_open
	findsig -08000h,open_alt, .exearc_open
	findsig -4D000h,open_AC ,,.exearc_error
	mov	[exearc_open_AC],1
    .exearc_open:
	mov	[EXEArc_Open],eax
	findsig +40000h,extract , .exearc_extract
	findsig -4D000h,extr_alt,,.exearc_error
	mov	[exearc_extr_alt],1
    .exearc_extract:
	mov	[EXEArc_Extract],eax
	jmp	.done
    .exearc_error:
	mov	[file_err],1
    .done:
	pop	dword [fs:0]
	add	esp,4
    .already:
	jmp	[_GetCommandLineW]

  MySystemParametersInfoA:
	mov	eax,[esp]
	cmp	word [eax-2],0D6FFh
	jnz	.already
	cmp	[already],1
	je	.already
	push	eax
	call	get_alloc_base
	mov	edx,[esp]
	call	get_frwrd_bckwrd_range
	call	filename
	push	.handler
	push	dword [fs:0]
	mov	[fs:0],esp
	findsig +08000h,3_2_10_0
	findsig +06000h,3_2_8_0
    .err:
	pop	dword [fs:0]
	add	esp,4
	push	buf
	call	[DeleteFile]
	push	0
	call	[ExitProcess]
    .handler:
	mov	esp,[esp+8]
	cmp	[already],0
	je	.err
	mov	[file_err],1
	jmp	.done
    .3_2_10_0:
	mov	cl,[eax+_modrm_3_2_10_0]
	add	eax,_count_3_2_10_0
	jmp	.hook
    .3_2_8_0:
	mov	cl,[eax+_modrm_3_2_8_0]
	add	eax,_count_3_2_8_0
    .hook:
	mov	[modrm],cl
	call	hook_critical_part
	cmp	[file_err],1
	je	.done
	mov	[exearc_ascii],1
	findsig +14000h,open_A8 ,,.exearc_error
	mov	[EXEArc_Open],eax
	findsig +14000h,extr_alt,,.exearc_error
	mov	[EXEArc_Extract],eax
	mov	[exearc_extr_alt],1
	jmp	.done
    .exearc_error:
	mov	[file_err],1
    .done:
	pop	dword [fs:0]
	add	esp,4
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
	mov	eax,[GetModuleFileNameW]
	cmp	[exearc_ascii],1
	cmove	eax,[GetModuleFileNameA]
	call	eax
	push	edi
	mov	edi,oRead
	push	buf
	cmp	[exearc_open_AC],1
	jnz	.via_edi
	push	edi
      .via_edi:
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
	cmp	[exearc_ascii],1
	je	.ascii
	call	.unicode
	mov	esi,dummy
	mov	edi,buf
	call	.unicode
	jmp	.extract
    .ascii:
	push	esi
	push	edi
	call	[strcpy]
	push	dummy
	push	buf
	call	[strcpy]
	add	esp,10h
    .extract:
	mov	ebx,oRead
	push	path
	push	buf
	cmp	[exearc_extr_alt],1
	je	.via_ebx
	push	ebx
      .via_ebx:
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
	jnz	.nospace32
	mov	al,[esi+4]
	mov	[step_mod],0
	cmp	al,7Fh
	je	.nospace32
	mov	byte [buf],' '
	push	1
	push	buf
	push	edi
	call	[_lwrite]
      .nospace32:
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
	cmp	[step_mod],1
	jnz	.nospace64
	mov	al,[esi+4]
	mov	[step_mod],0
	cmp	al,7Fh
	je	.nospace64
	mov	byte [buf],' '
	push	1
	push	buf
	push	edi
	call	[_lwrite]
      .nospace64:
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
	xor	[eax],bx
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
	mov	[edi],cl
	pop	edi esi
	cmp	[file_mod],1
	jnz	.empty
	call	extract_file
	mov	[file_mod],0
      .empty:
	mov	al,[esi-1]
	cmp	al,36h
	je	.string
	cmp	al,37h
	je	.nolower
	push	eax
	push	dummy
	call	[CharLower]
	pop	eax
      .nolower:
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
	cmp	dword [dummy],'Defa'
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
	je	.ops_no_unary
	mov	cx,'['
	cmp	al,4Eh
	je	.ops_fin
	mov	cx,']'
	cmp	al,4Fh
	je	.ops_no_unary
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
	mov	[unary_mod],1
      .ops_no_unary:
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
	jmp	.loop
    .eol:
	mov	[step_mod],0
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
	push	1
	push	-2
	push	edi
	call	[_llseek]
	push	2
	push	buf
	push	edi
	call	[_lread]
	cmp	word [buf],0A0Dh
	je	.close
	push	2
	push	_eol
	push	edi
	call	[_lwrite]
      .close:
	push	edi
	call	[_lclose]
	push	0
	call	[ExitProcess]

	include 'misc.inc'

section '.data' data readable writeable

  VERSION equ 'Exe2Autv8beta'

  _kernel32 db 'kernel32.dll',0
  _user32 db 'user32.dll',0
  _ws2_32 db 'ws2_32.dll',0
  _kernelbase db 'kernelbase.dll',0
  _gclw db 'GetCommandLineW',0
  _spia db 'SystemParametersInfoA',0
  _cpw db 'CreateProcessW',0
  _rpm db 'ReadProcessMemory',0
  _armadillo db VERSION,':Armadillo',0
  _loaded db VERSION,':Armadillo_OK',0
  _address db VERSION,':Armadillo_PTR',0
  _ready db VERSION,':Armadillo_READY',0
  _nofiles db VERSION,':NoFileInstall',0

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
  include 'signatures.inc'

  frwrd_range rd 1
  bckwrd_range rd 1

  hmodule rd 1
  hkernel rd 1
  _GetCommandLineW rd 1
  _SystemParametersInfoA rd 1
  _CreateProcessW rd 1
  _ReadProcessMemory rd 1
  already rb 1

  armadillo rb 1
  process rd 1
  address rd 1

  include 'exearc_read.inc'
  oRead HS_EXEArc_Read
  EXEArc_Open rd 1
  EXEArc_Extract rd 1

  file_err rb 1
  file_mod rb 1
  exearc_ascii rb 1
  exearc_open_AC rb 1
  exearc_extr_alt rb 1
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
	 memcpy,'memcpy',\
	 sprintf,'sprintf',\
	 strcmp,'strcmp',\
	 strcpy,'strcpy',\
	 strlen,'strlen',\
	 strncpy,'strncpy',\
	 stricmp,'_stricmp',\
	 strnicmp,'_strnicmp'

section '.reloc' fixups data discardable
