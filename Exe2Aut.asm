
format PE GUI 4.0
entry start

include 'win32a.inc'

ERROR_ALREADY_EXISTS = 0B7h

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

section '.code' code readable executable

  start:
	push	_mutex
	push	0
	push	0
	call	[CreateMutex]
	call	[GetLastError]
	cmp	eax,ERROR_ALREADY_EXISTS
	je	.err
	call	[GetCommandLineW]
	push	argc
	push	eax
	call	[CommandLineToArgvW]
	push	eax
	cmp	[argc],1
	je	.free
	mov	ebx,[argc]
	lea	esi,[eax+4]
	dec	ebx
    .argv:
	mov	edi,[esi]
	on_arg	dword [esi],_armswitch,.armadillo
	on_arg	dword [esi],_nfiswitch,.nofiles
	on_arg	dword [esi],_nogui,.nogui
	on_arg	dword [esi],_quiet,.quiet
	push	esi
	mov	esi,[esi]
	mov	edi,path
      .copy:
	lodsw
	stosb
	test	al,al
	jnz	.copy
	pop	esi
	push	path
	call	[GetFileAttributes]
	test	eax,eax
	jns	.next
	mov	word [path],0100h
	jmp	.next
      .armadillo:
	push	_armmutex
	push	0
	push	0
	call	[CreateMutex]
	mov	[armmutex],eax
	jmp	.next
      .nofiles:
	push	_nfimutex
	push	0
	push	0
	call	[CreateMutex]
	mov	[nfimutex],eax
	jmp	.next
      .nogui:
	mov	[no_gui],1
	jmp	.next
      .quiet:
	mov	[be_quiet],1
    .next:
	add	esi,4
	dec	ebx
	jnz	.argv
    .free:
	call	[LocalFree]
	cmp	[no_gui],1
	je	.hidden
	push	0
	call	[GetModuleHandle]
	push	0
	push	DialogProc
	push	0
	push	IDD_MAIN
	push	eax
	call	[DialogBoxParam]
    .fin:
	push	0
	call	[ExitProcess]
    .err:
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	_already
	push	0
	call	[MessageBox]
	push	_window
	push	0
	call	[FindWindow]
	push	eax
	call	[SetForegroundWindow]
	jmp	.fin
    .hidden:
	mov	ecx,_notfound
	cmp	[path+1],1
	je	.msgbox
	push	path
	call	[lstrlen]
	mov	ecx,_nopath
	test	eax,eax
	je	.msgbox
	xchg	eax,edx
	call	decompile
	mov	ecx,_32bit
	cmp	eax,NO_32BIT
	je	.msgbox
	mov	ecx,_error
	cmp	eax,NO_PROCESS
	je	.msgbox
	mov	ecx,_failed
	cmp	eax,NO_INJECTION
	je	.msgbox
	mov	ecx,_output
	cmp	eax,NO_OUTPUT
	je	.msgbox
	push	edx
	call	[GetProcessHeap]
	push	0
	push	eax
	call	[HeapFree]
	cmp	[be_quiet],1
	je	.fin
	push	0
	call	[GetModuleHandle]
	mov	[mp.cbSize],sizeof.MSGBOXPARAMS
	mov	[mp.hInstance],eax
	mov	[mp.lpszText],_done
	mov	[mp.lpszCaption],_title
	mov	[mp.dwStyle],MB_OK+MB_SETFOREGROUND+MB_USERICON
	mov	[mp.lpszIcon],IDI_ICON1
	push	mp
	call	[MessageBoxIndirect]
	jmp	.fin
    .msgbox:
	cmp	[be_quiet],1
	je	.fin
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	ecx
	push	0
	call	[MessageBox]
	jmp	.fin

proc DialogProc hwnd,msg,wparam,lparam
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_SYSCOMMAND
	je	.wm_syscommand
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_SIZE
	je	.wm_size
	cmp	[msg],WM_DROPFILES
	je	.wm_dropfiles
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	push	0
	push	[hwnd]
	call	[GetSystemMenu]
	mov	ebx,eax
	menu_sep
	menu_item 0,_header,,MF_GRAYED
	menu_item IDM_ARMDB,_armadillo,armmutex
	menu_sep
	menu_item IDM_NOFILES,_nofiles,nfimutex
	push	0
	call	[GetModuleHandle]
	push	0
	push	16
	push	16
	push	IMAGE_ICON
	push	IDI_ICON2
	push	eax
	call	[LoadImage]
	push	eax
	push	0
	push	WM_SETICON
	push	[hwnd]
	call	[SendMessage]
	push	_courier
	push	DEFAULT_PITCH+FF_MODERN
	push	DEFAULT_QUALITY
	push	CLIP_DEFAULT_PRECIS
	push	OUT_DEFAULT_PRECIS
	push	ANSI_CHARSET
	push	0
	push	0
	push	0
	push	FW_NORMAL
	push	0
	push	0
	push	0
	push	-11
	call	[CreateFont]
	push	0
	push	eax
	push	WM_SETFONT
	push	IDC_RESULT
	push	[hwnd]
	call	[GetDlgItem]
	push	eax
	call	[SendMessage]
	cmp	[path],0
	je	.done
	push	0
	push	-1
	push	WM_DROPFILES
	push	[hwnd]
	call	[PostMessage]
	jmp	.done
    .wm_syscommand:
	xor	eax,eax
	cmp	[wparam],IDM_ARMDB
	je	.armadillo
	cmp	[wparam],IDM_NOFILES
	je	.nofiles
	jmp	.fin
      .armadillo:
	push	ebx esi edi
	mov	ebx,IDM_ARMDB
	mov	esi,_armmutex
	mov	edi,armmutex
	jmp	.sysmenu
      .nofiles:
	push	ebx esi edi
	mov	ebx,IDM_NOFILES
	mov	esi,_nfimutex
	mov	edi,nfimutex
      .sysmenu:
	push	0
	push	[hwnd]
	call	[GetSystemMenu]
	push	eax
	push	0
	push	ebx
	push	eax
	call	[GetMenuState]
	xor	eax,MF_CHECKED
	pop	ecx
	push	eax
	push	eax
	push	ebx
	push	ecx
	call	[CheckMenuItem]
	pop	eax
	test	esi,esi
	je	.switch
	test	eax,MF_CHECKED
	je	.release
	push	esi
	push	0
	push	0
	call	[CreateMutex]
	mov	[edi],eax
	jmp	.cleanup
      .release:
	mov	ebx,[edi]
	push	ebx
	call	[ReleaseMutex]
	push	ebx
	call	[CloseHandle]
	and	dword [edi],0
	jmp	.cleanup
      .switch:
	xor	byte [edi],1
      .cleanup:
	pop	edi esi ebx
	jmp	.done
    .wm_command:
	cmp	[wparam],EN_SETFOCUS shl 16+IDC_RESULT
	jnz	.done
	push	IDC_RESULT
	push	[hwnd]
	call	[GetDlgItem]
	push	eax
	call	[HideCaret]
	jmp	.done
    .wm_size:
	push	IDC_RESULT
	push	[hwnd]
	call	[GetDlgItem]
	movzx	edx,word [lparam+2]
	movzx	ecx,word [lparam]
	sub	edx,5
	sub	ecx,6
	push	TRUE
	push	edx
	push	ecx
	push	5
	push	6
	push	eax
	call	[MoveWindow]
	jmp	.done
    .wm_dropfiles:
	cmp	[wparam],-1
	je	.directly
	push	256
	push	path
	push	0
	push	[wparam]
	call	[DragQueryFile]
	push	eax
	push	[wparam]
	call	[DragFinish]
	pop	edx
	jmp	.dothejob
      .directly:
	push	path
	call	[lstrlen]
	xchg	eax,edx
      .dothejob:
	call	decompile
	mov	ecx,_32bit
	cmp	eax,NO_32BIT
	je	.err
	mov	ecx,_error
	cmp	eax,NO_PROCESS
	je	.err
	mov	ecx,_failed
	cmp	eax,NO_INJECTION
	je	.output
	mov	ecx,_output
	cmp	eax,NO_OUTPUT
	je	.output
	push	edx
	push	edx
	push	IDC_RESULT
	push	[hwnd]
	call	[SetDlgItemText]
	call	[GetProcessHeap]
	push	0
	push	eax
	call	[HeapFree]
	push	0
	call	[GetModuleHandle]
	push	0
	push	16
	push	16
	push	IMAGE_ICON
	push	IDI_ICON1
	push	eax
	call	[LoadImage]
	push	eax
	push	0
	push	WM_SETICON
	push	[hwnd]
	call	[SendMessage]
	cmp	[armmutex],0
	je	.done
	push	0
	push	IDM_ARMDB
	push	WM_SYSCOMMAND
	push	[hwnd]
	call	[SendMessage]
	jmp	.done
      .output:
	push	ecx
	push	0
	call	[GetModuleHandle]
	push	0
	push	16
	push	16
	push	IMAGE_ICON
	push	IDI_ICON2
	push	eax
	call	[LoadImage]
	push	eax
	push	0
	push	WM_SETICON
	push	[hwnd]
	call	[SendMessage]
	push	IDC_RESULT
	push	[hwnd]
	call	[SetDlgItemText]
	jmp	.done
      .err:
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	ecx
	push	[hwnd]
	call	[MessageBox]
	jmp	.done
    .wm_close:
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

decompile:
	push	ebx esi edi
	std
	or	ecx,-1
	mov	al,'\'
	lea	edi,[path+edx-1]
	repnz	scasb
	cld
	mov	byte [edi+1],0
	push	path
	call	[SetCurrentDirectory]
	mov	byte [edi+1],'\'
	sub	esp,4
	push	esp
	push	path
	call	[GetBinaryType]
	mov	eax,[esp]
	add	esp,4
	mov	ecx,NO_32BIT
	cmp	eax,SCS_32BIT_BINARY
	jnz	.fin
	mov	[_si.cb],sizeof.STARTUPINFO
	xor	eax,eax
	push	_pi
	push	_si
	push	eax
	push	eax
	push	CREATE_SUSPENDED
	push	eax
	push	eax
	push	eax
	push	path
	push	eax
	call	[CreateProcess]
	mov	ecx,NO_PROCESS
	test	eax,eax
	je	.fin
	push	pathdll
	push	256
	call	[GetTempPath]
	push	pathdll
	push	0
	push	0
	push	pathdll
	call	[GetTempFileName]
	push	0
	push	pathdll
	call	[_lcreat]
	push	eax
	sub	esp,4
	push	esp
	push	RT_ICON
	push	IDR_DLL
	call	LoadResfile
	mov	ecx,[esp]
	add	esp,4
	mov	edx,[esp]
	push	ecx
	push	eax
	push	edx
	call	[_lwrite]
	call	[_lclose]
	push	pathdll
	push	[_pi.dwProcessId]
	call	InjectDll
	test	eax,eax
	je	.err
	push	[_pi.hThread]
	call	[ResumeThread]
	push	-1
	push	[_pi.hProcess]
	call	[WaitForSingleObject]
	push	pathdll
	call	[DeleteFile]
	push	[_pi.hProcess]
	call	[CloseHandle]
	push	[_pi.hThread]
	call	[CloseHandle]
	push	path
	call	[lstrlen]
	xchg	eax,edx
	std
	or	ecx,-1
	mov	al,'\'
	lea	edi,[path+edx-1]
	mov	esi,edi
	repnz	scasb
	neg	ecx
	mov	al,'.'
	sub	ecx,2
	mov	edi,esi
	repnz	scasb
	cld
	lea	eax,[edi+1]
	cmovnz	eax,esi
	mov	dword [eax],'_.au'
	mov	word [eax+4],'3'
	push	OF_READ
	push	path
	call	[_lopen]
	mov	ecx,NO_OUTPUT
	test	eax,eax
	js	.fin
	mov	esi,eax
	push	2
	push	0
	push	esi
	call	[_llseek]
	mov	ebx,eax
	call	[GetProcessHeap]
	inc	ebx
	push	ebx
	push	0
	push	eax
	call	[HeapAlloc]
	mov	edi,eax
	dec	ebx
	mov	byte [edi+ebx],0
	push	0
	push	0
	push	esi
	call	[_llseek]
	push	ebx
	push	edi
	push	esi
	call	[_lread]
	push	esi
	call	[_lclose]
	xor	ecx,ecx
	mov	edx,edi
	jmp	.fin
    .err:
	push	0
	push	[_pi.hProcess]
	call	[TerminateProcess]
	push	[_pi.hProcess]
	call	[CloseHandle]
	push	[_pi.hThread]
	call	[CloseHandle]
	mov	ecx,NO_INJECTION
	xor	edx,edx
    .fin:
	xchg	eax,ecx
	pop	edi esi ebx
	retn

proc LoadResfile name,type,size
	push	edi
	push	[type]
	push	[name]
	push	0
	call	[FindResource]
	test	eax,eax
	je	.fin
	mov	edi,eax
	push	eax
	push	0
	call	[SizeofResource]
	mov	ecx,[size]
	test	ecx,ecx
	je	.noptr
	mov	[ecx],eax
    .noptr:
	push	edi
	push	0
	call	[LoadResource]
	test	eax,eax
	je	.fin
	push	eax
	call	[LockResource]
    .fin:
	pop	edi
	ret
endp

proc InjectDll pid,dll
	push	ebx esi edi
	push	[pid]
	push	0
	push	PROCESS_ALL_ACCESS
	call	[OpenProcess]
	test	eax,eax
	je	.err
	mov	edi,eax
	push	[dll]
	call	[lstrlen]
	lea	esi,[eax+1]
	push	PAGE_EXECUTE_READWRITE
	push	MEM_RESERVE+MEM_COMMIT
	push	esi
	push	0
	push	edi
	call	[VirtualAllocEx]
	test	eax,eax
	je	.close
	mov	ebx,eax
	push	0
	push	esi
	push	[dll]
	push	ebx
	push	edi
	call	[WriteProcessMemory]
	call	.kernel32
	db 'kernel32',0
      .kernel32:
	call	[GetModuleHandle]
	call	.loadlibrary
	db 'LoadLibraryA',0
      .loadlibrary:
	push	eax
	call	[GetProcAddress]
	xor	ecx,ecx
	push	ecx
	push	ecx
	push	ebx
	push	eax
	push	ecx
	push	ecx
	push	edi
	call	[CreateRemoteThread]
	xor	esi,esi
	test	eax,eax
	je	.cleanup
	mov	esi,eax
	push	-1
	push	esi
	call	[WaitForSingleObject]
	sub	esp,4
	push	esp
	push	esi
	call	[GetExitCodeThread]
	push	esi
	call	[CloseHandle]
	mov	esi,[esp]
	add	esp,4
    .cleanup:
	push	MEM_RELEASE
	push	0
	push	ebx
	push	edi
	call	[VirtualFreeEx]
	push	edi
	call	[CloseHandle]
	mov	eax,esi
	jmp	.fin
    .close:
	push	edi
	call	[CloseHandle]
    .err:
	xor	eax,eax
    .fin:
	pop	edi esi ebx
	ret
endp

section '.data' data readable writeable

  VERSION equ 'Exe2Autv4'
  WINDOW_TITLE equ 'Exe2Aut - AutoIt3 Decompiler'

  NO_32BIT     = 1
  NO_PROCESS   = 2
  NO_INJECTION = 3
  NO_OUTPUT    = 4

  _courier db 'Courier New',0
  _output db 'Apparently, it didn''t work..',0
  _failed db 'Something went wrong..',0
  _title db 'Exe2Aut',0
  _32bit db 'Only 32bit PE files are supported!',0
  _error db 'Either it''s not a PE file or it''s corrupted!',0
  _nopath db 'No file specified!',0
  _notfound db 'File not found!',0
  _done db 'Done.',0
  _mutex db VERSION,0
  _already db 'I''m already running!',0
  _window db WINDOW_TITLE,0
  _armadillo db 'Armadillo''s Debug-Blocker',0
  _armswitch du '-armadillo',0
  _armmutex db VERSION,':Armadillo',0
  _nofiles db 'Don''t Extract FileInstalls',0
  _nfiswitch du '-nofiles',0
  _nfimutex db VERSION,':NoFileInstall',0
  _nogui du '-nogui',0
  _quiet du '-quiet',0

  path rb 256
  pathdll rb 256

  _pi PROCESS_INFORMATION
  _si STARTUPINFO

  armmutex rd 1
  nfimutex rd 1
  no_gui rb 1
  be_quiet rb 1
  argc rd 1

  mp MSGBOXPARAMS

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  shell32,'SHELL32.DLL',\
	  gdi32,'GDI32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'

  import shell32,\
	 CommandLineToArgvW,'CommandLineToArgvW',\
	 DragFinish,'DragFinish',\
	 DragQueryFile,'DragQueryFileA'

  import gdi32,\
	 CreateFont,'CreateFontA',\
	 SelectObject,'SelectObject'

section '.rsrc' resource data readable

  IDI_ICON1   = 1
  IDI_ICON2   = 2
  IDR_DLL     = 4
  IDD_MAIN    = 100
  IDC_RESULT  = 101
  IDM_ARMDB   = 102
  IDM_NOFILES = 103

  directory RT_ICON,icons,\
	    RT_GROUP_ICON,group_icons,\
	    RT_DIALOG,dialogs

  resource icons,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data,\
	   2,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data2,\
	   3,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data3,\
	   IDR_DLL,LANG_ENGLISH+SUBLANG_DEFAULT,exe2autdll

  resource group_icons,\
	   IDI_ICON1,LANG_ENGLISH+SUBLANG_DEFAULT,main_icon,\
	   IDI_ICON2,LANG_ENGLISH+SUBLANG_DEFAULT,other_icon

  resource dialogs,\
	   IDD_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,main_dialog

  icon main_icon,icon_data,'icon.ico',\
		 icon_data2,'icon2.ico'

  icon other_icon,icon_data3,'icon3.ico'

  resdata exe2autdll
    file 'Exe2AutDll.dll'
  endres

  dialog main_dialog,WINDOW_TITLE,0,0,380,310,WS_OVERLAPPEDWINDOW+DS_CENTER,WS_EX_ACCEPTFILES
    dialogitem 'edit','',IDC_RESULT,0,0,0,0,WS_VISIBLE+ES_MULTILINE+WS_HSCROLL+WS_VSCROLL+ES_READONLY
  enddialog
