
include 'win32a.inc'

BUFFER_SIZE = 3052

macro findsig range,sig,success,failure
 { match op int,range
   \{ mov ecx,int
      mov eax,[esp+8]
      cmp [armadillo],1
      match +,op \\{ cmovnz ecx,[ frwrd_range] \\}
      match -,op \\{ cmovnz ecx,[bckwrd_range] \\}
      push _size_\#sig
      push _mask_\#sig
      push _ptrn_\#sig
      push ecx
      push eax
      match +,op \\{ call  FindPattern \\}
      match -,op \\{ call RFindPattern \\}
      test eax,eax
      if ~ success eq
       jnz success
      else if ~ failure eq
       je failure
      else
       jnz .\#sig
      end if \} }

macro hookapi mod,dll,api,func
 { if ~ mod eq
    push api
    push mod
    call [GetProcAddress]
    call get_cb_for_hook
    push ecx
    push func
    push eax
    call DetourFunc
   else
    push dll
    call [GetModuleHandle]
    push api
    push eax
    call [GetProcAddress]
    call get_cb_for_hook
    push ecx
    push func
    push eax
    call DetourFunc
   end if }
