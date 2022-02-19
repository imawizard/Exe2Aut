
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
;     3_3_8_1
;     3_3_8_0
;     3_3_7_23
;     3_3_7_22
;     3_3_7_21
;     3_3_7_20
;     3_3_7_19
;     3_3_7_18
;     3_3_7_17
;     3_3_7_15
;     3_3_7_14
;     3_3_7_13
;     3_3_7_12
;     3_3_7_11
;     3_3_7_10
;     3_3_7_9
;     3_3_7_8
_ptrn_3_3_7_7  db 032h,0C0h,0E9h,000h,000h,000h,0FFh,08Bh,000h,000h,08Bh
;     3_3_7_6
;     3_3_7_5
;     3_3_7_4
;     3_3_7_3
;     3_3_7_2
;     3_3_7_1
_ptrn_3_3_7_0  db 059h,0EBh,000h,08Bh,000h,010h,08Bh,000h,08Bh
;     3_3_6_1
;     3_3_6_0
;     3_3_4_0
;     3_3_2_0
_ptrn_3_3_0_0  db 0FFh,08Bh,000h,000h,000h,08Bh,000h,000h,000h,00Fh,0B6h
;     3_2_12_1
;     3_2_12_0
_ptrn_3_2_10_0 db 059h,0EBh,000h,08Bh,000h,000h,08Bh,000h,08Bh
;     3_2_8_1
_ptrn_3_2_8_0  db 059h,0EBh,000h,08Bh,000h,000h,000h,08Bh,000h,08Bh
;
;     UNICODE
;     3_2_10_0 falls under 3_3_7_0
;     3_2_6_0  falls under 3_3_7_0
;
;     ANSI
;     3_2_6_0  falls under 3_2_10_0
;
;=====================================================================================
_mask _3_3_7_7	, 'xxx...xx..x' ,8,10
_mask _3_3_7_0	, 'xx.x.xx.x'	,4,6
_mask _3_3_0_0	, 'xx...x...xx' ,6,9
_mask _3_2_10_0 , 'xx.x..x.x'	,4,6
_mask _3_2_8_0	, 'xx.x...x.x'	,4,7
;=====================================================================================
_ptrn_open    db 055h,08Bh,0ECh,083h,0E4h,0F8h,081h,0ECh,000h,001h,000h,000h,053h,056h
_ptrn_open2   db 055h,08Bh,0ECh,083h,0E4h,0F8h,081h,0ECh,000h,001h,000h,000h,056h,068h
_ptrn_extract db 055h,08Bh,0ECh,083h,0E4h,0F8h,0B8h,000h,000h,001h,000h,0E8h
_mask _open    , 'xxxxxxxx.xxxxx'
_mask _open2   , 'xxxxxxxx.xxxxx'
_mask _extract , 'xxxxxxx..xxx'
;=====================================================================================
