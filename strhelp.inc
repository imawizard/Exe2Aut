
macro toupper [reg]
 { forward
    local .skip
    cmp reg,'a'
    jb .skip
    cmp reg,'z'
    ja .skip
    sub reg,' '
   .skip: }

proc Dupe src
	push	[src]
	call	[strlen]
	add	esp,4
	inc	eax
	push	eax
	push	0
	call	[LocalAlloc]
	push	[src]
	push	eax
	call	[strcpy]
	mov	eax,[esp]
	add	esp,8
	ret
endp

proc stristr c src,find
	push	esi
	mov	edx,[find]
	mov	esi,[src]
	xor	ecx,ecx
	jmp	.next
    .reset:
	sub	edx,ecx
	xor	ecx,ecx
    .next:
	mov	al,[edx]
	inc	ecx
	inc	edx
	test	al,al
	je	.found
	toupper al
    .compare:
	mov	ah,[esi]
	test	ah,ah
	je	.err
	toupper ah
	inc	esi
	cmp	al,ah
	je	.next
	cmp	ecx,1
	je	.compare
	dec	esi
	jmp	.reset
    .err:
	xor	eax,eax
	jmp	.fin
    .found:
	neg	ecx
	lea	eax,[esi+ecx+1]
    .fin:
	pop	esi
	ret
endp

proc Replace src,find,repl
  local flen:DWORD,rlen:DWORD,diff:DWORD,empty:BYTE
	push	ebx esi edi
	lea	eax,[empty]
	mov	esi,[src]
	mov	edi,[repl]
	mov	byte [eax],0
	test	edi,edi
	cmove	edi,eax
	push	edi
	call	[strlen]
	mov	[rlen],eax
	push	[find]
	call	[strlen]
	mov	[flen],eax
	sub	eax,[rlen]
	mov	[diff],eax
	add	esp,8
	push	[find]
	test	eax,eax
	js	.bigger
	jnz	.smaller
	mov	ebx,[flen]
	mov	edi,[repl]
    .loop:
	push	esi
	call	[strstr]
	add	esp,4
	test	eax,eax
	je	.fin
	push	ebx
	push	edi
	push	eax
	call	[strncpy]
	add	esp,0Ch
	lea	esi,[eax+ebx]
	jmp	.loop
    .smaller:
	mov	ebx,[rlen]
	mov	edi,[diff]
      .loop2:
	push	esi
	call	[strstr]
	add	esp,4
	test	eax,eax
	je	.fin
	lea	esi,[eax+ebx]
	push	ebx
	push	[repl]
	push	eax
	call	[strncpy]
	lea	ecx,[esi+edi]
	push	ecx
	push	esi
	call	[strcpy]
	add	esp,14h
	jmp	.loop2
    .bigger:
	neg	[diff]
	push	esi
	call	[strlen]
	mov	[esp],eax
	push	esi
	call	[LocalSize]
	push	eax
	test	eax,eax
	je	.noresize
	mov	edi,[flen]
	xor	ebx,ebx
	mov	eax,esi
	push	[find]
    .count:
	push	eax
	call	[strstr]
	mov	ecx,eax
	add	esp,4
	add	eax,edi
	inc	ebx
	test	ecx,ecx
	jnz	.count
	add	esp,4
	dec	ebx
	imul	ebx,[diff]
	add	ebx,[esp+4]
	inc	ebx
	cmp	ebx,[esp]
	jna	.noresize
	push	LMEM_MOVEABLE
	push	ebx
	push	esi
	call	[LocalReAlloc]
	mov	esi,eax
	mov	[src],eax
      .noresize:
	add	esp,4
	mov	ebx,[flen]
	pop	edi
	inc	edi
      .loop3:
	push	esi
	call	[strstr]
	add	esp,4
	mov	edx,eax
	test	eax,eax
	je	.fin
	sub	edx,esi
	lea	esi,[eax+ebx]
	mov	ecx,[diff]
	sub	edi,edx
	sub	edi,ebx
	lea	edx,[esi+ecx]
	push	[rlen]
	push	[repl]
	push	eax
	push	edi
	push	esi
	push	edx
	add	esi,ecx
	call	[memmove]
	add	esp,0Ch
	call	[strncpy]
	add	esp,0Ch
	jmp	.loop3
    .fin:
	add	esp,4
	mov	eax,[src]
	pop	edi esi ebx
	ret
endp

proc iReplace src,find,repl
  local flen:DWORD,rlen:DWORD,diff:DWORD,empty:BYTE
	push	ebx esi edi
	lea	eax,[empty]
	mov	esi,[src]
	mov	edi,[repl]
	mov	byte [eax],0
	test	edi,edi
	cmove	edi,eax
	push	edi
	call	[strlen]
	mov	[rlen],eax
	push	[find]
	call	[strlen]
	mov	[flen],eax
	sub	eax,[rlen]
	mov	[diff],eax
	add	esp,8
	push	[find]
	test	eax,eax
	js	.bigger
	jnz	.smaller
	mov	ebx,[flen]
	mov	edi,[repl]
    .loop:
	push	esi
	call	stristr
	add	esp,4
	test	eax,eax
	je	.fin
	push	ebx
	push	edi
	push	eax
	call	[strncpy]
	add	esp,0Ch
	lea	esi,[eax+ebx]
	jmp	.loop
    .smaller:
	mov	ebx,[rlen]
	mov	edi,[diff]
      .loop2:
	push	esi
	call	stristr
	add	esp,4
	test	eax,eax
	je	.fin
	lea	esi,[eax+ebx]
	push	ebx
	push	[repl]
	push	eax
	call	[strncpy]
	lea	ecx,[esi+edi]
	push	ecx
	push	esi
	call	[strcpy]
	add	esp,14h
	jmp	.loop2
    .bigger:
	neg	[diff]
	push	esi
	call	[strlen]
	mov	[esp],eax
	push	esi
	call	[LocalSize]
	push	eax
	test	eax,eax
	je	.noresize
	mov	edi,[flen]
	xor	ebx,ebx
	mov	eax,esi
	push	[find]
    .count:
	push	eax
	call	stristr
	mov	ecx,eax
	add	esp,4
	add	eax,edi
	inc	ebx
	test	ecx,ecx
	jnz	.count
	add	esp,4
	dec	ebx
	imul	ebx,[diff]
	add	ebx,[esp+4]
	inc	ebx
	cmp	ebx,[esp]
	jna	.noresize
	push	LMEM_MOVEABLE
	push	ebx
	push	esi
	call	[LocalReAlloc]
	mov	esi,eax
	mov	[src],eax
      .noresize:
	add	esp,4
	mov	ebx,[flen]
	pop	edi
	inc	edi
      .loop3:
	push	esi
	call	stristr
	add	esp,4
	mov	edx,eax
	test	eax,eax
	je	.fin
	sub	edx,esi
	lea	esi,[eax+ebx]
	mov	ecx,[diff]
	sub	edi,edx
	sub	edi,ebx
	lea	edx,[esi+ecx]
	push	[rlen]
	push	[repl]
	push	eax
	push	edi
	push	esi
	push	edx
	add	esi,ecx
	call	[memmove]
	add	esp,0Ch
	call	[strncpy]
	add	esp,0Ch
	jmp	.loop3
    .fin:
	add	esp,4
	mov	eax,[src]
	pop	edi esi ebx
	ret
endp

proc Split src,dlmtr
  local len:DWORD
	push	ebx esi edi
	push	[dlmtr]
	call	[strlen]
	add	esp,4
	mov	[len],eax
	xchg	eax,edi
	mov	esi,[src]
	mov	eax,[src]
	xor	ebx,ebx
	push	[dlmtr]
    .count:
	push	eax
	call	[strstr]
	mov	ecx,eax
	add	esp,4
	add	eax,edi
	inc	ebx
	test	ecx,ecx
	jnz	.count
	add	esp,4
	lea	ecx,[ebx-1]
	dec	edi
	imul	edi,ecx
	push	esi
	call	[strlen]
	add	esp,4
	lea	ecx,[ebx*4+4]
	sub	eax,edi
	add	eax,ecx
	mov	edi,ecx
	inc	eax
	push	eax
	push	0
	call	[LocalAlloc]
	mov	dword [eax+ebx*4],0
	push	ebx
	mov	ebx,eax
	add	edi,eax
	push	eax
	push	[dlmtr]
    .loop:
	mov	[ebx],edi
	push	esi
	call	[strstr]
	add	esp,4
	test	eax,eax
	je	.fin
	mov	edx,eax
	sub	eax,esi
	push	eax
	push	esi
	push	edi
	mov	byte [edi+eax],0
	mov	esi,edx
	add	edi,eax
	add	esi,[len]
	inc	edi
	call	[strncpy]
	add	esp,0Ch
	add	ebx,4
	jmp	.loop
    .fin:
	push	esi
	push	edi
	call	[strcpy]
	add	esp,0Ch
	pop	eax
	pop	edx
	pop	edi esi ebx
	ret
endp

proc hextoa dest,src
	push	esi edi
	mov	edi,[dest]
	mov	esi,[src]
    .loop:
	movzx	eax,word [esi]
	movzx	ecx,word [esi]
	test	al,al
	je	.fin
	sub	eax,'00'
	sub	ecx,'00'
	and	eax,1010h
	shr	eax,4
	imul	eax,7
	sub	ecx,eax
	and	ecx,0F0Fh
	shl	cl,4
	or	cl,ch
	mov	[edi],cl
	add	esi,2
	inc	edi
	jmp	.loop
    .fin:
	mov	byte [edi],0
	mov	eax,[dest]
	pop	edi esi
	ret
endp

macro awtoi src,m
 { irps r,a b c d
   \{
     irps h,l h
     \\{
	match =src,r\\#h
	\\\{
	 \\\local ._l
	    sub src,'0'
	    cmp src,10
	    jb ._l
	    sub src,7
	   ._l:
	    and src,0Fh
	\\\}
     \\}
     match =src, r\#x
     \\{
	sub src,'00'
	irps h,l h
	\\\{
	 \\\local ._l
	    cmp r\\\#h,10
	    jb ._l
	    sub r\\\#h,7
	   ._l:
	\\\}
	and src,0F0Fh
	if m eq | m eq 1
	 shl r\#l,4
	 or r\#l,r\#h
	else
	 shl r\#l,4
	 or r\#h,r\#l
	end if
     \\}
   \} }

macro escape r1,r2,index,m,succ,fail,[list]
 { common
    mov r2,[edx+index]
    mov r1,[edx+index]
   forward
    cmp r2,list
    je succ
   common
    mov r1,10
    cmp r2,'n'
    je succ
    mov r1,13
    cmp r2,'r'
    je succ
    mov r1,9
    cmp r2,'t'
    je succ
    xor r1,r1
    cmp r2,'0'
    je succ
    mov r1,'\'
    cmp r2,'\'
    je succ
    cmp r2,'x'
    jnz fail
    irps r,a b c d
    \{
      irps h,l h
      \\{
	 match =r1,r\\#h
	 \\\{
	     mov r\#x,[edx+index+1]
	     add edx,2
	     if m eq
	      awtoi r\#x
	     else
	      awtoi r\#x,m
	     end if
	 \\\}
      \\}
    \} }

f_first     = 1
f_dontput   = 2
f_fliptable = 4
f_multiple  = 8
f_needed    = 10h
f_optional  = 20h
f_wildcard  = 40h
f_static    = 80h

proc strscan dest,src,fmt
  local table[256]:BYTE,deadlock:BYTE
	push	ebx esi edi
	mov	edi,[dest]
	mov	esi,[src]
	lea	ebx,[table]
	mov	edx,[fmt]
	xor	ecx,ecx
	mov	ax,[edx]
	cmp	al,'@'
	je	.static
	cmp	ax,'\@'
	je	.atchar
	jmp	.begin
      .static:
	or	ch,f_static
      .atchar:
	inc	edx
	mov	[fmt],edx
	jmp	.begin
    .reset:
	xor	ecx,ecx
	mov	edx,[fmt]
    .begin:
	or	ch,f_first
	jmp	.isfirst
    .next:
	and	ch,not (f_first+f_fliptable+f_multiple+f_optional+f_wildcard)
    .isfirst:
	mov	al,[edx]
	xor	cl,cl
	test	al,al
	je	.fin
	cmp	al,'\'
	je	.escape
	cmp	al,'|'
	je	.silent
	cmp	al,'`'
	je	.silent
	cmp	al,'´'
	je	.silent
	cmp	al,'&'
	je	.ampersand
	cmp	al,'$'
	je	.dollar
	cmp	al,'#'
	je	.hash
	cmp	al,'%'
	je	.percent
	cmp	al,'.'
	je	.wildcard
	cmp	al,'['
	je	.table
    .singlechar:
	mov	[ebx],al
	inc	cl
	jmp	.load
    .silent:
	xor	ch,f_dontput
    .break:
	inc	edx
	jmp	.isfirst
    .break2:
	inc	edx
	jmp	.next
    .percent:
	mov	ax,[edx+1]
	awtoi	ax
	movzx	eax,al
	sub	edi,eax
	add	edx,3
	cmp	edi,[dest]
	cmovb	edi,[dest]
	jmp	.isfirst
    .wildcard:
	or	ch,f_wildcard
	jmp	.load
    .escape:
	escape	al,ah,1,,.escaped,.singlechar,'|','`','´','&','$','#','%','.','['
      .escaped:
	inc	edx
	jmp	.singlechar
    .ampersand:
	mov	al,[edx+1]
	inc	edx
	test	al,al
	je	.abort
	cmp	al,'&'
	je	.break
	cmp	al,'\'
	je	.ampescape
      .ampwrite:
	mov	[edi],al
	inc	edi
	jmp	.ampersand
      .ampescape:
	escape	al,ah,1,,.ampescaped,.ampwrite,'&'
      .ampescaped:
	inc	edx
	jmp	.ampwrite
    .dlrreset:
	movzx	eax,cl
	sub	edx,eax
	xor	cl,cl
    .dollar:
	mov	al,[edx+1]
	inc	edx
	inc	cl
	test	al,al
	je	.abort
	cmp	al,'$'
	je	.break2
	cmp	al,'\'
	je	.dlrescape
      .dlrcompare:
	test	ch,f_dontput
	jnz	.dlrdontput
      .dlrput:
	mov	ah,[esi]
	inc	esi
	test	ah,ah
	je	.abort
	mov	[edi],ah
	inc	edi
	cmp	al,ah
	je	.dollar
	cmp	cl,1
	je	.dlrput
	dec	esi
	dec	edi
	jmp	.dlrreset
      .dlrdontput:
	mov	ah,[esi]
	inc	esi
	test	ah,ah
	je	.abort
	cmp	al,ah
	je	.dollar
	cmp	cl,1
	je	.dlrdontput
	dec	esi
	jmp	.dlrreset
      .dlrescape:
	escape	al,ah,1,,.dlrescaped,.dlrcompare,'$'
      .dlrescaped:
	inc	edx
	jmp	.dlrcompare
    .hashreset:
	movzx	eax,cl
	sub	edx,eax
	xor	cl,cl
    .hash:
	mov	al,[edx+1]
	inc	edx
	inc	cl
	test	al,al
	je	.abort
	cmp	al,'#'
	je	.break2
	cmp	al,'\'
	je	.hashescape
	toupper al
      .hashcompare:
	test	ch,f_dontput
	jnz	.hashdontput
      .hashput:
	mov	ah,[esi]
	inc	esi
	test	ah,ah
	je	.abort
	mov	[edi],ah
	inc	edi
	toupper ah
	cmp	al,ah
	je	.hash
	cmp	cl,1
	je	.hashput
	dec	esi
	dec	edi
	jmp	.hashreset
      .hashdontput:
	mov	ah,[esi]
	inc	esi
	test	ah,ah
	je	.abort
	toupper ah
	cmp	al,ah
	je	.hash
	cmp	cl,1
	je	.hashdontput
	dec	esi
	jmp	.hashreset
      .hashescape:
	escape	al,ah,1,,.hashescaped,.hashcompare,'#'
      .hashescaped:
	inc	edx
	jmp	.hashcompare
    .table:
	cmp	byte [edx+1],'^'
	jnz	.tblloop
	or	ch,f_fliptable
	inc	edx
      .tblloop:
	mov	ah,[edx+1]
	test	ah,ah
	je	.abort
	cmp	ah,']'
	je	.tblend
	cmp	ah,'['
	je	.const
	cmp	ah,'\'
	je	.tblsinesc
	cmp	ah,'-'
	jnz	.single
	mov	ah,[edx+2]
	inc	edx
	cmp	ah,'\'
	jnz	.range
	call	.tblescape
      .range:
	inc	al
	cmp	al,ah
	ja	.tblnext
	mov	[ebx],al
	inc	cl
	inc	ebx
	jmp	.range
      .tblsinesc:
	push	.single
      .tblescape:
	shl	ecx,16
	escape	ch,cl,2,2,.tblescaped,.tblnoescape,'[',']','-'
      .tblescaped:
	inc	edx
      .tblnoescape:
	mov	ah,ch
	shr	ecx,16
	retn
      .single:
	mov	[ebx],ah
	mov	al,ah
	inc	cl
	inc	ebx
      .tblnext:
	inc	edx
	jmp	.tblloop
      .const:
	mov	eax,[edx+3]
	cmp	eax,'alnu'
	je	.alnum
	cmp	eax,'word'
	je	.word
	cmp	eax,'alph'
	je	.alpha
	cmp	eax,'blan'
	je	.blank
	cmp	eax,'cntr'
	je	.cntrl
	cmp	eax,'digi'
	je	.digit
	cmp	eax,'grap'
	je	.graph
	cmp	eax,'lowe'
	je	.lower
	cmp	eax,'prin'
	je	.print
	cmp	eax,'punc'
	je	.punct
	cmp	eax,'spac'
	je	.space
	cmp	eax,'uppe'
	je	.upper
	cmp	eax,'xdig'
	je	.xdigit
	mov	ah,'\'
	jmp	.single
      .alnum:
	mov	ax,'AZ'
	call	.addrange
	mov	ax,'az'
	call	.addrange
	mov	ax,'09'
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .word:
	mov	ax,'AZ'
	call	.addrange
	mov	ax,'az'
	call	.addrange
	mov	ax,'09'
	call	.addrange
	mov	byte [ebx],'_'
	inc	cl
	inc	ebx
	add	edx,4+4
	jmp	.tblloop
      .alpha:
	mov	ax,'AZ'
	call	.addrange
	mov	ax,'az'
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .blank:
	mov	word [ebx],0920h
	add	cl,2
	add	ebx,2
	add	edx,4+5
	jmp	.tblloop
      .cntrl:
	mov	ax,1F00h
	call	.addrange
	mov	byte [ebx],7Fh
	inc	cl
	inc	ebx
	add	edx,4+5
	jmp	.tblloop
      .digit:
	mov	ax,'09'
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .graph:
	mov	ax,7E21h
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .lower:
	mov	ax,'az'
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .print:
	mov	ax,7E20h
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .punct:
	mov	dword [ebx+00h],'!"#$'
	mov	dword [ebx+04h],'%&''('
	mov	dword [ebx+08h],')*+,'
	mov	dword [ebx+0Ch],'-./:'
	mov	dword [ebx+10h],';<=>'
	mov	dword [ebx+14h],'?@[\'
	mov	dword [ebx+18h],']^_`'
	mov	dword [ebx+1Ch],'{|}~'
	add	cl,20h
	add	ebx,20h
	add	edx,4+5
	jmp	.tblloop
      .space:
	mov	dword [ebx+0],0A0D0920h
	mov	dword [ebx+4],1211h
	add	cl,6
	add	ebx,6
	add	edx,4+5
	jmp	.tblloop
      .upper:
	mov	ax,'AZ'
	call	.addrange
	add	edx,4+5
	jmp	.tblloop
      .xdigit:
	mov	ax,'AF'
	call	.addrange
	mov	ax,'af'
	call	.addrange
	mov	ax,'09'
	call	.addrange
	add	edx,4+6
	jmp	.tblloop
      .addrange:
	cmp	al,ah
	ja	.addrngend
	mov	[ebx],al
	inc	al
	inc	cl
	inc	ebx
	jmp	.addrange
      .addrngend:
	retn
      .tblend:
	inc	edx
	test	cl,cl
	je	.empty
	mov	ah,[edx+1]
	mov	al,f_multiple
	cmp	ah,'*'
	je	.modifier
	mov	al,f_needed
	cmp	ah,'+'
	je	.modifier
	mov	al,f_optional
	cmp	ah,'?'
	jnz	.load
      .modifier:
	or	ch,al
	inc	edx
	jmp	.load
      .empty:
	or	ch,f_wildcard
	and	ch,not f_fliptable
    .load:
	lea	ebx,[table]
      .modified:
	push	ecx
	test	ch,f_wildcard
	jnz	.found
      .search:
	mov	ah,[esi]
	test	ah,ah
	je	.cleanup
	xor	ch,ch
      .compare:
	mov	al,cl
	dec	al
	xlatb
	cmp	al,ah
	loopnz	.compare
	mov	cx,[esp]
	sete	cl
	test	ch,f_fliptable
	setnz	ch
	xor	cl,ch
	mov	cx,[esp]
	jnz	.found
	test	ch,f_optional+f_multiple
	jnz	.gotonext
	test	ch,f_static
	jnz	.abort
	test	ch,f_first
	je	.failed
	inc	esi
	jmp	.search
      .failed:
	add	esp,4
	cmp	[deadlock],1
	je	.avoid_lock
	mov	edi,[dest]
	jmp	.reset
      .avoid_lock:
	mov	[deadlock],0
	inc	esi
	mov	edi,[dest]
	jmp	.reset
      .gotonext:
	test	ch,f_first
	setnz	[deadlock]
	add	esp,4
	inc	edx
	jmp	.next
    .found:
	add	esp,4
	test	ch,f_dontput
	jnz	.ignore
	mov	[edi],ah
	inc	edi
      .ignore:
	inc	esi
	test	ch,f_needed
	jnz	.f_needed
	test	ch,f_multiple
	jnz	.f_multiple
	inc	edx
	jmp	.next
      .f_needed:
	or	ch,f_multiple
	and	ch,not f_needed
	jmp	.modified
      .f_multiple:
	sub	esp,4
	jmp	.search
    .cleanup:
	add	esp,4
    .abort:
	test	ch,f_multiple
	je	.err
	cmp	byte [edx+1],0
	je     .fin
    .err:
	mov	edi,[dest]
    .fin:
	cmp	[dest],0
	je	.posonly
	mov	byte [edi],0
	mov	ecx,edi
	mov	edx,edi
	sub	ecx,[dest]
    .posonly:
	mov	eax,esi
	sub	edx,ecx
	pop	edi esi ebx
	ret
endp
