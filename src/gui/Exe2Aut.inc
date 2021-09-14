
include 'win32a.inc'

macro menu_item idm,caption,mutex,flags
 { if ~ mutex eq
    xor eax,eax
    cmp [mutex],0
    sete al
    dec eax
    and eax,MF_CHECKED
    or eax,MF_STRING
    push caption
    push idm
    push eax
   else
    push caption
    push idm
    if ~ flags eq
     push MF_STRING+flags
    else
     push MF_STRING
    end if
   end if
   push ebx
   call [AppendMenu] }

macro menu_sep
 { push 0
   push 0
   push MF_SEPARATOR
   push ebx
   call [AppendMenu] }

macro on_arg src,to_cmp,goto,count
 { if count eq
    push to_cmp
    push src
    call [lstrcmpiW]
   else
    push count
    push to_cmp
    push src
    call [wcsncmp]
    add esp,0Ch
   end if
   test eax,eax
   je goto }
