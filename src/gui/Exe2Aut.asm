
format PE GUI 4.0
entry start

include 'Exe2Aut.inc'

section '.code' code readable executable

  start:
	push	ExceptionFilter
	call	[SetUnhandledExceptionFilter]
	STATUS	_startup
	push	0
	call	[GetModuleHandle]
	mov	[hinstance],eax
	call	[GetCommandLineW]
	push	argc
	push	eax
	call	[CommandLineToArgvW]
	mov	[argv],eax
	cmp	[argc],1
	je	.init
	mov	ebx,[argc]
	lea	esi,[eax+4]
	dec	ebx
    .argv:
	mov	edi,[esi]
	onarg	edi,_armaswitch,.armadillo
	onarg	edi,_nofiswitch,.nofiles
	onarg	edi,_nogui,.nogui
	onarg	edi,_quiet,.quiet
	onarg	edi,_noadjustfiles,.noadjustfiles
	onarg	edi,_no@compiled,.no@compiled
	onarg	edi,_noplugins,.noplugins
	onarg	edi,_nosettings,.nosettings
	onarg	edi,_uninstall,.uninstall
	onarg	edi,_help1,.help
	onarg	edi,_help2,.help
	onarg	edi,_help3,.help
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
	push	_armamutex
	push	0
	push	0
	call	[CreateMutex]
	mov	[armamutex],eax
	jmp	.next
      .nofiles:
	push	_nofimutex
	push	0
	push	0
	call	[CreateMutex]
	mov	[nofimutex],eax
	jmp	.next
      .nogui:
	mov	[no_gui],1
	jmp	.next
      .quiet:
	mov	[be_quiet],1
	jmp	.next
      .noadjustfiles:
	mov	[set.adjust_files],0
	jmp	.next
      .no@compiled:
	mov	[set.no_@compiled],1
	jmp	.next
      .noplugins:
	mov	[no_plugins],1
	jmp	.next
      .nosettings:
	mov	[no_settings],1
	jmp	.next
      .uninstall:
	call	Settings.Exists
	test	eax,eax
	je	.done
	call	Settings.Delete
	jmp	.done
      .help:
	push	0
	push	HelpProc
	push	0
	push	IDD_HELP
	push	[hinstance]
	call	[DialogBoxParam]
	jmp	.done
    .next:
	add	esi,4
	dec	ebx
	jnz	.argv
	cmp	[no_gui],1
	je	.skip
    .init:
	push	_mutex
	push	0
	push	0
	call	[CreateMutex]
	call	[GetLastError]
	cmp	eax,ERROR_ALREADY_EXISTS
	je	.already
    .skip:
	cmp	[no_plugins],1
	je	.skipplugins
	call	PluginManager.Load
      .skipplugins:
	cmp	[no_settings],1
	je	.skipsettings
	call	Settings.Load
      .skipsettings:
	cmp	[no_gui],1
	je	.hidden
	call	ShowWarning
	test	eax,eax
	je	.fin
	push	0
	push	DialogProc
	push	0
	push	IDD_MAIN
	push	[hinstance]
	call	[DialogBoxParam]
    .fin:
	xchg	eax,ebx
	call	PluginManager.Free
	push	[argv]
	call	[LocalFree]
	xchg	eax,ebx
    .exit:
	push	eax
	call	[ExitProcess]
    .already:
	push	_window
	push	0
	call	[FindWindow]
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	_already
	push	eax
	call	MMessageBox
	jmp	.exit
    .hidden:
	mov	ecx,_notfound
	cmp	[path+1],1
	je	.msgbox
	mov	ecx,_nopath
	cmp	[path],0
	je	.msgbox
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
	call	[GetProcessHeap]
	push	[au3_code]
	push	0
	push	eax
	call	[HeapFree]
	cmp	[be_quiet],1
	je	.done
	mov	eax,[hinstance]
	mov	[mp.cbSize],sizeof.MSGBOXPARAMS
	mov	[mp.hInstance],eax
	mov	[mp.lpszText],_done
	mov	[mp.lpszCaption],_title
	mov	[mp.dwStyle],MB_OK+MB_SETFOREGROUND+MB_USERICON
	mov	[mp.lpszIcon],IDI_MAIN
	push	mp
	call	[MessageBoxIndirect]
    .done:
	xor	eax,eax
	jmp	.fin
    .msgbox:
	cmp	[be_quiet],1
	je	.err
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	ecx
	push	0
	call	[MessageBox]
    .err:
	mov	eax,1
	jmp	.fin

proc ShowWarning
	mov	eax,1
	test	[set.dontshowagain],NO_WARNING
	jnz	.fin
	push	0
	push	WarningProc
	push	0
	push	IDD_WARNING
	push	[hinstance]
	call	[DialogBoxParam]
    .fin:
	ret
endp

proc ShowArmaNote
	mov	eax,1
	cmp	[armamutex],0
	jnz	.fin
	test	[set.dontshowagain],NO_ARMANOTE
	jnz	.fin
	push	[main_hwnd]
	push	ArmaNoteProc
	push	[main_hwnd]
	push	IDD_ARMANOTE
	push	[hinstance]
	call	[DialogBoxParam]
    .fin:
	ret
endp

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
	cmp	[msg],WM_TIMER
	je	.wm_timer
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
	STATUS	_idling
	push	0
	push	[hwnd]
	call	[GetSystemMenu]
	mov	ebx,eax
	menusep ebx
	menuitem ebx,0,_header,,MF_GRAYED
	menuitem ebx,IDM_ARMDBGBL,_armadillo,armamutex
	menusep ebx
	menuitem ebx,IDM_NOFILES,_nofiles,nofimutex
	menuitem ebx,IDM_SETTINGS,_settings,,MF_MENUBARBREAK
	menusep ebx
	menuitem ebx,IDM_ABOUT,_about
	seticon [hwnd],IDI_HI2U
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
	mov	[main_font],eax
	push	0
	push	eax
	push	WM_SETFONT
	push	IDC_RESULT
	push	[hwnd]
	call	[SendDlgItemMessage]
	mov	[hi2u],IDI_HI2U
	push	0
	push	50
	push	1
	push	[hwnd]
	call	[SetTimer]
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
    .wm_timer:
	cmp	[hi2u],IDI_HI2U_END
	je	.hi2u_done
	seticon [hwnd],[hi2u]
	inc	[hi2u]
	jmp	.done
      .hi2u_done:
	push	1
	push	[hwnd]
	call	[KillTimer]
	seticon [hwnd],IDI_MAIN
	jmp	.done
    .wm_getminmaxinfo:
	mov	eax,[lparam]
	mov	[eax+MINMAXINFO.ptMinTrackSize+POINT.x],310
	mov	[eax+MINMAXINFO.ptMinTrackSize+POINT.y],344
	jmp	.done
    .wm_syscommand:
	xor	eax,eax
	cmp	[wparam],IDM_ARMDBGBL
	je	.armadillo
	cmp	[wparam],IDM_NOFILES
	je	.nofiles
	cmp	[wparam],IDM_SETTINGS
	je	.settings
	cmp	[wparam],IDM_ABOUT
	je	.about
	jmp	.fin
      .armadillo:
	call	ShowArmaNote
	test	eax,eax
	je	.fin
	push	ebx esi edi
	mov	ebx,IDM_ARMDBGBL
	mov	esi,_armamutex
	mov	edi,armamutex
	jmp	.sysmenu
      .nofiles:
	push	ebx esi edi
	mov	ebx,IDM_NOFILES
	mov	esi,_nofimutex
	mov	edi,nofimutex
	jmp	.sysmenu
      .settings:
	push	[hwnd]
	push	SettingsProc
	push	[hwnd]
	push	IDD_SETTINGS
	push	[hinstance]
	call	[DialogBoxParam]
	jmp	.done
      .about:
	push	XM_MEMORY
	push	sizeof.chiptune
	push	chiptune
	call	uFMOD_PlaySong
	mov	eax,[hinstance]
	mov	ecx,[hwnd]
	mov	[mp.cbSize],sizeof.MSGBOXPARAMS
	mov	[mp.hwndOwner],ecx
	mov	[mp.hInstance],eax
	mov	[mp.lpszText],_about_exe2aut
	mov	[mp.lpszCaption],_title
	mov	[mp.dwStyle],MB_OK+MB_SETFOREGROUND+MB_USERICON
	mov	[mp.lpszIcon],IDI_ABOUT
	push	mp
	call	MMessageBoxIndirect
	push	0
	push	0
	push	0
	call	uFMOD_PlaySong
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
	je	.dothejob
	push	256
	push	path
	push	0
	push	[wparam]
	call	[DragQueryFile]
	push	[wparam]
	call	[DragFinish]
      .dothejob:
	push	0
	push	0
	push	0
	push	decompile_thread
	push	0
	push	0
	call	[CreateThread]
	push	[hwnd]
	push	ProgressProc
	push	[hwnd]
	push	IDD_PROGRESS
	push	[hinstance]
	call	[DialogBoxParam]
	jmp	.done
    .wm_close:
	mov	[main_hwnd],0
	push	[main_font]
	call	[DeleteObject]
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

decompile_thread:
mov [0],eax
	call	decompile
	xchg	eax,ebx
	mov	esi,[au3_code]
	mov	ecx,_3264bit
	cmp	ebx,NO_3264BIT
	je	.err
	mov	ecx,_error
	cmp	ebx,NO_PROCESS
	je	.err
	push	1
	push	[main_hwnd]
	call	[KillTimer]
	mov	ecx,_failed
	cmp	ebx,NO_INJECTION
	je	.didntwork
	mov	ecx,_output
	cmp	ebx,NO_OUTPUT
	je	.didntwork
	push	esi
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SetDlgItemText]
	seticon [main_hwnd],IDI_HAPPY
	push	_@compiled
	push	esi
	call	[strstr]
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
	push	ecx
	seticon [main_hwnd],IDI_UNHAPPY
	push	IDC_RESULT
	push	[main_hwnd]
	call	[SetDlgItemText]
    .finalize:
	call	[GetProcessHeap]
	push	esi
	push	0
	push	eax
	call	[HeapFree]
	cmp	[armamutex],0
	je	.fin
	push	0
	push	IDM_ARMDBGBL
	push	WM_SYSCOMMAND
	push	[main_hwnd]
	call	[SendMessage]
	jmp	.fin
    .err:
	push	MB_OK+MB_ICONINFORMATION+MB_SETFOREGROUND
	push	_title
	push	ecx
	push	[main_hwnd]
	call	MMessageBox
    .fin:
	push	0
	push	0
	push	WM_CLOSE
	push	[progress_hwnd]
	call	[SendMessage]
	retn	4

  decompile:
	push	ebx esi edi
	push	path
	call	[lstrlen]
	std
	mov	ecx,eax
	lea	edi,[path+eax-1]
	mov	al,'\'
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
	;=>[ x64 temporarily disabled ]
	cmp	eax,SCS_64BIT_BINARY
	je	.start
	mov	ecx,NO_3264BIT
	jmp	.fin
    .start:
	STATUS	_decompiling
	mov	[_si.cb],sizeof.STARTUPINFO
	push	_pi
	push	_si
	push	0
	push	0
	push	CREATE_SUSPENDED
	push	0
	push	0
	push	0
	push	path
	push	0
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
	push	ecx
	push	eax
	push	dword [esp+8]
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
	push	[_pi.dwProcessId]
	push	_toint
	push	edi
	call	[sprintf]
	add	esp,0Ch
	push	pathdll
	push	inj64
	call	[strcat]
	add	esp,8
	mov	[_si2.cb],sizeof.STARTUPINFO
	push	_pi2
	push	_si2
	push	0
	push	0
	push	0
	push	0
	push	0
	push	0
	push	inj64
	push	0
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
	mov	edi,eax
	push	2
	push	0
	push	edi
	call	[_llseek]
	lea	ebx,[eax+1]
	call	[GetProcessHeap]
	push	ebx
	push	0
	push	eax
	call	[HeapAlloc]
	mov	[au3_code],eax
	mov	esi,eax
	dec	ebx
	mov	byte [esi+ebx],0
	push	0
	push	0
	push	edi
	call	[_llseek]
	push	ebx
	push	esi
	push	edi
	call	[_lread]
	push	ebx
	push	esi
	call	finalize_source
	test	eax,eax
	je	.done
	;=>[ muss hier eigentlich alles überarbeiten, Plugins durchlaufen lassen, Src neuladen, finalizen und neuspeichern ]

	push	0
	push	0
	push	edi
	call	[_llseek]

	push	esi
	call	[lstrlen]
	push	eax
	push	esi
	push	edi
	call	[_lwrite]

	push	edi
	call	[SetEndOfFile]
    .done:
	push	edi
	call	[_lclose]
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
	STATUS	_idling
	xchg	eax,ecx
	pop	edi esi ebx
	retn

proc finalize_source src,len
	mov	eax,1
	ret
endp

proc SettingsAddPlugins plugin,index,hwnd
	mov	eax,[plugin]
	cbadd	[hwnd],[eax+E2APLUGIN.Name]
	ret
endp

proc SettingsProc hwnd,msg,wparam,lparam
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
	mov	eax,[hwnd]
	mov	[settings_hwnd],eax
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
	push	[hwnd]
	call	[GetClientRect]
	push	IDC_SAVE
	push	[hwnd]
	call	[GetDlgItem]
	mov	ecx,[rect.bottom]
	mov	edx,[rect.right]
	sub	ecx,36
	sub	edx,145
	push	SWP_NOSIZE
	push	0
	push	0
	push	ecx
	push	edx
	push	0
	push	eax
	call	[SetWindowPos]
	push	IDCANCEL
	push	[hwnd]
	call	[GetDlgItem]
	mov	ecx,[rect.bottom]
	mov	edx,[rect.right]
	sub	ecx,36
	sub	edx,70
	push	SWP_NOSIZE
	push	0
	push	0
	push	ecx
	push	edx
	push	0
	push	eax
	call	[SetWindowPos]
	push	IDC_TEMPORARILY
	push	[hwnd]
	call	[GetDlgItem]
	mov	ecx,[rect.bottom]
	mov	edx,[rect.left]
	sub	ecx,35
	add	edx,10
	push	SWP_NOSIZE
	push	0
	push	0
	push	ecx
	push	edx
	push	0
	push	eax
	call	[SetWindowPos]
	push	ebx edi
	mov	ebx,[hwnd]
	push	[set.temporarily]
	push	IDC_TEMPORARILY
	push	ebx
	call	[CheckDlgButton]
	push	IDC_FUNCTIONS
	push	ebx
	call	[GetDlgItem]
	xchg	eax,edi
	cbadd	edi,_rename_plugin
	cbadd	edi,_rename_always
	cbadd	edi,_rename_never
	cbsel	edi,[set.rename_funcs]
	push	IDC_GLOBALS
	push	ebx
	call	[GetDlgItem]
	xchg	eax,edi
	cbadd	edi,_rename_plugin
	cbadd	edi,_rename_always
	cbadd	edi,_rename_never
	cbsel	edi,[set.rename_globs]
	push	IDC_LOCALS
	push	ebx
	call	[GetDlgItem]
	xchg	eax,edi
	cbadd	edi,_rename_plugin
	cbadd	edi,_rename_always
	cbadd	edi,_rename_never
	cbsel	edi,[set.rename_locs]
	push	[set.adjust_files]
	push	IDC_FILEINSTALLS
	push	ebx
	call	[CheckDlgButton]
	push	[set.no_@compiled]
	push	IDC_@COMPILED
	push	ebx
	call	[CheckDlgButton]
	push	IDC_PLUGINS
	push	ebx
	call	[GetDlgItem]
	mov	edi,eax
	push	eax
	push	SettingsAddPlugins
	call	PluginManager.Iterate
	cbsel	edi,0
	push	edi
	push	CBN_SELCHANGE shl 16+IDC_PLUGINS
	push	WM_COMMAND
	push	ebx
	call	[SendMessage]
	call	Settings.Exists
	test	eax,eax
	jnz	.skip
	push	IDC_UNINSTALL
	push	ebx
	call	[GetDlgItem]
	push	0
	push	eax
	call	[EnableWindow]
      .skip:
	cmp	[plm.initialized],1
	je	.done
	push	IDC_PLUGINS
	push	ebx
	call	[GetDlgItem]
	push	0
	push	eax
	call	[EnableWindow]
	push	IDC_PLUGIN_ABOUT
	push	ebx
	call	[GetDlgItem]
	push	0
	push	eax
	call	[EnableWindow]
	push	IDC_PLUGIN_SETTINGS
	push	ebx
	call	[GetDlgItem]
	push	0
	push	eax
	call	[EnableWindow]
	push	IDC_PLUGIN_ENABLED
	push	ebx
	call	[GetDlgItem]
	push	0
	push	eax
	call	[EnableWindow]
	pop	edi ebx
	jmp	.done
    .wm_command:
	cmp	[wparam],BN_CLICKED shl 16+IDCANCEL
	je	.wm_close
	cmp	[wparam],BN_CLICKED shl 16+IDOK
	je	.save
	cmp	[wparam],BN_CLICKED shl 16+IDC_SAVE
	je	.save
	cmp	[wparam],CBN_SELCHANGE shl 16+IDC_PLUGINS
	je	.select
	cmp	[wparam],BN_CLICKED shl 16+IDC_PLUGIN_ABOUT
	je	.about
	cmp	[wparam],BN_CLICKED shl 16+IDC_PLUGIN_SETTINGS
	je	.settings
	cmp	[wparam],BN_CLICKED shl 16+IDC_PLUGIN_ENABLED
	je	.enable
	cmp	[wparam],BN_CLICKED shl 16+IDC_UNINSTALL
	jnz	.done
	call	Settings.Delete
	push	0
	call	[ExitProcess]
      .select:
	call	.current_plugin
	test	eax,eax
	je	.done
	mov	ecx,[eax+E2APLUGIN.Settings]
	mov	edx,[eax+E2APLUGIN.Enabled]
	push	ecx
	push	edx
	push	IDC_PLUGIN_ENABLED
	push	[hwnd]
	call	[CheckDlgButton]
	push	IDC_PLUGIN_SETTINGS
	push	[hwnd]
	call	[GetDlgItem]
	pop	edx
	xor	ecx,ecx
	test	edx,edx
	setnz	cl
	push	ecx
	push	eax
	call	[EnableWindow]
	jmp	.done
      .enable:
	call	.current_plugin
	test	eax,eax
	je	.done
	push	eax
	push	IDC_PLUGIN_ENABLED
	push	[hwnd]
	call	[IsDlgButtonChecked]
	pop	edx
	mov	[edx+E2APLUGIN.Enabled],eax
	jmp	.done
      .about:
	call	.current_plugin
	test	eax,eax
	je	.done
	push	eax
	call	[eax+E2APLUGIN.AboutThis]
	pop	edx
	test	eax,eax
	je	.done
	push	MB_OK+MB_ICONINFORMATION
	push	[edx+E2APLUGIN.Name]
	push	eax
	push	[hwnd]
	call	MMessageBox
	jmp	.done
      .settings:
	call	.current_plugin
	test	eax,eax
	je	.done
	call	[eax+E2APLUGIN.Settings]
	jmp	.done
      .current_plugin:
	push	IDC_PLUGINS
	push	[hwnd]
	call	[GetDlgItem]
	cbsel	eax
	push	eax
	call	PluginManager.Get
	retn
      .save:
	push	ebx
	mov	ebx,[hwnd]
	push	IDC_FUNCTIONS
	push	ebx
	call	[GetDlgItem]
	cbsel	eax
	mov	[set.rename_funcs],eax
	push	IDC_GLOBALS
	push	ebx
	call	[GetDlgItem]
	cbsel	eax
	mov	[set.rename_globs],eax
	push	IDC_LOCALS
	push	ebx
	call	[GetDlgItem]
	cbsel	eax
	mov	[set.rename_locs],eax
	push	IDC_FILEINSTALLS
	push	ebx
	call	[IsDlgButtonChecked]
	mov	[set.adjust_files],eax
	push	IDC_@COMPILED
	push	ebx
	call	[IsDlgButtonChecked]
	mov	[set.no_@compiled],eax
	push	IDC_TEMPORARILY
	push	ebx
	call	[IsDlgButtonChecked]
	pop	ebx
	test	eax,eax
	jnz	.wm_close
	call	Settings.Save
    .wm_close:
	mov	[settings_hwnd],0
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
	setcenter [hwnd],[lparam],2
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
	mov	[progress_hwnd],0
	push	0
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc WarningProc hwnd,msg,wparam,lparam
	xor	eax,eax
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	seticon [hwnd],IDI_WARNING
	push	_tahoma
	push	DEFAULT_PITCH+FF_MODERN
	push	DEFAULT_QUALITY
	push	CLIP_DEFAULT_PRECIS
	push	OUT_DEFAULT_PRECIS
	push	ANSI_CHARSET
	push	0
	push	0
	push	0
	push	FW_BOLD
	push	0
	push	0
	push	0
	push	-14
	call	[CreateFont]
	mov	[disclaimer_font],eax
	push	0
	push	eax
	push	WM_SETFONT
	push	IDC_DISCLAIMER
	push	[hwnd]
	call	[SendDlgItemMessage]
	jmp	.done
    .wm_command:
	cmp	[wparam],BN_CLICKED shl 16+IDCANCEL
	je	.wm_close
	cmp	[wparam],BN_CLICKED shl 16+IDOK
	jnz	.done
	push	IDC_DONTSHOW
	push	[hwnd]
	call	[IsDlgButtonChecked]
	cmp	eax,BST_CHECKED
	jnz	.ok
	push	NO_WARNING
	call	Settings.DontShowAgain
      .ok:
	mov	eax,1
    .wm_close:
	push	eax
	push	[disclaimer_font]
	call	[DeleteObject]
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc ArmaNoteProc hwnd,msg,wparam,lparam
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	seticon [hwnd],IDI_WARNING
	setcenter [hwnd],[lparam]
	jmp	.done
    .wm_command:
	xor	eax,eax
	cmp	[wparam],BN_CLICKED shl 16+IDCANCEL
	je	.wm_close
	cmp	[wparam],BN_CLICKED shl 16+IDYES
	jnz	.done
	push	IDC_DONTSHOW
	push	[hwnd]
	call	[IsDlgButtonChecked]
	cmp	eax,BST_CHECKED
	jnz	.ok
	push	NO_ARMANOTE
	call	Settings.DontShowAgain
      .ok:
	mov	eax,1
    .wm_close:
	push	eax
	push	[hwnd]
	call	[EndDialog]
    .done:
	mov	eax,1
    .fin:
	ret
endp

proc HelpProc hwnd,msg,wparam,lparam
  local rect:RECT,ps:PAINTSTRUCT
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_CTLCOLORDLG
	je	.wm_ctlcolordlg
	cmp	[msg],WM_CTLCOLORSTATIC
	je	.wm_ctlcolorstatic
	cmp	[msg],WM_PAINT
	je	.wm_paint
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
	push	ebx
	seticon [hwnd],IDI_MAIN
	lea	eax,[rect]
	push	eax
	push	[hwnd]
	call	[GetClientRect]
	push	IDCANCEL
	push	[hwnd]
	call	[GetDlgItem]
	mov	ecx,[rect.bottom]
	mov	edx,[rect.right]
	sub	ecx,38
	sub	edx,98
	push	SWP_NOSIZE
	push	0
	push	0
	push	ecx
	push	edx
	push	0
	push	eax
	call	[SetWindowPos]
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
	mov	[help_font],eax
	push	0
	push	eax
	push	WM_SETFONT
	push	IDC_HELPTEXT
	push	[hwnd]
	call	[GetDlgItem]
	mov	ebx,eax
	push	eax
	call	[SendMessage]
	push	_help_exe2aut
	push	ebx
	call	[SetWindowText]
	push	ebx
	call	[SetFocus]
	pop	ebx
	xor	eax,eax
	jmp	.fin
    .wm_ctlcolordlg:
	push	WHITE_BRUSH
	call	[GetStockObject]
	jmp	.fin
    .wm_ctlcolorstatic:
	push	WHITE_BRUSH
	call	[GetStockObject]
	jmp	.fin
    .wm_paint:
	lea	eax,[ps]
	push	eax
	push	[hwnd]
	call	[BeginPaint]
	lea	eax,[rect]
	push	eax
	push	[hwnd]
	call	[GetClientRect]
	mov	eax,[rect.bottom]
	sub	eax,50
	mov	[rect.top],eax
	push	COLOR_BTNFACE
	call	[GetSysColorBrush]
	lea	edx,[rect]
	push	eax
	push	edx
	push	[ps.hdc]
	call	[FillRect]
	lea	eax,[ps]
	push	eax
	push	[hwnd]
	call	[EndPaint]
	jmp	.done
    .wm_command:
	cmp	[wparam],BN_CLICKED shl 16+IDCANCEL
	jnz	.done
    .wm_close:
	push	[help_font]
	call	[DeleteObject]
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
	seticon [hwnd],IDI_UNHAPPY
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
	mov	[crash_font],eax
	push	0
	push	eax
	push	WM_SETFONT
	push	IDC_CRASH
	push	[hwnd]
	call	[SendDlgItemMessage]
	mov	edi,[lparam]
	mov	edi,[edi+EXCEPTION_POINTERS.ContextRecord]
	push	[edi+CONTEXT.Eip]
	call	get_alloc_base
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
	call	[sprintf]
	add	esp,4*15
	push	IDC_CRASH
	push	[hwnd]
	call	[GetDlgItem]
	lea	edx,[buf]
	push	eax
	push	edx
	push	eax
	call	[SetWindowText]
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
	cmp	[wparam],BN_CLICKED shl 16+IDCANCEL
	je	.wm_close
	cmp	[wparam],EN_SETFOCUS shl 16+IDC_CRASH
	jnz	.done
	push	IDC_CRASH
	push	[hwnd]
	call	[GetDlgItem]
	push	eax
	call	[HideCaret]
	jmp	.done
    .wm_close:
	push	[crash_font]
	call	[DeleteObject]
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
	cmp	[settings_hwnd],0
	je	.no_settings_hwnd
	push	0
	push	0
	push	WM_CLOSE
	push	[settings_hwnd]
	call	[SendMessage]
    .no_settings_hwnd:
	cmp	[main_hwnd],0
	je	.no_main_hwnd
	push	SW_HIDE
	push	[main_hwnd]
	call	[ShowWindow]
    .no_main_hwnd:
	push	[ExceptionInfo]
	push	CrashProc
	push	0
	push	IDD_CRASH
	push	[hinstance]
	call	[DialogBoxParam]
	mov	eax,1
	ret
endp

set_status:
	pushad
	push	dword [esp+4*9]
	push	state
	call	[strcpy]
	add	esp,8
	popad
	retn	4

	include '../x86/misc.inc'
	include 'PluginManager.inc'
	include 'Settings.inc'
	include '../../lib/uFMOD/ufmod.inc'

section '.data' data readable writeable

  VERSION      equ 'Exe2Autv8beta'
  VERSION_NUM  equ '8'
  WINDOW_TITLE equ 'Exe2Aut - AutoIt3 Decompiler'

  _help_exe2aut db 'Exe2Aut.exe [-nogui] [-quiet] [-nofiles] [...] filename',13,10,13,10
		db '  -nogui          launch without gui, try to decompile, report back and close afterwards',13,10
		db '  -quiet          don''t show any messages (for "-nogui"), a nonzero exit-code indicates success',13,10
		db '  -nofiles        don''t extract files embedded via FileInstall',13,10,13,10
		db '  -noadjustfiles  FileInstall-paths won''t get adjusted',13,10
		db '  -no@compiled    replace @Compiled with "1"',13,10,13,10
		db '  -noplugins      don''t load any plugins',13,10
		db '  -nosettings     don''t load previously saved settings',13,10,13,10
		db '  -uninstall      delete registry-keys and exit',13,10,13,10
		db '  filename        optional if -nogui isn''t specified',13,10,13,10,0

  _about_exe2aut db 'Exe2Aut - Tiny AutoIt3 Decompiler',13,10,'v',VERSION_NUM,13,10
		 db 'web: http://exe2aut.com/',13,10,13,10
		 db 'Greetz to ~',13,10,'scbiz, terrornerd,',13,10,'fasm community,',13,10,'cw2k & others.',13,10,13,10
		 db '3rd party libs ~',13,10,' • uFMOD',13,10,13,10
		 db 'Chiptune ~',13,10
		 db 'Linda''s street by cerror',0

  _courier db 'Courier New',0
  _tahoma db 'Tahoma',0
  _output db 'Apparently, it didn''t work..',0 ;Couldn't be identified as an AutoIt3 Exe!
  _failed db 'Something went wrong..',0 ;Injection failed!
  _title db 'Exe2Aut',0
  _wtitle du 'Exe2Aut',0
  _3264bit db 'Only 32/64bit PE files are supported!',0
  _error db 'Either it''s not a PE file or it''s corrupted!',0	;CreateProcess failed!
  _nopath db 'No file specified!',0
  _notfound db 'File not found!',0
  _done db 'Done.',0
  _mutex db VERSION,0
  _already db 'I''m already running!',0
  _window db WINDOW_TITLE,0
  _header db '- Exe2Aut Parameters -',0
  _armadillo db 'Armadillo''s Debug-Blocker',0
  _nofiles db 'Don''t Extract FileInstalls',0
  _settings db 'Settings',0
  _about db 'About',0
  _armamutex db VERSION,':Armadillo',0
  _nofimutex db VERSION,':NoFileInstall',0
  _armaswitch du '-armadillo',0
  _nofiswitch du '-nofiles',0
  _nogui du '-nogui',0
  _quiet du '-quiet',0
  _noadjustfiles du '-noadjustfiles',0
  _no@compiled du '-no@compiled',0
  _noplugins du '-noplugins',0
  _nosettings du '-nosettings',0
  _uninstall du '-uninstall',0
  _help1 du '-help',0
  _help2 du '-h',0
  _help3 du '-?',0

  _@compiled db '@Compiled',0
  _rename_plugin db 'If a plug-in says so',0
  _rename_always db 'Always rename them',0
  _rename_never db 'Never rename them',0

  ;=>[ _STATUS überarbeiten]
  _startup db 'startup',0
  _idling db 'idling',0
  _decompiling db 'decompiling',0
  _deobfuscating db 'deobfuscating',0
  _plugins db 'plugins',0
  ;;;;

  _compiled_macro du '» @Compiled « was found at least once!'
		  du 13,10,'You should probably look into that.',0

  _crash db 'I''m sorry to tell you that Exe2Aut has crashed :(',13,10
	 db '(',VERSION,' [%s],')',13,10,13,10
	 db 'EAX = %08Xh  ECX = %08Xh  EDX = %08Xh',13,10
	 db 'EBX = %08Xh  ESP = %08Xh  EBP = %08Xh',13,10
	 db 'ESI = %08Xh  EDI = %08Xh  EIP = %08Xh',13,10
	 db 'Flags:%08Xh%s(%s)',0

  _toint db '%d',0

  ebt EDITBALLOONTIP sizeof.EDITBALLOONTIP,_wtitle,_compiled_macro,TTI_INFO

  misc_idata
  plman_idata
  sets_idata
  ufmod_idata

  hinstance rd 1
  main_hwnd rd 1
  settings_hwnd rd 1
  progress_hwnd rd 1
  main_font rd 1
  disclaimer_font rd 1
  help_font rd 1
  crash_font rd 1
  hi2u rd 1

  argv rd 1
  argc rd 1
  state rb 10h

  armamutex rd 1
  nofimutex rd 1
  no_gui rd 1
  be_quiet rd 1
  no_plugins rd 1
  no_settings rd 1

  au3_code rd 1
  path rb 256
  pathdll rb 256
  inj64 rb 256

  _pi PROCESS_INFORMATION
  _pi2 PROCESS_INFORMATION
  _si STARTUPINFO
  _si2 STARTUPINFO

  mp MSGBOXPARAMS

  misc_udata
  plman_udata
  sets_udata
  ufmod_udata

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  gdi32,'GDI32.DLL',\
	  advapi32,'ADVAPI32.DLL',\
	  shell32,'SHELL32.DLL',\
	  msvcrt,'MSVCRT.DLL',\
	  shlwapi,'SHLWAPI.DLL',\
	  winmm,'WINMM.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\gdi32.inc'
  include 'api\advapi32.inc'

  import shell32,\
	 CommandLineToArgvW,'CommandLineToArgvW',\
	 DragFinish,'DragFinish',\
	 DragQueryFile,'DragQueryFileA'

  import msvcrt,\
	 qsort,'qsort',\
	 sprintf,'sprintf',\
	 strcasecmp,'_stricmp',\
	 strcat,'strcat',\
	 strcpy,'strcpy',\
	 strlen,'strlen',\
	 strstr,'strstr',\
	 toupper,'toupper'

  import shlwapi,\
	 PathStripPath,'PathStripPathA',\
	 SHDeleteKey,'SHDeleteKeyA'

  import winmm,\
	 waveOutClose,'waveOutClose',\
	 waveOutGetPosition,'waveOutGetPosition',\
	 waveOutOpen,'waveOutOpen',\
	 waveOutPrepareHeader,'waveOutPrepareHeader',\
	 waveOutReset,'waveOutReset',\
	 waveOutUnprepareHeader,'waveOutUnprepareHeader',\
	 waveOutWrite,'waveOutWrite'

section '.edata' export data readable

  export 'Exe2Aut.EXE',\
	 argv,'E2A_ArgV',\
	 argc,'E2A_ArgC'

section '.rsrc' resource data readable

  RES_PATH	      equ '../../res/'
  RES_PATH_BEGIN      fix match RES_PATH,RES_PATH {
  RES_PATH_END	      fix } restore RES_PATH

  HI2U_ICONS_BEGIN    fix match HI2U_ICONS,HI2U_ICONS {
  HI2U_ICONS_END      fix } rept HI2U_COUNT { restore HI2U_ICONS }
  HI2U_GROUP_BEGIN    fix match HI2U_GROUP,HI2U_GROUP {
  HI2U_GROUP_END      fix } rept HI2U_COUNT { restore HI2U_GROUP }

  HI2U_COUNT	      equ 44

  IDI_MAIN	      = 1
  IDI_HAPPY	      = 2
  IDI_UNHAPPY	      = 3
  IDI_WARNING	      = 4
  IDI_ABOUT	      = 5
  IDI_HI2U	      = 6
  IDI_HI2U_END	      = IDI_HI2U+HI2U_COUNT

  IDR_DLL	      = 51
  IDR_DLL64	      = 52
  IDR_INJ64	      = 53

  IDD_MAIN	      = 100
  IDD_SETTINGS	      = 101
  IDD_PROGRESS	      = 102
  IDD_WARNING	      = 103
  IDD_ARMANOTE	      = 104
  IDD_HELP	      = 105
  IDD_CRASH	      = 106

  IDC_RESULT	      = 1000
  IDC_PROGRESS	      = 1000
  IDC_HELPTEXT	      = 1000
  IDC_CRASH	      = 1000

  IDC_SAVE	      = 1000
  IDC_TEMPORARILY     = 1001
  IDC_PLUGINS	      = 1002
  IDC_PLUGIN_ABOUT    = 1003
  IDC_PLUGIN_SETTINGS = 1004
  IDC_PLUGIN_ENABLED  = 1005
  IDC_FUNCTIONS       = 1006
  IDC_GLOBALS	      = 1007
  IDC_LOCALS	      = 1008
  IDC_FILEINSTALLS    = 1009
  IDC_@COMPILED       = 1010
  IDC_UNINSTALL       = 1011

  IDC_DISCLAIMER      = 1000
  IDC_DONTSHOW	      = 1001

  IDM_ARMDBGBL	      = 2000
  IDM_NOFILES	      = 2001
  IDM_SETTINGS	      = 2002
  IDM_ABOUT	      = 2003

  directory RT_ICON,icons,\
	    RT_GROUP_ICON,group_icons,\
	    RT_DIALOG,dialogs,\
	    RT_MANIFEST,manifests,\
	    RT_VERSION,versions

  HI2U_ICONS equ
  rept HI2U_COUNT i:7,n
   { match any,HI2U_ICONS \{ HI2U_ICONS equ HI2U_ICONS,i,LANG_ENGLISH+SUBLANG_DEFAULT,hi2u_data#n \}
     match ,HI2U_ICONS \{ HI2U_ICONS equ i,LANG_ENGLISH+SUBLANG_DEFAULT,hi2u_data#n \} }

  HI2U_ICONS_BEGIN
  resource icons,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data1,\
	   2,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data2,\
	   3,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data3,\
	   4,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data4,\
	   5,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data5,\
	   6,LANG_ENGLISH+SUBLANG_DEFAULT,icon_data6,\
	   HI2U_ICONS,\
	   IDR_DLL,LANG_ENGLISH+SUBLANG_DEFAULT,exe2autdll,\
	   IDR_DLL64,LANG_ENGLISH+SUBLANG_DEFAULT,exe2autdll64,\
	   IDR_INJ64,LANG_ENGLISH+SUBLANG_DEFAULT,injectdll64
  HI2U_ICONS_END

  HI2U_GROUP equ
  rept HI2U_COUNT i:0,n
   { match any,HI2U_GROUP \{ HI2U_GROUP equ HI2U_GROUP,IDI_HI2U+i,LANG_ENGLISH+SUBLANG_DEFAULT,hi2u_icon#n \}
     match ,HI2U_GROUP \{ HI2U_GROUP equ IDI_HI2U+i,LANG_ENGLISH+SUBLANG_DEFAULT,hi2u_icon#n \} }

  HI2U_GROUP_BEGIN
  resource group_icons,\
	   IDI_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,main_icon,\
	   IDI_LAUGHING,LANG_ENGLISH+SUBLANG_DEFAULT,laughing_icon,\
	   IDI_NEUTRAL,LANG_ENGLISH+SUBLANG_DEFAULT,neutral_icon,\
	   IDI_WARNING,LANG_ENGLISH+SUBLANG_DEFAULT,warn_icon,\
	   IDI_ABOUT,LANG_ENGLISH+SUBLANG_DEFAULT,about_icon,\
	   HI2U_GROUP
  HI2U_GROUP_END

  resource dialogs,\
	   IDD_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,main_dialog,\
	   IDD_SETTINGS,LANG_ENGLISH+SUBLANG_DEFAULT,settings_dialog,\
	   IDD_PROGRESS,LANG_ENGLISH+SUBLANG_DEFAULT,progress_dialog,\
	   IDD_WARNING,LANG_ENGLISH+SUBLANG_DEFAULT,warning_dialog,\
	   IDD_ARMANOTE,LANG_ENGLISH+SUBLANG_DEFAULT,armanote_dialog,\
	   IDD_HELP,LANG_ENGLISH+SUBLANG_DEFAULT,help_dialog,\
	   IDD_CRASH,LANG_ENGLISH+SUBLANG_DEFAULT,crash_dialog

  resource manifests,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,manifest

  resource versions,\
	   1,LANG_ENGLISH+SUBLANG_DEFAULT,version

  RES_PATH_BEGIN

  icon main_icon,icon_data1,RES_PATH#'icon.ico',\
		 icon_data2,RES_PATH#'icon2.ico'
  icon laughing_icon,icon_data3,RES_PATH#'icon3.ico'
  icon neutral_icon,icon_data4,RES_PATH#'icon4.ico'
  icon warn_icon,icon_data5,RES_PATH#'icon5.ico'
  icon about_icon,icon_data6,RES_PATH#'icon6.ico'
  rept HI2U_COUNT n
  \{ icon hi2u_icon\#n,hi2u_data\#n,RES_PATH#'hi2u/'\#\`n\#'.ico' \}

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

  chiptune file RES_PATH#'Linda''s street.xm'
  sizeof.chiptune = $-chiptune

  RES_PATH_END

  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,\
		      LANG_ENGLISH+SUBLANG_DEFAULT,0,\
	      'ProductName','Exe2Aut',\
	      'FileDescription','Tiny AutoIt3 Decompiler',\
	      'FileVersion',VERSION_NUM,\
	      'ProductVersion',<'v',VERSION_NUM>

  dialog main_dialog,WINDOW_TITLE,0,0,380,310,WS_OVERLAPPEDWINDOW+DS_CENTER,WS_EX_ACCEPTFILES,,'MS Shell Dlg',8
    dialogitem 'edit','',IDC_RESULT,0,0,0,0,WS_VISIBLE+ES_MULTILINE+WS_HSCROLL+WS_VSCROLL+ES_READONLY
  enddialog

  dialog settings_dialog,'',0,0,180,110,WS_POPUPWINDOW,,,'MS Shell Dlg',8
    dialogitem 'button','Plug-ins',-1,6,3,183,30,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'combobox','',IDC_PLUGINS,12,14,100,64,WS_VISIBLE+CBS_DROPDOWNLIST+CBS_NOINTEGRALHEIGHT
    dialogitem 'button','?',IDC_PLUGIN_ABOUT,12+101,14,10,13,WS_VISIBLE
    dialogitem 'button','Settings',IDC_PLUGIN_SETTINGS,12+101+11,14,36,13,WS_VISIBLE
    dialogitem 'button','',IDC_PLUGIN_ENABLED,12+117+10+36,15,12,12,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'button','Post-Processing',-1,6,3+36,183,85,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'static','Rename Functions',-1,12,14+38+14*0,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+82,14+38+14*0,6,12,WS_VISIBLE
    dialogitem 'combobox','',IDC_FUNCTIONS,102,12+38+14*0,82,64,WS_VISIBLE+CBS_DROPDOWNLIST+CBS_NOINTEGRALHEIGHT
    dialogitem 'static','Rename Globals',-1,12,14+38+14*1,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+82,14+38+14*1,6,12,WS_VISIBLE
    dialogitem 'combobox','',IDC_GLOBALS,102,12+38+14*1,82,64,WS_VISIBLE+CBS_DROPDOWNLIST+CBS_NOINTEGRALHEIGHT
    dialogitem 'static','Rename Locals',-1,12,14+38+14*2,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+82,14+38+14*2,6,12,WS_VISIBLE
    dialogitem 'combobox','',IDC_LOCALS,102,12+38+14*2,82,64,WS_VISIBLE+CBS_DROPDOWNLIST+CBS_NOINTEGRALHEIGHT
    dialogitem 'static','Adjust FileInstall-Paths',-1,12,14+38+14*3,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+82,14+38+14*3,6,12,WS_VISIBLE
    dialogitem 'button','',IDC_FILEINSTALLS,102,13+38+14*3,12,12,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'static','Replace @Compiled',-1,12,14+38+14*4,82,12,WS_VISIBLE
    dialogitem 'static',':',-1,12+82,14+38+14*4,6,12,WS_VISIBLE
    dialogitem 'button','',IDC_@COMPILED,102,13+38+14*4,12,12,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'button','General',-1,6,3+36+91,183,31,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'button','Delete Registry-keys && exit',IDC_UNINSTALL,12,11+38+93,172,12,WS_VISIBLE
    dialogitem 'button','Only save temporarily',IDC_TEMPORARILY,0,0,80,16,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX
    dialogitem 'button','Save',IDC_SAVE,0,0,40,16,WS_VISIBLE,WS_EX_STATICEDGE
    dialogitem 'button','Cancel',IDCANCEL,0,0,40,16,WS_VISIBLE,WS_EX_STATICEDGE
  enddialog

  dialog progress_dialog,'',0,0,102,17,WS_BORDER+WS_POPUP,,,'MS Shell Dlg',8
    dialogitem 'msctls_progress32','',IDC_PROGRESS,1,1,99,15,WS_VISIBLE+PBS_MARQUEE
  enddialog

  dialog warning_dialog,WINDOW_TITLE,0,0,316,66,WS_POPUP+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+DS_CENTER,WS_EX_APPWINDOW,,'MS Shell Dlg',8
    dialogitem 'static','',-1,111,6,5,5,WS_VISIBLE,WS_EX_CLIENTEDGE
    dialogitem 'static','',-1,189,6,5,5,WS_VISIBLE,WS_EX_CLIENTEDGE
    dialogitem 'static','',-1,6,16,304,1,WS_VISIBLE+SS_SUNKEN
    dialogitem 'static','',-1,6,41,304,1,WS_VISIBLE+SS_SUNKEN
    dialogitem 'static','DISCLAIMER',IDC_DISCLAIMER,122,3,62,10,WS_VISIBLE
    dialogitem 'static','Dropping modified or non-AutoIt files into Exe2Aut could result in harmful code being executed, so use it with caution. I do not take any responsibility!',-1,10,20,296,16,WS_VISIBLE
    dialogitem 'button','Don''t show again',IDC_DONTSHOW,6,46,74,20,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX,
    dialogitem 'button','OK',IDOK,270,46,40,16,WS_VISIBLE,WS_EX_STATICEDGE
  enddialog

  dialog armanote_dialog,'See the ReadMe first!',0,0,306,46,WS_POPUP+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+DS_CENTER,WS_EX_APPWINDOW,,'MS Shell Dlg',8
    dialogitem 'static','This mode is for targets which spawn a new process for the actual AutoIt script like Armadillo''s Debug-Blocker. Continue && activate it?',-1,5,5,296,16,WS_VISIBLE
    dialogitem 'button','Don''t show again',IDC_DONTSHOW,6,26,74,20,WS_VISIBLE+BS_FLAT+BS_AUTOCHECKBOX,
    dialogitem 'button','Yes',IDYES,210,26,40,16,WS_VISIBLE,WS_EX_STATICEDGE
    dialogitem 'button','Cancel',IDCANCEL,260,26,40,16,WS_VISIBLE+BS_DEFPUSHBUTTON,WS_EX_STATICEDGE
  enddialog

  dialog help_dialog,WINDOW_TITLE,0,0,430,151,WS_POPUP+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+DS_CENTER,,,'Tahoma',10
    dialogitem 'static','',IDC_HELPTEXT,38,10,430-38,110,WS_VISIBLE
    dialogitem 'static',IDI_MAIN,-1,15,10,0,0,WS_VISIBLE+SS_ICON
    dialogitem 'button','OK',IDCANCEL,0,0,50,13,WS_VISIBLE+BS_DEFPUSHBUTTON
  enddialog

  dialog crash_dialog,WINDOW_TITLE,0,0,230,80,WS_POPUP+WS_CAPTION+WS_MINIMIZEBOX+DS_CENTER,,,'MS Shell Dlg',8
    dialogitem 'edit','',IDC_CRASH,0,0,230,62,WS_VISIBLE+ES_MULTILINE+ES_READONLY+WS_TABSTOP
    dialogitem 'button','Exit',IDCANCEL,95,66,40,12,WS_VISIBLE+BS_DEFPUSHBUTTON+WS_TABSTOP
  enddialog
