
include 'win32a.inc'

BUFFER_SIZE = 3052

macro findsig _sig,target
 { match op range:sig,_sig
   \{ mov ecx,range
      mov eax,[esp+8]
      cmp [armadillo],1
      match +,op \\{ cmovnz ecx,[size_delta  ] \\}
      match -,op \\{ cmovnz ecx,[size_delta+4] \\}
      push _size_\#sig
      push _mask_\#sig
      push _ptrn_\#sig
      push ecx
      push eax
      match +,op \\{ call  FindPattern \\}
      match -,op \\{ call RFindPattern \\}
      test eax,eax
      match any,target
      \\{
	 done@target equ
	 match ~l,any
	 \\\{
	    je l
	    restore done@target
	\\\}
	 match :l,done@target:any
	 \\\{
	    jnz l
	    restore done@target
	 \\\}
      \\}
      match ,target \\{ jnz .\\#sig \\} \} }

macro hookapi args
 { done@hookapi equ
   match ~mod:api->func,args
   \{ push mod
      call [GetModuleHandle]
      push api
      push eax
      call [GetProcAddress]
      call get_cb_for_hook
      push ecx
      push func
      push eax
      call DetourFunc
      restore done@hookapi \}
   match :mod:api->func,done@hookapi:args
   \{ push api
      push mod
      call [GetProcAddress]
      call get_cb_for_hook
      push ecx
      push func
      push eax
      call DetourFunc
      restore done@hookapi \} }
