
RENAME_FUNCTIONS    = RENAME_PLUGIN
RENAME_GLOBALS	    = RENAME_PLUGIN
RENAME_LOCALS	    = RENAME_PLUGIN
ADJUST_FILEINSTALLS = 1
REPLACE_@COMPILED   = 0

RENAME_PLUGIN	    = 0
RENAME_ALWAYS	    = 1
RENAME_NEVER	    = 2
NO_WARNING	    = 1
NO_ARMANOTE	    = 2

proc Settings.Load
  local hkey:DWORD,cb:DWORD
	push	esi
	lea	eax,[hkey]
	push	eax
	push	KEY_ALL_ACCESS
	push	0
	push	set._reg_key
	push	HKEY_LOCAL_MACHINE
	call	[RegOpenKeyEx]
	test	eax,eax
	jnz	.err
	mov	esi,[hkey]
	lea	eax,[cb]
	lea	edx,[set.dontshowagain]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	set._reg_dontshowagain
	push	esi
	call	[RegQueryValueEx]
	lea	eax,[cb]
	lea	edx,[set.rename_funcs]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	set._reg_rename_funcs
	push	esi
	call	[RegQueryValueEx]
	lea	eax,[cb]
	lea	edx,[set.rename_globs]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	set._reg_rename_globs
	push	esi
	call	[RegQueryValueEx]
	lea	eax,[cb]
	lea	edx,[set.rename_locs]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	set._reg_rename_locs
	push	esi
	call	[RegQueryValueEx]
	lea	eax,[cb]
	lea	edx,[set.adjust_files]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	set._reg_adjust_files
	push	esi
	call	[RegQueryValueEx]
	lea	eax,[cb]
	lea	edx,[set.no_@compiled]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	set._reg_no_@compiled
	push	esi
	call	[RegQueryValueEx]
	push	esi
	call	[RegCloseKey]
    .err:
	pop	esi
	ret
endp

proc Settings.Save
  local hkey:DWORD,value:DWORD,buf[32]:BYTE
	push	edi
	lea	eax,[hkey]
	push	0
	push	eax
	push	0
	push	KEY_ALL_ACCESS
	push	REG_OPTION_NON_VOLATILE
	push	0
	push	0
	push	set._reg_key
	push	HKEY_LOCAL_MACHINE
	call	[RegCreateKeyEx]
	test	eax,eax
	jnz	.err
	mov	edi,[hkey]
	mov	ecx,[set.rename_funcs]
	lea	eax,[value]
	mov	dword [eax],ecx
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	set._reg_rename_funcs
	push	edi
	call	[RegSetValueEx]
	mov	ecx,[set.rename_globs]
	lea	eax,[value]
	mov	dword [eax],ecx
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	set._reg_rename_globs
	push	edi
	call	[RegSetValueEx]
	mov	ecx,[set.rename_locs]
	lea	eax,[value]
	mov	dword [eax],ecx
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	set._reg_rename_locs
	push	edi
	call	[RegSetValueEx]
	mov	ecx,[set.adjust_files]
	lea	eax,[value]
	mov	dword [eax],ecx
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	set._reg_adjust_files
	push	edi
	call	[RegSetValueEx]
	mov	ecx,[set.no_@compiled]
	lea	eax,[value]
	mov	dword [eax],ecx
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	set._reg_no_@compiled
	push	edi
	call	[RegSetValueEx]
	push	edi
	call	[RegCloseKey]
	lea	edi,[buf]
	push	set._reg_key
	push	edi
	call	[strcpy]
	push	set._reg_plugins
	push	edi
	call	[strcat]
	add	esp,10h
	lea	eax,[hkey]
	push	0
	push	eax
	push	0
	push	KEY_ALL_ACCESS
	push	REG_OPTION_NON_VOLATILE
	push	0
	push	0
	push	edi
	push	HKEY_LOCAL_MACHINE
	call	[RegCreateKeyEx]
	test	eax,eax
	jnz	.err
	push	[hkey]
	push	Settings.SavePlugin
	call	PluginManager.Iterate
	push	[hkey]
	call	[RegCloseKey]
    .err:
	pop	edi
	ret
endp

proc Settings.SavePlugin plugin,index,hkey
  local value:DWORD
	push	esi
	mov	[value],0
	mov	esi,[plugin]
	mov	edx,[esi+E2APLUGIN.Name]
	cmp	[esi+E2APLUGIN.Enabled],1
	je	.delete
	lea	eax,[value]
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	edx
	push	[hkey]
	call	[RegSetValueEx]
	jmp	.fin
    .delete:
	push	edx
	push	[hkey]
	call	[RegDeleteValue]
    .fin:
	ret
endp

proc Settings.IsPluginEnabled plugin
  local hkey:DWORD,value:DWORD,cb:DWORD,buf[32]:BYTE
	push	ebx
	mov	[value],1
	lea	ebx,[buf]
	push	set._reg_key
	push	ebx
	call	[strcpy]
	push	set._reg_plugins
	push	ebx
	call	[strcat]
	add	esp,10h
	lea	eax,[hkey]
	push	eax
	push	KEY_ALL_ACCESS
	push	0
	push	ebx
	push	HKEY_LOCAL_MACHINE
	call	[RegOpenKeyEx]
	test	eax,eax
	jnz	.fin
	mov	ebx,[hkey]
	lea	eax,[cb]
	lea	edx,[value]
	mov	dword [eax],4
	push	eax
	push	edx
	push	0
	push	0
	push	[plugin]
	push	ebx
	call	[RegQueryValueEx]
	push	ebx
	call	[RegCloseKey]
    .fin:
	mov	eax,[value]
	pop	ebx
	ret
endp

proc Settings.Exists
  local hkey:DWORD
	lea	eax,[hkey]
	push	eax
	push	KEY_ALL_ACCESS
	push	0
	push	set._reg_key
	push	HKEY_LOCAL_MACHINE
	call	[RegOpenKeyEx]
	test	eax,eax
	jnz	.err
	push	[hkey]
	call	[RegCloseKey]
	mov	eax,1
	jmp	.fin
    .err:
	xor	eax,eax
    .fin:
	ret
endp

proc Settings.Delete
	push	set._reg_key
	push	HKEY_LOCAL_MACHINE
	call	[SHDeleteKey]
	ret
endp

proc Settings.CheckPlugin

	ret
endp

proc Settings.DontShowAgain param
  local hkey:DWORD,value:DWORD
	mov	eax,[param]
	or	eax,[set.dontshowagain]
	mov	[set.dontshowagain],eax
	mov	[value],eax
	lea	eax,[hkey]
	push	0
	push	eax
	push	0
	push	KEY_ALL_ACCESS
	push	REG_OPTION_NON_VOLATILE
	push	0
	push	0
	push	set._reg_key
	push	HKEY_LOCAL_MACHINE
	call	[RegCreateKeyEx]
	test	eax,eax
	jnz	.err
	lea	eax,[value]
	push	4
	push	eax
	push	REG_DWORD
	push	0
	push	set._reg_dontshowagain
	push	[hkey]
	call	[RegSetValueEx]
	push	[hkey]
	call	[RegCloseKey]
    .err:
	ret
endp

macro sets_idata
 {
   set._reg_key db 'SOFTWARE\Exe2Aut',0
   set._reg_plugins db '\plugins',0
   set._reg_dontshowagain db 'DontShowAgain',0
   set._reg_rename_funcs db 'RenameFunctions',0
   set._reg_rename_globs db 'RenameGlobals',0
   set._reg_rename_locs db 'RenameLocals',0
   set._reg_adjust_files db 'AdjustFileInstalls',0
   set._reg_no_@compiled db 'Replace@Compiled',0

   set.dontshowagain dd 0
   set.temporarily dd 1
   set.rename_funcs dd RENAME_FUNCTIONS
   set.rename_globs dd RENAME_GLOBALS
   set.rename_locs dd RENAME_LOCALS
   set.adjust_files dd ADJUST_FILEINSTALLS
   set.no_@compiled dd REPLACE_@COMPILED
 }

macro sets_udata {}
