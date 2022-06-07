
format PE GUI 4.0 DLL
entry start

include 'win32a.inc'

section '.code' code readable executable

proc start hinstDLL,fdwReason,lpvReserved
	mov	eax,1
	ret
endp

proc DoMyJob hwnd,script
	xor	eax,eax
	ret
endp

proc LoadDll
	mov	eax,_loaddll
	ret
endp

proc AboutThis
	mov	eax,_about
	ret
endp

section '.data' data readable writeable

  _loaddll db 'BinaryToString Replacer',0
  _about db 'Simply decodes hardcoded BinaryToString()-calls.',0

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'

section '.edata' export data readable

  export 'Sample.DLL',\
	 DoMyJob,'DoMyJob',\
	 LoadDll,'LoadDll',\
	 AboutThis,'AboutThis'

section '.reloc' fixups data readable discardable
