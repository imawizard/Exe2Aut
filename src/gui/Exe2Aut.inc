
include 'win32a.inc'

NO_3264BIT   = 1
NO_PROCESS   = 2
NO_INJECTION = 3
NO_OUTPUT    = 4

macro STATUS status
 { push status
   call set_status }

macro seticon hwnd,id
 { if ~ defined hinstance
    push 0
    call [GetModuleHandle]
   end if
   push 0
   push 16
   push 16
   push IMAGE_ICON
   push id
   if ~ defined hinstance
    push eax
   else
    push [hinstance]
   end if
   call [LoadImage]
   push eax
   push 0
   push WM_SETICON
   push hwnd
   call [SendMessage] }

macro menuitem menu,idm,caption,mutex,flags
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
   push menu
   call [AppendMenu] }

macro menusep menu
 { push 0
   push 0
   push MF_SEPARATOR
   push menu
   call [AppendMenu] }

macro cbadd combobox,caption
 { push caption
   push 0
   push CB_ADDSTRING
   push combobox
   call [SendMessage] }

macro cbsel combobox,index
 { if index eq
    push 0
    push 0
    push CB_GETCURSEL
    push combobox
    call [SendMessage]
   else
    push 0
    push index
    push CB_SETCURSEL
    push combobox
    call [SendMessage]
   end if }

macro onarg src,to_cmp,goto
 { push to_cmp
   push src
   call [lstrcmpiW]
   test eax,eax
   je goto }

macro setcenter hwnd,parent,mode=0
 { if mode>0
    push SM_CYCAPTION
    call [GetSystemMetrics]
    push eax
   end if
   push hwnd
   push parent
   call CalcMid
   if mode>0
    pop ecx
    if mode=1
     shr ecx,1
    else
     shr ecx,2
    end if
    add edx,ecx
   end if
   push SWP_NOSIZE+SWP_NOZORDER+SWP_NOACTIVATE
   push 0
   push 0
   push edx
   push eax
   push 0
   push hwnd
   call [SetWindowPos] }
