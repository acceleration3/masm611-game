; Macros para Interrupções DOS

print_string	macro string
	mov 	ah, 09h 
	lea		dx, string
	int 	21h
endm

print_char		macro char
	mov 	ah, 02h
	mov 	dl, char
	int 	21h
endm

file_read		macro buffer, len, fhandle
	mov		ah, 3fh 
    mov 	bx, fhandle 
    mov 	cx, len 
    lea 	dx, buffer 
    int 	21h 
endm

file_write 		macro buffer, len, fhandle
	mov 	ah, 40h
	mov 	bx, fhandle
	mov 	cx, len
	lea 	dx, buffer
	int 	21h
endm

move_cursor		macro row, col
	mov 	ah, 02h
	mov 	bh, 0
	mov		dh, row
	mov 	dl, col
	int 	10h
endm

print_byte			macro num
	local return, string, singledigit

		mov 		cl, 0
		mov 		al, num
		mov 		bl, 10
		div			bl
		mov 		bx, ax
		add 		bx, 3030h
		cmp 		al, 0
		je			singledigit			

		print_char	bl
		inc			cl
		
		singledigit:
		print_char 	bh
		inc			cl
endm

print_word 	macro num
	local loop1, loop2

	mov 	ax, num
	mov 	bx, 10
	xor 	dx, dx
	xor 	cx, cx

	loop1:  
	xor 	dx, dx
	div 	bx
	push 	dx
	inc 	cx
	cmp 	ax, 0
	jne 	loop1

	loop2:  
	pop 	dx
	add 	dx, 30h 
	mov 	ah, 02h     
	int 	21h
	loop 	loop2    
endm

get_key 		macro 
	mov 	ah, 0
	int 	16h
endm
