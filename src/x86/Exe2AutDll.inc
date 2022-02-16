
include 'win32a.inc'

BUFFER_SIZE = 3052

macro hookapi args
 { done@hookapi equ
   match ~mod:api->func,args
   \{ push mod
      call [GetModuleHandle]
      push api
      push eax
      call [GetProcAddress]
      call jmp_size
      push ecx
      push func
      push eax
      call DetourFunc
      restore done@hookapi \}
   match :mod:api->func,done@hookapi:args
   \{ push api
      push mod
      call [GetProcAddress]
      call jmp_size
      push ecx
      push func
      push eax
      call DetourFunc
      restore done@hookapi \} }
