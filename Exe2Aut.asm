
format PE GUI 4.0
entry start

include 'win32a.inc'

section '.code' code readable executable

  start:
	push	0
	call	[GetModuleHandle]
	push	0
	push	DialogProc
	push	0
	push	IDD_MAIN
	push	eax
	call	[DialogBoxParam]
	push	0
	call	[ExitProcess]

proc DialogProc hwnd,msg,wparam,lparam
	cmp	[msg],WM_INITDIALOG
	je	.wm_initdialog
	cmp	[msg],WM_COMMAND
	je	.wm_command
	cmp	[msg],WM_SIZE
	je	.wm_size
	cmp	[msg],WM_CTLCOLORSTATIC
	je	.wm_ctlcolorstatic
	cmp	[msg],WM_DROPFILES
	je	.wm_dropfiles
	cmp	[msg],WM_CLOSE
	je	.wm_close
	xor	eax,eax
	jmp	.fin
    .wm_initdialog:
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
	push	FF_SCRIPT
	push	DEFAULT_QUALITY
	push	CLIP_DEFAULT_PRECIS
	push	OUT_DEFAULT_PRECIS
	push	OEM_CHARSET
	push	0
	push	0
	push	0
	push	FW_NORMAL
	push	0
	push	0
	push	0
	push	14
	call	[CreateFont]
	mov	[font],eax
	jmp	.done
    .wm_command:
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
    .wm_ctlcolorstatic:
	push	[font]
	push	[wparam]
	call	[SelectObject]
	xor	eax,eax
	jmp	.fin
    .wm_dropfiles:
	push	256
	push	path
	push	0
	push	[wparam]
	call	[DragQueryFile]
	push	eax
	push	[wparam]
	call	[DragFinish]
	pop	edx
	push	edi
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
	pop	edi
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
	test	eax,eax
	je	.err
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
	je	.failed
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
	repnz	scasb
	cld
	mov	al,'.'
	neg	ecx
	repnz	scasb
	mov	eax,edi
	jnz	.file
	dec	eax
    .file:
	mov	dword [eax],'_.au'
	mov	word [eax+4],'3'
	push	OF_READ
	push	path
	call	[_lopen]
	mov	edx,_output
	test	eax,eax
	js	.output
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
	push	edi
	push	IDC_RESULT
	push	[hwnd]
	call	[SetDlgItemText]
	call	[GetProcessHeap]
	push	edi
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
	jmp	.done
      .failed:
	push	0
	push	[_pi.hProcess]
	call	[TerminateProcess]
	push	[_pi.hProcess]
	call	[CloseHandle]
	push	[_pi.hThread]
	call	[CloseHandle]
	mov	edx,_failed
      .output:
	push	edx
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
	push	MB_OK+MB_ICONINFORMATION
	push	_title
	push	_error
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
	push	2000
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

  _courier db 'Courier New',0
  _output db 'Apparently, it didn''t work..',0
  _failed db 'Something went wrong..',0
  _title db 'Exe2Aut',0
  _error db 'Either it''s not a PE file or it''s corrupted!',0

  path rb 256
  pathdll rb 256

  _pi PROCESS_INFORMATION
  _si STARTUPINFO

  font rd 1

section '.idata' import data readable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  shell32,'SHELL32.DLL',\
	  gdi32,'GDI32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'

  import shell32,\
	 DragFinish,'DragFinish',\
	 DragQueryFile,'DragQueryFileA'

  import gdi32,\
	 CreateFont,'CreateFontA',\
	 SelectObject,'SelectObject'

section '.rsrc' resource data readable

  IDI_ICON1  = 1
  IDI_ICON2  = 2
  IDR_DLL    = 4
  IDD_MAIN   = 100
  IDC_RESULT = 101

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

  dialog main_dialog,'Exe2Aut (AutoIt v3.3.6.1)',0,0,380,310,WS_OVERLAPPEDWINDOW+DS_CENTER,WS_EX_ACCEPTFILES
    dialogitem 'edit','',IDC_RESULT,0,0,0,0,WS_VISIBLE+ES_MULTILINE+WS_HSCROLL+WS_VSCROLL+ES_READONLY
  enddialog
