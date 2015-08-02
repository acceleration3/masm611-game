.8086
.model small
.stack 2048

.data
	bExit	db	0
	pos_x	db	2
	pos_y 	db 	2
	key		db 	0
	
.code
	start:
	mov 	ax, @data
	mov 	ds, ax	
	
	mov 	ah, 00h
	mov 	al, 13h
	int 	10h
	
	gameloop:
	call 	getKeys
	
	cmp 	byte ptr[bExit], 1
	je 		endprog
	jmp 	gameloop
	
	endprog:
	mov     ah, 4ch 
	int     21h

	proc getKeys
		mov     ah, 0 
		int     16h
		mov     ah, 1 
		int     16h
		
		cmp 	al, 77h
		je move_up
		cmp 	al, 61h
		je move_left
		cmp 	al, 73h
		je move_down
		cmp 	al, 64h
		je move_right
		
		ret
	endp getKeys
	
end start