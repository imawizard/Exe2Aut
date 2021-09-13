
struct MEMORY_BASIC_INFORMATION
  BaseAddress	    dd ?
  AllocationBase    dd ?
  AllocationProtect dd ?
  RegionSize	    dd ?
  State 	    dd ?
  Protect	    dd ?
  Type		    dd ?
ends

FindPattern:
	push	ebx esi edi
	cld
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
	cmp	byte [edx+eax],'.'
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
