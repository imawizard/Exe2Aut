
ERROR_ALREADY_EXISTS = 0B7h
MUTEX_ALL_ACCESS     = 1F0001h
SEMAPHORE_ALL_ACCESS = 1F0003h

struct MEMORY_BASIC_INFORMATION
  BaseAddress	    rd 1
  AllocationBase    rd 1
  AllocationProtect rd 1
  RegionSize	    rd 1
  State 	    rd 1
  Protect	    rd 1
  Type		    rd 1
ends

FindPattern:
	push	ebx esi edi
	mov	edi,[esp+10h]
	mov	ecx,[esp+14h]
	mov	edx,[esp+1Ch]
	dec	dword [esp+20h]
    .loop:
	mov	esi,[esp+18h]
	mov	al,[esi]
	repnz	scasb
	jnz	.not_found
	xchg	ebx,ecx
	push	edi
	inc	esi
	mov	ecx,[esp+24h]
    .compare:
	repe	cmpsb
	jnz	.check_wildcard
	pop	eax
	dec	eax
	jmp	.fin
    .check_wildcard:
	jecxz	.no_match
	mov	eax,[esp]
	sub	eax,edi
	neg	eax
	cmp	byte [edx+eax],1
	je	.compare
    .no_match:
	pop	edi
	xchg	ebx,ecx
	jmp	.loop
    .not_found:
	xor	eax,eax
    .fin:
	pop	edi esi ebx
	retn	14h

RFindPattern:
	push	ebx esi edi
	mov	edi,[esp+10h]
	mov	ecx,[esp+14h]
	mov	edx,[esp+1Ch]
	dec	dword [esp+20h]
    .loop:
	mov	esi,[esp+18h]
	mov	al,[esi]
	std
	repnz	scasb
	jnz	.not_found
	add	edi,2
	xchg	ebx,ecx
	push	edi
	inc	esi
	mov	ecx,[esp+24h]
	cld
    .compare:
	repe	cmpsb
	jnz	.check_wildcard
	pop	eax
	dec	eax
	jmp	.fin
    .check_wildcard:
	jecxz	.no_match
	mov	eax,[esp]
	sub	eax,edi
	neg	eax
	cmp	byte [edx+eax],1
	je	.compare
    .no_match:
	pop	edi
	xchg	ebx,ecx
	sub	edi,2
	jmp	.loop
    .not_found:
	xor	eax,eax
	cld
    .fin:
	pop	edi esi ebx
	retn	14h

IsMutex:
	push	dword [esp+4]
	push	0
	push	MUTEX_ALL_ACCESS
	call	[OpenMutex]
	test	eax,eax
	setnz	al
	and	eax,1
	retn	4

MakeDir:
	push	esi edi
	mov	esi,[esp+0Ch]
	mov	edi,[esp+0Ch]
	push	esi
	call	[lstrlen]
	mov	ecx,eax
    .loop:
	mov	al,'\'
	repnz	scasb
	jnz	.fin
	cmp	byte [edi-2],':'
	je	.loop
	mov	byte [edi-1],0
	push	ecx
	push	0
	push	esi
	call	[CreateDirectory]
	pop	ecx
	mov	byte [edi-1],'\'
	jmp	.loop
    .fin:
	pop	edi esi
	retn	4

proc alloc_base address
  local mbi:MEMORY_BASIC_INFORMATION
	lea	eax,[mbi]
	push	sizeof.MEMORY_BASIC_INFORMATION
	push	eax
	push	[address]
	call	[VirtualQuery]
	mov	eax,[mbi.AllocationBase]
	ret
endp

proc DetourFunc address,gateway,size
  local old:DWORD,mbi:MEMORY_BASIC_INFORMATION
	push	ebx esi edi
	mov	esi,[address]
	mov	edi,[gateway]
	mov	ecx,[size]
	mov	ebx,ecx
	add	ecx,5
	call	[GetProcessHeap]
	push	ecx
	push	0
	push	eax
	call	[HeapAlloc]
	test	eax,eax
	je	.fin
	push	edi
	mov	ecx,ebx
	mov	edi,eax
	rep	movsb
	sub	esi,ebx
	pop	edi
	mov	byte [eax+ebx],0E9h
	mov	edx,esi
	sub	edx,eax
	sub	edx,5
	mov	[eax+ebx+1],edx
	push	eax
	push	sizeof.MEMORY_BASIC_INFORMATION
	lea	eax,[mbi]
	push	eax
	push	esi
	call	[VirtualQuery]
	mov	edx,PAGE_READWRITE
	call	.deprotect
	mov	byte [esi],0E9h
	mov	edx,edi
	sub	edx,esi
	sub	edx,5
	mov	[esi+1],edx
	cmp	ebx,5
	jbe	.done
	mov	ecx,ebx
	sub	ecx,5
	mov	edi,esi
	add	edi,5
	mov	al,90h
	rep	stosb
    .done:
	mov	edx,[old]
	call	.deprotect
	pop	eax
	jmp	.fin
    .deprotect:
	lea	eax,[old]
	push	eax
	push	edx
	push	[mbi.RegionSize]
	push	[mbi.BaseAddress]
	call	[VirtualProtect]
	retn
    .fin:
	pop	edi esi ebx
	ret
endp

proc InjectDll pid,dll
	push	ebx esi edi
	push	[pid]
	push	0
	push	PROCESS_ALL_ACCESS
	call	[OpenProcess]
	test	eax,eax
	je	.err
	mov	edi,eax
	push	[dll]
	call	[lstrlen]
	lea	esi,[eax+1]
	push	PAGE_EXECUTE_READWRITE
	push	MEM_RESERVE+MEM_COMMIT
	push	esi
	push	0
	push	edi
	call	[VirtualAllocEx]
	test	eax,eax
	je	.close
	mov	ebx,eax
	push	0
	push	esi
	push	[dll]
	push	ebx
	push	edi
	call	[WriteProcessMemory]
	call	.kernel32
	db 'kernel32',0
      .kernel32:
	call	[GetModuleHandle]
	call	.loadlibrary
	db 'LoadLibraryA',0
      .loadlibrary:
	push	eax
	call	[GetProcAddress]
	xor	ecx,ecx
	push	ecx
	push	ecx
	push	ebx
	push	eax
	push	ecx
	push	ecx
	push	edi
	call	[CreateRemoteThread]
	xor	esi,esi
	test	eax,eax
	je	.cleanup
	mov	esi,eax
	push	-1
	push	esi
	call	[WaitForSingleObject]
	sub	esp,4
	push	esp
	push	esi
	call	[GetExitCodeThread]
	push	esi
	call	[CloseHandle]
	mov	esi,[esp]
	add	esp,4
    .cleanup:
	push	MEM_RELEASE
	push	0
	push	ebx
	push	edi
	call	[VirtualFreeEx]
	push	edi
	call	[CloseHandle]
	mov	eax,esi
	jmp	.fin
    .close:
	push	edi
	call	[CloseHandle]
    .err:
	xor	eax,eax
    .fin:
	pop	edi esi ebx
	ret
endp
