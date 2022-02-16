
format PE GUI 4.0
entry start

include 'Exe2Aut.inc'

section '.code' code readable executable

  start:
	push	ExceptionFilter
	call	[SetUnhandledExceptionFilter]
	push	_startup
	push	state
	call	[strcpy]
	add	esp,8
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
	xor	edi,edi
	on_arg	dword [esi],_deobfusc,.deobfu_params,2
	inc	edi
	on_arg	dword [esi],_rename,.deobfu_params,2
	inc	edi
	on_arg	dword [esi],_fileinst,.deobfu_params,2
	inc	edi
	on_arg	dword [esi],_compiled,.deobfu_params,2
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
	jmp	.next
      .deobfu_params:
	mov	eax,[esi]
	add	eax,4
	push	eax
	call	[wtoi]
	add	esp,4
	mov	[s_deobfusc+edi*4],eax
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
	push	eax
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
	mov	ecx,_3264bit
	cmp	eax,NO_3264BIT
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
	xor	eax,eax
	jmp	.fin
    .msgbox:
	cmp	[be_quiet],1
	je	.fin
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	ecx
	push	0
	call	[MessageBox]
	mov	eax,1
	jmp	.fin

  UponStart:
	push	100
	call	[Sleep]
	push	0
	push	-1
	push	WM_DROPFILES
	push	[main_hwnd]
	call	[PostMessage]
	retn	4

proc DialogProc hwnd,msg,wparam,lparam
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_GETMINMAXINFO
	je	.wm_getminmaxinfo
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
	mov	eax,[hwnd]
	mov	[main_hwnd],eax
	push	_idle
	push	state
	call	[strcpy]
	add	esp,8
	push	0
	push	[hwnd]
	call	[GetSystemMenu]
	mov	ebx,eax
	menu_sep
	menu_item 0,_header,,MF_GRAYED
	menu_item IDM_ARMDB,_armadillo,armmutex
	menu_sep
	menu_item IDM_NOFILES,_nofiles,nfimutex
	menu_item IDM_DEOBFU,_deobfu,,MF_MENUBARBREAK
	menu_sep
	menu_item IDM_ABOUT,_about
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
	call	[SendDlgItemMessage]
	cmp	[path],0
	je	.done
	push	0
	push	0
	push	0
	push	UponStart
	push	0
	push	0
	call	[CreateThread]
	jmp	.done
    .wm_getminmaxinfo:
	mov	eax,[lparam]
	mov	[eax+MINMAXINFO.ptMinTrackSize+POINT.x],280
	mov	[eax+MINMAXINFO.ptMinTrackSize+POINT.y],201
	jmp	.done
    .wm_syscommand:
	xor	eax,eax
	cmp	[wparam],IDM_ARMDB
	je	.armadillo
	cmp	[wparam],IDM_NOFILES
	je	.nofiles
	cmp	[wparam],IDM_DEOBFU
	je	.deobfu
	cmp	[wparam],IDM_ABOUT
	je	.about
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
	jmp	.sysmenu
      .deobfu:
	push	0
	call	[GetModuleHandle]
	push	[hwnd]
	push	DeobfuProc
	push	[hwnd]
	push	IDD_DEOBFU
	push	eax
	call	[DialogBoxParam]
	jmp	.done
      .about:
	push	0
	call	[GetModuleHandle]
	push	[hwnd]
	push	AboutProc
	push	[hwnd]
	push	IDD_ABOUT
	push	eax
	call	[DialogBoxParam]
	jmp	.done
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
	push	[hwnd]
	call	[SetForegroundWindow]
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
	push	0
	push	0
	push	edx
	push	decompile_thread
	push	0
	push	0
	call	[CreateThread]
	push	0
	call	[GetModuleHandle]
	push	[hwnd]
	push	ProgressProc
	push	[hwnd]
	push	IDD_PROGRESS
	push	eax
	call	[DialogBoxParam]
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

proc decompile_thread len
	mov	edx,[len]
	call	decompile
	push	ecx
	mov	ecx,_3264bit
	cmp	eax,NO_3264BIT
	je	.err
	mov	ecx,_error
	cmp	eax,NO_PROCESS
	je	.err
	mov	ecx,_failed
	cmp	eax,NO_INJECTION
	je	.didntwork
	mov	ecx,_output
	cmp	eax,NO_OUTPUT
	je	.didntwork
	mov	esi,edx
	push	edx
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SetDlgItemText]
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
	push	[main_hwnd]
	call	[SendMessage]
	pop	ecx
	test	ecx,ecx
	je	.finalize
	push	_@compiled
	push	esi
	call	stristr
	add	esp,8
	sub	eax,esi
	js	.finalize
	lea	ecx,[eax+9]
	push	ecx
	push	eax
	push	EM_SETSEL
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SendDlgItemMessage]
	push	0
	push	0
	push	EM_SCROLLCARET
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SendDlgItemMessage]
	push	ebt
	push	0
	push	EM_SHOWBALLOONTIP
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SendDlgItemMessage]
	jmp	.finalize
    .didntwork:
	mov	[esp],ecx
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
	push	[main_hwnd]
	call	[SendMessage]
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SetDlgItemText]
    .finalize:
	call	[GetProcessHeap]
	push	esi
	push	0
	push	eax
	call	[HeapFree]
	cmp	[armmutex],0
	je	.fin
	push	0
	push	IDM_ARMDB
	push	WM_SYSCOMMAND
	push	[main_hwnd]
	call	[SendMessage]
	jmp	.fin
    .err:
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	ecx
	push	[main_hwnd]
	call	[MessageBox]
    .fin:
	push	0
	push	0
	push	WM_CLOSE
	push	[progress_hwnd]
	call	[SendMessage]
	mov	[progress_hwnd],0
	ret
endp

  decompile:
	push	ebx esi edi
	std
	mov	ecx,edx
	mov	al,'\'
	lea	edi,[path+edx-1]
	repnz	scasb
	cld
	jecxz	.ok
	mov	byte [edi+1],0
	push	path
	call	[SetCurrentDirectory]
	mov	byte [edi+1],'\'
    .ok:
	sub	esp,4
	push	esp
	push	path
	call	[GetBinaryType]
	mov	eax,[esp]
	add	esp,4
	xor	edi,edi
	cmp	eax,SCS_32BIT_BINARY
	je	.start
	inc	edi
	cmp	eax,SCS_64BIT_BINARY
	je	.start
	mov	ecx,NO_3264BIT
	jmp	.fin
    .start:
	push	_decompiling
	push	state
	call	[strcpy]
	add	esp,8
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
	lea	eax,[IDR_DLL+edi]
	sub	esp,4
	push	esp
	push	RT_ICON
	push	eax
	call	LoadResfile
	mov	ecx,[esp]
	add	esp,4
	mov	edx,[esp]
	push	ecx
	push	eax
	push	edx
	call	[_lwrite]
	call	[_lclose]
	test	edi,edi
	jnz	.x64
	push	pathdll
	push	[_pi.dwProcessId]
	call	InjectDll
	test	eax,eax
	je	.err
	jmp	.wait
    .x64:
	push	inj64
	push	256
	call	[GetTempPath]
	push	inj64
	push	0
	push	0
	push	inj64
	call	[GetTempFileName]
	push	0
	push	inj64
	call	[_lcreat]
	push	eax
	sub	esp,4
	push	esp
	push	RT_ICON
	push	IDR_INJ64
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
	call	[strlen]
	add	esp,4
	std
	lea	esi,[pathdll-1+eax]
	lea	edi,[esi+2]
	push	edi
	xchg	eax,ecx
	rep	movsb
	pop	edi
	cld
	inc	edi
	mov	word [pathdll],' "'
	mov	word [edi],'" '
	add	edi,2
	push	10
	push	edi
	push	[_pi.dwProcessId]
	call	[itoa]
	add	esp,0Ch
	push	pathdll
	push	inj64
	call	[strcat]
	add	esp,8
	mov	[_si2.cb],sizeof.STARTUPINFO
	xor	eax,eax
	push	_pi2
	push	_si2
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	inj64
	push	eax
	call	[CreateProcess]
	push	-1
	push	[_pi2.hProcess]
	call	[WaitForSingleObject]
	sub	esp,4
	push	esp
	push	[_pi2.hProcess]
	call	[GetExitCodeProcess]
	mov	ebx,[esp]
	add	esp,4
	mov	edi,pathdll+2
	mov	al,'"'
	or	ecx,-1
	repnz	scasb
	mov	byte [edi-1],0
	push	pathdll+2
	push	pathdll
	call	[strcpy]
	add	esp,8
	mov	edi,inj64
	mov	al,'"'
	or	ecx,-1
	repnz	scasb
	mov	byte [edi-2],0
	push	inj64
	call	[DeleteFile]
	push	[_pi2.hProcess]
	call	[CloseHandle]
	push	[_pi2.hThread]
	call	[CloseHandle]
	test	ebx,ebx
	je	.err
    .wait:
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
	push	OF_READWRITE
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
	lea	ebx,[eax+1]
	call	[GetProcessHeap]
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
	push	[s_compiled]
	push	[s_fileinst]
	push	[s_rename]
	push	[s_deobfusc]
	push	ebx
	push	edi
	call	deobfuscate
	push	ecx
	cmp	edx,ebx
	je	.done
	push	eax
	push	edx
	push	eax
	push	0
	push	0
	push	esi
	call	[_llseek]
	push	esi
	call	[_lwrite]
	push	esi
	call	[SetEndOfFile]
	pop	eax
    .done:
	xchg	eax,ebx
	push	esi
	call	[_lclose]
	push	edi
	call	[LocalFree]
	pop	eax
	mov	edx,ebx
	xor	ecx,ecx
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
	push	eax edx
	push	_idle
	push	state
	call	[strcpy]
	add	esp,8
	pop	edx eax
	pop	edi esi ebx
	retn

proc DeobfuProc hwnd,msg,wparam,lparam
  local rect:RECT
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	lea	eax,[rect]
	push	eax
	push	[lparam]
	call	[GetClientRect]
	lea	eax,[rect]
	push	eax
	push	[lparam]
	call	[ClientToScreen]
	dec	[rect.left]
	dec	[rect.top]
	add	[rect.bottom],2
	add	[rect.right],2
	push	0
	push	[rect.bottom]
	push	[rect.right]
	push	[rect.top]
	push	[rect.left]
	push	0
	push	[hwnd]
	call	[SetWindowPos]
	lea	eax,[rect]
	push	eax
	push	[lparam]
	call	[GetClientRect]
	push	IDC_SAVE
	push	[hwnd]
	call	[GetDlgItem]
	mov	ecx,[rect.bottom]
	mov	edx,[rect.right]
	sub	ecx,36
	sub	edx,46
	push	SWP_NOSIZE
	push	0
	push	0
	push	ecx
	push	edx
	push	0
	push	eax
	call	[SetWindowPos]
	push	ebx
	mov	ebx,[hwnd]
	push	[s_deobfusc]
	push	IDC_DEOBFUSC
	push	ebx
	call	[CheckDlgButton]
	push	[s_fileinst]
	push	IDC_FILEINST
	push	ebx
	call	[CheckDlgButton]
	push	[s_compiled]
	push	IDC_COMPILED
	push	ebx
	call	[CheckDlgButton]
	push	IDC_SYMBOLS
	push	ebx
	call	[GetDlgItem]
	xchg	eax,ebx
	push	_ifobfu
	push	0
	push	CB_ADDSTRING
	push	ebx
	call	[SendMessage]
	push	_always
	push	0
	push	CB_ADDSTRING
	push	ebx
	call	[SendMessage]
	push	_never
	push	0
	push	CB_ADDSTRING
	push	ebx
	call	[SendMessage]
	push	0
	push	[s_rename]
	push	CB_SETCURSEL
	push	ebx
	call	[SendMessage]
	pop	ebx
	jmp	.done
    .wm_command:
	cmp	[wparam],IDCANCEL
	je	.save
	cmp	[wparam],BN_CLICKED shl 16+IDC_SAVE
	jnz	.done
      .save:
	push	ebx
	mov	ebx,[hwnd]
	push	IDC_DEOBFUSC
	push	ebx
	call	[IsDlgButtonChecked]
	mov	[s_deobfusc],eax
	push	IDC_FILEINST
	push	ebx
	call	[IsDlgButtonChecked]
	mov	[s_fileinst],eax
	push	IDC_COMPILED
	push	ebx
	call	[IsDlgButtonChecked]
	mov	[s_compiled],eax
	push	0
	push	0
	push	CB_GETCURSEL
	push	IDC_SYMBOLS
	push	ebx
	call	[SendDlgItemMessage]
	mov	[s_rename],eax
	pop	ebx
    .wm_close:
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc ProgressProc hwnd,msg,wparam,lparam
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_SYSCOMMAND
	je	.wm_syscommand
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	mov	eax,[hwnd]
	mov	[progress_hwnd],eax
	push	[hwnd]
	push	[lparam]
	call	CalcMid
	push	SWP_NOSIZE
	push	0
	push	0
	push	edx
	push	eax
	push	0
	push	[hwnd]
	call	[SetWindowPos]
	push	0
	push	TRUE
	push	PBM_SETMARQUEE
	push	IDC_PROGRESS
	push	[hwnd]
	call	[SendDlgItemMessage]
	jmp	.done
    .wm_syscommand:
	xor	eax,eax
	cmp	[wparam],SC_CLOSE
	je	.done
	jmp	.fin
    .wm_close:
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc AboutProc hwnd,msg,wparam,lparam
  local ps:PAINTSTRUCT
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_TIMER
	je	.wm_timer
	cmp	[msg],WM_PAINT
	je	.wm_paint
	cmp	[msg],WM_LBUTTONDOWN
	je	.wm_lbuttondown
	cmp	[msg],WM_RBUTTONDOWN
	je	.wm_close
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	push	[hwnd]
	push	[lparam]
	call	CalcMid
	push	SWP_NOSIZE
	push	0
	push	0
	push	edx
	push	eax
	push	0
	push	[hwnd]
	call	[SetWindowPos]
	call	randomize
	push	[hwnd]
	call	GFX_INIT
	push	0
	push	30
	push	0
	push	[hwnd]
	call	[SetTimer]
	jmp	.done
    .wm_timer:
	cmp	[GFX_Done],1
	je	.close
	call	GFX_UPDATE
	push	0
	push	0
	push	[hwnd]
	call	[InvalidateRect]
	jmp	.done
    .wm_paint:
	push	edi
	lea	edi,[ps]
	push	edi
	push	[hwnd]
	call	[BeginPaint]
	push	eax
	call	GFX_SHOW
	push	edi
	push	[hwnd]
	call	[EndPaint]
	pop	edi
	jmp	.fin
    .wm_lbuttondown:
	push	0
	push	HTCAPTION
	push	WM_NCLBUTTONDOWN
	push	[hwnd]
	call	[SendMessage]
	jmp	.done
    .wm_command:
	cmp	[wparam],IDCANCEL
	jnz	.done
    .wm_close:
	mov	[GFX_Burst],1
	jmp	.done
      .close:
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc CrashProc hwnd,msg,wparam,lparam
  local buf[200h]:BYTE,buf2[33]:BYTE
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_CTLCOLORSTATIC
	je	.wm_ctlcolorstatic
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	push	edi
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
	push	IDC_CRASH
	push	[hwnd]
	call	[SendDlgItemMessage]
	mov	edi,[lparam]
	mov	edi,[edi+EXCEPTION_POINTERS.ContextRecord]
	push	[edi+CONTEXT.Eip]
	call	alloc_base
	push	MAX_PATH
	push	path
	push	eax
	call	[GetModuleFileName]
	push	path
	call	[PathStripPath]
	push	path
	call	[strlen]
	push	edi
	mov	ecx,32
	lea	edi,[buf2]
	sub	ecx,eax
	js	.no_padding
	mov	al,' '
	rep	stosb
      .no_padding:
	mov	byte [edi],0
	pop	edi
	lea	eax,[buf2]
	push	path
	push	eax
	push	[edi+CONTEXT.EFlags]
	push	[edi+CONTEXT.Eip]
	push	[edi+CONTEXT.Edi]
	push	[edi+CONTEXT.Esi]
	push	[edi+CONTEXT.Ebp]
	push	[edi+CONTEXT.Esp]
	push	[edi+CONTEXT.Ebx]
	push	[edi+CONTEXT.Edx]
	push	[edi+CONTEXT.Ecx]
	push	[edi+CONTEXT.Eax]
	push	state
	lea	eax,[buf]
	push	_crash
	push	eax
	call	[wsprintf]
	add	esp,4*15
	push	_crash
	push	IDC_CRASH
	push	[hwnd]
	call	[SetDlgItemText]
	lea	eax,[buf]
	push	eax
	push	IDC_CRASH
	push	[hwnd]
	call	[SetDlgItemText]
	push	0
	push	0
	push	EM_SETSEL
	push	IDC_CRASH
	push	[hwnd]
	call	[SendDlgItemMessage]
	push	IDC_EXIT
	push	[hwnd]
	call	[GetDlgItem]
	push	eax
	call	[SetFocus]
	pop	edi
	xor	eax,eax
	jmp	.fin
    .wm_ctlcolorstatic:
	push	000FF00h
	push	[wparam]
	call	[SetTextColor]
	push	TRANSPARENT
	push	[wparam]
	call	[SetBkMode]
	push	BLACK_BRUSH
	call	[GetStockObject]
	jmp	.fin
    .wm_command:
	cmp	[wparam],IDCANCEL
	je	.wm_close
	cmp	[wparam],BN_CLICKED shl 16+IDC_EXIT
	jnz	.done
    .wm_close:
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc ExceptionFilter ExceptionInfo
	cmp	[progress_hwnd],0
	je	.no_progress_hwnd
	push	0
	push	0
	push	WM_CLOSE
	push	[progress_hwnd]
	call	[SendMessage]
    .no_progress_hwnd:
	cmp	[main_hwnd],0
	je	.no_main_hwnd
	push	SW_HIDE
	push	[main_hwnd]
	call	[ShowWindow]
    .no_main_hwnd:
	push	0
	call	[GetModuleHandle]
	push	[ExceptionInfo]
	push	CrashProc
	push	0
	push	IDD_CRASH
	push	eax
	call	[DialogBoxParam]
	mov	eax,1
	ret
endp

	include '../x86/misc.inc'
	include 'deobfuscate.inc'
	include 'gfx.inc'
	include 'nvlist.inc'
	include 'strhelp.inc'

section '.data' data readable writeable

  VERSION equ 'Exe2Autv6RC'
  VERSION_NUM equ '6.1'
  WINDOW_TITLE equ 'Exe2Aut - AutoIt3 Decompiler'

  NO_3264BIT   = 1
  NO_PROCESS   = 2
  NO_INJECTION = 3
  NO_OUTPUT    = 4

  _courier db 'Courier New',0
  _output db 'Apparently, it didn''t work..',0
  _failed db 'Something went wrong..',0
  _title db 'Exe2Aut',0
  _wtitle du 'Exe2Aut',0
  _3264bit db 'Only 32/64bit PE files are supported!',0
  _error db 'Either it''s not a PE file or it''s corrupted!',0
  _nopath db 'No file specified!',0
  _notfound db 'File not found!',0
  _done db 'Done.',0
  _mutex db VERSION,0
  _already db 'I''m already running!',0
  _window db WINDOW_TITLE,0
  _header db '- Exe2Aut Settings -',0
  _armadillo db 'Armadillo''s Debug-Blocker',0
  _armswitch du '-armadillo',0
  _armmutex db VERSION,':Armadillo',0
  _nofiles db 'Don''t Extract FileInstalls',0
  _nfiswitch du '-nofiles',0
  _nfimutex db VERSION,':NoFileInstall',0
  _deobfu db 'Deobfuscator Options',0
  _ifobfu db 'If obfuscated',0
  _always db 'Always',0
  _never db 'Never',0
  _about db 'About',0
  _compiled_macro du '» @Compiled « was found at least once!',\
		     13,10,'You should probably look into that.',0
  _nogui du '-nogui',0
  _quiet du '-quiet',0
  _deobfusc du '-d',0
  _rename du '-r',0
  _fileinst du '-f',0
  _compiled du '-c',0
  _crash db 'I''m sorry to tell you that Exe2Aut has crashed :(',13,10
	 db '(',VERSION,' [%s], built ',DATE,')',13,10,13,10
	 db 'EAX = %08Xh  ECX = %08Xh  EDX = %08Xh',13,10
	 db 'EBX = %08Xh  ESP = %08Xh  EBP = %08Xh',13,10
	 db 'ESI = %08Xh  EDI = %08Xh  EIP = %08Xh',13,10
	 db 'Flags:%08Xh%s(%s)',0
  _startup db 'startup',0
  _idle db 'idle',0
  _decompiling db 'decompiling',0
  _deobfuscating db 'deobfuscating',0

  s_deobfusc dd BST_CHECKED
  s_rename dd 0
  s_fileinst dd BST_CHECKED
  s_compiled dd BST_UNCHECKED

  ebt EDITBALLOONTIP sizeof.EDITBALLOONTIP,_wtitle,_compiled_macro,TTI_INFO

  misc_idata
  deobfus_idata
  gfx_idata

  state rb 10h

  path rb 256
  pathdll rb 256
  inj64 rb 256

  _pi  PROCESS_INFORMATION
  _pi2 PROCESS_INFORMATION
  _si  STARTUPINFO
  _si2 STARTUPINFO

  armmutex rd 1
  nfimutex rd 1
  no_gui rb 1
  be_quiet rb 1
  argc rd 1

  main_hwnd rd 1
  progress_hwnd rd 1

  mp MSGBOXPARAMS

  misc_udata
  deobfus_udata
  gfx_udata

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  gdi32,'GDI32.DLL',\
	  shell32,'SHELL32.DLL',\
	  msvcrt,'MSVCRT.DLL',\
	  shlwapi,'SHLWAPI.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\gdi32.inc'

  import shell32,\
	 CommandLineToArgvW,'CommandLineToArgvW',\
	 DragFinish,'DragFinish',\
	 DragQueryFile,'DragQueryFileA'

  import msvcrt,\
	 atoi,'atoi',\
	 itoa,'_itoa',\
	 memmove,'memmove',\
	 memset,'memset',\
	 sprintf,'sprintf',\
	 strcat,'strcat',\
	 strchr,'strchr',\
	 strcmp,'strcmp',\
	 strcpy,'strcpy',\
	 stricmp,'_stricmp',\
	 strlen,'strlen',\
	 strncpy,'strncpy',\
	 strstr,'strstr',\
	 wcsncmp,'wcsncmp',\
	 wtoi,'_wtoi'

  import shlwapi,\
	 PathStripPath,'PathStripPathA'

section '.rsrc' resource data readable

  RES_PATH	 equ '../../res/'
  RES_PATH_BEGIN fix match RES_PATH,RES_PATH {
  RES_PATH_END	 fix }

  IDI_ICON1    = 1
  IDI_ICON2    = 2
  IDR_DLL      = 4
  IDR_DLL64    = 5
  IDR_INJ64    = 6
  IDD_MAIN     = 100
  IDD_DEOBFU   = 101
  IDD_PROGRESS = 102
  IDD_ABOUT    = 103
  IDD_CRASH    = 104
  IDC_RESULT   = 1000
  IDC_SAVE     = 1001
  IDC_DEOBFUSC = 1002
  IDC_SYMBOLS  = 1003
  IDC_FILEINST = 1004
  IDC_COMPILED = 1005
  IDC_PROGRESS = 1006
  IDC_CRASH    = 1007
  IDC_EXIT     = 1008
  IDM_ARMDB    = 2000
  IDM_NOFILES  = 2001
  IDM_DEOBFU   = 2002
  IDM_ABOUT    = 2003

  directory RT_ICON,icons,\
	    RT_GROUP_ICON,group_icons,\
	    RT_DIALOG,dialogs,\
	    RT_MANIFEST,manifests,\
	    RT_VERSION,versions

  resource icons,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data,\
	   2,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data2,\
	   3,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data3,\
	   IDR_DLL,LANG_ENGLISH+SUBLANG_DEFAULT,exe2autdll,\
	   IDR_DLL64,LANG_ENGLISH+SUBLANG_DEFAULT,exe2autdll64,\
	   IDR_INJ64,LANG_ENGLISH+SUBLANG_DEFAULT,injectdll64

  resource group_icons,\
	   IDI_ICON1,LANG_ENGLISH+SUBLANG_DEFAULT,main_icon,\
	   IDI_ICON2,LANG_ENGLISH+SUBLANG_DEFAULT,other_icon

  resource dialogs,\
	   IDD_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,main_dialog,\
	   IDD_DEOBFU,LANG_ENGLISH+SUBLANG_DEFAULT,deobfu_dialog,\
	   IDD_PROGRESS,LANG_ENGLISH+SUBLANG_DEFAULT,progress_dialog,\
	   IDD_ABOUT,LANG_ENGLISH+SUBLANG_DEFAULT,about_dialog,\
	   IDD_CRASH,LANG_ENGLISH+SUBLANG_DEFAULT,crash_dialog

  resource manifests,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,manifest

  resource versions,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,version

  RES_PATH_BEGIN

  icon main_icon,icon_data,RES_PATH#'icon.ico',\
		 icon_data2,RES_PATH#'icon2.ico'

  icon other_icon,icon_data3,RES_PATH#'icon3.ico'

  resdata exe2autdll
    file '../x86/Exe2AutDll.dll'
  endres

  resdata exe2autdll64
    file '../x64/Exe2AutDll64.dll'
  endres

  resdata injectdll64
    file 'InjectDll64.exe'
  endres

  resdata manifest
    file RES_PATH#'manifest.xml'
  endres

  RES_PATH_END

  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,\
		      LANG_ENGLISH+SUBLANG_DEFAULT,0,\
	      'ProductName','Exe2Aut',\
	      'FileDescription','Tiny AutoIt3 Decompiler',\
	      'FileVersion',VERSION_NUM,\
	      'ProductVersion',<'v',VERSION_NUM>

  dialog main_dialog,WINDOW_TITLE,0,0,380,310,WS_OVERLAPPEDWINDOW+DS_CENTER,WS_EX_ACCEPTFILES
    dialogitem 'edit','',IDC_RESULT,0,0,0,0,WS_VISIBLE+ES_MULTILINE+WS_HSCROLL+WS_VSCROLL+ES_READONLY
  enddialog

  dialog deobfu_dialog,'',0,0,180,110,WS_POPUPWINDOW
    dialogitem 'button','',-1,6,3,163,69,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'static','Deobfuscate JvdZ 1.0.29',-1,12,14+14*0,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+83,14+14*0,6,12,WS_VISIBLE
    dialogitem 'button','',IDC_DEOBFUSC,102,12+12*0,12,12,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'static','Rename Symbols',-1,12,14+14*1,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+83,14+14*1,6,12,WS_VISIBLE
    dialogitem 'combobox','',IDC_SYMBOLS,102,12+14*1,60,60,WS_VISIBLE+CBS_DROPDOWNLIST+CBS_NOINTEGRALHEIGHT
    dialogitem 'static','Adjust FileInstall(...)',-1,12,14+14*2,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+83,14+14*2,6,12,WS_VISIBLE
    dialogitem 'button','',IDC_FILEINST,102,12+14*2,12,12,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'static','Replace @Compiled',-1,12,14+14*3,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+83,14+14*3,6,12,WS_VISIBLE
    dialogitem 'button','',IDC_COMPILED,102,12+14*3,12,12,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'button','OK',IDC_SAVE,0,0,24,16,WS_VISIBLE,WS_EX_STATICEDGE
  enddialog

  dialog progress_dialog,'',0,0,102,17,WS_BORDER+WS_POPUP
    dialogitem 'msctls_progress32','',IDC_PROGRESS,1,1,99,15,WS_VISIBLE+PBS_MARQUEE
  enddialog

  dialog about_dialog,'',0,0,176,100,WS_POPUP
  enddialog

  dialog crash_dialog,WINDOW_TITLE,0,0,230,80,WS_POPUP+WS_CAPTION+WS_MINIMIZEBOX+DS_CENTER
    dialogitem 'edit','',IDC_CRASH,0,0,230,62,WS_VISIBLE+ES_MULTILINE+ES_READONLY
    dialogitem 'button','Exit',IDC_EXIT,95,66,40,12,WS_VISIBLE
  enddialog
