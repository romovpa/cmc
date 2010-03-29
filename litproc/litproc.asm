; ---------------------------------------
; CMC Practice - Literred data processing 
;    Student: Peter Romov
;    Variant: 3 - 5 - 6
; ---------------------------------------

include io.asm

str_len equ 256

stack segment stack
	db 128 dup (?)
stack ends

data segment
	msg_prompt	db "Enter text: $"
	msg_result	db "Result: $"
	msg_first 	db "First$"
	msg_second	db "Second$"
	msg_trans	db " transformation$"
	msg_empty	db "Empty!$"
	str 		db str_len dup ('$')
data ends

code segment
	assume SS:stack, CS:code, DS:data
	
	; Is latin
	;    input:  AL - symbol
	;    output: AH - result
	islat proc
				xor AH, AH				
				; Lower latin
				cmp AL, 'a'
				jb isup
				cmp AL, 'z'
				ja isup
				jmp true
				; Upper latin
		isup:	cmp AL, 'A'
				jb false
				cmp AL, 'Z'
				ja false
				; Result				
		true:	mov AH, 1
		false:	ret	
	islat endp
	
	; First transformation (lowercase)
	;    input: BX - string addr
	trans1 proc
				shift equ 'a'-'A'
				push AX
				
				; Start scanning
		next1:	mov AL, [BX]
				cmp AL, '$'
				je fin1
				cmp AL, 'A'
				jb nou
				cmp AL, 'Z'
				ja nou			
				
				; Transform symbol	
				add AL, shift
				mov [BX], AL
				
		nou:	inc BX
				jmp next1
				
		fin1:	pop AX
				ret
	trans1 endp
	
	; Second transformation (collapse)
	;    input: BX - non-empty string addr 
	trans2 proc
				push AX
				push SI
				push DI
				
				mov SI, BX
				mov DI, BX
				inc SI
				
				; Start scanning
		beg:	mov AL, [SI]
				cmp AL, '$'
				je fin2
				cmp AL, [DI]
				je next2
				; Put symbol
				inc DI
				mov [DI], AL 
				; Next iteration
		next2:	inc SI
				jmp beg
				
				; Cutting 
		fin2:	mov byte ptr [DI+1], '$'
				
				pop DI
				pop SI
				pop AX		
				ret
	trans2 endp
	
	; Program code
	start:	; Changing data segment
			mov AX, data
			mov DS, AX
			
			; Printing prompt
			lea DX, msg_prompt
			outstr
			
			; Reading string 
			mov CX, str_len
			mov DI, 0
	read:	inch AL
			cmp AL, '.'
			je eread
			mov str[DI], AL
			inc DI
			loop read			
	eread:	mov str[DI], '$'
			cmp DI, 0
			je empty
			dec DI
			
			; Checking property 
			mov AL, str
			call islat						
			cmp AH, 0
			je dosec		
			mov AL, str[DI]
			call islat			
			cmp AH, 0
			je dosec
			
	dofst:	; Message
			lea DX, msg_first
			outstr
			lea DX, msg_trans
			outstr
			newline	
			
			; Call transformation 
			lea BX, str
			call trans1
			
			jmp print
	
	dosec:	; Message
			lea DX, msg_second
			outstr
			lea DX, msg_trans
			outstr
			newline	
			
			; Call transformation
			lea BX, str
			call trans2
			
	print:	; Printing string
			lea DX, msg_result
			outstr
			lea DX, str
			outstr
			newline
			finish
			
	empty:	; Empty input
			lea DX, msg_empty
			outstr
			newline
			finish
	
code ends

end start
