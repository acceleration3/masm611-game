
LerDados 		proc 

	; Abrir ficheiro para leitura
	mov 	ax, 3d02h 
    lea 	dx, fname 
    int 	21h 
    jc 		error 
    mov 	aaafhandle, ax

	file_read operandos1, 99, fhandle
	file_read operadores1, 99, fhandle
	file_read operandos2, 99, fhandle
	file_read operadores2, 99, fhandle
	file_read operandos3, 99, fhandle

	mov 	ah, 3Eh
	mov 	bx, fhandle
	int 	21h
	ret
	
	error:	
	move_cursor 10,2
	
	mov 	ax, 0601h
	mov 	bh, 0CFh
	mov 	cl, 2		;x0
	mov 	ch, 10		;y0
	mov 	dl, 47		;x1
	mov 	dh, 10		;y1
	int 	10h

	print_string ferror
	ret

LerDados 		endp

EcraMenu 		proc 

	; Mudar o cursor para a fila 4, coluna 2
	move_cursor 4, 2
	
	; Print da string 'menu_titulo'
	print_string menu_titulo
	
	; Mudar o cursor para a fila 6, coluna 2
	move_cursor 6, 2
	
	; Print da string 'menu_item1'
	print_string menu_item1
	
	; Mudar o cursor para a fila 7, coluna 2
	move_cursor 7, 2
	
	; Print da string 'menu_item2'
	print_string menu_item2
	
	; Mudar o cursor para a fila 8, coluna 2
	move_cursor 8, 2
	
	; Print da string 'menu_item3'
	print_string menu_item3
	
	; Esperar por uma tecla
	get_key
	
	cmp 	ah, 4		;Tecla = 3
	je 		endprogram

	cmp 	ah, 3		;Tecla = 2
	je 		scores

	cmp		ah, 2		;Tecla = 1	
	je		startgame
	jmp 	return
	
	; Sair do programa
	endprogram:
	mov 	bExit, 1 	; Sair do loop principal
	jmp 	return	
		
	scores:
	mov 	ax, [EcraPontos]
	mov		[DrawScreen], ax
	call 	ClearScreen
	jmp 	return
	
	; Abrir o ficheiro de dados 'dados.bin'
	startgame:
	call 	LerDados
	cmp 	fhandle, 0
	je 		return

	; Mudar o cursor para um bloco preenchido
	mov 	cx, 0007h 
	mov 	ah, 1
	int 	10h 

	; Apontar DrawScreen para o ecra de jogo
	mov 	ax, [EcraJogo]
	mov		[DrawScreen], ax
	call 	ClearScreen
	
	return:
	ret
	
EcraMenu	 	endp 