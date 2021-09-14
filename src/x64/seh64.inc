
macro enqueue list,item
 { match any,list \{ list equ list,item \}
   match ,list \{ list equ item \} }

macro dequeue list,item
 { done@dequeue equ
   match first=,rest,list
   \{ item equ first
      list equ rest
      restore done@dequeue \}
   match :m,done@dequeue:list
   \{ item equ m
      list equ
      restore done@dequeue \}
   match ,done@dequeue
   \{ item equ
      restore done@dequeue \} }

macro queue list,index,item
 { local copy
   copy equ list
   rept index+1 \{ dequeue copy,item \} }

macro data directory
 { done@data equ
   match =3,directory
   \{ local l_infos,_info,_end
      l_infos equ
      align 4
      match list,l_handlers
      \\{
	 irp _handler,list
	 \\\{ local rva$
	    rva$ = rva $
	    enqueue l_infos,rva$
	    db 19h,0,0,0
	    dd _handler,0
	 \\\}
      \\}
      data 3
      match list,l_begins
      \\{
	 irp _begin,list
	 \\\{
	    dequeue l_ends,_end
	    dequeue l_infos,_info
	    dd _begin
	    dd _end
	    dd _info
	 \\\}
      \\}
      restore done@data
   \}
   match ,done@data
   \{ data directory
      restore done@data \} }

l_begins equ
l_ends equ
l_handlers equ

macro .try handler
 { local ..try
   __TRY equ ..try
   local ..end
   __END equ ..end
   local ..catch
   __CATCH equ ..catch
   __TRY:
   if ~ handler eq
    virtual at handler
    __CATCH:
    end virtual
   end if }

macro .catch
 { jmp __END
   __CATCH: }

macro .end
 { __END:
   enqueue l_begins,rva __TRY
   enqueue l_ends,rva __END
   enqueue l_handlers,rva __CATCH
   restore __TRY
   restore __END
   restore __CATCH }
