
struct E2APLUGIN
  Module    rd 1
  DllName   rb MAX_PATH
  Name	    rd 1
  DoMyJob   rd 1
  LoadDll   rd 1
  AboutThis rd 1
  Settings  rd 1
  Enabled   rd 1
ends

proc PluginManager.Load
  local fd:WIN32_FIND_DATA
	push	ebx esi edi
	push	plm._plugins
	call	[SetCurrentDirectory]
	lea	esi,[fd]
	push	esi
	push	plm._pattern
	call	[FindFirstFile]
	test	eax,eax
	js	.err
	xor	ebx,ebx
	xchg	eax,edi
    .count:
	inc	ebx
	push	esi
	push	edi
	call	[FindNextFile]
	test	eax,eax
	jnz	.count
	push	edi
	call	[FindClose]
	mov	[plm.capacity],ebx
	mov	[plm.count],0
	call	PluginManager.Alloc
	push	esi
	push	plm._pattern
	call	[FindFirstFile]
	xchg	eax,edi
	mov	ebx,[plm.plugins]
    .loop:
	push	ebx
	test	[esi+WIN32_FIND_DATA.dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
	jnz	.next
	mov	ebx,[ebx]
	lea	eax,[esi+WIN32_FIND_DATA.cFileName]
	lea	edx,[ebx+E2APLUGIN.DllName]
	push	eax edi
	mov	edi,eax
	mov	ecx,MAX_PATH
	xor	al,al
	repnz	scasb
	cmp	dword [edi-5],'.dll'
	pop	edi eax
	jnz	.next
	push	eax
	push	edx
	call	[strcpy]
	add	esp,4
	call	[LoadLibrary]
	test	eax,eax
	jnz	.load
	;=>[ LoadLibrary failed ]
	jmp	.next
    .miss:
	add	esp,4
	;=>[ Exports are missing ]
	jmp	.next
    .load:
	push	esi
	xchg	eax,esi
	push	plm._DoMyJob
	push	esi
	call	[GetProcAddress]
	test	eax,eax
	je	.miss
	mov	[ebx+E2APLUGIN.DoMyJob],eax
	push	plm._LoadDll
	push	esi
	call	[GetProcAddress]
	test	eax,eax
	je	.miss
	mov	[ebx+E2APLUGIN.LoadDll],eax
	push	plm._AboutThis
	push	esi
	call	[GetProcAddress]
	test	eax,eax
	je	.miss
	mov	[ebx+E2APLUGIN.AboutThis],eax
	push	plm._Settings
	push	esi
	call	[GetProcAddress]
	mov	[ebx+E2APLUGIN.Settings],eax
	mov	[ebx+E2APLUGIN.Module],esi
	call	[ebx+E2APLUGIN.LoadDll]
	mov	[ebx+E2APLUGIN.Name],eax
	push	eax
	call	Settings.IsPluginEnabled
	mov	[ebx+E2APLUGIN.Enabled],eax
	pop	esi
	inc	[plm.count]
	add	dword [esp],4
    .next:
	pop	ebx
	push	esi
	push	edi
	call	[FindNextFile]
	test	eax,eax
	jnz	.loop
	push	edi
	call	[FindClose]
	push	PluginManager.SortPlugins
	push	4
	push	[plm.count]
	push	[plm.plugins]
	call	[qsort]
	mov	[plm.initialized],1
    .err:
	push	plm._back
	call	[SetCurrentDirectory]
	pop	edi esi ebx
	ret
endp

proc PluginManager.SortPlugins c p1,p2
	mov	edx,[p2]
	mov	ecx,[p1]
	mov	edx,[edx]
	mov	ecx,[ecx]
	mov	edx,[edx+E2APLUGIN.Name]
	mov	ecx,[ecx+E2APLUGIN.Name]
	push	edx
	push	ecx
	call	[strcasecmp]
	add	esp,8
	ret
endp

proc PluginManager.Iterate callback,param
	push	ebx esi edi
	mov	ebx,[plm.count]
	mov	edi,[plm.plugins]
	xor	esi,esi
	test	ebx,ebx
	je	.fin
    .loop:
	push	[param]
	push	esi
	push	dword [edi]
	call	[callback]
	inc	esi
	add	edi,4
	dec	ebx
	jnz	.loop
    .fin:
	pop	edi esi ebx
	ret
endp

proc PluginManager.Get index
	xor	eax,eax
	mov	ecx,[index]
	test	ecx,ecx
	js	.err
	cmp	ecx,[plm.count]
	jnb	.err
	mov	eax,[plm.plugins]
	shl	ecx,2
	add	eax,ecx
	mov	eax,[eax]
    .err:
	ret
endp

proc PluginManager.Alloc
	push	ebx esi edi
	call	[GetProcessHeap]
	xchg	eax,esi
	mov	eax,[plm.capacity]
	mov	ebx,[plm.capacity]
	shl	eax,2
	push	eax
	push	0
	push	esi
	call	[HeapAlloc]
	mov	[plm.plugins],eax
	xchg	eax,edi
    .loop:
	push	sizeof.E2APLUGIN
	push	HEAP_ZERO_MEMORY
	push	esi
	call	[HeapAlloc]
	mov	[edi],eax
	add	edi,4
	dec	ebx
	jnz	.loop
	pop	edi esi ebx
	ret
endp

proc PluginManager.Free
	cmp	[plm.initialized],1
	jnz	.err
	push	ebx esi edi
	call	[GetProcessHeap]
	xchg	eax,esi
	mov	ebx,[plm.capacity]
	mov	edi,[plm.plugins]
	test	ebx,ebx
	je	.err
    .loop:
	mov	eax,[edi]
	mov	ecx,[eax+E2APLUGIN.Module]
	push	eax
	test	ecx,ecx
	je	.free
	push	ecx
	call	[FreeLibrary]
    .free:
	push	0
	push	esi
	call	[HeapFree]
	add	edi,4
	dec	ebx
	jnz	.loop
	push	[plm.plugins]
	push	0
	push	esi
	call	[HeapFree]
	mov	[plm.initialized],0
	pop	edi esi ebx
    .err:
	ret
endp

macro plman_idata
 {
   plm._plugins db 'plugins',0
   plm._back db '..',0
   plm._pattern db '*.dll',0
   plm._DoMyJob db 'DoMyJob',0
   plm._LoadDll db 'LoadDll',0
   plm._AboutThis db 'AboutThis',0
   plm._Settings db 'Settings',0
 }

macro plman_udata
 {
   plm.initialized rd 1
   plm.plugins rd 1
   plm.capacity rd 1
   plm.count rd 1
 }
