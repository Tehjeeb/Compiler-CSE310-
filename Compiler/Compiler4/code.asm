.MODEL SMALL
.STACK 1000h
.DATA

	CR EQU 0DH
	LF EQU 0AH
	number DB "00000$"

main PROC
	MOV AX, @DATA
		mov DS, AX
		; data segment loaded

	PUSH BP
	MOV BP, SP
		SUB SP, 2	;line 3: i declared
		SUB SP, 2	;line 3: j declared
		SUB SP, 2	;line 3: k declared
		SUB SP, 2	;line 3: ll declared
	MOV AX, 0	;load 0 in ax 
	PUSH AX	;save ax 
	POP AX 	;line no: 5
	MOV [BP-2], AX 			;line no: 5
	PUSH AX 	;line no: 5
	POP AX 	 ;line no: 5 kaj sesh!
L1:
	MOV AX, [BP-2] 	 ;Line: 5 save var
	PUSH AX 	 ;Line: 5 save var
	MOV AX, 6	;load 6 in ax 
	PUSH AX	;save ax 
	POP AX 	 ;line no 5
	MOV DX, AX 	 ;line no 5
	POP AX 	 ;line no 5
	CMP AX, DX 	 ;line no 5
	JL L2 	 ;line no 5
	JMP L3 	 ;line no 5
L2:
	MOV AX, 1	 ;line no 5
	JMP L4 	 ;line no 5
L3:
	MOV AX, 0	 ;line no 5
L4:
	PUSH AX   	 ;line no 5
	POP AX 	 ;line no: 5 kaj sesh!
	CMP AX, 0 	;check condition value
	JE L7 	;getting out 
	JMP L6 	;getting in 
L5:
	MOV AX, [BP-2] 	 ;Line: 5 save var
	PUSH AX 	 ;Line: 5 save var
	INC AX 	 ;Line: 5 increment var
	MOV [BP-2], AX 	 ;Line: 5 decrement var
	POP AX  	;poping cause no semicolon in for 3rd expression
	JMP L1 	;going to check condition again 
L6:
	MOV AX, [BP-2]
	CALL print_output
	CALL new_line
	JMP L5 	;loop ended so starting again from top in 
L7:	;for loop ending tag
	MOV AX, 4	;load 4 in ax 
	PUSH AX	;save ax 
	POP AX 	;line no: 9
	MOV [BP-6], AX 			;line no: 9
	PUSH AX 	;line no: 9
	POP AX 	 ;line no: 9 kaj sesh!
	MOV AX, 6	;load 6 in ax 
	PUSH AX	;save ax 
	POP AX 	;line no: 10
	MOV [BP-8], AX 			;line no: 10
	PUSH AX 	;line no: 10
	POP AX 	 ;line no: 10 kaj sesh!
L8:	;while starting tag
	MOV AX, [BP-6] 	 ;Line: 11 save var
	PUSH AX 	 ;Line: 11 save var
	MOV AX, 0	;load 0 in ax 
	PUSH AX	;save ax 
	POP AX 	 ;line no 11
	MOV DX, AX 	 ;line no 11
	POP AX 	 ;line no 11
	CMP AX, DX 	 ;line no 11
	JG L9 	 ;line no 11
	JMP L10 	 ;line no 11
L9:
	MOV AX, 1	 ;line no 11
	JMP L11 	 ;line no 11
L10:
	MOV AX, 0	 ;line no 11
L11:
	PUSH AX   	 ;line no 11
	POP AX 	;getting condition value
	CMP AX, 0 	;check condition value
	JE L12 	;getting out 
	MOV AX, [BP-8] 	 ;Line: 12 save var
	PUSH AX 	 ;Line: 12 save var
	MOV AX, 3	;load 3 in ax 
	PUSH AX	;save ax 
	POP AX 	 ;line no 12
	MOV DX, AX 	 ;line no 12
	POP AX 	 ;line no 12
	ADD AX, DX 	 ;line no 12
	PUSH AX 	 ;line no 12
	POP AX 	;line no: 12
	MOV [BP-8], AX 			;line no: 12
	PUSH AX 	;line no: 12
	POP AX 	 ;line no: 12 kaj sesh!
	MOV AX, [BP-6] 	 ;Line: 13 save var
	PUSH AX 	 ;Line: 13 save var
DEC AX 	 ;Line: 13 decrement var
MOV [BP-6], AX 	 ;Line: 13 decrement var
	POP AX 	 ;line no: 13 kaj sesh!
	JMP L8 	;getting back
L12:	;while end tag
	MOV AX, [BP-8]
	CALL print_output
	CALL new_line
	MOV AX, [BP-6]
	CALL print_output
	CALL new_line
	MOV AX, 4	;load 4 in ax 
	PUSH AX	;save ax 
	POP AX 	;line no: 19
	MOV [BP-6], AX 			;line no: 19
	PUSH AX 	;line no: 19
	POP AX 	 ;line no: 19 kaj sesh!
	MOV AX, 6	;load 6 in ax 
	PUSH AX	;save ax 
	POP AX 	;line no: 20
	MOV [BP-8], AX 			;line no: 20
	PUSH AX 	;line no: 20
	POP AX 	 ;line no: 20 kaj sesh!
L13:	;while starting tag
	MOV AX, [BP-6] 	 ;Line: 22 save var
	PUSH AX 	 ;Line: 22 save var
DEC AX 	 ;Line: 22 decrement var
MOV [BP-6], AX 	 ;Line: 22 decrement var
	POP AX 	;getting condition value
	CMP AX, 0 	;check condition value
	JE L14 	;getting out 
	MOV AX, [BP-8] 	 ;Line: 23 save var
	PUSH AX 	 ;Line: 23 save var
	MOV AX, 3	;load 3 in ax 
	PUSH AX	;save ax 
	POP AX 	 ;line no 23
	MOV DX, AX 	 ;line no 23
	POP AX 	 ;line no 23
	ADD AX, DX 	 ;line no 23
	PUSH AX 	 ;line no 23
	POP AX 	;line no: 23
	MOV [BP-8], AX 			;line no: 23
	PUSH AX 	;line no: 23
	POP AX 	 ;line no: 23 kaj sesh!
	JMP L13 	;getting back
L14:	;while end tag
	MOV AX, [BP-8]
	CALL print_output
	CALL new_line
	MOV AX, [BP-6]
	CALL print_output
	CALL new_line
	MOV AX, 0	;load 0 in ax 
	PUSH AX	;save ax 
	MOV AH, 4CH
	INT 21H
main ENDP

new_line proc
	push ax
	push dx
	mov ah,2
	mov dl,cr
	int 21h
	mov ah,2
	mov dl,lf
	int 21h
	pop dx
	pop ax
	ret
new_line endp

print_output proc  ;print what is in ax
	push ax
	push bx
	push cx
	push dx
	push si
	lea si,number
	mov bx,10
	add si,4
	cmp ax,0
	jnge negate
	print:
	xor dx,dx
	div bx
	mov [si],dl
	add [si],'0'
	dec si
	cmp ax,0
	jne print
	inc si
	lea dx,si
	mov ah,9
	int 21h
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	negate:
	push ax
	mov ah,2
	mov dl,'-'
	int 21h
	pop ax
	neg ax
	jmp print
print_output endp
END main
