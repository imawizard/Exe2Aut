;
; un[f]ancy [d]isassembler [e]ngine (fde32) v0.01
;

  ; structure representing any instruction

struct fde32s
  len	      rb 1
  prefix      rb 1
  prefix.lock rb 1
  prefix.rep  rb 1
  prefix.seg  rb 1
  prefix.66   rb 1
  prefix.67   rb 1
  vex	      rb 1
  vex2	      rb 1
  vex3	      rb 1
  vex.r       rb 1
  vex.x       rb 1
  vex.b       rb 1
  vex.m_mmmm  rb 1
  vex.w       rb 1
  vex.vvvv    rb 1
  vex.l       rb 1
  vex.pp      rb 1
  opcode.len  rb 1
  opcode      rb 1
  opcode2     rb 1
  opcode3     rb 1
  modrm       rb 1
  modrm.mod   rb 1
  modrm.reg   rb 1
  modrm.rm    rb 1
  sib	      rb 1
  sib.scale   rb 1
  sib.index   rb 1
  sib.base    rb 1
  union
    disp8     rb 1
    disp16    rw 1
    disp32    rd 1
  ends
  union
    imm8      rb 1
    imm16     rw 1
    imm32     rd 1
  ends
  union
    imm8_2    rb 1
    imm16_2   rw 1
  ends
  flags       rd 1
ends

  ; flags

  F_NONE	      = 00000000h
  F_MODRM	      = 00000001h
  F_SIB 	      = 00000002h
  F_DISP8	      = 00000004h
  F_DISP16	      = 00000008h
  F_DISP32	      = 00000010h
  F_DISP	      = F_DISP8+F_DISP16+F_DISP32
  F_IMM8	      = 00000020h
  F_IMM16	      = 00000040h
  F_IMM32	      = 00000080h
  F_IMM 	      = F_IMM8+F_IMM16+F_IMM32
  F_RELATIVE	      = 00000100h
  F_GROUP	      = 00000200h	; index specified in modrm.reg
  F_VEX_BAD_PREFIX    = 00000400h
  F_ERROR_LOCK	      = 00000800h	; lock-prefix not possible
  F_ERROR_LENGTH      = 00001000h
  F_ERROR_OPCODE      = 00002000h	; undefined opcode

  ; prefix flags

  PRE_NONE	      = 000h
  PRE_LOCK	      = 001h
  PRE_REP	      = 002h
  PRE_SEG	      = 004h
  PRE_66	      = 008h
  PRE_67	      = 010h
  PRE_VEX	      = 020h		; partly encoded in complements to distinguish from les/lds
  PRE_ALL	      = PRE_LOCK+PRE_REP+PRE_SEG+PRE_66+PRE_67
  PRE_ALL32	      = PRE_ALL+PRE_VEX

  ; vex-prefix m-mmmm

  M_MMMM_0F	      = 1
  M_MMMM_0F_38	      = 2
  M_MMMM_0F_3A	      = 3

  ; vex-prefix l

  L_SCALAR	      = 0
  L_128_VECTOR	      = 0
  L_256_VECTOR	      = 1

  ; vex-prefix pp

  PP_NONE	      = 0
  PP_66 	      = 1
  PP_F3 	      = 2
  PP_F2 	      = 3

  ; modr/m mod

  MOD_NODISP	      = 0
  MOD_DISP8	      = 1
  MOD_DISP16	      = 2
  MOD_DISP32	      = 2
  MOD_REG	      = 3

  ; modr/m reg

  ; GPRs
  REG_EAX	      = 0
  REG_ECX	      = 1
  REG_EDX	      = 2
  REG_EBX	      = 3
  REG_ESP	      = 4
  REG_EBP	      = 5
  REG_ESI	      = 6
  REG_EDI	      = 7
  REG_AL	      = REG_EAX
  REG_AH	      = REG_ESP
  REG_CL	      = REG_ECX
  REG_CH	      = REG_EBP
  REG_DL	      = REG_EDX
  REG_DH	      = REG_ESI
  REG_BL	      = REG_EBX
  REG_BH	      = REG_EDI
  ; special
  REG_CR0	      = REG_EAX
  REG_CR2	      = REG_EDX
  REG_CR3	      = REG_EBX
  REG_CR4	      = REG_ESP
  REG_DR0	      = REG_EAX
  REG_DR1	      = REG_ECX
  REG_DR2	      = REG_EDX
  REG_DR3	      = REG_EBX
  REG_DR4	      = REG_ESP 	; refers to DR6 if CR4.DE is cleared
  REG_DR5	      = REG_EBP 	; refers to DR7 ^
  REG_DR6	      = REG_ESI
  REG_DR7	      = REG_EDI
  ; MMX/XMM/YMM
  REG_SIMD0	      = REG_EAX
  REG_SIMD1	      = REG_ECX
  REG_SIMD2	      = REG_EDX
  REG_SIMD3	      = REG_EBX
  REG_SIMD4	      = REG_ESP
  REG_SIMD5	      = REG_EBP
  REG_SIMD6	      = REG_ESI
  REG_SIMD7	      = REG_EDI
  ; FPU
  REG_ST0	      = REG_EAX
  REG_ST1	      = REG_ECX
  REG_ST2	      = REG_EDX
  REG_ST3	      = REG_EBX
  REG_ST4	      = REG_ESP
  REG_ST5	      = REG_EBP
  REG_ST6	      = REG_ESI
  REG_ST7	      = REG_EDI
  ; Sregs
  SEG_ES	      = REG_EAX
  SEG_CS	      = REG_ECX
  SEG_SS	      = REG_EDX
  SEG_DS	      = REG_EBX
  SEG_FS	      = REG_ESP
  SEG_GS	      = REG_EBP

  ; modr/m r/m

  RM_SIB	      = REG_ESP
  RM_DISP16	      = REG_ESI
  RM_DISP32	      = REG_EBP

  ; sib scale

  SCALE_1	      = 0
  SCALE_2	      = 1
  SCALE_4	      = 2
  SCALE_8	      = 3

  ; prefixes

  PREFIX_SEGMENT_CS   = 02Eh
  PREFIX_SEGMENT_SS   = 036h
  PREFIX_SEGMENT_DS   = 03Eh
  PREFIX_SEGMENT_ES   = 026h
  PREFIX_SEGMENT_FS   = 064h
  PREFIX_SEGMENT_GS   = 065h
  PREFIX_LOCK	      = 0F0h
  PREFIX_REPNZ	      = 0F2h
  PREFIX_REP	      = 0F3h
  PREFIX_OPERAND_SIZE = 066h
  PREFIX_ADDRESS_SIZE = 067h
  PREFIX_VEX_2_BYTE   = 0C5h
  PREFIX_VEX_3_BYTE   = 0C4h

  ; encoding routine

proc encode				; 406 bytes

	db	$60, $89, $CF, $89, $D6, $51, $8A, $4E, $01, $F6, $C1, $04, $74, $04, $8A, $46
	db	$04, $AA, $F6, $C1, $10, $74, $03, $B0, $67, $AA, $F6, $C1, $20, $75, $22, $F6
	db	$C1, $01, $74, $03, $B0, $F0, $AA, $F6, $C1, $02, $74, $04, $8A, $46, $03, $AA
	db	$F6, $C1, $08, $74, $03, $B0, $66, $AA, $F6, $C1, $20, $0F, $84, $8C, $00, $00
	db	$00, $8A, $46, $07, $AA, $88, $C4, $80, $7E, $0A, $FF, $75, $0F, $8A, $46, $08
	db	$AA, $80, $FC, $C4, $75, $77, $8A, $46, $09, $AA, $EB, $71, $80, $FC, $C5, $75
	db	$25, $8A, $46, $0A, $8A, $66, $0F, $8A, $4E, $10, $8A, $6E, $11, $F6, $D0, $F6
	db	$D4, $C0, $E0, $07, $C0, $E4, $03, $C0, $E1, $02, $08, $E0, $08, $E9, $08, $C8
	db	$AA, $8A, $46, $14, $EB, $4A, $66, $8B, $46, $0A, $66, $8B, $4E, $0C, $66, $F7
	db	$D0, $F6, $D1, $C0, $E0, $07, $C0, $E4, $06, $C0, $E1, $05, $08, $E0, $08, $E9
	db	$08, $C8, $AA, $66, $8B, $46, $0E, $66, $8B, $4E, $10, $F6, $D4, $C0, $E0, $07
	db	$C0, $E4, $03, $C0, $E1, $02, $08, $E0, $08, $E9, $08, $C8, $AA, $8A, $66, $0D
	db	$8A, $46, $14, $80, $FC, $01, $74, $08, $8A, $46, $15, $EB, $03, $8A, $46, $13
	db	$AA, $F6, $46, $01, $20, $75, $14, $3C, $0F, $75, $10, $8A, $46, $14, $AA, $3C
	db	$38, $74, $04, $3C, $3A, $75, $04, $8A, $46, $15, $AA, $8B, $4E, $28, $F7, $C1
	db	$01, $00, $00, $00, $74, $1E, $80, $7E, $17, $FF, $75, $06, $8A, $46, $16, $AA
	db	$EB, $12, $66, $8B, $46, $17, $8A, $56, $19, $C0, $E0, $06, $C0, $E4, $03, $08
	db	$E0, $08, $D0, $AA, $F7, $C1, $02, $00, $00, $00, $74, $1E, $80, $7E, $1B, $FF
	db	$75, $06, $8A, $46, $1A, $AA, $EB, $12, $66, $8B, $46, $1B, $8A, $56, $1D, $C0
	db	$E0, $06, $C0, $E4, $03, $08, $E0, $08, $D0, $AA, $F7, $C1, $10, $00, $00, $00
	db	$74, $06, $8B, $46, $1E, $AB, $EB, $1C, $F7, $C1, $08, $00, $00, $00, $74, $08
	db	$66, $8B, $46, $1E, $66, $AB, $EB, $0C, $F7, $C1, $04, $00, $00, $00, $74, $04
	db	$8A, $46, $1E, $AA, $F7, $C1, $80, $00, $00, $00, $74, $04, $8B, $46, $22, $AB
	db	$F7, $C1, $40, $00, $00, $00, $74, $06, $66, $8B, $46, $22, $66, $AB, $F7, $C1
	db	$20, $00, $00, $00, $74, $04, $8A, $46, $22, $AA, $58, $97, $29, $F8, $88, $06
	db	$89, $44, $24, $1C, $61, $C3
endp

  ; decoding routine

proc decode				    ; 1225 bytes

	db	$60, $89, $CE, $51, $E8, $00, $00, $00, $00, $5D, $31, $C9, $30, $C0, $89, $D7
	db	$B1, $2C, $F3, $AA, $AC, $88, $C1, $88, $C5, $80, $E1, $FE, $80, $E5, $E7, $3C
	db	$F0, $74, $20, $80, $F9, $F2, $74, $24, $3C, $66, $74, $29, $3C, $67, $74, $2E
	db	$80, $F9, $64, $74, $05, $80, $FD, $2E, $75, $2D, $80, $4A, $01, $04, $88, $42
	db	$04, $EB, $D1, $80, $4A, $01, $01, $88, $42, $02, $EB, $C8, $80, $4A, $01, $02
	db	$88, $42, $03, $EB, $BF, $80, $4A, $01, $08, $88, $42, $05, $EB, $B6, $80, $4A
	db	$01, $10, $88, $42, $06, $EB, $AD, $80, $F9, $C4, $0F, $85, $D5, $00, $00, $00
	db	$88, $C1, $AC, $88, $C5, $80, $E5, $C0, $80, $FD, $C0, $74, $09, $83, $EE, $02
	db	$AC, $E9, $BF, $00, $00, $00, $C6, $42, $13, $0F, $80, $4A, $01, $20, $88, $4A
	db	$07, $88, $42, $08, $F6, $42, $01, $0B, $74, $07, $81, $4A, $28, $00, $04, $00
	db	$00, $80, $F9, $C5, $75, $2C, $88, $C4, $88, $C1, $88, $C5, $D0, $E4, $C0, $E1
	db	$05, $C0, $E8, $07, $C0, $EC, $04, $C0, $E9, $07, $80, $E5, $03, $0C, $FE, $80
	db	$CC, $F0, $F6, $D0, $F6, $D4, $88, $42, $0A, $88, $62, $0F, $66, $89, $4A, $10
	db	$EB, $5C, $88, $C4, $88, $C1, $88, $C5, $D0, $E4, $C0, $E1, $02, $C0, $E8, $07
	db	$C0, $EC, $07, $C0, $E9, $07, $80, $E5, $1F, $0C, $FE, $80, $CC, $FE, $80, $C9
	db	$FE, $F6, $D0, $F6, $D4, $F6, $D1, $66, $89, $42, $0A, $66, $89, $4A, $0C, $AC
	db	$88, $42, $09, $88, $C4, $88, $C1, $88, $C3, $D0, $E4, $C0, $E1, $05, $C0, $E8
	db	$07, $C0, $EC, $04, $C0, $E9, $07, $80, $E3, $03, $80, $CC, $F0, $F6, $D4, $66
	db	$89, $42, $0E, $88, $4A, $10, $88, $5A, $11, $80, $FD, $01, $75, $04, $B3, $FD
	db	$EB, $50, $B3, $FE, $B7, $38, $88, $7A, $14, $80, $FD, $02, $74, $59, $B7, $3A
	db	$88, $7A, $14, $EB, $52, $C6, $42, $12, $01, $88, $42, $13, $8D, $9D, $91, $03
	db	$00, $00, $88, $C4, $8A, $0B, $8A, $2B, $C0, $E9, $05, $80, $E5, $1F, $FE, $C1
	db	$43, $28, $C8, $73, $EF, $88, $E8, $8D, $9D, $7E, $03, $00, $00, $D7, $93, $80
	db	$FB, $FF, $75, $0E, $81, $4A, $28, $00, $20, $00, $00, $30, $DB, $E9, $7F, $01
	db	$00, $00, $80, $FB, $FD, $75, $10, $AC, $C6, $42, $12, $02, $88, $42, $14, $8D
	db	$9D, $F1, $03, $00, $00, $EB, $BB, $80, $FB, $FE, $75, $3F, $AC, $C6, $42, $12
	db	$03, $88, $42, $15, $31, $C9, $B4, $43, $B1, $38, $F6, $42, $01, $20, $74, $02
	db	$88, $E1, $8D, $BD, $33, $04, $00, $00, $B3, $01, $80, $FF, $38, $74, $14, $B4
	db	$20, $B1, $18, $F6, $42, $01, $20, $74, $02, $88, $E1, $8D, $BD, $76, $04, $00
	db	$00, $B3, $03, $F2, $AE, $75, $9D, $88, $C7, $EB, $1D, $80, $FB, $FB, $75, $18
	db	$8D, $7A, $1E, $F6, $42, $01, $10, $74, $08, $83, $4A, $28, $08, $66, $A5, $EB
	db	$8A, $83, $4A, $28, $10, $A5, $EB, $83, $F6, $C3, $01, $0F, $84, $C7, $00, $00
	db	$00, $AC, $83, $4A, $28, $01, $88, $42, $16, $88, $C1, $88, $C5, $C0, $E5, $02
	db	$C0, $E9, $06, $C0, $ED, $05, $24, $07, $66, $89, $4A, $17, $88, $42, $19, $8A
	db	$62, $13, $80, $E4, $FE, $80, $FC, $F6, $75, $07, $84, $ED, $74, $03, $80, $E3
	db	$F5, $F6, $42, $01, $10, $74, $1E, $80, $F9, $02, $74, $0D, $80, $F9, $01, $74
	db	$0E, $84, $C9, $75, $61, $3C, $06, $75, $5D, $83, $4A, $28, $08, $EB, $57, $83
	db	$4A, $28, $04, $EB, $51, $80, $F9, $02, $74, $0D, $80, $F9, $01, $74, $0E, $84
	db	$C9, $75, $0E, $3C, $05, $75, $0A, $83, $4A, $28, $10, $EB, $04, $83, $4A, $28
	db	$04, $80, $F9, $03, $74, $30, $3C, $04, $75, $2C, $AC, $83, $4A, $28, $02, $88
	db	$42, $1A, $88, $C4, $88, $C5, $C0, $E4, $02, $C0, $E8, $06, $C0, $EC, $05, $80
	db	$E5, $07, $66, $89, $42, $1B, $88, $6A, $1D, $84, $C9, $75, $09, $80, $FD, $05
	db	$75, $04, $83, $4A, $28, $10, $8D, $7A, $1E, $F7, $42, $28, $10, $00, $00, $00
	db	$74, $01, $A5, $F7, $42, $28, $08, $00, $00, $00, $74, $02, $66, $A5, $F7, $42
	db	$28, $04, $00, $00, $00, $74, $01, $A4, $8D, $7A, $22, $F6, $C3, $08, $74, $19
	db	$F6, $42, $01, $08, $74, $08, $83, $4A, $28, $40, $66, $A5, $EB, $08, $81, $4A
	db	$28, $80, $00, $00, $00, $A5, $8D, $7A, $26, $F6, $C3, $04, $74, $09, $83, $4A
	db	$28, $40, $66, $A5, $8D, $7A, $26, $F6, $C3, $02, $74, $05, $83, $4A, $28, $20
	db	$A4, $F6, $42, $01, $01, $74, $45, $F6, $C3, $01, $74, $39, $80, $F9, $03, $74
	db	$34, $B9, $12, $00, $00, $00, $8D, $BD, $AE, $04, $00, $00, $80, $7A, $13, $0F
	db	$74, $0E, $80, $E7, $FE, $B9, $18, $00, $00, $00, $8D, $BD, $96, $04, $00, $00
	db	$38, $3F, $8D, $7F, $02, $E0, $F9, $75, $0C, $8A, $4A, $18, $8A, $47, $FF, $FE
	db	$C1, $D2, $E8, $73, $07, $81, $4A, $28, $00, $08, $00, $00, $F6, $C3, $10, $74
	db	$07, $81, $4A, $28, $00, $01, $00, $00, $F6, $C3, $20, $74, $07, $81, $4A, $28
	db	$00, $02, $00, $00, $58, $96, $29, $F0, $88, $02, $3C, $0F, $72, $07, $81, $4A
	db	$28, $00, $10, $00, $00, $31, $C0, $F7, $42, $28, $00, $3C, $00, $00, $0F, $94
	db	$C0, $89, $44, $24, $1C, $61, $C3, $00, $01, $03, $09, $02, $04, $06, $08, $0C
	db	$12, $18, $21, $23, $29, $FB, $FC, $FD, $FE, $FF, $61, $04, $07, $20, $61, $04
	db	$07, $00, $10, $61, $04, $07, $20, $61, $04, $07, $20, $61, $04, $07, $0F, $00
	db	$61, $04, $07, $0F, $00, $61, $04, $07, $0F, $00, $61, $04, $07, $0F, $E0, $E0
	db	$E0, $E0, $40, $21, $6F, $07, $03, $04, $02, $60, $E9, $E9, $0C, $0D, $2C, $E1
	db	$61, $E0, $20, $08, $80, $6E, $60, $04, $07, $A0, $E4, $E7, $2C, $05, $00, $21
	db	$02, $03, $06, $00, $05, $20, $04, $20, $6B, $24, $20, $EB, $69, $64, $2A, $08
	db	$09, $60, $0F, $00, $2F, $20, $0C, $0D, $A0, $2B, $2B, $21, $12, $80, $12, $00
	db	$12, $0B, $00, $02, $E1, $00, $E1, $41, $72, $E1, $A0, $12, $00, $11, $12, $11
	db	$92, $E1, $E1, $E1, $E1, $E1, $E1, $02, $4C, $41, $00, $21, $32, $61, $EA, $EA
	db	$E1, $E1, $40, $01, $02, $01, $32, $40, $01, $02, $01, $0B, $E1, $41, $0C, $C1
	db	$02, $01, $42, $0B, $E0, $E1, $E1, $E1, $E1, $E1, $C1, $00, $00, $01, $02, $03
	db	$04, $05, $06, $07, $08, $09, $0A, $0B, $10, $14, $15, $17, $1C, $1D, $1E, $20
	db	$21, $22, $23, $24, $25, $28, $29, $2A, $2B, $30, $31, $32, $33, $34, $35, $37
	db	$38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $80, $81, $82, $DB, $DC, $DD
	db	$DE, $DF, $F0, $F1, $0C, $0D, $0E, $0F, $18, $19, $1A, $2C, $2D, $2E, $2F, $08
	db	$09, $0A, $0B, $0C, $0D, $0E, $0F, $14, $15, $16, $17, $20, $21, $22, $40, $41
	db	$42, $44, $60, $61, $62, $63, $DF, $04, $05, $06, $18, $19, $4A, $4B, $4C, $00
	db	$00, $08, $00, $10, $00, $18, $00, $20, $00, $28, $00, $30, $00, $80, $80, $82
	db	$80, $86, $00, $F6, $F3, $FE, $FC, $AB, $00, $B0, $00, $B1, $00, $B3, $00, $BA
	db	$1F, $BB, $00, $C0, $00, $C1, $00, $C7, $FD
endp
