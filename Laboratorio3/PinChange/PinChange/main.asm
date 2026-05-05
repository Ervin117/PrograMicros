; PinChange.asm
;
; Created: 2/19/2025 10:17:36 AM
; Author : Ervin Gomez 231226
;

.include "M328PDEF.inc"
.cseg
.org	0x0000
	JMP INICIO
.org	PCI0addr
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
	CBI		DDRB, PB0 
	//SBI		PORTB, PB0 //Pull-ups activados 
	CBI		DDRB, PB1
	//SBI		PORTB, PB1 //Pull-ups activados 

	//Configuración de C como la salida del contador 
	LDI		R16, 0xFF
	OUT		DDRC, R16
	LDI		R16, 0x00
	OUT		PORTC, R16

	//Configuracion de las interrupciones de Pin change
	LDI		R16, (1 << PCINT1) | (1 << PCINT0)
	STS		PCMSK0, R16

	LDI		R16, (1 << PCIE0)
	STS		PCICR, R16

	CLR		R18
	OUT		PORTC, R18
	SEI

MAIN: 
	//Loop infinito 
	RJMP	MAIN

//Logica de interrupciones
INTER1: 
	//Interrupcion que realiza el conteo 
	PUSH	R16
	IN		R16, SREG
	PUSH	R16

	IN		R19, PINB
	SBIS	PINB, PB0
	CALL	INCREMENT
	SBIS	PINB, PB1
	CALL	DECREMENT
	OUT		PORTC, R18

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
