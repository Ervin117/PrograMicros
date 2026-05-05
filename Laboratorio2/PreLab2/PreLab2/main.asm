;
; PreLab2.asm
;
; Created: 2/8/2025 3:27:58 PM
; Author : Ervin Gomez 231226
;

.include "M328PDEF.inc"
.cseg
.org 0x0000
.def COUNTER = R17

//Configuración de la pila 
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16

SETUP: 
	//Configuración del Prescaler "Principal"
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16
	LDI		R16, (1 << CLKPS2)
	STS		CLKPR, R16

	//Inicio del Timer0
	CALL TMR0

	//Configuración de los puertos 
	LDI		R16, 0xFF
	OUT		DDRB, R16
	LDI		R16, 0x00
	OUT		PORTB, R16

	LDI		R18, 0x00

MAIN: 
	//Loop infinito 
	IN		R16, TIFR0
	SBRS	R16, TOV0
	RJMP	MAIN
	SBI		TIFR0, TOV0
	LDI		R16, 100
	OUT		TCNT0, R16
	INC		COUNTER
	CPI		COUNTER, 10 //Cuando el counter llegue a 100ms
	BRNE	MAIN
	CLR		COUNTER
	INC		R18
	OUT		PORTB, R18
	RJMP	MAIN

// NON-Interrupt subroutines
TMR0: 
	LDI		R16, (1<<CS01) | (1<<CS00)
	OUT		TCCR0B, R16
	LDI		R16, 100
	OUT		TCNT0, R16
	RET