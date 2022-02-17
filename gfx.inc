
ORBS	 = 250
RADIUS	 = 20
MIN_INIT = 200
MIN_TEXT = 30
MIN_DONE = 100

struct ORB
  angle dd ?
  radius dd ?
  rate dd ?
  backwards db ?
ends

proc GFX_INIT hwnd
	push	edi
	push	[hwnd]
	call	[GetDC]
	mov	edi,eax
	push	eax
	call	[CreateCompatibleDC]
	mov	[GFX_hDC],eax
	push	GFX_Rect
	push	[hwnd]
	call	[GetClientRect]
	mov	edx,[GFX_Rect.bottom]
	mov	ecx,[GFX_Rect.right]
	mov	[GFX_Height],edx
	mov	[GFX_Width],ecx
	push	edx
	push	ecx
	shr	edx,1
	shr	ecx,1
	dec	edx
	dec	ecx
	mov	[GFX_MY],edx
	mov	[GFX_MX],ecx
	push	edi
	call	[CreateCompatibleBitmap]
	push	eax
	push	[GFX_hDC]
	call	[SelectObject]
	push	edi
	call	[ReleaseDC]
	push	TRANSPARENT
	push	[GFX_hDC]
	call	[SetBkMode]
	push	_terminal
	push	FIXED_PITCH+FF_MODERN
	push	DEFAULT_QUALITY
	push	CLIP_DEFAULT_PRECIS
	push	OUT_DEFAULT_PRECIS
	push	OEM_CHARSET
	push	0
	push	0
	push	0
	push	0
	push	0
	push	0
	push	5
	push	-12
	call	[CreateFont]
	push	eax
	push	[GFX_hDC]
	call	[SelectObject]
	push	BLACK_BRUSH
	call	[GetStockObject]
	mov	[GFX_Black],eax
	mov	[GFX_Min],MIN_INIT
	mov	[GFX_Burst],0
	mov	[GFX_Done],0
	mov	[GFX_TextColor],0
	push	180
	fldpi
	fidiv	dword [esp]
	fstp	[radf]
	add	esp,4
	call	GFX_ORBS
	pop	edi
	ret
endp

proc GFX_ORBS
	push	ebx edi
	mov	ebx,ORBS
	mov	edi,orbs
    .loop:
	mov	eax,360
	call	random
	inc	eax
	mov	[edi+ORB.angle],eax
	test	ebx,3
	je	.border
	mov	eax,32
	call	random
	mov	[edi+ORB.radius],eax
	jmp	.next
      .border:
	mov	[edi+ORB.radius],50
	mov	[edi+ORB.backwards],1
      .next:
	mov	eax,8
	call	random
	mov	[edi+ORB.rate],eax
	add	edi,sizeof.ORB
	dec	ebx
	jnz	.loop
	pop	edi ebx
	ret
endp

proc GFX_SHOW hDestDC
	push	SRCCOPY
	push	0
	push	0
	push	[GFX_hDC]
	push	[GFX_Height]
	push	[GFX_Width]
	push	0
	push	0
	push	[hDestDC]
	call	[BitBlt]
	ret
endp

proc GFX_UPDATE
	push	[GFX_Black]
	push	GFX_Rect
	push	[GFX_hDC]
	call	[FillRect]
	push	ebx edi
	mov	ebx,ORBS
	mov	edi,orbs
    .loop:
	cmp	[GFX_Burst],1
	je	.burst
	cmp	[edi+ORB.backwards],1
	je	.backwards
	mov	eax,[edi+ORB.rate]
	shr	eax,1
	inc	eax
	add	[edi+ORB.angle],eax
	push	ebx
	xor	ebx,ebx
      .left:
	mov	eax,[edi+ORB.angle]
	sub	eax,ebx
	push	[edi+ORB.radius]
	push	eax
	call	calc_pos
	add	edx,[GFX_MY]
	add	eax,[GFX_MX]
	push	eax
	mov	ecx,0FFFFFFh
	mov	eax,0303030h
	imul	eax,ebx
	sub	ecx,eax
	pop	eax
	push	ecx
	push	edx
	push	eax
	push	[GFX_hDC]
	call	[SetPixel]
	inc	ebx
	cmp	ebx,5
	jb	.left
	pop	ebx
	cmp	[edi+ORB.angle],360
	jb	.next
	mov	[edi+ORB.angle],1
	mov	eax,8
	call	random
	mov	[edi+ORB.rate],eax
	jmp	.next
    .backwards:
	mov	eax,[edi+ORB.rate]
	shr	eax,2
	inc	eax
	sub	[edi+ORB.angle],eax
	push	ebx
	xor	ebx,ebx
      .right:
	mov	eax,[edi+ORB.angle]
	mov	ecx,[edi+ORB.radius]
	add	eax,ebx
	movzx	edx,[GFX_Spiked+eax]
	add	ecx,edx
	push	ecx
	push	eax
	call	calc_pos
	add	edx,[GFX_MY]
	add	eax,[GFX_MX]
	push	eax
	mov	ecx,0FFFFFFh
	mov	eax,0303030h
	imul	eax,ebx
	sub	ecx,eax
	pop	eax
	push	ecx
	push	edx
	push	eax
	push	[GFX_hDC]
	call	[SetPixel]
	inc	ebx
	cmp	ebx,5
	jb	.right
	pop	ebx
	cmp	[edi+ORB.angle],0
	jg	.next
	mov	[edi+ORB.angle],360
	mov	eax,8
	call	random
	mov	[edi+ORB.rate],eax
	jmp	.next
    .burst:
	mov	eax,[edi+ORB.rate]
	shr	eax,1
	inc	eax
	add	[edi+ORB.radius],eax
	mov	eax,[GFX_Min]
	mov	edx,[edi+ORB.radius]
	cmp	eax,edx
	cmovnb	eax,edx
	mov	[GFX_Min],eax
	push	ebx
	xor	ebx,ebx
      .other:
	mov	eax,[edi+ORB.radius]
	sub	eax,ebx
	push	eax
	push	[edi+ORB.angle]
	call	calc_pos
	add	edx,[GFX_MY]
	add	eax,[GFX_MX]
	push	eax
	mov	ecx,0FFFFFFh
	mov	eax,0303030h
	imul	eax,ebx
	sub	ecx,eax
	pop	eax
	push	ecx
	push	edx
	push	eax
	push	[GFX_hDC]
	call	[SetPixel]
	inc	ebx
	cmp	ebx,5
	jb	.other
	pop	ebx
    .next:
	add	edi,sizeof.ORB
	dec	ebx
	jnz	.loop
	cmp	[GFX_Burst],1
	jnz	.fin
	cmp	[GFX_Min],MIN_DONE
	seta	al
	mov	[GFX_Done],al
	cmp	[GFX_Min],MIN_TEXT
	jb	.notext
	cmp	[GFX_TextColor],0FCFCFCh
	je	.white
	add	[GFX_TextColor],0040404h
      .white:
	push	[GFX_TextColor]
	push	[GFX_hDC]
	call	[SetTextColor]
	push	DT_CENTER+DT_VCENTER+DT_SINGLELINE
	push	GFX_Rect
	push	lamelen
	push	_lame
	push	[GFX_hDC]
	call	[DrawText]
      .notext:
	mov	[GFX_Min],MIN_INIT
    .fin:
	pop	edi ebx
	ret
endp

proc calc_pos angle,radius
  local x:DWORD,y:DWORD
	mov	eax,[radius]
	add	eax,RADIUS
	push	eax
	fild	dword [esp]
	add	esp,4
	fild	[angle]
	fld	[radf]
	fmulp
	fsincos
	fmul	st,st2
	fistp	[x]
	fmulp
	fistp	[y]
	mov	eax,[x]
	mov	edx,[y]
	ret
endp

macro gfx_idata
 {

  _terminal db 'Terminal',0
  _lame db 'wow, this looks so lame'
  lamelen = $-_lame

  GFX_Spiked db 14 dup (2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,6,8,10,10,10,10,10,10,10,10,8,6,4)

 }

macro gfx_udata
 {

  orbs rb sizeof.ORB*ORBS

  GFX_hDC rd 1
  GFX_Width rd 1
  GFX_Height rd 1
  GFX_Rect RECT
  GFX_MX rd 1
  GFX_MY rd 1
  GFX_Black rd 1

  GFX_Min rd 1
  GFX_Burst rb 1
  GFX_Done rb 1
  GFX_TextColor rd 1

  radf rq 1

 }
