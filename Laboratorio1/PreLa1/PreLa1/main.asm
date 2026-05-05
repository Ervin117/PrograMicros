;
; PreLa1.asm
;
; Created: 2/2/2025 10:33:44 PM
; Author : Ervin Gomez 231226
;

//Configurara el ATmega328P
.include "m328Pdef.inc"

.cseg
.org	0x0000
//Configuración de la pila 
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16

//Configuracion de inicio 
SETUP: 
	//Configuracion de los pines de entrada y salida
	LDI		R16, 0x0F
	OUT		DDRB, R16 //PORTB como salida
	LDI		R16, 0x0F
	OUT		DDRC, R16 //PORTC como salida
	LDI		R16, 0x00
	OUT		DDRD, R16 //PORTD como entrada
	LDI		R16, 0x0C
	CLR		R17
	OUT		PORTB, R17 //Inicio del contador1 en 0 
	CLR		R18
	OUT		PORTC, R18 //Inicio del contador2 en 0

MAIN: 
	//Loop infinito
	SBIC	PIND, PD2 //Verifica el estado del boton 1
	CALL	INCREMENT //Llama la rutina de incremento
	SBIC	PIND, PD3 //Verifica el estado del boton 2
	CALL	DECREMENT //Llama la rutina de decremento
	SBIC	PIND, PD4 //Verifica el estado del boton 3
	CALL	INCREMENT2 //Llama la rutina de incremento
	SBIC	PIND, PD5 //Verifica el estado del boton 4
	CALL	DECREMENT2 //Llama la rutina de decremento
	RJMP	MAIN //Regresa al loop

INCREMENT: 
	//Logica de incremento 
	CPI		R17, 0x0F //Para el incremento al llegar al valor 0x0F
	BREQ	MAIN
	INC		R17		  //Incrementa el contador 
	OUT		PORTB, R17 //Actualiza la salida
	RJMP	RETARDO
	RET

DECREMENT:
	//Logica de decremento
	CPI		R17, 0x00 //Para el contador si es 0x00
	BREQ	MAIN
	DEC		R17		  //Decrementar el contador 
	OUT		PORTB, R17 //Actualiza salida
	RJMP	RETARDO
	RET

INCREMENT2: 
	//Logica de incremento 
	CPI		R18, 0x0F //Para el incremento al llegar al valor 0x0F
	BREQ	MAIN
	INC		R18		  //Incrementa el contador 
	OUT		PORTC, R18 //Actualiza la salida
	RJMP	RETARDO
	RET

DECREMENT2:
	//Logica de decremento
	CPI		R18, 0x00 //Para el contador si es 0x00
	BREQ	MAIN
	DEC		R18 	  //Decrementar el contador 
	OUT		PORTC, R18 //Actualiza salida
	RJMP	RETARDO
	RET

//Logica Antirebotes
RETARDO: 
	LDI		R19, 0xFF //Cargar valor para retardo 

DELAY: 
	DEC		R19
	BRNE	DELAY //Espera hasta que R19 llegue a 0. 
	RJMP	MAIN
