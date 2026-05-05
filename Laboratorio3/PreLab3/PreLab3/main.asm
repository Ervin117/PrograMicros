;
; PreLab3.asm
;
; Created: 2/16/2025 7:22:10 PM
; Author : Ervin Gomez 231226
;

.include "M328PDEF.inc"
.cseg
.org	0x0000
	JMP INICIO
.org	INT0addr
	JMP INTER0
.org	INT1addr
	JMP INTER1

//Configuracion de la pila 
INICIO: 
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16

SETUP: 
	CLI
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16
	LDI		R16, (1 << CLKPS2)
	STS		CLKPR, R16

	// Configuración del bit 2 y 3 como entradas
	CBI		DDRD, PD2
	SBI		PORTD, PD2 //Pull-ups activados 
	CBI		DDRD, PD3
	SBI		PORTD, PD3 //Pull-ups activados 

	//Configuración de C como la salida del contador 
	LDI		R16, 0xFF
	OUT		DDRC, R16
	LDI		R16, 0x00
	OUT		PORTC, R16

	//Configuracion de las interrupciones del INT0 e INT1
	LDI		R16, (0 << ISC01) | (1 << ISC00) | (0 << ISC11) | (1 << ISC10)
	STS		EICRA, R16

	SBI		EIMSK, INT0
	SBI		EIMSK, INT1


	CLR		R18
	OUT		PORTC, R18
	SEI

MAIN: 
	//Loop infinito 
	RJMP	MAIN

//Logica de interrupciones
INTER0: 
	//Interrupcion que realiza el PD2
	PUSH	R16
	IN		R16, SREG
	PUSH	R16
	PUSH	R17

	CALL	INCREMENT
	OUT		PORTC, R18

	POP		R17
	POP		R16
	OUT		SREG, R16
	POP		R16
	RETI

INTER1:
	//Interrupcion que realiza el PD3
	PUSH	R16
	IN		R16, SREG
	PUSH	R16
	PUSH	R17

	CALL	DECREMENT
	OUT		PORTC, R18

	POP		R17
	POP		R16
	OUT		SREG, R16
	POP		R16
	RETI

INCREMENT: 
	//Logica para incrementar el contador 
	INC		R18
	CPI		R18, 0x10
	BRNE	OVER
	LDI		R18, 0x00
OVER:
	RET

DECREMENT: 
	//logica para decrementar el contador 
	CPI		R18, 0x00
	BREQ	UNDER
	DEC		R18
	RET
UNDER: 
	LDI		R18, 0x0F
	RET