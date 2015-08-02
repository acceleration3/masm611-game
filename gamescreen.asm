UpdateTimer		proc

	; Ler o relogio do sistema (CH = hora, CL = minuto, DH = segundo, DL = 1/100 segundo)
	mov 	ah, 2Ch
	int 	21h 
	
	; Saltar inicializacao se as variaveis ja foram inicializadas
	cmp 	old_seg, 255
	jne 	timerupdate
	
	; Inicializar variaveis
	mov 	old_seg, dh
	mov 	al, tempo_limite
	mov		tempo_restante, al
	jmp		return

	timerupdate:
	; Verificar se o segundo do relogio do sistema mudou
	cmp 	old_seg, dh
	je 		return		;Se nao, saltar a actualizacao do temporizador 
	
	; Se sim, colocar o novo valor dos segundos para comparar e diminuir o tempo restante
	mov 	old_seg, dh	
	dec		tempo_restante
	
	; Converter o tempo restante para m:ss
	xor 	ax, ax
	mov		al, tempo_restante
	mov 	bl, 60
	div		bl
	
	; Formatar os dados na string 'strTempo'
	mov 	bmin, al
	add 	bmin, 30h
	mov 	al, ah
	xor 	ah, ah
	mov 	bl, 10
	div 	bl
	add		ax, 3030h	; Conversao para ASCII
	lea		si, strTempo
	mov		bl, bmin
	mov		byte ptr[si+18], bl
	mov		word ptr[si+20], ax
	
	; Mudar o cursor para a fila 3, coluna 29
	move_cursor 9, 29
	
	; Print da string 'strTempo'
	print_string strTempo

	return:
	ret

UpdateTimer 	endp

MakeString		proc
	
	cmp 	bPrintCalc, 0
	je 		return

	move_cursor 13, 29
	
	; Limpar o calculo anterior
	mov 	ax, 0601h
	mov 	bh, 1Fh
	mov 	cl, 31		;x0
	mov 	ch, 13		;y0
	mov 	dl, 60		;x1
	mov 	dh, 13		;y1
	int 	10h

	mov 	inputoffset, 0 	; Reset do offset de input

	mov 	inputpos, 38	; 27 + strlen("Calcule: ")

	print_string strcalculo

	; Fazer print do primeiro numero
	xor 	ax, ax
	lea 	si, [operandos1]
	add 	si, indexcalculo
	mov 	al, [si]
	print_byte al
	add		inputpos, cl

	; Fazer print do primeiro operador
	xor 	ax, ax
	lea 	si, operadores1
	add 	si, indexcalculo
	mov 	al, [si]
	print_char al
	add		inputpos, 2

	; Fazer print do segundo numero
	xor 	ax, ax
	lea 	si, operandos2
	add 	si, indexcalculo
	mov 	al, [si]
	print_byte al
	add		inputpos, cl

	cmp 	tempo_restante, 60
	ja		skip

	mov 	bextended, 1
	xor 	ax, ax
	lea 	si, operadores2
	add 	si, indexcalculo
	mov 	al, [si]
	print_char al
	add		inputpos, 1

	xor 	ax, ax
	lea 	si, operandos3
	add 	si, indexcalculo
	mov 	al, [si]
	print_byte al
	add		inputpos, cl

	skip:
	print_char '='
	mov 	bPrintCalc, 0

	return:
	ret

MakeString		endp

CheckKeys		proc

	mov 	bl,	inputpos
	add		bl, inputoffset

	move_cursor	13, bl

	mov 	ah, 1
	int 	16h
	jz		return

	mov 	ah, 0
	int 	16h

	cmp 	al, 1Bh
	je 		endgame

	cmp 	al, 08h
	je 		delete

	cmp 	al, 0DH
	je 		eval

	cmp 	ah, 4Bh
	je 		move_left

	cmp 	ah, 4Dh
	je 		move_right

	cmp 	al, 'c'
	je 		show_res

	cmp 	al, 'v'
	je 		endtime

	cmp 	al, '0'
	jb		return

	cmp 	al, '9'
	ja 		return
	
	cmp 	inputoffset, 5
	jae 	return

	xor 	bx, bx
	mov 	bl, inputoffset
	lea 	si, inputbuffer
	add 	si, bx
	mov 	[si], al

	print_char	al
	inc 	inputoffset

	return:
	ret

	endtime:
	mov 	tempo_restante, 1
	jmp 	return

	delete:
	cmp 	inputoffset, 0
	je 		return

	mov 	cl, inputpos
	add 	cl, inputoffset
	dec 	cl
	mov 	dl, cl

	xor 	bx, bx
	mov 	bl, inputoffset
	lea 	si, inputbuffer
	add 	si, bx
	dec 	si 
	mov 	byte ptr[si], 0

	mov 	ax, 0601h
	mov 	bh, 1Fh
	mov 	ch, 13		;y0
	mov 	dh, 13		;y1
	int 	10h
	dec 	inputoffset
	jmp 	return

	show_res:
	mov 	ax, 0601h
	mov 	bh, 1Fh
	mov 	cl, 1		;x0
	mov 	ch, 15		;y0
	mov 	dl, 60		;x1
	mov 	dh, 15		;y1
	int 	10h
	
	move_cursor	15, 2
	
	call 	CalcRes
	print_word dx
	mov 	pontosCalc, 0
	

	move_left:
	cmp 	inputoffset, 0
	jbe		return
	dec		inputoffset
	jmp		return

	move_right:
	cmp 	inputoffset, 5
	jae		return
	inc		inputoffset
	jmp		return

	eval:
	call 	CalcRes		;Res = dx 			
	push 	dx
	call 	GetInput	;Input = cx
	pop 	dx
	cmp 	cx, dx
	jne 	erro

	mov 	ax, pontosCalc
	add		pontosTotal, ax
	call  	PrintScore
	mov 	pontosCalc, 0

	mov 	inputoffset, 0
	lea 	si, inputbuffer
	mov 	word ptr[si], 0
	mov 	word ptr[si+2], 0
	mov 	word ptr[si+4], 0
	inc 	bPrintCalc
	inc 	indexcalculo
	inc 	certas
	jmp 	return

	erro:
	inc 	erradas
	cmp 	pontosTotal, 0
	je 		return
	sub		pontosTotal, 2
	call  	PrintScore
	mov 	pontosCalc, 0
	jmp 	return

	endgame:
	; Reset das variaveis
	mov 	old_seg, 255
	mov 	inputoffset, 0
	mov 	inputpos, 0
	mov 	bPrintCalc, 1
	mov 	bPrintTeclas, 1
	mov 	indexcalculo, 0
	mov 	pontosCalc, 0
	mov 	pontosTotal, 0

	mov 	cx, 0007h 
	mov 	ah, 0
	int 	10h 

	; Apontar o ponteiro DrawScreen para o procedimento do primeiro ecra (menu)
	mov 	ax, [EcraMenu]
	mov 	[DrawScreen], ax
	call 	ClearScreen
	ret
	

CheckKeys		endp

GetInput		proc
    xor     dx, dx
	lea 	si, inputbuffer

	cmp 	byte ptr[si], 0
	je 		return 

	xor 	cx, cx
	mov 	ax, 1
	mov 	bx, 10

	makemult:
	cmp 	byte ptr[si], 0
	je		todec
	mul 	bx 
	inc     si
	jmp 	makemult       
	
	todec:  
	lea 	si, inputbuffer
	div     bx
	
	decloop:
	mov 	bx, ax
	push 	ax
	mov 	ax, bx
	mov 	dl, [si]
	sub     dl, 30h
	mul 	dx
	add 	cx, ax
	pop 	ax
	cmp 	ax, 1
	je 		return
	mov 	bx, 10
	div 	bx             
	inc     si
	jmp 	decloop
	
	return:
	ret
GetInput		endp

CalcRes			proc
	xor		dx, dx
	; Verificar se o calculo tem 3 numeros
	cmp 	bextended, 0
	je 		calcsimple

	lea 	si, [operadores2]
	add 	si, indexcalculo
	mov 	al, [si]

	; Verificar priordade da divisao
	cmp 	al, '/'
	je 		prior_div

	; Verificar priordade da multiplicacao
	cmp 	al, '*'
	je 		swap       
	
	jmp     calccomplex
	
	calcsimple:
	; Ordem normal
	mov 	cx, 2

	xor 	ax, ax
	lea 	si, [operandos2]
	add 	si, indexcalculo
	mov 	al, [si]
	push 	ax

	xor 	ax, ax
	lea 	si, [operadores1]
	add 	si, indexcalculo
	mov 	al, [si]
	push 	ax

	xor 	ax, ax
	lea 	si, [operandos1]
	add 	si, indexcalculo
	mov 	al, [si]
	push 	ax

	main:
	pop 	dx	; Colocar o primeiro numero em DX
	
	calcloop:
	dec		cx
	cmp 	cx, 0
	je 		return

	pop 	bx 	; Operador

	cmp 	bx, '+'
	je 		soma
	
	cmp 	bx, '-'
	je 		subtraccao

	cmp 	bx, '*'
	je 		multiplicacao

	cmp 	bx, '/'
	je 		divisao

	return:
	ret

	prior_div:
	lea 	si, [operadores1]
	add 	si, indexcalculo
	mov 	al, [si]

	cmp 	al, '*' 		; Divisao nao tem prioridade sobre a multiplicacao
	je 		calccomplex

	cmp 	al, '/'			; Divisao nao e comutativa
	je 		calccomplex

	jmp 	swap
          
    ; Ordem trocada
	swap:
	xor 	ax, ax
	lea 	si, [operandos1]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operadores1]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operandos3]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operadores2]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operandos2]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	mov 	cx, 3
	jmp  	main     
	
	
	calccomplex:
	xor 	ax, ax
	lea 	si, [operandos3]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operadores2]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operandos2]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operadores1]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	xor 	ax, ax
	lea 	si, [operandos1]
	add 	si, indexcalculo
	mov 	al, [si]
	push	ax

	mov 	cx, 3
	jmp  	main  

	soma:
	pop 	ax
	add		dx, ax
	add 	pontosCalc, 1
	jmp		calcloop 
	
	subtraccao:
	pop 	ax
	sub		dx, ax
	add 	pontosCalc, 1
	jmp		calcloop 
	
	divisao:
	xor 	ax, ax
	pop		bx
	mov 	ax, dx
	div 	bl
	xor 	dx, dx
	mov 	dl, al
	add 	pontosCalc, 2
	jmp		calcloop 
	
	multiplicacao:
	xor 	ax, ax
	pop		bx
	mov 	ax, dx
	mul 	bx
	mov 	dx, ax
	add 	pontosCalc, 2
	jmp		calcloop 
CalcRes			endp 

PrintScore		proc
	
	mov 	ax, 0601h
	mov 	bh, 1Fh
	mov 	cl, 1		;x0
	mov 	ch, 14		;y0
	mov 	dl, 60		;x1
	mov 	dh, 14		;y1
	int 	10h

	move_cursor 10, 35
	print_string strPontos
	print_word pontosTotal
	ret

PrintScore 		endp

EcraJogo		proc
	
	cmp 	bPrintTeclas, 1
	jne 	mainloop

	call 	PrintScore
	move_cursor	22, 2
	print_string strTeclas

	mov 	bPrintTeclas, 0


	mainloop:
	call 	UpdateTimer

	cmp 	tempo_restante, 0
	je 		endgame

	call 	MakeString
	call 	CheckKeys
	ret
	
	endgame:
	; Reset das variaveis
	mov 	old_seg, 255
	mov 	inputoffset, 0
	mov 	inputpos, 0
	mov 	bPrintCalc, 1
	mov 	bPrintTeclas, 1
	mov 	indexcalculo, 0

	mov 	cx, 0007h 
	mov 	ah, 0
	int 	10h 

	; Apontar o ponteiro DrawScreen para o procedimento do primeiro ecra (menu)
	mov 	ax, [EcraPontos]
	mov 	[DrawScreen], ax
	call 	ClearScreen
	ret
	
EcraJogo		endp