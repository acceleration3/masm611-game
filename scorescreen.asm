EcraPontos 	proc
	cmp  	pontosTotal, 0
	jne 	checkscore
	
	cmp 	printedscores, 1
	je 		return
	call 	PrintScores
	
	mov 	ah, 1
	int 	16h

	mov 	ah, 0
	int 	16h

	mov 	printedscores, 0 
	mov 	ax, [EcraMenu]
	mov 	[DrawScreen], ax
	call 	ClearScreen
	
	return:
	ret

	checkscore:
	call 	EnterName
	jmp 	return
EcraPontos 	endp

PrintScores	proc
	mov		ah, 3dh 
	mov 	al, 2
    lea 	dx, fichpontos 
    int 	21h 

    mov 	fhandle, ax
    mov 	col, 4

    move_cursor 3, 2
    print_string tableheader

    printloop:
    file_read dadosbuffer, 12, fhandle
    
    cmp 	ax, 0
   	je 		return

    move_cursor	col, 2
    print_string dadosbuffer
    print_char ','

    lea 	si, dadosbuffer
    mov 	ax, [si+6]
    print_word ax
	print_char ','
	mov 	ah, 0
	mov 	al, [si+8]
	print_word ax
	print_char ','
	mov 	ah, 0
	mov 	al, [si+9]
	print_word ax
    inc 	col
    
    cmp 	col, 23
    je 		return
    
    jmp 	printloop

    return:
    mov 	printedscores, 1
    ret

PrintScores endp

EnterName 		proc
	move_cursor  4, 3
	print_string strNome

	keyloop:
	mov 	ah, 1
	int 	16h
	jz		keyloop

	mov 	ah, 0
	int 	16h

	cmp 	al, 0DH
	je		save
	
	cmp 	al, 08h
	je 		delete

	cmp 	al, 'a'
	jb		keyloop

	cmp 	al, 'z'
	ja		keyloop

	cmp		namelen, 5
	je 		keyloop

	xor 	bx, bx
	mov 	bl, namelen
	lea 	si, namebuffer
	add 	si, bx
	mov 	[si], al
	print_char al
	inc 	namelen

	jmp 	keyloop	

	save:
	mov		ah, 3dh 
	mov 	al, 2
    lea 	dx, fichpontos 
    int 	21h 

    mov 	fhandle, ax

    mov 	ah, 42h
    mov 	al, 02
    mov 	bx, fhandle
    mov 	cx, 0
    mov 	dx, 0
    int 	21h

    lea 	bx, dadosbuffer
    lea 	si, namebuffer
    mov 	cx, 6
  
    nameloop:
    mov 	al, [si]
    mov 	[bx], al
    inc 	si
    inc 	bx
    loop 	nameloop

    mov 	ax, pontosTotal
    mov 	word ptr[bx], ax
    mov 	al, certas
    mov 	[bx+2], al
    mov 	al, erradas
    mov 	[bx+3], al
    mov 	al, 0
    mov 	[bx+4], al
    mov 	al, 0
    mov 	[bx+5], al
    mov 	ax, 0
    mov 	[bx+6], ax

    file_write	dadosbuffer, 12, fhandle
	
	mov 	ah, 3Eh
	mov 	bx, fhandle
	int 	21h

	mov 	pontosTotal, 0
	call 	ClearScreen

	return:	
	ret

	delete:
	cmp 	namelen, 0
	je 		keyloop

	mov 	cl, 22
	add 	cl, namelen
	dec 	cl
	mov 	dl, cl

	xor 	bx, bx
	mov 	bl, namelen
	lea 	si, namebuffer
	add 	si, bx
	dec 	si 
	mov 	byte ptr[si], 0

	mov 	ax, 0601h
	mov 	bh, 1Fh
	mov 	ch, 4		;y0
	mov 	dh, 4		;y1
	int 	10h
	dec 	namelen

	move_cursor 4, cl

	jmp 	keyloop

EnterName 		endp

