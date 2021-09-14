
format PE64 GUI 5.0 DLL at 10000000h
entry start

include 'win64a.inc'

BUFFER_SIZE = 3052

section '.code' code readable executable

	include 'seh64.inc'

  start:
	cmp	edx,DLL_PROCESS_ATTACH
	jnz	.skip
	sub	rsp,8*(4+1)
	mov	[hmodule],rcx
	call	[DisableThreadLibraryCalls]
	lea	rcx,[_kernel32]
	call	[GetModuleHandle]
	mov	[hkernel],rax
	;lea     rcx,[_loaded]
	;call    IsMutex
	;test    eax,eax
	;jnz     .decompile
	;lea     rcx,[_armadillo]
	;call    IsMutex
	;test    eax,eax
	;jnz     .armadillo
    ;.decompile:
	;lea     rcx,[_nofiles]
	;call    IsMutex
	mov	[file_err],al
	lea	rdx,[_gclw]
	mov	rcx,[hkernel]
	call	[GetProcAddress]
	lea	r8,[MyGetCommandLineW]
	mov	rdx,rax
	or	rcx,-1
	call	DetourFunc
	jmp	.fin
    ;.armadillo:
    .fin:
	add	rsp,8*(4+1)
	mov	rax,TRUE
    .skip:
	retn

  hook_critical_part:
	lea	rdx,[decompile]
	xchg	rax,rcx
	call	DetourCode
	retn

  filename:
	push	rsi rdi
	sub	rsp,8*(4+1)
	mov	r8d,BUFFER_SIZE
	lea	rdx,[buf]
	xor	ecx,ecx
	call	[GetModuleFileName]
	xchg	rax,rdx
	std
	or	rcx,-1
	mov	al,'\'
	lea	rdi,[buf-1]
	add	rdi,rdx
	repnz	scasb
	add	rdi,2
	cld
	neg	rcx
	mov	rsi,rdi
	sub	rcx,2
	sub	rdi,rdx
	add	rdi,rcx
	mov	rdx,rcx
	rep	movsb
	mov	rsi,rdi
	dec	rdi
	std
	mov	al,'.'
	mov	rcx,rdx
	repnz	scasb
	cld
	lea	rax,[rdi+1]
	cmovnz	rax,rsi
	mov	rdx,'_.au3'
	mov	[rax],rdx
	add	rsp,8*(4+1)
	pop	rdi rsi
	retn

  MyGetCommandLineW:
	cmp	[already],1
	je	.already
	push	r12
	mov	r12,[rsp+8]
	sub	rsp,8*(4+2)
	call	filename
       .try
	mov	dword [rsp+8*(4+0)],_size_3_3_0_0
	lea	r9,[_mask_3_3_0_0]
	lea	r8,[_ptrn_3_3_0_0]
	mov	edx,20000h
	mov	rcx,r12
	call	FindPattern
	test	rax,rax
	jnz	.3_3_0_0
	mov	dword [rsp+8*(4+0)],_size_3_3_7_7
	lea	r9,[_mask_3_3_7_7]
	lea	r8,[_ptrn_3_3_7_7]
	mov	edx,20000h
	mov	rcx,r12
	call	FindPattern
	test	rax,rax
	jnz	.3_3_7_7
	mov	dword [rsp+8*(4+0)],_size_3_3_7_0
	lea	r9,[_mask_3_3_7_0]
	lea	r8,[_ptrn_3_3_7_0]
	mov	edx,6A000h
	mov	rcx,r12
	call	RFindPattern
	test	rax,rax
	jnz	.3_3_7_0
	mov	dword [rsp+8*(4+0)],_size_3_2_10_0
	lea	r9,[_mask_3_2_10_0]
	lea	r8,[_ptrn_3_2_10_0]
	mov	edx,7B000h
	mov	rcx,r12
	call	RFindPattern
	test	rax,rax
	jnz	.3_2_10_0
       .catch
	mov	rsp,rdx
       .end
	lea	rcx,[buf]
	call	[DeleteFile]
	xor	ecx,ecx
	call	[ExitProcess]
    .3_3_0_0:
	mov	cl,[rax+_modrm_3_3_0_0]
	mov	ch,[rax+_modrm_3_3_0_0-2]
	add	rax,_count_3_3_0_0
	jmp	.fin
    .3_3_7_7:
	mov	cl,[rax+_modrm_3_3_7_7]
	mov	ch,[rax+_modrm_3_3_7_7-2]
	add	rax,_count_3_3_7_7
	jmp	.fin
    .3_3_7_0:
	mov	cl,[rax+_modrm_3_3_7_0]
	mov	ch,[rax+_modrm_3_3_7_0-2]
	add	rax,_count_3_3_7_0
	jmp	.fin
    .3_2_10_0:
	mov	cl,[rax+_modrm_3_2_10_0]
	mov	ch,[rax+_modrm_3_2_10_0-2]
	add	rax,_count_3_2_10_0
    .fin:
	mov	[modrm],cl
	mov	[rex.r],ch
	mov	rcx,rax
	call	hook_critical_part
	cmp	[file_err],1
	je	.done
	;EXEARC
    .done:
	mov	[already],1
	add	rsp,8*(4+2)
	pop	r12
    .already:
	jmp	[GetCommandLineW]

  sanitize_string:
	push	rdi
	sub	rsp,8*(4+0)
	mov	r15d,ecx
	lea	r14,[dummy]
	mov	ecx,ebx
	mov	al,'"'
	mov	rdi,r14
	repnz	scasb
	jnz	.ok
	mov	ecx,ebx
	mov	al,''''
	mov	rdi,r14
	repnz	scasb
	jnz	.single
	mov	r12,rdx
	mov	rdx,r14
	mov	rcx,r13
	call	[strcpy]
	xor	r8,r8
	mov	rcx,r14
	mov	rdx,r13
    .loop:
	mov	al,[rdx]
	mov	[rcx],al
	cmp	al,'"'
	jnz	.next
	mov	[rcx+1],al
	inc	r8
	inc	rcx
    .next:
	inc	rdx
	inc	rcx
	test	al,al
	jnz	.loop
	mov	rdx,r12
	lea	ecx,[r15+r8]
	jmp	.fin
    .single:
	lea	rdx,[_str2]
    .ok:
	mov	ecx,r15d
    .fin:
	add	rsp,8*(4+0)
	pop	rdi
	retn

  capitalize:
	sub	rsp,8*(4+1)
	cmp	r12l,33h
	je	.fin
	cmp	r12l,35h
	je	.fin
	cmp	r12l,36h
	je	.fin
	cmp	r12l,37h
	je	.prepr
	lea	r14,[dummy]
	movzx	ecx,byte [r14]
	cmp	ecx,'a'
	jb	.fin
	cmp	ecx,'z'
	ja	.fin
	sub	ecx,'a'
	lea	rax,[_macros]
	mov	r15d,[rax+rcx*4]
	cmp	r12l,32h
	je	.start
	lea	rax,[_keywords]
	mov	r15d,[rax+rcx*4]
	cmp	r12l,30h
	je	.start
	lea	rax,[_funcs]
	mov	r15d,[rax+rcx*4]
    .start:
	test	r15,r15
	je	.fin
	add	r15,[hmodule]
    .loop:
	mov	rdx,r14
	mov	rcx,r15
	call	[stricmp]
	test	eax,eax
	je	.equal
	mov	rcx,r15
	call	[strlen]
	lea	r15,[r15+rax+1]
	cmp	byte [r15],0
	je	.fin
	jmp	.loop
    .prepr:
	lea	r15,[_preprocessor]
    .loop2:
	mov	rcx,r15
	call	[strlen]
	mov	[rsp+8*(4+0)],rax
	mov	r8,rax
	mov	rdx,r15
	mov	rcx,r14
	call	[strnicmp]
	mov	r8,[rsp+8*(4+0)]
	test	eax,eax
	je	.equal2
	lea	r15,[r15+r8+1]
	cmp	byte [r15],0
	je	.fin
	jmp	.loop2
    .equal:
	mov	rdx,r15
	mov	rcx,r14
	call	[strcpy]
	jmp	.fin
    .equal2:
	mov	rdx,r15
	mov	rcx,r14
	call	[strncpy]
    .fin:
	add	rsp,8*(4+1)
	retn

  extract_file:
	cmp	[file_err],1
	je	.err
    .err:
	retn

  script_ptr:
	and	[rex.r],00000100b
	and	[modrm],00111000b
	shr	[rex.r],2
	shr	[modrm],3
	cmp	[rex.r],1
	je	.extended
	cmp	[modrm],0
	je	.fin
	mov	rax,rcx
	cmp	[modrm],1
	je	.fin
	mov	rax,rdx
	cmp	[modrm],2
	je	.fin
	mov	rax,rbx
	cmp	[modrm],3
	je	.fin
	mov	rax,rsi
	cmp	[modrm],6
	je	.fin
	mov	rax,rdi
	jmp	.fin
    .extended:
	mov	rax,r8
	cmp	[modrm],0
	je	.fin
	mov	rax,r9
	cmp	[modrm],1
	je	.fin
	mov	rax,r10
	cmp	[modrm],2
	je	.fin
	mov	rax,r11
	cmp	[modrm],3
	je	.fin
	mov	rax,r12
	cmp	[modrm],4
	je	.fin
	mov	rax,r13
	cmp	[modrm],5
	je	.fin
	mov	rax,r14
	cmp	[modrm],6
	je	.fin
	mov	rax,r15
    .fin:
	retn

  decompile:
	or	spl,8
	sub	rsp,8*(4+1)
	call	script_ptr
	mov	edx,[rax]
	mov	[lines],edx
	lea	rsi,[rax+4]
	lea	r13,[buf]
	xor	edx,edx
	mov	rcx,r13
	call	[_lcreat]
	mov	rdi,rax
    .loop:
	cmp	[newline],1
	jnz	.read
	mov	r8d,2
	lea	rdx,[_eol]
	mov	rcx,rdi
	call	[_lwrite]
	mov	[newline],0
      .read:
	mov	al,[rsi]
	inc	rsi
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
	mov	r8d,[rsi]
	lea	rdx,[_int32]
	mov	rcx,r13
	call	[sprintf]
	mov	r8d,eax
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
	cmp	[step_mod],1
	jnz	.nospace32
	mov	al,[rsi+4]
	mov	[step_mod],0
	cmp	al,7Fh
	je	.nospace32
	mov	byte [r13],' '
	mov	r8d,1
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
      .nospace32:
	mov	ebx,4
	jmp	.next
    .int64:
	mov	r8,[rsi]
	lea	rdx,[_int64]
	mov	rcx,r13
	call	[sprintf]
	mov	r8d,eax
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
	cmp	[step_mod],1
	jnz	.nospace64
	mov	al,[rsi+4]
	mov	[step_mod],0
	cmp	al,7Fh
	je	.nospace64
	mov	byte [r13],' '
	mov	r8d,1
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
      .nospace64:
	mov	ebx,8
	jmp	.next
    .float:
	mov	r8,[rsi]
	lea	rdx,[_float]
	mov	rcx,r13
	call	[sprintf]
	mov	r8d,eax
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
	mov	ebx,8
	jmp	.next
    .ustr:
	lea	rax,[rsi+4]
	mov	ebx,[rsi]
	mov	ecx,[rsi]
	test	ebx,ebx
	jnz	.decrypt
	mov	[dummy],0
	jmp	.empty
      .decrypt:
	xor	[rax],bx
	add	rax,2
	loop	.decrypt
	push	rsi rdi
	add	rsi,4
	lea	rdi,[dummy]
	mov	ecx,ebx
      .copy:
	lodsw
	stosb
	loop	.copy
	mov	[rdi],cl
	pop	rdi rsi
	cmp	[file_mod],1
	jnz	.empty
	call	extract_file
	mov	[file_mod],0
      .empty:
	mov	r12l,[rsi-1]
	cmp	r12l,36h
	je	.string
	cmp	r12l,37h
	je	.nolower
	lea	rcx,[dummy]
	call	[CharLower]
      .nolower:
	call	capitalize
	cmp	r12l,30h
	je	.keyword
	mov	[enum_mod],0
	cmp	r12l,31h
	je	.callwp
	mov	ecx,1
	lea	rdx,[_macro]
	cmp	r12l,32h
	je	.ustr_write
	lea	rdx,[_var]
	cmp	r12l,33h
	je	.ustr_write
	lea	rdx,[_prop]
	cmp	r12l,35h
	je	.ustr_write
      .other:
	mov	r8,rbx
	lea	rdx,[dummy]
	mov	rcx,rdi
	call	[_lwrite]
	jmp	.ustr_fin
      .string:
	mov	ecx,2
	lea	rdx,[_str]
	call	sanitize_string
	jmp	.ustr_write
      .callwp:
	lea	rdx,[dummy]
	lea	rcx,[_FileInstall]
	call	[strcmp]
	test	eax,eax
	jnz	.other
	mov	[file_mod],1
	jmp	.other
      .keyword:
	lea	r12,[dummy]
	mov	word [r12+rbx],' '
	cmp	dword [r12],'If '
	je	.itabs
	cmp	dword [r12+1],'lse '
	je	.else
	cmp	dword [r12+1],'lseI'
	je	.mtabs
	cmp	dword [r12],'EndI'
	je	.dtabs
	cmp	dword [r12],'Whil'
	je	.itabs
	cmp	dword [r12],'WEnd'
	je	.dtabs
	cmp	dword [r12],'Do '
	je	.itabs
	cmp	dword [r12],'Unti'
	je	.dtabs
	cmp	dword [r12],'For '
	je	.itabs
	cmp	dword [r12],'Next'
	je	.dtabs
	cmp	dword [r12],'Sele'
	je	.titabs
	cmp	dword [r12],'Swit'
	je	.titabs
	cmp	dword [r12],'EndS'
	je	.tdtabs
	cmp	dword [r12],'Case'
	je	.mtabs
	cmp	dword [r12],'Func'
	je	.itabs
	cmp	dword [r12],'EndF'
	je	.dtabs
	cmp	dword [r12],'With'
	je	.itabs
	cmp	dword [r12],'EndW'
	je	.dtabs
	jmp	.ltabs
      .else:
	cmp	byte [rsi-2],7Fh
	je	.mtabs
	jmp	.ltabs
      .titabs:
	inc	[tabs]
      .itabs:
	inc	[tabs]
	jmp	.ltabs
      .tdtabs:
	dec	[tabs]
	mov	r8d,1
	or	rdx,-1
	mov	rcx,rdi
	call	[_llseek]
      .dtabs:
	dec	[tabs]
      .mtabs:
	mov	r8d,1
	or	rdx,-1
	mov	rcx,rdi
	call	[_llseek]
      .ltabs:
	xor	edx,edx
	cmp	dword [r12],'AND '
	je	.leading_space
	cmp	dword [r12],'OR '
	je	.leading_space
	cmp	dword [r12],'Then'
	je	.then
	cmp	dword [r12],'To '
	je	.leading_space
	cmp	dword [r12],'In '
	je	.leading_space
	cmp	dword [r12],'Func'
	je	.newline
	cmp	dword [r12],'EndF'
	je	.tnewline
	cmp	dword [r12+1],'lse '
	je	.neither
	cmp	dword [r12],'EndI'
	je	.neither
	cmp	dword [r12],'WEnd'
	je	.neither
	cmp	dword [r12],'Do '
	je	.neither
	cmp	dword [r12],'Next'
	je	.neither
	cmp	dword [r12],'EndS'
	je	.neither
	cmp	dword [r12],'EndW'
	je	.neither
	cmp	dword [r12],'True'
	je	.neither
	cmp	dword [r12],'Fals'
	je	.neither
	cmp	dword [r12],'Defa'
	je	.neither
	cmp	dword [r12],'Enum'
	je	.enum
	cmp	dword [r12],'Step'
	jnz	.trailing_space
	mov	[step_mod],1
	cmp	[enum_mod],1
	jnz	.leading_space
	mov	[enum_mod],0
	mov	r8d,1
	or	rdx,-1
	mov	rcx,rdi
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
	mov	rdx,r12
	jmp	.write_keyword
      .newline:
	mov	r8d,1
	mov	rdx,-4
	mov	rcx,rdi
	call	[_llseek]
	mov	r8d,4
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lread]
	cmp	dword [r13],0A0D0A0Dh
	je	.trailing_space
	mov	r8d,2
	lea	rdx,[_eol]
	mov	rcx,rdi
	call	[_lwrite]
      .trailing_space:
	lea	ecx,[rbx+1]
	mov	rdx,r12
	jmp	.write_keyword
      .then:
	lea	edx,[rbx+rbx+4]
	cmp	byte [rsi+rdx],7Fh
	je	.leading_space
	xor	edx,edx
	dec	[tabs]
      .leading_space:
	mov	r8,r12
	mov	r12,rdx
	lea	rdx,[_space]
	mov	rcx,r13
	call	[sprintf]
	mov	eax,2
	test	r12,r12
	je	.with_trailing
	dec	eax
      .with_trailing:
	lea	ecx,[rbx+rax]
	mov	rdx,r13
      .write_keyword:
	mov	r8,rcx
	mov	rcx,rdi
	call	[_lwrite]
	jmp	.ustr_fin
      .ustr_write:
	mov	r12,rcx
	lea	r8,[dummy]
	mov	rcx,r13
	call	[sprintf]
	lea	r8,[rbx+r12]
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
      .ustr_fin:
	lea	ebx,[rbx+rbx+4]
    .next:
	mov	[unary_mod],0
	add	rsi,rbx
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
	xchg	rax,r12
	mov	byte [r13],' '
	mov	r8d,1
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
	xchg	rax,r12
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
	mov	r12,rcx
	mov	r8d,1
	or	rdx,-1
	mov	rcx,rdi
	call	[_llseek]
	mov	rcx,r12
	xor	ebx,ebx
      .ops_fin:
	mov	[unary_mod],1
      .ops_no_unary:
	xor	edx,edx
	mov	[r13],cx
	test	ch,ch
	je	.ops_len
	inc	edx
      .ops_len:
	inc	edx
	test	ebx,ebx
	je	.no_trailing_space
	mov	byte [r13+rdx],' '
	inc	edx
      .no_trailing_space:
	mov	r8,rdx
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
	jmp	.loop
    .eol:
	mov	[step_mod],0
	inc	[line]
	mov	eax,[lines]
	cmp	[line],eax
	je	.eos
	mov	r8d,2
	lea	rdx,[_eol]
	mov	rcx,rdi
	call	[_lwrite]
	mov	ecx,[tabs]
	mov	edx,[tabs]
	test	ecx,ecx
	je	.loop
      .tabs:
	mov	byte [r13+rcx-1],9
	loop	.tabs
	mov	r8,rdx
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
	jmp	.loop
    .corrupt:
	movzx	r8d,al
	lea	rdx,[_corrupt]
	mov	rcx,r13
	call	[sprintf]
	mov	r8,rax
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lwrite]
    .eos:
	mov	r8d,1
	mov	rdx,-2
	mov	rcx,rdi
	call	[_llseek]
	mov	r8d,2
	mov	rdx,r13
	mov	rcx,rdi
	call	[_lread]
	cmp	word [r13],0A0Dh
	je	.close
	mov	r8d,2
	lea	rdx,[_eol]
	mov	rcx,rdi
	call	[_lwrite]
      .close:
	mov	rcx,rdi
	call	[_lclose]
	xor	ecx,ecx
	call	[ExitProcess]

	include 'misc64.inc'

section '.data' data readable writeable

  VERSION equ 'Exe2Autv6BETA'

  _kernel32 db 'kernel32.dll',0
  _gclw db 'GetCommandLineW',0
  ;_cpw db 'CreateProcessW',0
  ;_rpm db 'ReadProcessMemory',0
  ;_armadillo db VERSION,':Armadillo',0
  ;_loaded db VERSION,':Armadillo_OK',0
  ;_address db VERSION,':Armadillo_PTR',0
  ;_ready db VERSION,':Armadillo_READY',0
  ;_nofiles db VERSION,':NoFileInstall',0

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

  include 'func_table64.inc'
  include 'signatures64.inc'

  hmodule rq 1
  hkernel rq 1
  already rb 1
  ;process rq 1
  ;address rq 1

  ;include 'exearc_read64.inc'
  ;oRead HS_EXEArc_Read
  ;EXEArc_Open rq 1
  ;EXEArc_Extract rq 1

  file_err rb 1
  file_mod rb 1
  ;path rb MAX_PATH

  modrm rb 1
  rex.r rb 1
  newline rb 1
  unary_mod rb 1
  enum_mod rb 1
  step_mod rb 1
  tabs rd 1
  line rd 1
  lines rd 1
  buf rb BUFFER_SIZE
  dummy rb BUFFER_SIZE

  data fixups
  end data

  data 3
  end data

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
