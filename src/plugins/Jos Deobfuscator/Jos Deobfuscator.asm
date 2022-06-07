
format PE GUI 4.0 DLL
entry start

include 'win32a.inc'

section '.code' code readable executable

proc start hinstDLL,fdwReason,lpvReserved
	mov	eax,1
	ret
endp

proc DoMyJob hwnd,script
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

proc Options hwnd
	ret
endp

section '.data' data readable writeable

  _loaddll db 'Jos v.d.Z. Deobfuscator',0
  _about db 'Exe2Aut Plugin made by link',0

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'

section '.edata' export data readable

  export 'Jos Deobfuscator.DLL',\
	 DoMyJob,'DoMyJob',\
	 LoadDll,'LoadDll',\
	 AboutThis,'AboutThis',\
	 Options,'Options'

section '.reloc' fixups data readable discardable
