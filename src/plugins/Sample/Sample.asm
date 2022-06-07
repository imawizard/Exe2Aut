
format PE GUI 4.0 DLL
entry start

include 'win32a.inc'

section '.code' code readable executable

proc start hinstDLL,fdwReason,lpvReserved
	cmp	[fdwReason],DLL_PROCESS_ATTACH
	je	.attach
	cmp	[fdwReason],DLL_PROCESS_DETACH
	je	.detach
	jmp	.fin
    .attach:
	push	MB_OK
	push	_loaddll
	push	_attach
	push	0
	call	[MessageBox]
	mov	eax,1
	jmp	.fin
    .detach:
	push	MB_OK
	push	_loaddll
	push	_detach
	push	0
	call	[MessageBox]
    .fin:
	ret
endp

;True zurückgeben, wenn was verändert wurde
proc DoMyJob hwnd,script
	push	MB_OK
	push	_loaddll
	push	_detach
	push	0
	call	[MessageBox]
	xor	eax,eax
	ret
endp

;initialisierung und dann name zurückgeben
proc LoadDll
	push	MB_OK
	push	_loaddll
	push	_LoadDll
	push	0
	call	[MessageBox]
	mov	eax,_loaddll
	ret
endp

;String zurückgeben, der einfach als MsgBox angezeigt wird, oder selber about mcahen
;und null zurückgeben
proc AboutThis
	push	MB_OK
	push	_loaddll
	push	_AboutThis
	push	0
	call	[MessageBox]
	mov	eax,_about
	ret
endp

;Hier Dialog mit Settings anzeigen
;auch die dazugehörigen Switches in den Argumenten anzeigen
proc Settings hwnd
	push	MB_OK
	push	_loaddll
	push	_Settings
	push	0
	call	[MessageBox]
	ret
endp

section '.data' data readable writeable

  _loaddll db 'Sample-Plugin',0
  _about db 'Sample plugin for Exe2Aut',0
  _attach db 'Sample.DLL_PROCESS_ATTACH',0
  _detach db 'Sample.DLL_PROCESS_DETACH',0
  _DoMyJob db 'Sample.DoMyJob got called.',0
  _LoadDll db 'Sample.LoadDll got called.',0
  _AboutThis db 'Sample.AboutThis got called.',0
  _Settings db 'Sample.Settings got called.',0

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'

section '.edata' export data readable

  export 'Sample.DLL',\
	 DoMyJob,'DoMyJob',\
	 LoadDll,'LoadDll',\
	 AboutThis,'AboutThis',\
	 Settings,'Settings'

section '.reloc' fixups data readable discardable
