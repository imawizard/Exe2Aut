; UFMOD.ASM
; ---------
; uFMOD public source code release.

if DRIVER_WINMM
	uF_WMMBlock_lpData          EQU 0
	uF_WMMBlock_dwBufferLength  EQU 4
	uF_WMMBlock_dwBytesRecorded EQU 8
	uF_WMMBlock_dwUser          EQU 12
	uF_WMMBlock_dwFlags         EQU 16
	uF_WMMBlock_dwLoops         EQU 20
	uF_WMMBlock_lpNext          EQU 24
	uF_WMMBlock_Reserved        EQU 28
	uF_WMMBlock_size            EQU 32
	pcm dd 20001h, FSOUND_MixRate, FSOUND_MixRate*4, 100004h
endif

if XM_RC_ON
	uFMOD_rc  dd res_open, mem_read
endif
	uFMOD_mem dd mem_open, mem_read
if XM_FILE_ON
	          dd mem_open
	uFMOD_fs  dd file_open, file_read, file_close
endif

if JUMP_TO_PAT_ON

	; Jump to the given pattern
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@Jump2Pattern
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSJump2Pattern
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALJump2Pattern
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_Jump2Pattern
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_Jump2Pattern@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_Jump2Pattern@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_Jump2Pattern
				uFMOD_Jump2Pattern:
			endif
			mov eax,[esp+4]
		endif
	endif
	mov ecx,OFFSET _mod+36
	movzx eax,ax
	and DWORD PTR [ecx+uF_MOD_nextrow-36],0
	cmp ax,[ecx+uF_MOD_numorders-36]
	sbb edx,edx
	and eax,edx
	mov [ecx+uF_MOD_nextorder-36],eax
	if PBASIC
		ret
	else
		ret 4
	endif
endif

if VOL_CONTROL_ON

	; Set global volume [0: silence, 25: max. volume]
	vol_scale dw 1     ; -45 dB
	          dw 130   ; -24
	          dw 164   ; -23
	          dw 207   ; -22
	          dw 260   ; -21
	          dw 328   ; -20
	          dw 413   ; -19
	          dw 519   ; -18
	          dw 654   ; -17
	          dw 823   ; -16
	          dw 1036  ; -15
	          dw 1305  ; -14
	          dw 1642  ; -13
	          dw 2068  ; -12
	          dw 2603  ; -11
	          dw 3277  ; -10
	          dw 4125  ; -9
	          dw 5193  ; -8
	          dw 6538  ; -7
	          dw 8231  ; -6
	          dw 10362 ; -5
	          dw 13045 ; -4
	          dw 16423 ; -3
	          dw 20675 ; -2
	          dw 26029 ; -1
	          dw 32768 ; 0 dB
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@SetVolume
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSSetVolume
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALSetVolume
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_SetVolume
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_SetVolume@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_SetVolume@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_SetVolume
				uFMOD_SetVolume:
			endif
			pop edx
			pop eax
		endif
	endif
		cmp eax,25
		jna get_vol_scale
		push 25
		pop eax
	get_vol_scale:
		mov ax,[vol_scale+eax*2]
		mov [ufmod_vol],eax
	if PBASIC
		ret
	else
		jmp edx
	endif
endif

if PAUSE_RESUME_ON

	; Pause the currently playing song.
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@Pause
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSPause
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALPause
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_Pause
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_Pause@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_Pause@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_Pause
				uFMOD_Pause:
			endif
		endif
	endif
	mov al,1
	jmp $+4

	; Resume the currently paused song.
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@Resume
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSResume
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALResume
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_Resume
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_Resume@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_Resume@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_Resume
				uFMOD_Resume:
			endif
		endif
	endif
	xor eax,eax
	mov [ufmod_pause_],al
	ret
endif

if INFO_API_ON

; Return currently playing signal stats:
;    lo word : RMS volume in R channel
;    hi word : RMS volume in L channel
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@GetStats
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSGetStats
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALGetStats
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_GetStats
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_GetStats@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_GetStats@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_GetStats
				uFMOD_GetStats:
			endif
		endif
	endif
	push 8
	jmp $+4

; Return currently playing row and order:
;    lo word : row
;    hi word : order
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@GetRowOrder
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSGetRowOrder
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALGetRowOrder
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_GetRowOrder
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_GetRowOrder@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_GetRowOrder@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_GetRowOrder
				uFMOD_GetRowOrder:
			endif
		endif
	endif
	push 12
	pop ecx
	mov edx,OFFSET RealBlock
	mov eax,[edx]
	add edx,ecx
	mov eax,[edx+eax*uF_STATS_size]
	ret

; Return the time in milliseconds since the song was started.
	if EBASIC
		EXPORTcc DRIVER_WINMM, CuFMOD@GetTime
	else
		if PBASIC
			EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSGetTime
			EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALGetTime
			EXPORTcc DRIVER_WINMM,       PB_uFMOD_GetTime
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_GetTime@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_GetTime@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_GetTime
				uFMOD_GetTime:
			endif
		endif
	endif
	mov eax,[time_ms]
	ret

; Return the currently playing track title, if any.
	if PBASIC
		EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSGetTitle
		EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALGetTitle
		EXPORTcc DRIVER_WINMM,       PB_uFMOD_GetTitle
		push esi
		push edi
		push 6
		mov esi,OFFSET szTtl
		mov edi,[_PB_StringBase]
		pop ecx
		mov eax,edi
		rep movsd
		pop edi
		pop esi
		ret

		EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSGetTitle_UNICODE
		EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALGetTitle_UNICODE
		EXPORTcc DRIVER_WINMM,       PB_uFMOD_GetTitle_UNICODE
		push esi
		push edi
		push 21
		mov esi,OFFSET szTtl
		mov edi,[_PB_StringBase]
		pop ecx
		xor eax,eax
		push edi
	ucode_copy:
		lodsb
		dec ecx
		stosw
		jnz ucode_copy
		pop eax
		pop edi
		pop esi
		ret
	endif

endif

; Dynamic memory allocation
alloc:
; EAX: how many bytes to allocate
	push eax
	push 9 ; HEAP_ZERO_MEMORY | HEAP_NO_SERIALIZE
	push DWORD PTR [hHeap]
	call HeapAlloc
	test eax,eax
	jnz alloc_R
	pop edx ; EIP
	pop ebx
	leave
alloc_R:
	ret

; ***********************
; * XM_MEMORY CALLBACKS *
; ***********************
mem_read:
; buf  in EAX
; size in EDX
	push edi
	push esi
	xchg eax,edi ; buf
	mov esi,OFFSET mmf
	lodsd
	mov ecx,edx
	add edx,[esi]
	cmp edx,eax
	jl copy
	sub eax,[esi]
	xchg eax,ecx
copy:
	test ecx,ecx
	jle mem_read_R
	lodsd
	add eax,[esi]
	mov [esi-4],edx
mem_do_copy:
	mov dl,[eax]
	mov [edi],dl
	inc eax
	inc edi
	dec ecx
	jnz mem_do_copy
mem_read_R:
	pop esi
	pop edi
if INFO_API_ON
	if PBASIC
	else
		if EBASIC
			EXPORTcc DRIVER_WINMM, CuFMOD@GetTitle
		else
			if VB6
				EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_GetTitle@DSuF_vb@@AAGXXZ
				EXPORTcc DRIVER_WINMM,       ?uFMOD_GetTitle@uF_vb@@AAGXXZ
			else
				PUBLIC uFMOD_GetTitle
				uFMOD_GetTitle:
			endif
		endif
		mov eax,OFFSET szTtl
	endif
endif
mem_open:
	ret

; *************************
; * XM_RESOURCE CALLBACKS *
; *************************
if XM_RC_ON
res_open:
; pszName in ESI
	push 10  ; RT_RCDATA
	push esi ; pszName
	lea esi,[ebp-20] ; mmf
	and DWORD PTR [esi+4],0
	push DWORD PTR [esi] ; HMODULE
	call FindResource
	push eax
	push DWORD PTR [esi]
	push eax
	push DWORD PTR [esi]
	call SizeofResource
	mov [esi],eax
	call LoadResource
	mov [esi+8],eax
	ret
endif

; *********************
; * XM_FILE CALLBACKS *
; *********************
if XM_FILE_ON
file_open:
; pszName in ESI
	push 0         ; hTemplateFile
	push 80h       ; dwFlagsAndAttributes <= FILE_ATTRIBUTE_NORMAL
	push 3         ; dwCreationDistribution <= OPEN_EXISTING
	push 0         ; lpSecurityAttributes
	push 1         ; dwShareMode <= FILE_SHARE_READ
	push 80000000h ; dwDesiredAccess <= GENERIC_READ
	push esi       ; lpFileName
	call CreateFile
	push -1
	push 1
	mov edx,OFFSET mmf
	mov [ebx+8],eax ; SW_Exit
	pop DWORD PTR [edx+8] ; cache_offset
	pop DWORD PTR [edx]   ; maximum size
	ret

do_fread:
; file offset             in ECX
; buffer                  in EDI
; number of bytes to read in ESI
	xor edx,edx
	mov eax,[SW_Exit]
	push edx ; lpOverlapped         = NULL
	push esp ; lpNumberOfBytesRead
	push esi ; nNumberOfBytesToRead
	push edi ; lpBuffer
	push eax ; hFile
	push edx ; dwMoveMethod         = FILE_BEGIN
	push edx ; lpDistanceToMoveHigh = NULL
	push ecx ; lDistanceToMove
	push eax ; hFile
	call SetFilePointer
	call ReadFile
	ret

file_read:
; buf in EAX
; size in EDX
	push ebx
	push esi
	push edi
	push ebp
	xchg eax,edi
file_read_begin:
	test edx,edx
	jg file_read_chk_cache
file_read_done:
	pop ebp
	pop edi
	pop esi
	pop ebx
	ret
	; *** CHECK IN THE CACHE
file_read_chk_cache:
	mov ebp,OFFSET mmf+4
	mov esi,[ebp]
	sub esi,[ebp+4] ; cache_offset
	js file_read_cache_done
	mov ecx,8192
	sub ecx,esi
	jle file_read_cache_done
	add esi,OFFSET MixBuf
	sub edx,ecx
	jns file_read_do_cache
	add ecx,edx
file_read_do_cache:
	add [ebp],ecx
	rep movsb
	test edx,edx
	jle file_read_done ; data read from the cache (no need to access the FS)
file_read_cache_done:
	; *** FS BATCH READ OPERATION
	mov ecx,edx
	add ecx,[ebp]
	and ecx,0FFFFE000h
	sub ecx,[ebp]
	jle file_read_fs_done ; Too few data requested for a FS batch operation
	sub edx,ecx
	mov esi,ecx           ; number of bytes to read
	push edx
	mov eax,[ebp]
	add [ebp],ecx
	xchg eax,ecx          ; file offset
	call do_fread
	add edi,esi
	pop edx
file_read_fs_done:
	; *** UPDATE THE CACHE
	mov ecx,[ebp]
	push edi
	and ecx,0FFFFE000h    ; file offset
	push edx
	mov [ebp+4],ecx       ; cache_offset
	mov esi,8192          ; number of bytes to read
	mov edi,OFFSET MixBuf ; buffer
	call do_fread
	pop edx
	pop edi
	jmp file_read_begin

file_close:
	push DWORD PTR [ebx+8] ; hObject <- SW_Exit
	call CloseHandle

endif

uFMOD_lseek:
; pos  in EAX
; org  in ECX
; !org in Z
	mov edx,OFFSET mmf+4
	jz mem_ok
	add eax,[edx]
mem_ok:
if CHK4VALIDITY
	test eax,eax
	js mem_seek_R
	cmp eax,[edx-4]
	ja mem_seek_R
endif
	mov [edx],eax
mem_seek_R:
	ret

; Starts playing a song.
if EBASIC
	EXPORTcc DRIVER_WINMM, CuFMOD@PlaySong
else
	if PBASIC
		EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSPlaySong
		EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALPlaySong
		EXPORTcc DRIVER_WINMM,       PB_uFMOD_PlaySong
	else
		if VB6
			EXPORTcc DRIVER_DIRECTSOUND, ?uFMOD_DSPlaySong@DSuF_vb@@AAGXXZ
			EXPORTcc DRIVER_WINMM,       ?uFMOD_PlaySong@uF_vb@@AAGXXZ
		else
			EXPORTcc DRIVER_DIRECTSOUND, uFMOD_DSPlaySong
			EXPORTcc DRIVER_OPENAL,      uFMOD_OALPlaySong
			EXPORTcc DRIVER_WINMM,       uFMOD_PlaySong
		endif
	endif
endif
	; *** FREE PREVIOUS TRACK, IF ANY
	call uFMOD_FreeSong
if DRIVER_OPENAL
	; *** GENERATE SOME STREAMING BUFFERS
	push OFFSET databuf ; *buffers
	push totalblocks    ; n
	call alGenBuffers
	pop eax
	pop eax
endif
	pop eax
	pop edx ; lpXM
	pop DWORD PTR [mmf] ; param
if DRIVER_WINMM
else
	pop DWORD PTR [hWaveOut] ; fdwSong
endif
	pop ecx ; IDirectSoundBuffer / alsource / fdwSong
	test edx,edx
	push eax
	jz mem_seek_R
	; *** SET I/O CALLBACKS
	push ebx
	push esi
	push edi
	push ebp
	mov ebx,OFFSET hWaveOut
	mov ebp,OFFSET uFMOD_fopen
if DRIVER_WINMM
else
	; IDirectSoundBuffer / alsource <-> fdwSong
	mov eax,[ebx]
	mov [ebx],ecx
	xchg ecx,eax
endif
	xor eax,eax
	mov [ebp-16],eax ; mmf+4
	test cl,XM_MEMORY
	mov esi,OFFSET uFMOD_mem
if XM_FILE_ON
	jnz set_callbacks
	test cl,XM_FILE
	lea esi,[esi+(uFMOD_fs-uFMOD_mem)]
	jnz set_callbacks
else
	if XM_RC_ON
		jnz set_callbacks
		test cl,XM_FILE
		jnz uFMOD_FreeSong+4 ; File-loading unsupported (return error)
	else
		jz uFMOD_FreeSong+4  ; Only memory
	endif
endif
if XM_RC_ON
	if XM_FILE_ON
		lea esi,[esi+(uFMOD_rc-uFMOD_fs)]
	else
		lea esi,[esi+(uFMOD_rc-uFMOD_mem)]
	endif
endif
set_callbacks:
if NOLOOP_ON
	test cl,XM_NOLOOP
	setnz [ebp-24] ; ufmod_noloop
endif
if PAUSE_RESUME_ON
	and cl,XM_SUSPENDED
	mov [ebp-23],cl ; ufmod_pause_
endif
	mov edi,ebp ; uFMOD_fopen
	movsd
	movsd
if XM_FILE_ON
	movsd
endif
	mov esi,edx ; uFMOD_fopen:lpXM <= ESI
if VOL_CONTROL_ON
	cmp [ebp-4],eax ; ufmod_vol
	jne play_vol_ok
	mov WORD PTR [ebp-4],32768
play_vol_ok:
endif
	push eax ; dwMaximumSize <- make it "growable"
	push eax ; dwInitialSize <- 1 page
	push eax ; flOptions
if DRIVER_WINMM
	; *** INIT OUTPUT PCM DRIVER
	push eax ; fdwOpen
	push eax ; dwCallbackInstance
	push eax ; dwCallback
	push OFFSET pcm ; pwfx
	push -1  ; uDeviceID
	push ebx ; phwo
	call waveOutOpen
endif
	; *** ALLOCATE A HEAP OBJECT
	call HeapCreate
	test eax,eax
	mov [ebx-8],eax ; hHeap
	jz goto_freesong
	; LOAD NEW TRACK
	mov [ebp-12],esi ; mmf+8 <= pMem
	call LoadXM
if XM_FILE_ON
	xchg eax,edi
	call DWORD PTR [ebp+8] ; uFMOD_fclose
	test edi,edi
else
	test eax,eax
endif
goto_freesong:
	jz uFMOD_FreeSong+4
if DRIVER_WINMM
	; *** CREATE AND START LOOPING WAVEOUT BLOCK
	mov esi,OFFSET MixBlock
	mov DWORD PTR [esi+uF_WMMBlock_dwBufferLength],FSOUND_BufferSize*4
	or DWORD PTR [esi+uF_WMMBlock_dwLoops],-1
	push 12 ; WHDR_BEGINLOOP | WHDR_ENDLOOP
	mov DWORD PTR [esi+uF_WMMBlock_lpData],OFFSET databuf
	pop DWORD PTR [esi+uF_WMMBlock_dwFlags]
	push 32 ; SIZEOF WAVEHDR
	push esi
	push DWORD PTR [ebx]
	call waveOutPrepareHeader
endif
	xor edi,edi
	; *** PREFILL THE MIXER BUFFER
loop_3:
if DRIVER_OPENAL
	mov eax,[ebx+4]
	mov eax,[OFFSET databuf+eax*4]
	mov [mmt],eax
	call alGetError
	test eax,eax
	jnz uFMOD_FreeSong+4
endif
	call uFMOD_SW_Fill
	cmp [ebx+4],edi ; uFMOD_FillBlk
	jnz loop_3
	mov [ebx+8],edi ; SW_Exit <= 0
	; START THE OUTPUT
if DRIVER_DIRECTSOUND
	mov eax,[ebx]
	push 1   ; dwFlags = DSBPLAY_LOOPING
	push edi ; dwPriority
	push edi ; dwReserved1
	push eax ; this
	mov ecx,[eax]
	call DWORD PTR [ecx+48] ; IDirectSoundBuffer::Play
	test eax,eax
	js uFMOD_FreeSong+4
endif
if DRIVER_WINMM
	push 32 ; SIZEOF WAVEHDR
	push esi
	push DWORD PTR [ebx] ; hWaveOut
	call waveOutWrite
	test eax,eax
	jnz uFMOD_FreeSong+4
endif
	; *** CREATE THE THREAD
	push ebp ; lpThreadID
	push edi
	push edi
	push OFFSET uFMOD_Thread
	push edi
	push edi
	call CreateThread
	test eax,eax
	mov [ebx-4],eax ; hThread
	jz uFMOD_FreeSong+4
	push 15 ; THREAD_PRIORITY_TIME_CRITICAL
	push eax
	call SetThreadPriority
	xchg eax,ebx ; OFFSET hWaveOut
	pop ebp
	pop edi
	pop esi
	pop ebx
	ret

if FMT_DLL
	PUBLIC DllEntry
	DllEntry:
		call uFMOD_FreeSong
		xor eax,eax
		inc eax
		ret 12
endif

; Stop the currently playing song, if any, and free all resources allocated for that song.
if PBASIC
	EXPORTcc DRIVER_DIRECTSOUND, PB_uFMOD_DSStopSong
	EXPORTcc DRIVER_OPENAL,      PB_uFMOD_OALStopSong
	EXPORTcc DRIVER_WINMM,       PB_uFMOD_StopSong
endif
uFMOD_FreeSong:
	push ebx
	push esi
	push edi
	push ebp
; uFMOD_FreeSong+4
	; *** STOP THE THREAD
	mov ebp,OFFSET hThread
	mov eax,[ebp]
	test eax,eax
	jz thread_finished
	mov [ebp+12],eax ; SW_Exit
	; Wait for thread to finish
	push eax ; hObject
	push ebp ; dwTimeout ~ INFINITE
	push eax ; hObject   = hThread
	call WaitForSingleObject
	call CloseHandle
thread_finished:
	xor ebx,ebx
if BENCHMARK_ON
	; *** RESET THE PERFORMANCE COUNTER
	mov [_uFMOD_tsc],ebx
endif
	; *** STOP, RESET AND CLOSE THE SOUND DRIVER
	mov [ebp],ebx   ; hThread
	mov edi,[ebp+4] ; hWaveOut
	mov [ebp+8],ebx ; uFMOD_FillBlk
	test edi,edi
	jz snd_closed
	mov [ebp+4],ebx
if DRIVER_DIRECTSOUND
	push ebx ; position = 0
	push edi ; this
	push edi ; this
	mov edi,[edi]
	call DWORD PTR [edi+72] ; IDirectSoundBuffer::Stop
	call DWORD PTR [edi+52] ; IDirectSoundBuffer::SetCurrentPosition
endif
if DRIVER_OPENAL
	push ebx            ; value = NULL
	push 1009h          ; param = AL_BUFFER
	push edi            ; source
	call alSourceStop
	call alSourcei
	push OFFSET databuf ; *buffers
	push totalblocks    ; n
	call alDeleteBuffers
	add esp,20
endif
if DRIVER_WINMM
	push edi ; hwo
	push 32  ; cbwh <= SIZEOF WAVEHDR
	push OFFSET MixBlock ; pwh
	push edi ; hwo
	push edi ; hwo
	call waveOutReset
	call waveOutUnprepareHeader
	; SHUT DOWN PCM DRIVER
	call waveOutClose
endif
snd_closed:
	; *** FREE THE HEAP
	mov eax,[ebp-4] ; hHeap
	test eax,eax
	jz free_R
	mov [ebp-4],ebx ; hHeap
	push eax ; hHeap
	call HeapDestroy
	xchg eax,ebx
if INFO_API_ON
	; *** CLEAR THE RealBlock, time_ms, VU ARRAY AND szTtl
	mov ecx,uF_STATS_size*totalblocks/4+3
	mov edi,OFFSET RealBlock
	rep stosd
endif
free_R:
if DRIVER_DIRECTSOUND
	dec eax ; HRESULT <- error
endif
	pop ebp
	pop edi
	pop esi
	pop ebx
	ret

uFMOD_Thread:
	push ebp
	push esi
	mov ebp,OFFSET mmt
thread_loop_1:
if DRIVER_OPENAL
	; *** RESUME ON STARTUP AND BUFFER UNDERRUNS
	push ebp                ; *value = &mmt
	push 1010h              ; pname  = AL_SOURCE_STATE
	push DWORD PTR [ebp+20] ; source = hWaveOut
	call alGetSourcei
	add esp,12
	; if(state != AL_PLAYING) alSourcePlay(source);
	cmp DWORD PTR [ebp],1012h
	je source_playing
	push DWORD PTR [ebp+20] ; source = hWaveOut
	call alSourcePlay
	pop eax
source_playing:
	push ebp                ; *value = &mmt
	push 1016h              ; pname  = AL_BUFFERS_PROCESSED
	push DWORD PTR [ebp+20] ; source = hWaveOut
	and DWORD PTR [ebp],0
	call alGetSourcei
	add esp,12
	mov esi,[ebp]
endif
if DRIVER_DIRECTSOUND
	push 0                  ; *pdwCurrentWriteCursor = NULL
	push ebp                ; *pdwCurrentPlayCursor  = &mmt
	mov eax,[ebp+20]        ; hWaveOut
	push eax                ; this
	mov ecx,[eax]
	call DWORD PTR [ecx+16] ; IDirectSoundBuffer::GetCurrentPosition
	mov esi,[ebp]
	shr esi,FSOUND_Block+2  ; / (FSOUND_BlockSize * 4)
	and esi,fragmentsmask   ; % totalblocks
endif
if DRIVER_WINMM
	push 4
	pop DWORD PTR [ebp]
	push 12 ; SIZEOF MMTIME
	push ebp
	push DWORD PTR [ebp+20] ; hWaveOut
	call waveOutGetPosition
	mov esi,[ebp+4] ; u.cb
	shr esi,FSOUND_Block+2  ; / (FSOUND_BlockSize * 4)
	and esi,fragmentsmask   ; % totalblocks
endif
thread_loop_2:
	; *** TAKE A LITTLE NAP :-)
	push 5
	call Sleep
	; *** CHECK FOR A REQUEST TO QUIT
	cmp DWORD PTR [ebp+28],0 ; SW_Exit
	je thread_loop_2_continue
	pop esi
	pop ebp
	ret 4
thread_loop_2_continue:
	; *** DO WE NEED TO FETCH ANY MORE DATA INTO SOUND BUFFERS?
if DRIVER_OPENAL
	dec esi
	js thread_loop_1
else
	cmp [ebp+24],esi ; uFMOD_FillBlk
	je thread_loop_1
endif
if DRIVER_OPENAL
	push ebp                ; *buffers = &mmt
	push 1                  ; n        = 1
	push DWORD PTR [ebp+20] ; source   = hWaveOut
	and DWORD PTR [ebp],0
	call alSourceUnqueueBuffers
	add esp,12
endif
if INFO_API_ON
	if PAUSE_RESUME_ON
		cmp BYTE PTR [ufmod_pause_],0
		jne thread_realblock_ok
	endif
	mov eax,OFFSET RealBlock
	inc BYTE PTR [eax]
	cmp BYTE PTR [eax],totalblocks
	jl thread_realblock_ok
	mov BYTE PTR [eax],0
thread_realblock_ok:
endif
	push OFFSET thread_loop_2 ; EIP

uFMOD_SW_Fill:
if BENCHMARK_ON
	dw 310Fh ; rdtsc
	mov [bench_t_lo],eax
endif
	mov ecx,FSOUND_BlockSize*2
	push ebx
	push esi
	push edi
	push ebp
	mov edi,OFFSET MixBuf
	xor eax,eax
	push edi ; mixbuffer <= OFFSET MixBuf
	push edi ; <- MixPtr
	; MIXBUFFER CLEAR
	mov esi,OFFSET _mod+36
	rep stosd
if PAUSE_RESUME_ON
	cmp [ufmod_pause_],al
	xchg eax,ebp
	jne do_swfill
endif
	mov ebp,FSOUND_BlockSize
	; UPDATE MUSIC
	mov ebx,[esi+uF_MOD_mixer_samplesleft-36]
fill_loop_1:
	test ebx,ebx
	jnz mixedleft_nz
	; UPDATE XM EFFECTS
	cmp [esi+uF_MOD_tick-36],ebx ; new note
	mov ecx,[esi+uF_MOD_pattern-36]
	jne update_effects
	dec ebx
	; process any rows commands to set the next order/row
	mov edx,[esi+uF_MOD_nextorder-36]
	mov eax,[esi+uF_MOD_nextrow-36]
	mov [esi+uF_MOD_nextorder-36],ebx
	test edx,edx
	mov [esi+uF_MOD_nextrow-36],ebx
	jl fill_nextrow
	mov [esi+uF_MOD_order-36],edx
fill_nextrow:
	test eax,eax
	jl update_note
	mov [esi+uF_MOD_row-36],eax
update_note:
	; mod+36 : ESI
	call DoNote
if ROWCOMMANDS_ON
	cmp DWORD PTR [esi+uF_MOD_nextrow-36],-1
	jne inc_tick
endif
	mov eax,[esi+uF_MOD_row-36]
	inc eax
	; if end of pattern
	; "if(mod->nextrow >= mod->pattern[mod->orderlist[mod->order]].rows)"
	cmp ax,[ebx]
	jl set_nextrow
	mov edx,[esi+uF_MOD_order-36]
	movzx ecx,WORD PTR [esi+uF_MOD_numorders-36]
	inc edx
	xor eax,eax
	cmp edx,ecx
	jl set_nextorder
	; We've reached the end of the order list. So, stop playing, unless looping is enabled.
if NOLOOP_ON
	cmp [ufmod_noloop],al
	je set_restart
	mov ebp,OFFSET hThread
	pop ebx
	pop DWORD PTR [ebp+12] ; SW_Exit : remove mixbuffer - signal thread to stop
	jmp thread_finished
set_restart:
endif
	movzx edx,WORD PTR [esi+uF_MOD_restart-36]
	cmp edx,ecx
	sbb ecx,ecx
	and edx,ecx
set_nextorder:
	mov [esi+uF_MOD_nextorder-36],edx
set_nextrow:
	mov [esi+uF_MOD_nextrow-36],eax
	jmp inc_tick
update_effects:
	; mod+36 : ESI
	call DoEffs
inc_tick:
	mov eax,[esi+uF_MOD_speed-36]
	mov ebx,[esi+uF_MOD_mixer_samplespertick-36]
	inc DWORD PTR [esi+uF_MOD_tick-36]
if PATTERNDELAY_ON
	add eax,[esi+uF_MOD_patterndelay-36]
endif
	cmp [esi+uF_MOD_tick-36],eax
	jl mixedleft_nz
if PATTERNDELAY_ON
	and DWORD PTR [esi+uF_MOD_patterndelay-36],0
endif
	and DWORD PTR [esi+uF_MOD_tick-36],0
mixedleft_nz:
	mov edi,ebp
	cmp ebx,edi
	jae fill_ramp
	mov edi,ebx
fill_ramp:
	pop edx  ; <- MixPtr
	sub ebp,edi
	lea eax,[edx+edi*8]
	push eax ; MixPtr += (SamplesToMix<<3)
	; tail    : [arg0]
	; len     : EDI
	; mixptr  : EDX
	; _mod+36 : ESI
	call Ramp
if INFO_API_ON
	lea eax,[edi+edi*4]
	cdq
	shl eax,2
	mov ecx,FSOUND_MixRate/50
	div ecx
	; time_ms += SamplesToMix*FSOUND_OOMixRate*1000
	add [time_ms],eax
endif
	sub ebx,edi ; MixedLeft -= SamplesToMix
	test ebp,ebp
	jnz fill_loop_1
	mov [esi+uF_MOD_mixer_samplesleft-36],ebx ; <= MixedLeft
if INFO_API_ON
	mov edx,[uFMOD_FillBlk]
	lea edx,[edx*uF_STATS_size + OFFSET tInfo+4]
	mov ecx,[esi + uF_MOD_row-36]
	or ecx,[esi + uF_MOD_order-2-36]
	mov [edx],ecx
endif
do_swfill:
	; *** CLIP AND COPY BLOCK TO OUTPUT BUFFER
	pop eax ; skip MixPtr
	pop esi ; <- mixbuffer
if INFO_API_ON
	; ebx : L channel RMS volume
	; ebp : R channel RMS volume
	xor ebx,ebx
endif
if DRIVER_DIRECTSOUND
	mov eax,[esi-8] ; uFMOD_FillBlk
	; Lock the output buffer
	cdq
	shl eax,FSOUND_Block+2 ; x FSOUND_BlockSize*4
	mov edi,OFFSET mmt
	push edx ; Lock:dwFlags
	push edx ; Lock:pdwAudioBytes2
	push edx ; Lock:ppvAudioPtr2
	push edi ; Lock:pdwAudioBytes1
	stosd
	push edi ; Lock:ppvAudioPtr1
	push FSOUND_BlockSize*4 ; Lock:dwBytes
	push eax ; Lock:dwOffset
	mov eax,[edi+16]
	push eax ; this
	mov ecx,[eax]
	call DWORD PTR [ecx+44] ; IDirectSoundBuffer::Lock
	test eax,eax
	jns DS_lock_ok
	cmp eax,88780096h ; DSERR_BUFFERLOST
	jne DS_R
	; Try to restore the buffer
	mov eax,[edi+16]
	push eax ; this
	mov ecx,[eax]
	call DWORD PTR [ecx+80] ; IDirectSoundBuffer::Restore
	jmp DS_R
DS_lock_ok:
	mov ecx,[edi-4]
	mov edi,[edi]   ; <dest. ptr>
endif
if DRIVER_WINMM
	mov eax,[esi-8] ; uFMOD_FillBlk
	shl eax,FSOUND_Block+2 ; x FSOUND_BlockSize*4
	lea edi,[eax+OFFSET databuf]
endif
if DRIVER_OPENAL
	mov edi,esi
	push FSOUND_MixRate     ; freq
	push FSOUND_BlockSize*4 ; size
	push esi                ; *data
endif
if DRIVER_DIRECTSOUND
	shr ecx,1
	jz SW_Fill_Ret
else
	mov ecx,FSOUND_BlockSize*2
endif
	align 4
fill_loop_2:
	lodsd
if INFO_API_ON
	push edi
	cdq
	mov edi,eax
	push esi
	xor eax,edx
	mov esi,255*volumerampsteps/2
	sub eax,edx
	xor edx,edx
	div esi
	cmp edx,255*volumerampsteps/4
	pop esi
	sbb eax,-1
	cmp eax,8000h
	sbb edx,edx
	not edx
	or eax,edx
	sar edi,31
	and eax,7FFFh
if VOL_CONTROL_ON
	mul DWORD PTR [ufmod_vol]
	shr eax,15
endif
	; sum. the L and R channel RMS volume
	ror ecx,1
	sbb edx,edx
	and edx,eax
	add ebp,edx ; += |vol|
	rol ecx,1
	sbb edx,edx
	not edx
	and edx,eax
	add ebx,edx ; += |vol|
	xor eax,edi
	sub eax,edi
	pop edi
else
	mov ebx,eax
	cdq
	xor eax,edx
	sub eax,edx
	mov ebp,255*volumerampsteps/2
	xor edx,edx
	div ebp
	cmp edx,255*volumerampsteps/4
	sbb eax,-1
	cmp eax,8000h
	sbb edx,edx
	not edx
	or eax,edx
	sar ebx,31
	and eax,7FFFh
if VOL_CONTROL_ON
	mul DWORD PTR [ufmod_vol]
	shr eax,15
endif
	xor eax,ebx
	sub eax,ebx
endif
	dec ecx
	stosw
	jnz fill_loop_2
SW_Fill_Ret:
if DRIVER_DIRECTSOUND
	; Unlock the output buffer
	mov edi,OFFSET mmt
	push ecx                  ; Unlock:pdwAudioBytes2
	push ecx                  ; Unlock:ppvAudioPtr2
	push DWORD PTR [edi]      ; Unlock:pdwAudioBytes1
	push DWORD PTR [edi+4]    ; Unlock:ppvAudioPtr1
	mov eax,[edi+20]
	push eax ; this
	mov ecx,[eax]
	call DWORD PTR [ecx+76]   ; IDirectSoundBuffer::Unlock
DS_R:
endif
if DRIVER_OPENAL
	push 1103h                ; format = AL_FORMAT_STEREO16
	push DWORD PTR [mmt]      ; buffer
	call alBufferData
	push OFFSET mmt           ; *buffers
	push 1                    ; n
	push DWORD PTR [hWaveOut] ; source
	call alSourceQueueBuffers
	add esp,32
endif
	mov eax,[uFMOD_FillBlk]
	inc eax
	cmp eax,totalblocks
	jl SW_Fill_R
	xor eax,eax
SW_Fill_R:
	mov [uFMOD_FillBlk],eax
if INFO_API_ON
	shr ebp,FSOUND_Block      ; R_vol / FSOUND_BlockSize
	shl ebx,16-FSOUND_Block   ; (L_vol / FSOUND_BlockSize) << 16
	mov bx,bp
	mov DWORD PTR [OFFSET tInfo+eax*uF_STATS_size],ebx
endif
	pop ebp
	pop edi
	pop esi
	pop ebx
if BENCHMARK_ON
	dw 310Fh ; rdtsc
	sub eax,[bench_t_lo]
	mov [_uFMOD_tsc],eax
endif
	ret
