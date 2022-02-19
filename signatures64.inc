
macro random x,y
 { if ~ defined random_seed
    random_seed=%t
   end if
   random_seed=((random_seed*8088405h+1) shr 16) and $FFFF'FFFF
   if x eq
    rand=random_seed
   else
    if y eq
     rand=random_seed mod x
    else
     rand=random_seed mod (y-x+1)+x
    end if
   end if }

macro _mask ver,mask,modrm,count
 { local c
   _mask#ver db mask
   _size#ver = $-_mask#ver
   if ~ modrm eq
   _modrm#ver = modrm
   _count#ver = count
   end if
   repeat _size#ver
    load c from _mask#ver+%-1
    if c='x'
     random 0,9
     while rand=1
      random 0,9
     end while
     c=rand
    else
     c=1
    end if
    store c at _mask#ver+%-1
   end repeat }

;=====================================================================================
;     3_3_9_0
;     3_3_8_0
;     3_3_7_23
;     3_3_7_22
;     3_3_7_21
;     3_3_7_20
;     3_3_7_19
;     3_3_7_18
;     3_3_7_17
;     3_3_7_16
;     3_3_7_15
;     3_3_7_14
;     3_3_7_13
;     3_3_7_12
;     3_3_7_11
;     3_3_7_10
;     3_3_7_9
;     3_3_7_8
_ptrn_3_3_7_7  db 032h,0C0h,0E9h,000h,000h,000h,0FFh,033h,000h,04Ch,089h,000h,000h,000h,000h,000h,000h,04Ch,08Bh
;     3_3_7_6
;     3_3_7_5
;     3_3_7_4
;     3_3_7_3
;     3_3_7_2
;     3_3_7_1
_ptrn_3_3_7_0  db 048h,083h,000h,000h,000h,048h,083h,000h,000h,000h,048h,083h,000h,000h,000h,04Ch,08Bh,000h,000h,000h,083h,000h,0FFh
;     3_3_6_1
;     3_3_6_0
;     3_3_4_0
;     3_3_2_0
_ptrn_3_3_0_0  db 032h,0C0h,0E9h,000h,000h,000h,0FFh,04Ch,08Bh,000h,000h,000h,033h
;     3_2_12_1
;     3_2_12_0
_ptrn_3_2_10_0 db 048h,083h,000h,000h,000h,000h,048h,083h,000h,000h,000h,000h,048h,083h,000h,000h,000h,000h,04Ch,08Bh,000h,000h,000h,000h,083h,000h,0FFh
;=====================================================================================
_mask _3_3_7_7	, 'xxx...xx.xx......xx' 	,19,21
_mask _3_3_7_0	, 'xx..xxx..xxx..xxx...x.x'	,17,19
_mask _3_3_0_0	, 'xxx...xxx...x'		, 9,12
_mask _3_2_10_0 , 'xx...xxx...xxx...xxx....x.x' ,20,23
;=====================================================================================
; EXEARC
;=====================================================================================
