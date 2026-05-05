;
; Laboratorio 3.asm
;
; Created: 2/17/2025 4:52:41 PM
; Author : Ervin Gomez 231226
;

.include "M328PDEF.inc"
.cseg
.org 0x0000
	JMP		START
.org	PCI0addr
	JMP		INTER1
.org OVF0addr 
	JMP		TMR0_7SEG1
TABLA7SEG:	.DB		0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B //Orden de los numeros
					//0	   1	 2	    3	  4	    5    6     7	  8	    9	 

START: 
	//Configuracion de la pila
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16

SETUP:
//Configuraciones iniciales 
	CLI
	//Configuraciones del Prescaler
	LDI		R16, (1<< CLKPCE)
	STS 	CLKPR, R16 
	LDI		R16, (1<< CLKPS2) 
	STS		CLKPR, R16

	LDI		R16, (1<<CS01) | (1<<CS00)
	OUT		TCCR0B, R16
	LDI		R16, 100
	OUT		TCNT0, R16

	CBI		DDRB, PB0
	CBI		DDRB, PB1 //Se establece al bit 0 y 1 en entradas
	CBI		PORTB, PB2
	CBI		PORTB, PB3

	LDI		R16, 0xFF
	OUT		DDRD, R16 //Se establece D como salida 
	OUT		DDRC, R16 //Se establece C como salida 
	LDI		R16, 0x00
	OUT		PORTD, R16
	OUT		PORTC, R16

	CALL	INICIO

	LDI		R16, 0x00
	STS		UCSR0B, R16

	//Configuraciones de interrupciones
	LDI		R16, (1 <<TOIE0)
	STS		TIMSK0, R16
	LDI		R16, (1<< PCINT0) | (1<< PCINT1)
	STS		PCMSK0, R16
	LDI		R16, (1<< PCIE0)
	STS		PCICR, R16

	SEI
	
MAIN: 
	//Loop infinito. 
	RJMP	MAIN

INICIO:
	LDI		ZL, LOW(TABLA7SEG <<1)
	LDI		ZH, HIGH(TABLA7SEG <<1)
	LPM		R22, Z
	OUT		PORTD, R22
	RET

INTER1: 
	//Interrupcion que realiza el conteo 
	PUSH	R16
	IN		R16, SREG
	PUSH	R16

	IN		R17, PINB
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



TMR0_7SEG1:
//Interupcion para el display de unidades
	PUSH	R16
	IN		R16, SREG
	PUSH	R16

	SBI		TIFR0, TOV0
	LDI		R16, 100
	OUT		TCNT0, R16
	INC		R20
	CPI		R20, 100 //Compara si ya paso un segundo 
	BRNE	TRST //Si no ocurre, pasa a TRST, realiza el control de los displays
	INC		R19
	CPI		R19, 0x0A
	BRNE	OVER1
	LDI		R19, 0x00
	INC		R21
	LDI		R20, 0
	CPI		R21, 0x06
	BRNE	OVER1
	LDI		R21, 0x00
	
OVER1: 
	LPM		R22, Z
	LDI		R20, 0
	RJMP	FIN


TRST:
//Mostrar en la salida D
	CPI		R23, 0x00
	BREQ	DIS1
	CPI		R23, 0x01
	BREQ	DIS2

DIS1:
	LDI		ZL, LOW(TABLA7SEG <<1)
	LDI		ZH, HIGH(TABLA7SEG <<1)
	ADD		ZL, R19
	LPM		R22, Z
	SBI		PORTB, PB2
	CBI		PORTB, PB3
	OUT		PORTD, R22
	LDI		R23, 0x01
	RJMP	FIN


DIS2:
	LDI		ZL, LOW(TABLA7SEG <<1)
	LDI		ZH, HIGH(TABLA7SEG <<1)
	ADD		ZL, R21
	LPM		R22, Z
	CBI		PORTB, PB2
	SBI		PORTB, PB3
	OUT		PORTD, R22
	LDI		R23, 0x00

FIN:
	POP		R16
	OUT		SREG, R16
	POP		R16
	RETI
