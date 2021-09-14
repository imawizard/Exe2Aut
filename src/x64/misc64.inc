
ERROR_ALREADY_EXISTS = 0B7h
MUTEX_ALL_ACCESS     = 1F0001h
SEMAPHORE_ALL_ACCESS = 1F0003h

struct MEMORY_BASIC_INFORMATION
  BaseAddress	    rq 1
  AllocationBase    rq 1
  AllocationProtect rd 2
  RegionSize	    rq 1
  State 	    rd 1
  Protect	    rd 1
  Type		    rd 2
ends

FindPattern:
	push	rsi rdi
	mov	rdi,rcx
	mov	rcx,rdx
	mov	r10,[rsp+8*(4+3)]
	dec	r10
    .loop:
	mov	al,[r8]
	repnz	scasb
	jnz	.not_found
	mov	r11,rcx
	mov	rdx,rdi
	lea	rsi,[r8+1]
	mov	rcx,r10
    .compare:
	repe	cmpsb
	jnz	.check_wildcard
	lea	rax,[rdx-1]
	jmp	.fin
    .check_wildcard:
	jecxz	.no_match
	mov	rax,rdi
	sub	rax,rdx
	cmp	byte [r9+rax],1
	je	.compare
    .no_match:
	mov	rdi,rdx
	mov	rcx,r11
	jmp	.loop
    .not_found:
	xor	eax,eax
    .fin:
	pop	rdi rsi
	retn

RFindPattern:
	push	rsi rdi
	mov	rdi,rcx
	mov	rcx,rdx
	mov	r10,[rsp+8*(4+3)]
	dec	r10
    .loop:
	mov	al,[r8]
	std
	repnz	scasb
	jnz	.not_found
	add	rdi,2
	mov	r11,rcx
	mov	rdx,rdi
	lea	rsi,[r8+1]
	mov	rcx,r10
	cld
    .compare:
	repe	cmpsb
	jnz	.check_wildcard
	lea	rax,[rdx-1]
	jmp	.fin
    .check_wildcard:
	jecxz	.no_match
	mov	rax,rdi
	sub	rax,rdx
	cmp	byte [r9+rax],1
	je	.compare
    .no_match:
	mov	rdi,rdx
	mov	rcx,r11
	sub	rdi,2
	jmp	.loop
    .not_found:
	xor	eax,eax
    .fin:
	cld
	pop	rdi rsi
	retn

IsMutex:
	sub	rsp,8*(4+1)
	mov	r8,rcx
	xor	edx,edx
	mov	ecx,MUTEX_ALL_ACCESS
	call	[OpenMutex]
	test	rax,rax
	setnz	al
	and	eax,1
	add	rsp,8*(4+1)
	retn

IMAGE_DOS_SIGNATURE		 = 'MZ'
IMAGE_NT_SIGNATURE		 = 'PE'
IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16
IMAGE_DIRECTORY_ENTRY_IMPORT	 = 1
IMAGE_DIRECTORY_ENTRY_IAT	 = 12

struct IMAGE_DOS_HEADER
  e_magic    rw 1
  e_cblp     rw 1
  e_cp	     rw 1
  e_crlc     rw 1
  e_cparhdr  rw 1
  e_minalloc rw 1
  e_maxalloc rw 1
  e_ss	     rw 1
  e_sp	     rw 1
  e_csum     rw 1
  e_ip	     rw 1
  e_cs	     rw 1
  e_lfarlc   rw 1
  e_ovno     rw 1
  e_res      rw 4
  e_oemid    rw 1
  e_oeminfo  rw 1
  e_res2     rw 10
  e_lfanew   rd 1
ends

struct IMAGE_FILE_HEADER
  Machine	       rw 1
  NumberOfSections     rw 1
  TimeDateStamp        rd 1
  PointerToSymbolTable rd 1
  NumberOfSymbols      rd 1
  SizeOfOptionalHeader rw 1
  Characteristics      rw 1
ends

struct IMAGE_DATA_DIRECTORY
  VirtualAddress rd 1
  Size		 rd 1
ends

struct IMAGE_OPTIONAL_HEADER64
  Magic 		      rw 1
  MajorLinkerVersion	      rb 1
  MinorLinkerVersion	      rb 1
  SizeOfCode		      rd 1
  SizeOfInitializedData       rd 1
  SizeOfUninitializedData     rd 1
  AddressOfEntryPoint	      rd 1
  BaseOfCode		      rd 1
  ImageBase		      rq 1
  SectionAlignment	      rd 1
  FileAlignment 	      rd 1
  MajorOperatingSystemVersion rw 1
  MinorOperatingSystemVersion rw 1
  MajorImageVersion	      rw 1
  MinorImageVersion	      rw 1
  MajorSubsystemVersion       rw 1
  MinorSubsystemVersion       rw 1
  Win32VersionValue	      rd 1
  SizeOfImage		      rd 1
  SizeOfHeaders 	      rd 1
  CheckSum		      rd 1
  Subsystem		      rw 1
  DllCharacteristics	      rw 1
  SizeOfStackReserve	      rq 1
  SizeOfStackCommit	      rq 1
  SizeOfHeapReserve	      rq 1
  SizeOfHeapCommit	      rq 1
  LoaderFlags		      rd 1
  NumberOfRvaAndSizes	      rd 1
  DataDirectory 	      IMAGE_DATA_DIRECTORY
			      rb (IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1)*sizeof.IMAGE_DATA_DIRECTORY
ends

struct IMAGE_NT_HEADERS64
  Signature	 rd 1
  FileHeader	 IMAGE_FILE_HEADER
  OptionalHeader IMAGE_OPTIONAL_HEADER64
ends

struct IMAGE_IMPORT_DESCRIPTOR
  union
    Characteristics    rd 1
    OriginalFirstThunk rd 1
  ends
  TimeDateStamp        rd 1
  ForwarderChain       rd 1
  Name		       rd 1
  FirstThunk	       rd 1
ends

struct IMAGE_THUNK_DATA64
  union
    ForwarderString rq 1
    Function	    rq 1
    Ordinal	    rq 1
    AddressOfData   rq 1
  ends
ends

proc DetourFunc module,address,new_address
  local old:DWORD,pad1:DWORD,mbi:MEMORY_BASIC_INFORMATION
	push	r12 r13 r14
	sub	rsp,8*(4+1)
	mov	r12,rdx
	mov	r13,r8
	test	rcx,rcx
	jns	.ok
	xor	ecx,ecx
	call	[GetModuleHandle]
	xchg	rax,rcx
    .ok:
	mov	r11,rcx
	mov	r14,rcx
	cmp	word [r11],IMAGE_DOS_SIGNATURE
	jnz	.err
	mov	r8d,[r11+IMAGE_DOS_HEADER.e_lfanew]
	add	r14,r8
	cmp	dword [r14],IMAGE_NT_SIGNATURE
	jnz	.err
	lea	r9,[r14+IMAGE_NT_HEADERS64.OptionalHeader.DataDirectory+IMAGE_DIRECTORY_ENTRY_IAT*sizeof.IMAGE_DATA_DIRECTORY]
	mov	r8d,[r9+IMAGE_DATA_DIRECTORY.VirtualAddress]
	mov	r9d,[r9+IMAGE_DATA_DIRECTORY.Size]
	test	r8,r8
	je	.no_iat
	lea	r14,[r11+r8]
    .loop:
	cmp	[r14+IMAGE_THUNK_DATA64.Function],r12
	je	.found
	add	r14,8
	sub	r9,8
	jnz    .loop
	jmp    .err
    .no_iat:
	mov	r8d,[r14+IMAGE_NT_HEADERS64.OptionalHeader.DataDirectory.VirtualAddress+IMAGE_DIRECTORY_ENTRY_IMPORT*sizeof.IMAGE_DATA_DIRECTORY]
	lea	r9,[r11+r8]
    .descriptors:
	mov	r8d,[r9+IMAGE_IMPORT_DESCRIPTOR.FirstThunk]
	test	r8,r8
	je	.err
	lea	r14,[r11+r8]
    .thunks:
	mov	r8,[r14+IMAGE_THUNK_DATA64.Function]
	test	r8,r8
	je	.next
	cmp	r8,r12
	je	.found
	add	r14,8
	jmp	.thunks
    .next:
	add	r9,sizeof.IMAGE_IMPORT_DESCRIPTOR
	jmp	.descriptors
    .found:
	mov	r8d,sizeof.MEMORY_BASIC_INFORMATION
	lea	rdx,[mbi]
	mov	rcx,r14
	call	[VirtualQuery]
	lea	r9,[old]
	mov	r8d,PAGE_READWRITE
	mov	rdx,[mbi.RegionSize]
	mov	rcx,[mbi.BaseAddress]
	call	[VirtualProtect]
	mov	[r14],r13
	lea	r9,[old]
	mov	r8d,[old]
	mov	rdx,[mbi.RegionSize]
	mov	rcx,[mbi.BaseAddress]
	call	[VirtualProtect]
	jmp	.fin
    .err:
	xor	eax,eax
    .fin:
	add	rsp,8*(4+1)
	pop	r14 r13 r12
	ret
endp

proc DetourCode address,new_address
  local old:DWORD,pad1:DWORD,mbi:MEMORY_BASIC_INFORMATION
	push	rsi rdi
	sub	rsp,8*(4+0)
	mov	rsi,rcx
	mov	rdi,rdx
	mov	r8d,sizeof.MEMORY_BASIC_INFORMATION
	lea	rdx,[mbi]
	call	[VirtualQuery]
	lea	r9,[old]
	mov	r8d,PAGE_READWRITE
	mov	rdx,[mbi.RegionSize]
	mov	rcx,[mbi.BaseAddress]
	call	[VirtualProtect]
	mov	word [rsi],0B848h
	mov	[rsi+2],rdi
	mov	word [rsi+10],0E0FFh
	lea	r9,[old]
	mov	r8d,[old]
	mov	rdx,[mbi.RegionSize]
	mov	rcx,[mbi.BaseAddress]
	call	[VirtualProtect]
	add	rsp,8*(4+1)
	pop	rdi rsi
	ret
endp

proc InjectDll pid,dll
	push	r12 r13 r14
	sub	rsp,8*(4+3)
	mov	[dll],rdx
	mov	r8d,ecx
	xor	edx,edx
	mov	ecx,PROCESS_ALL_ACCESS
	call	[OpenProcess]
	test	rax,rax
	je	.err
	mov	r12,rax
	mov	rcx,[dll]
	call	[lstrlenW]
	lea	r14d,[eax*2+2]
	mov	dword [rsp+8*4],PAGE_EXECUTE_READWRITE
	mov	r9d,MEM_RESERVE+MEM_COMMIT
	mov	r8d,r14d
	xor	edx,edx
	mov	rcx,r12
	call	[VirtualAllocEx]
	test	rax,rax
	je	.close
	mov	r13,rax
	mov	dword [rsp+8*4],0
	mov	r9d,r14d
	mov	r8,[dll]
	mov	rdx,rax
	mov	rcx,r12
	call	[WriteProcessMemory]
	test	eax,eax
	je	.close
	lea	rcx,[.kernel32]
	call	[GetModuleHandle]
	lea	rdx,[.loadlibrary]
	mov	rcx,rax
	call	[GetProcAddress]
	xor	edx,edx
	mov	[rsp+8*6],rdx
	mov	[rsp+8*5],edx
	mov	[rsp+8*4],r13
	mov	r9,rax
	xor	r8,r8
	xor	edx,edx
	mov	rcx,r12
	call	[CreateRemoteThread]
	xor	r14,r14
	test	rax,rax
	je	.cleanup
	mov	r14,rax
	or	rdx,-1
	mov	rcx,rax
	call	[WaitForSingleObject]
	lea	rdx,[rsp+8*4]
	mov	rcx,r14
	call	[GetExitCodeThread]
	mov	rcx,r14
	call	[CloseHandle]
	mov	r14,[rsp+8*4]
    .cleanup:
	mov	r9d,MEM_RELEASE
	xor	r8,r8
	mov	rdx,r13
	mov	rcx,r12
	call	[VirtualFreeEx]
	mov	rcx,r12
	call	[CloseHandle]
	xchg	rax,r14
	jmp	.fin
    .close:
	mov	rcx,r12
	call	[CloseHandle]
    .err:
	xor	eax,eax
    .fin:
	add	rsp,8*(4+3)
	pop	r14 r13 r12
	ret

  .kernel32 db 'kernel32',0
  .loadlibrary db 'LoadLibraryW',0
endp
