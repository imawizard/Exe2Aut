
_funcs dd    _FA,\
	     _FB,\
	     _FC,\
	     _FD,\
	     _FE,\
	     _FF,\
	     _FG,\
	     _FH,\
	     _FI,\
	       0,\
	       0,\
	     _FL,\
	     _FM,\
	     _FN,\
	     _FO,\
	     _FP,\
	       0,\
	     _FR,\
	     _FS,\
	     _FT,\
	     _FU,\
	     _FV,\
	     _FW,\
	       0,\
	       0,\
	       0

_macros dd   _MA,\
	       0,\
	     _MC,\
	     _MD,\
	     _ME,\
	     _MF,\
	     _MG,\
	     _MH,\
	     _MI,\
	       0,\
	     _MK,\
	     _ML,\
	     _MM,\
	     _MN,\
	     _MO,\
	     _MP,\
	       0,\
	       0,\
	     _MS,\
	     _MT,\
	     _MU,\
	       0,\
	     _MW,\
	       0,\
	     _MY,\
	       0

_keywords dd _KA,\
	     _KB,\
	     _KC,\
	     _KD,\
	     _KE,\
	     _KF,\
	     _KG,\
	       0,\
	     _KI,\
	       0,\
	       0,\
	     _KL,\
	       0,\
	     _KN,\
	     _KO,\
	       0,\
	       0,\
	     _KR,\
	     _KS,\
	     _KT,\
	     _KU,\
	       0,\
	     _KW,\
	       0,\
	       0,\
	       0

_FA db 'Abs',0,\
       'ACos',0,\
       'AdlibRegister',0,\
       'AdlibUnRegister',0,\
       'Asc',0,\
       'AscW',0,\
       'ASin',0,\
       'Assign',0,\
       'ATan',0,\
       'AutoItSetOption',0,\
       'AutoItWinGetTitle',0,\
       'AutoItWinSetTitle',0,0
_FB db 'Beep',0,\
       'Binary',0,\
       'BinaryLen',0,\
       'BinaryMid',0,\
       'BinaryToString',0,\
       'BitAND',0,\
       'BitNOT',0,\
       'BitOR',0,\
       'BitRotate',0,\
       'BitShift',0,\
       'BitXOR',0,\
       'BlockInput',0,\
       'Break',0,0
_FC db 'Call',0,\
       'CDTray',0,\
       'Ceiling',0,\
       'Chr',0,\
       'ChrW',0,\
       'ClipGet',0,\
       'ClipPut',0,\
       'ConsoleRead',0,\
       'ConsoleWrite',0,\
       'ConsoleWriteError',0,\
       'ControlClick',0,\
       'ControlCommand',0,\
       'ControlDisable',0,\
       'ControlEnable',0,\
       'ControlFocus',0,\
       'ControlGetFocus',0,\
       'ControlGetHandle',0,\
       'ControlGetPos',0,\
       'ControlGetText',0,\
       'ControlHide',0,\
       'ControlListView',0,\
       'ControlMove',0,\
       'ControlSend',0,\
       'ControlSetText',0,\
       'ControlShow',0,\
       'ControlTreeView',0,\
       'Cos',0,0
_FD db 'Dec',0,\
       'DirCopy',0,\
       'DirCreate',0,\
       'DirGetSize',0,\
       'DirMove',0,\
       'DirRemove',0,\
       'DllCall',0,\
       'DllCallbackFree',0,\
       'DllCallbackGetPtr',0,\
       'DllCallbackRegister',0,\
       'DllClose',0,\
       'DllOpen',0,\
       'DllStructCreate',0,\
       'DllStructGetData',0,\
       'DllStructGetPtr',0,\
       'DllStructGetSize',0,\
       'DllStructSetData',0,\
       'DriveGetDrive',0,\
       'DriveGetFileSystem',0,\
       'DriveGetLabel',0,\
       'DriveGetSerial',0,\
       'DriveGetType',0,\
       'DriveMapAdd',0,\
       'DriveMapDel',0,\
       'DriveMapGet',0,\
       'DriveSetLabel',0,\
       'DriveSpaceFree',0,\
       'DriveSpaceTotal',0,\
       'DriveStatus',0,0
_FE db 'EnvGet',0,\
       'EnvSet',0,\
       'EnvUpdate',0,\
       'Eval',0,\
       'Execute',0,\
       'Exp',0,0
_FF db 'FileChangeDir',0,\
       'FileClose',0,\
       'FileCopy',0,\
       'FileCreateNTFSLink',0,\
       'FileCreateShortcut',0,\
       'FileDelete',0,\
       'FileExists',0,\
       'FileFindFirstFile',0,\
       'FileFindNextFile',0,\
       'FileFlush',0,\
       'FileGetAttrib',0,\
       'FileGetEncoding',0,\
       'FileGetLongName',0,\
       'FileGetPos',0,\
       'FileGetShortcut',0,\
       'FileGetShortName',0,\
       'FileGetSize',0,\
       'FileGetTime',0,\
       'FileGetVersion',0
_FileInstall db \
       'FileInstall',0,\
       'FileMove',0,\
       'FileOpen',0,\
       'FileOpenDialog',0,\
       'FileRead',0,\
       'FileReadLine',0,\
       'FileRecycle',0,\
       'FileRecycleEmpty',0,\
       'FileSaveDialog',0,\
       'FileSelectFolder',0,\
       'FileSetAttrib',0,\
       'FileSetPos',0,\
       'FileSetTime',0,\
       'FileWrite',0,\
       'FileWriteLine',0,\
       'Floor',0,\
       'FtpSetProxy',0,0
_FG db 'GUICreate',0,\
       'GUICtrlCreateAvi',0,\
       'GUICtrlCreateButton',0,\
       'GUICtrlCreateCheckbox',0,\
       'GUICtrlCreateCombo',0,\
       'GUICtrlCreateContextMenu',0,\
       'GUICtrlCreateDate',0,\
       'GUICtrlCreateDummy',0,\
       'GUICtrlCreateEdit',0,\
       'GUICtrlCreateGraphic',0,\
       'GUICtrlCreateGroup',0,\
       'GUICtrlCreateIcon',0,\
       'GUICtrlCreateInput',0,\
       'GUICtrlCreateLabel',0,\
       'GUICtrlCreateList',0,\
       'GUICtrlCreateListView',0,\
       'GUICtrlCreateListViewItem',0,\
       'GUICtrlCreateMenu',0,\
       'GUICtrlCreateMenuItem',0,\
       'GUICtrlCreateMonthCal',0,\
       'GUICtrlCreateObj',0,\
       'GUICtrlCreatePic',0,\
       'GUICtrlCreateProgress',0,\
       'GUICtrlCreateRadio',0,\
       'GUICtrlCreateSlider',0,\
       'GUICtrlCreateTab',0,\
       'GUICtrlCreateTabItem',0,\
       'GUICtrlCreateTreeView',0,\
       'GUICtrlCreateTreeViewItem',0,\
       'GUICtrlCreateUpdown',0,\
       'GUICtrlDelete',0,\
       'GUICtrlGetHandle',0,\
       'GUICtrlGetState',0,\
       'GUICtrlRead',0,\
       'GUICtrlRecvMsg',0,\
       'GUICtrlRegisterListViewSort',0,\
       'GUICtrlSendMsg',0,\
       'GUICtrlSendToDummy',0,\
       'GUICtrlSetBkColor',0,\
       'GUICtrlSetColor',0,\
       'GUICtrlSetCursor',0,\
       'GUICtrlSetData',0,\
       'GUICtrlSetDefBkColor',0,\
       'GUICtrlSetDefColor',0,\
       'GUICtrlSetFont',0,\
       'GUICtrlSetGraphic',0,\
       'GUICtrlSetImage',0,\
       'GUICtrlSetLimit',0,\
       'GUICtrlSetOnEvent',0,\
       'GUICtrlSetPos',0,\
       'GUICtrlSetResizing',0,\
       'GUICtrlSetState',0,\
       'GUICtrlSetStyle',0,\
       'GUICtrlSetTip',0,\
       'GUIDelete',0,\
       'GUIGetCursorInfo',0,\
       'GUIGetMsg',0,\
       'GUIGetStyle',0,\
       'GUIRegisterMsg',0,\
       'GUISetAccelerators',0,\
       'GUISetBkColor',0,\
       'GUISetCoord',0,\
       'GUISetCursor',0,\
       'GUISetFont',0,\
       'GUISetHelp',0,\
       'GUISetIcon',0,\
       'GUISetOnEvent',0,\
       'GUISetState',0,\
       'GUISetStyle',0,\
       'GUIStartGroup',0,\
       'GUISwitch',0,0
_FH db 'Hex',0,\
       'HotKeySet',0,\
       'HttpSetProxy',0,\
       'HttpSetUserAgent',0,\
       'HWnd',0,0
_FI db 'InetClose',0,\
       'InetGet',0,\
       'InetGetInfo',0,\
       'InetGetSize',0,\
       'InetRead',0,\
       'IniDelete',0,\
       'IniRead',0,\
       'IniReadSection',0,\
       'IniReadSectionNames',0,\
       'IniRenameSection',0,\
       'IniWrite',0,\
       'IniWriteSection',0,\
       'InputBox',0,\
       'Int',0,\
       'IsAdmin',0,\
       'IsArray',0,\
       'IsBinary',0,\
       'IsBool',0,\
       'IsDeclared',0,\
       'IsDllStruct',0,\
       'IsFloat',0,\
       'IsHWnd',0,\
       'IsInt',0,\
       'IsKeyword',0,\
       'IsNumber',0,\
       'IsObj',0,\
       'IsPtr',0,\
       'IsString',0,0
_FL db 'Log',0,0
_FM db 'MemGetStats',0,\
       'Mod',0,\
       'MouseClick',0,\
       'MouseClickDrag',0,\
       'MouseDown',0,\
       'MouseGetCursor',0,\
       'MouseGetPos',0,\
       'MouseMove',0,\
       'MouseUp',0,\
       'MouseWheel',0,\
       'MsgBox',0,0
_FN db 'Number',0,0
_FO db 'ObjCreate',0,\
       'ObjEvent',0,\
       'ObjGet',0,\
       'ObjName',0,\
       'OnAutoItExitRegister',0,\
       'OnAutoItExitUnRegister',0,\
       'Opt',0,0
_FP db 'Ping',0,\
       'PixelChecksum',0,\
       'PixelGetColor',0,\
       'PixelSearch',0,\
       'PluginClose',0,\
       'PluginOpen',0,\
       'ProcessClose',0,\
       'ProcessExists',0,\
       'ProcessGetStats',0,\
       'ProcessList',0,\
       'ProcessSetPriority',0,\
       'ProcessWait',0,\
       'ProcessWaitClose',0,\
       'ProgressOff',0,\
       'ProgressOn',0,\
       'ProgressSet',0,\
       'Ptr',0,0
_FR db 'Random',0,\
       'RegDelete',0,\
       'RegEnumKey',0,\
       'RegEnumVal',0,\
       'RegRead',0,\
       'RegWrite',0,\
       'Round',0,\
       'Run',0,\
       'RunAs',0,\
       'RunAsWait',0,\
       'RunWait',0,0
_FS db 'Send',0,\
       'SendKeepActive',0,\
       'SetError',0,\
       'SetExtended',0,\
       'ShellExecute',0,\
       'ShellExecuteWait',0,\
       'Shutdown',0,\
       'Sin',0,\
       'Sleep',0,\
       'SoundPlay',0,\
       'SoundSetWaveVolume',0,\
       'SplashImageOn',0,\
       'SplashOff',0,\
       'SplashTextOn',0,\
       'Sqrt',0,\
       'SRandom',0,\
       'StatusbarGetText',0,\
       'StderrRead',0,\
       'StdinWrite',0,\
       'StdioClose',0,\
       'StdoutRead',0,\
       'String',0,\
       'StringAddCR',0,\
       'StringCompare',0,\
       'StringFormat',0,\
       'StringFromASCIIArray',0,\
       'StringInStr',0,\
       'StringIsAlNum',0,\
       'StringIsAlpha',0,\
       'StringIsASCII',0,\
       'StringIsDigit',0,\
       'StringIsFloat',0,\
       'StringIsInt',0,\
       'StringIsLower',0,\
       'StringIsSpace',0,\
       'StringIsUpper',0,\
       'StringIsXDigit',0,\
       'StringLeft',0,\
       'StringLen',0,\
       'StringLower',0,\
       'StringMid',0,\
       'StringRegExp',0,\
       'StringRegExpReplace',0,\
       'StringReplace',0,\
       'StringRight',0,\
       'StringSplit',0,\
       'StringStripCR',0,\
       'StringStripWS',0,\
       'StringToASCIIArray',0,\
       'StringToBinary',0,\
       'StringTrimLeft',0,\
       'StringTrimRight',0,\
       'StringUpper',0,0
_FT db 'Tan',0,\
       'TCPAccept',0,\
       'TCPCloseSocket',0,\
       'TCPConnect',0,\
       'TCPListen',0,\
       'TCPNameToIP',0,\
       'TCPRecv',0,\
       'TCPSend',0,\
       'TCPShutdown',0,\
       'TCPStartup',0,\
       'TimerDiff',0,\
       'TimerInit',0,\
       'ToolTip',0,\
       'TrayCreateItem',0,\
       'TrayCreateMenu',0,\
       'TrayGetMsg',0,\
       'TrayItemDelete',0,\
       'TrayItemGetHandle',0,\
       'TrayItemGetState',0,\
       'TrayItemGetText',0,\
       'TrayItemSetOnEvent',0,\
       'TrayItemSetState',0,\
       'TrayItemSetText',0,\
       'TraySetClick',0,\
       'TraySetIcon',0,\
       'TraySetOnEvent',0,\
       'TraySetPauseIcon',0,\
       'TraySetState',0,\
       'TraySetToolTip',0,\
       'TrayTip',0,0
_FU db 'UBound',0,\
       'UDPBind',0,\
       'UDPCloseSocket',0,\
       'UDPOpen',0,\
       'UDPRecv',0,\
       'UDPSend',0,\
       'UDPShutdown',0,\
       'UDPStartup',0,0
_FV db 'VarGetType',0,0
_FW db 'WinActivate',0,\
       'WinActive',0,\
       'WinClose',0,\
       'WinExists',0,\
       'WinFlash',0,\
       'WinGetCaretPos',0,\
       'WinGetClassList',0,\
       'WinGetClientSize',0,\
       'WinGetHandle',0,\
       'WinGetPos',0,\
       'WinGetProcess',0,\
       'WinGetState',0,\
       'WinGetText',0,\
       'WinGetTitle',0,\
       'WinKill',0,\
       'WinList',0,\
       'WinMenuSelectItem',0,\
       'WinMinimizeAll',0,\
       'WinMinimizeAllUndo',0,\
       'WinMove',0,\
       'WinSetOnTop',0,\
       'WinSetState',0,\
       'WinSetTitle',0,\
       'WinSetTrans',0,\
       'WinWait',0,\
       'WinWaitActive',0,\
       'WinWaitClose',0,\
       'WinWaitNotActive',0,0

_MA db 'AppDataCommonDir',0,\
       'AppDataDir',0,\
       'AutoItExe',0,\
       'AutoItPID',0,\
       'AutoItVersion',0,\
       'AutoItX64',0,0
_MC db 'COM_EventObj',0,\
       'CommonFilesDir',0
_Compiled db \
       'Compiled',0,\
       'ComputerName',0,\
       'ComSpec',0,\
       'CPUArch',0,\
       'CR',0,\
       'CRLF',0,0
_MD db 'DesktopCommonDir',0,\
       'DesktopDir',0,\
       'DesktopHeight',0,\
       'DesktopWidth',0,\
       'DesktopDepth',0,\
       'DesktopRefresh',0,\
       'DocumentsCommonDir',0,0
_ME db 'error',0,\
       'exitCode',0,\
       'exitMethod',0,\
       'extended',0,0
_MF db 'FavoritesCommonDir',0,\
       'FavoritesDir',0,0
_MG db 'GUI_CtrlId',0,\
       'GUI_CtrlHandle',0,\
       'GUI_DragId',0,\
       'GUI_DragFile',0,\
       'GUI_DropId',0,\
       'GUI_WinHandle',0,0
_MH db 'HomeDrive',0,\
       'HomePath',0,\
       'HomeShare',0,\
       'HOUR',0,\
       'HotKeyPressed',0,0
_MI db 'IPAddress1',0,\
       'IPAddress2',0,\
       'IPAddress3',0,\
       'IPAddress4',0,0
_MK db 'KBLayout',0,0
_ML db 'LF',0,\
       'LogonDNSDomain',0,\
       'LogonDomain',0,\
       'LogonServer',0,0
_MM db 'MDAY',0,\
       'MIN',0,\
       'MON',0,\
       'MSEC',0,\
       'MUILang',0,\
       'MyDocumentsDir',0,0
_MN db 'NumParams',0,0
_MO db 'OSArch',0,\
       'OSBuild',0,\
       'OSLang',0,\
       'OSServicePack',0,\
       'OSType',0,\
       'OSVersion',0,0
_MP db 'ProgramFilesDir',0,\
       'ProgramsCommonDir',0,\
       'ProgramsDir',0,0
_MS db 'ScriptDir',0,\
       'ScriptFullPath',0,\
       'ScriptLineNumber',0,\
       'ScriptName',0,\
       'SEC',0,\
       'StartMenuCommonDir',0,\
       'StartMenuDir',0,\
       'StartupCommonDir',0,\
       'StartupDir',0,\
       'SW_DISABLE',0,\
       'SW_ENABLE',0,\
       'SW_HIDE',0,\
       'SW_LOCK',0,\
       'SW_MAXIMIZE',0,\
       'SW_MINIMIZE',0,\
       'SW_RESTORE',0,\
       'SW_SHOW',0,\
       'SW_SHOWDEFAULT',0,\
       'SW_SHOWMAXIMIZED',0,\
       'SW_SHOWMINIMIZED',0,\
       'SW_SHOWMINNOACTIVE',0,\
       'SW_SHOWNA',0,\
       'SW_SHOWNOACTIVATE',0,\
       'SW_SHOWNORMAL',0,\
       'SW_UNLOCK',0,\
       'SystemDir',0,0
_MT db 'TAB',0,\
       'TempDir',0,\
       'TRAY_ID',0,\
       'TrayIconFlashing',0,\
       'TrayIconVisible',0,0
_MU db 'UserProfileDir',0,\
       'UserName',0,0
_MW db 'WDAY',0,\
       'WindowsDir',0,\
       'WorkingDir',0,0
_MY db 'YDAY',0,\
       'YEAR',0,0

_KA db 'AND',0,0
_KB db 'ByRef',0,0
_KC db 'Case',0
_Const db \
       'Const',0,\
       'ContinueCase',0,\
       'ContinueLoop',0,0
_KD db 'Default',0
_Dim db \
       'Dim',0,\
       'Do',0,0
_KE db 'Else',0,\
       'ElseIf',0,\
       'EndFunc',0,\
       'EndIf',0,\
       'EndSelect',0,\
       'EndSwitch',0,\
       'EndWith',0,\
       'Enum',0,\
       'Exit',0,\
       'ExitLoop',0,0
_KF db 'False',0,\
       'For',0
_Func db \
       'Func',0,0
_KG db 'Global',0,0
_KI db 'If',0,\
       'In',0,0
_KL db 'Local',0,0
_KN db 'Next',0,\
       'NOT',0,0
_KO db 'OR',0,0
_KR db 'Redim',0,\
       'Return',0,0
_KS db 'Select',0,\
       'Static',0,\
       'Step',0,\
       'Switch',0,0
_KT db 'Then',0,\
       'To',0,\
       'True',0,0
_KU db 'Until',0,0
_KW db 'WEnd',0,\
       'While',0,\
       'With',0,0

_preprocessor db '#comments-start',0,\
		 '#comments-end',0,\
		 '#cs',0,\
		 '#ce',0,\
		 '#include-once',0,\
		 '#include',0,\
		 '#NoAutoIt3Execute',0,\
		 '#NoTrayIcon',0,\
		 '#OnAutoItStartRegister',0,\
		 '#Region',0,\
		 '#EndRegion',0,\
		 '#RequireAdmin',0,\
		 '#Obfuscator_Parameters',0,\
		 '#Obfuscator_Off',0,\
		 '#Obfuscator_On',0,\
		 '#Obfuscator_Ignore_Funcs',0,\
		 '#Obfuscator_Ignore_Variables',0,\
		 '#Tidy_Parameters',0,\
		 '#Compiler_Run_Obfuscator',0,\
		 '#AutoIt3Wrapper_UseX64',0,\
		 '#AutoIt3Wrapper_Version',0,\
		 '#AutoIt3Wrapper_Run_Debug_Mode',0,\
		 '#AutoIt3Wrapper_Run_SciTE_Minimized',0,\
		 '#AutoIt3Wrapper_Run_SciTE_OutputPane_Minimized',0,\
		 '#AutoIt3Wrapper_Autoit3Dir',0,\
		 '#AutoIt3Wrapper_Aut2exe',0,\
		 '#AutoIt3Wrapper_AutoIt3',0,\
		 '#AutoIt3Wrapper_Icon',0,\
		 '#AutoIt3Wrapper_OutFile',0,\
		 '#AutoIt3Wrapper_OutFile_Type',0,\
		 '#AutoIt3Wrapper_OutFile_X64',0,\
		 '#AutoIt3Wrapper_Compression',0,\
		 '#AutoIt3Wrapper_UseUpx',0,\
		 '#AutoIt3Wrapper_UPX_Parameters',0,\
		 '#AutoIt3Wrapper_Change2CUI',0,\
		 '#AutoIt3Wrapper_Compile_both',0,\
		 '#AutoIt3Wrapper_Res_Comment',0,\
		 '#AutoIt3Wrapper_Res_Description',0,\
		 '#AutoIt3Wrapper_Res_Fileversion',0,\
		 '#AutoIt3Wrapper_Res_FileVersion_AutoIncrement',0,\
		 '#AutoIt3Wrapper_Res_ProductVersion',0,\
		 '#AutoIt3Wrapper_Res_Language',0,\
		 '#AutoIt3Wrapper_Res_LegalCopyright',0,\
		 '#AutoIt3Wrapper_res_requestedExecutionLevel',0,\
		 '#AutoIt3Wrapper_res_Compatibility',0,\
		 '#AutoIt3Wrapper_Res_SaveSource',0,\
		 '#AutoIt3Wrapper_Res_Field',0,\
		 '#AutoIt3Wrapper_Res_Icon_Add',0,\
		 '#AutoIt3Wrapper_Res_File_Add',0,\
		 '#AutoIt3Wrapper_Run_Tidy',0,\
		 '#AutoIt3Wrapper_Tidy_Stop_OnError',0,\
		 '#AutoIt3Wrapper_Run_Obfuscator',0,\
		 '#AutoIt3Wrapper_Run_AU3Check',0,\
		 '#AutoIt3Wrapper_AU3Check_Parameters',0,\
		 '#AutoIt3Wrapper_AU3Check_Stop_OnWarning',0,\
		 '#AutoIt3Wrapper_PlugIn_Funcs',0,\
		 '#AutoIt3Wrapper_Run_cvsWrapper',0,\
		 '#AutoIt3Wrapper_cvsWrapper_Parameters',0,\
		 '#AutoIt3Wrapper_Run_Before',0,\
		 '#AutoIt3Wrapper_Run_After',0,\
		 '#AutoIt3Wrapper_Add_Constants',0,0
