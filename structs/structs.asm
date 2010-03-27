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
empty_char	equ '_'

; types definition
node struc 
	str db str_size dup (?)
	number db ?
	left dw ?
	right dw ?
node ends

stack segment stack
	db stack_size dup (?)
stack ends

data segment
	msg_heap_overflow db "Heap overflow$"
	root dw nil
	free dw nil
	heap node heap_size dup (<,,,>)
data ends

code segment
	assume SS:stack, CS:code, DS:data, ES:data
	
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
	
	; procedure print
	;    args: BX - node pointer 
	print proc
					; printing string
					push CX
					push DI
					mov CX, str_size					
					lea DI, ES:[BX].str
		_prt_loop:	outch ES:[DI]
					inc DI
					loop _prt_loop
					pop DI
					pop CX
					
					; printing extra information
					outch ' '
					outch '('
					push AX
					xor AX, AX
					mov AL, ES:[BX].number
					outword AX
					pop AX
					outch ')'
					
					ret
	print endp
	
	; procedure compare
	;    args: SI - first node pointer
	;          DI - second node pointer
	compare proc
					
	compare endp
	
	; === main code ===
	
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
				
				call new
				call read
				mov SI, BX
				
				call new
				call read
				mov DI, BX
				
				mov BX, SI
				call print
				newline
				mov BX, DI
				call print
				
				
				
				finish
	
code ends

end _start
 
