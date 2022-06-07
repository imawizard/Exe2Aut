
format PE64 GUI 5.0
entry start

include 'win64a.inc'

section '.code' code readable executable

  start:
	sub	rsp,8*(4+1)
	call	[GetCommandLineW]
	lea	rdx,[argc]
	mov	rcx,rax
	call	[CommandLineToArgvW]
	mov	[rsp+8*4],rax
	or	rcx,-1
	cmp	[argc],3
	jnz	.fin
	lea	rsi,[rax+8]
	mov	r8d,10
	xor	edx,edx
	mov	rcx,[rsi+8]
	call	[wcstol]
	mov	rdx,[rsi]
	mov	ecx,eax
	call	InjectDll
	xor	ecx,ecx
	test	rax,rax
	setnz	cl
    .fin:
	mov	rbx,rcx
	mov	rcx,[rsp+8*4]
	call	[LocalFree]
	mov	rcx,rbx
	call	[ExitProcess]

proc InjectDll pid,dll
	push	r12 r13 r14
	sub	rsp,8*(4+3)
	mov	[dll],rdx
	mov	r8d,ecx
	xor	edx,edx
	mov	ecx,PROCESS_ALL_ACCESS
	call	[OpenProcess]
	test	rax,rax
	je	.err
	mov	r12,rax
	mov	rcx,[dll]
	call	[lstrlenW]
	lea	r14d,[eax*2+2]
	mov	dword [rsp+8*4],PAGE_EXECUTE_READWRITE
	mov	r9d,MEM_RESERVE+MEM_COMMIT
	mov	r8d,r14d
	xor	edx,edx
	mov	rcx,r12
	call	[VirtualAllocEx]
	test	rax,rax
	je	.close
	mov	r13,rax
	mov	dword [rsp+8*4],0
	mov	r9d,r14d
	mov	r8,[dll]
	mov	rdx,rax
	mov	rcx,r12
	call	[WriteProcessMemory]
	test	eax,eax
	je	.close
	lea	rcx,[.kernel32]
	call	[GetModuleHandle]
	lea	rdx,[.loadlibrary]
	mov	rcx,rax
	call	[GetProcAddress]
	xor	edx,edx
	mov	[rsp+8*6],rdx
	mov	[rsp+8*5],edx
	mov	[rsp+8*4],r13
	mov	r9,rax
	xor	r8,r8
	xor	edx,edx
	mov	rcx,r12
	call	[CreateRemoteThread]
	xor	r14,r14
	test	rax,rax
	je	.cleanup
	mov	r14,rax
	or	rdx,-1
	mov	rcx,rax
	call	[WaitForSingleObject]
	lea	rdx,[rsp+8*4]
	mov	rcx,r14
	call	[GetExitCodeThread]
	mov	rcx,r14
	call	[CloseHandle]
	mov	r14,[rsp+8*4]
    .cleanup:
	mov	r9d,MEM_RELEASE
	xor	r8,r8
	mov	rdx,r13
	mov	rcx,r12
	call	[VirtualFreeEx]
	mov	rcx,r12
	call	[CloseHandle]
	xchg	rax,r14
	jmp	.fin
    .close:
	mov	rcx,r12
	call	[CloseHandle]
    .err:
	xor	eax,eax
    .fin:
	add	rsp,8*(4+3)
	pop	r14 r13 r12
	ret

  .kernel32 db 'kernel32',0
  .loadlibrary db 'LoadLibraryW',0
endp

section '.data' data readable writeable

  argc rd 1

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  shell32,'SHELL32.DLL',\
	  msvcrt,'MSVCRT.DLL'

  include 'api\kernel32.inc'

  import shell32,\
	 CommandLineToArgvW,'CommandLineToArgvW'

  import msvcrt,\
	 wcstol,'wcstol'
