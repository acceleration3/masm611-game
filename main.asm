.8086
.model small

.stack 2048

.data
	; Booleano para sair do loop do jogo
	bExit			db 		0
	
	; Ponteiro para o procedimento de desenho de cada ecra
	DrawScreen		dw		0

	; String com caracteres ASCII para uma interface basica
	ecratitulo 		db 		0c9h, 78 dup(0cdh), 0bbh, 0bah, 28 dup(0), 'Jogo de Calculo Mental', 28 dup(0), 0bah, 0cch, 78 dup(0cdh), 0b9h, '$'
	ecracorpo 		db  	0bah, 78 dup(0), 0bah, '$'
	ecrarodape		db 		0c8h, 78 dup(0cdh), 0bch, ' (c) Alexandre Deus - 2015$'

	; Variaveis do ecra 'menu'
	menu_titulo		db		'Escolha uma opcao utilizando os numeros:$'
	menu_item1		db 		'1. Novo jogo$'
	menu_item2		db		'2. Consultar dados/estatisticas$'
	menu_item3		db		'3. Sair$'
	menu_item4		db 		'4. Retomar jogo'
	fname			db 		'dados.bin', 0
	ferror			db  	'Houve um erro ao abrir o ficheiro "dados.bin".$'

	; Variaveis do ecra 'jogo'
	resultado 		dw 		0
	tempo_limite 	db 		121
	tempo_restante	db 		0
	strTempo		db 		'Tempo restante - 00:00$'
	old_seg			db 		255
	bmin			db 		0
	operadores1 	db 		99 dup(0)
	operadores2 	db 		99 dup(0)
	operandos1 		db 		99 dup(0)
	operandos2 		db 		99 dup(0)
	operandos3 		db 		99 dup(0)
	strcalculo		db  	'Calcule: $'
	indexcalculo 	dw 		0
	bPrintCalc		db 		1
	bPrintTeclas 	db 		1
	inputpos		db 		0
	inputoffset 	sbyte	0
	inputbuffer		db 		6 dup(0)
	bextended 		db 		0
	strTeclas 		db 		'ESC-Sair$'
	strPontos		db 		'Pontos: $'
	pontosCalc		dw		0
	pontosTotal 	dw 		0
	certas			db 		0
	erradas 		db 		0

	; Variaveis do ecra 'pontos'
	strNome 		db 		'Insira o seu nome: $'
	namelen			db 		0
	namebuffer 		db 		'     $'
	fichpontos 		db 		'jogos.bin', 0
	dadosbuffer 	db 		12 dup(0)
	writepos		dw 		0
	fhandle 		dw 		0
	col 			db 		0
	printedscores	db 		0
	tableheader 	db 		'nome, pontos, acertadas, erradas$'
.code
	
	; Includes
	include macros.asm
	include gamesc~1.asm
	include menusc~1.asm
	include scores~1.asm

	; Entrypoint do programa
	start:
	mov		ax, @data
	mov 	ds, ax
	
	; Esconder o cursor do DOS
	mov 	ch, 32
	mov 	ah, 1
	int 	10h 

	; Apontar o ponteiro DrawScreen para o procedimento do primeiro ecra (menu)
	mov 	ax, [EcraMenu]
	mov 	[DrawScreen], ax
	call 	ClearScreen
		
	; Loop do jogo
	gameloop:
	call 	DrawScreen		; Chamar o procedimento apontado por DrawScreen 
	cmp		bExit,	1
	je		exit
	jmp 	gameloop
	
	;Finalizar o jogo
	exit:
	; Limpar ecra
	mov 	ah, 00h
	mov 	al, 03h
	int 	10h
	
	; Sair para o DOS
	mov		ah,04Ch	
	int		21h	


	ClearScreen 	proc 
		
		; Preencher o ecra com a cor background 1(0001) e foreground F(1111)
		mov 	ax, 0600h
		mov 	bh, 1Fh
		mov 	cl, 0		;x0
		mov 	ch, 0		;y0
		mov 	dl, 79		;x1
		mov 	dh, 24		;y1
		int 	10h
		
		; Mudar o cursor para o topo esquerdo do ecra
		move_cursor 0, 0
		

		; Print da string 'ecratitulo'
		print_string ecratitulo
		
		; Print de 20 copias da string 'ecracorpo'
		mov 	cx, 20
		corpo:
		print_string ecracorpo
		loop 	corpo

		; Print da string 'ecrarodape'
		print_string ecrarodape 

		ret
		
	ClearScreen 	endp

end start