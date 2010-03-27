; ---------------------------------------
; CMC Practice - Literred data processing 
;    Student: Peter Romov
;    Variant: 3 - 5 - 6
; ---------------------------------------

include io.asm

; constants
heap_size 	equ 20
str_size 	equ 8
stack_size 	equ 128
nil 		equ 0
word_end	equ ','
seq_end		equ '.'
empty_char	equ 0
print_shift equ 2

; types definition
node struc 
	str db str_size dup (?)
	id db ?
	match db ?
	left dw ?
	right dw ?
node ends

stack segment stack
	db stack_size dup (?)
stack ends

data segment
	msg_prompt db "Enter sequence: $"
	msg_heap_overflow db "Heap overflow!$"
	msg_matched db "Matched $"
	msg_times db " times$"
	root dw nil
	free dw nil	
data ends

heap segment
	heap_ptr node heap_size dup (<,,,>)
heap ends

code segment
	assume SS:stack, CS:code, DS:data, ES:data
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure new
	;    result: BX - node pointer
	new proc 
					; checking memory avaliable
					cmp free, nil
					je _new_over
					
					; allocating new node
					push AX
					mov BX, free
					mov AX, ES:[BX].right
					mov free, AX
					pop AX
					ret
					
		_new_over:	; crash! heap overflow
					lea DX, msg_heap_overflow
					outstr
					finish
	new endp
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure read
	;    args:   BX - node pointer
	;    result: AL - last symbol
	;            [ES:DX].str filled field
	read proc
					push CX
					push DI					
					mov CX, str_size
					lea DI, ES:[BX].str
					
					; reading from stdin
		_read_loop:	inch AL
					cmp AL, word_end
					je _read_fill
					cmp AL, seq_end
					je _read_fill
					mov ES:[DI], AL
					inc DI
					loop _read_loop
					
					; waiting for terminal char
		_read_wait:	inch AL
					cmp AL, word_end
					je _read_fin
					cmp AL, seq_end
					je _read_fin
					jmp _read_wait
					
					; filling by spaces
		_read_fill:	mov byte ptr ES:[DI], empty_char
					inc DI
					loop _read_fill
					
		_read_fin:	pop DI
					pop CX
					ret
	read endp
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure print
	;    args: BX - node pointer
	print proc
					REPT print_shift
					outch ' '
					ENDM
					; printing string					
					push CX
					push DI
					mov CX, str_size					
					lea DI, ES:[BX].str
		_prt_loop:	cmp byte ptr ES:[DI], empty_char
					je _prt_ends
					outch ES:[DI]
					inc DI
					loop _prt_loop
		_prt_ends:	pop DI
					pop CX
					
					; printing extra information
					outch ' '
					outch '('
					push AX
					xor AX, AX
					mov AL, ES:[BX].id
					outword AX
					pop AX
					outch ')'
					
					ret
	print endp
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure compare
	;    args:   SI - first node pointer
	;            DI - second node pointer
	;    result: Flags - result of comparing
	;   (whores can works if DS = ES)
	compare proc
					push SI
					push DI					
					
					lea SI, ES:[SI].str
					lea DI, ES:[DI].str
					
					push CX
					mov CX, str_size
					; scanning string
		_cmp_loop:	mov CH, ES:[DI]
					cmp ES:[SI], CH
					jne _cmp_fin
					xor CH, CH
					inc DI
					inc SI
					loop _cmp_loop
					; set equal flags
					cmp AL, AL 
					
		_cmp_fin:	pop CX
					pop DI
					pop SI
					ret					
	compare endp
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure insert
	;    args: BX - new node pointer
	insert proc
					; making leaf
					mov ES:[BX].left, nil
					mov ES:[BX].right, nil
					
					; tree empty check
					cmp root, nil
					jne _ins_start
					mov root, BX
					ret
	
					; nonempty tree
		_ins_start:	push SI
					push DI
					mov SI, BX
					mov DI, root
					
		_ins_loop:	call compare
					ja _ins_above
					
					; left ( <= )
					cmp ES:[DI].left, nil
					je _ins_left
					mov DI, ES:[DI].left
					jmp _ins_loop				
					
		_ins_above:	; right ( > )
					cmp ES:[DI].right, nil
					je _ins_right
					mov DI, ES:[DI].right
					jmp _ins_loop
					
		_ins_left:	; inserting as left leaf
					mov ES:[DI].left, SI
					jmp _ins_fin					
		
		_ins_right:	; inserting as right leaf
					mov ES:[DI].right, SI
				
		_ins_fin:	pop DI
					pop SI
					ret
	insert endp
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure fill
	;    args: SI - subtree node pointer
	;          DI - previous node (static)
	fill proc
					cmp ES:[SI].left, nil
					je _fill_mid					
					; processing left subtree
					push SI
					mov SI, ES:[SI].left
					call fill
					pop SI
					
		_fill_mid:	; processing middle element
					cmp DI, nil
					je _fill_fst
					; it is not first
					call compare
					je _fill_chn
					; new chain
					mov ES:[SI].match, 1
					jmp _fill_endp
		_fill_chn:	; next element in chain
					push CX
					mov CL, ES:[DI].match
					inc CL
					mov ES:[SI].match, CL
					pop CX
					jmp _fill_endp
		_fill_fst:	; it is first
					mov ES:[SI].match, 1					
		_fill_endp:	; end of processing
					mov DI, SI
		
					cmp ES:[SI].right, nil
					je _fill_fin					
					; processing right subtree
					push SI
					mov SI, ES:[SI].right
					call fill
					pop SI
					
		_fill_fin:	ret
	fill endp
	
	;;;;;;;;;;;;;;;;;;;;
	; procedure view
	;    args:   AL - match number
	;            SI - node pointer
	;    result: CX += n, where n is printed elements number
	view proc
					cmp ES:[SI].left, nil
					je _view_mid					
					; processing left subtree
					push SI
					mov SI, ES:[SI].left
					call view
					pop SI
					
		_view_mid:	cmp ES:[SI].match, AL
					jne _view_righ
					
					; printing element information
					push BX
					mov BX, SI
					call print
					newline
					inc CX
					pop BX					
					
		_view_righ:	cmp ES:[SI].right, nil
					je _view_fin
					; processing right subtree
					push SI
					mov SI, ES:[SI].right
					call view
					pop SI
					
		_view_fin:	ret		
	view endp
	
	; === initializations ===
	
	_start:		; changing segments
				mov AX, data
				mov DS, AX
				mov AX, heap
				mov ES, AX
				
				; heap initialization				
				mov CX, heap_size
				lea BX, heap_ptr
				mov AX, nil
	_hi_loop:	mov ES:[BX].right, AX
				mov AX, BX
				add BX, size node
				loop _hi_loop
				mov free, AX
				
				; tree initialization
				mov root, nil
				
	; === reading sequence ===				
				
				; printing prompt
				lea DX, msg_prompt
				outstr
	
				xor CL, CL	
	_inp_next:	call new
				call read
				mov ES:[BX].id, CL
				call insert
				inc CL
				cmp AL, seq_end
				jne _inp_next
				
	; === resulting ===
	
				mov SI, root
				
				mov DI, nil
				call fill
								
				mov AX, 1				
	_outp_loop:	mov CL, 0
				; printing message
				lea DX, msg_matched
				outstr
				outword AX
				lea DX, msg_times
				outstr
				newline		
				; printing entries
				call view
				newline
				; loop end
				inc AL
				cmp CL, 0
				jne _outp_loop
				
				
				finish
code ends

end _start
 
