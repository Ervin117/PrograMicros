;
; PostLab1.asm
;
; Created: 2/4/2025 1:39:27 PM
; Author : Ervin Gomez 231226
;

.include "m328Pdef.inc"

.cseg
.org	0x0000
// Configuración de la pila 
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16

// Configuración de inicio 
SETUP: 
	// Configuración de los pines de entrada y salida
	LDI		R16, 0x00
	OUT		DDRB, R16 	// PORTB como entrada
	LDI		R16, 0xFF
	OUT		PORTB, R16 	// Activar pull-ups en PORTB

	LDI		R16, 0xFF
	OUT		DDRC, R16 	// PORTC como salida
	OUT		DDRD, R16 	// PORTD como salida
	LDI		R16, 0x00
	OUT		PORTC, R16
	OUT		PORTD, R16
	
	// Inicialización de contadores
	LDI		R17, 0x00
	LDI		R18, 0x00
	LDI		R21, 0x00

//Oscilador de 1MHz
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16
	LDI		R16, (1 << CLKPS2)
	STS		CLKPR, R16

MAIN: 
	// Loop infinito
	IN		R16, PINB // Guardando el estado de PORTB
	CP		R21, R16 //Comparar estados de los botones
	BREQ	MAIN
	CALL	DELAY
	IN		R16, PINB
	CP		R21, R16 //Verificar el estado del boton
	MOV		R21, R16
	SBIS	PINB, 0 // Verifica el estado del boton 1
	CALL	INCREMENT  // Llama la rutina de incremento
	SBIS	PINB, 1 // Verifica el estado del boton 2
	CALL	DECREMENT  // Llama la rutina de decremento
	SBIS	PINB, 2 // Verifica el estado del boton 3
	CALL	INCREMENT2 // Llama la rutina de incremento
	SBIS	PINB, 3 // Verifica el estado del boton 4
	CALL	DECREMENT2 // Llama la rutina de decremento
	SBIS	PINB, 4 // Verifica el estado del boton 5
	CALL	SUMA       // Llama la rutina de suma
	
	// Orden de los bits compartiendo PUERTO
	MOV		R22, R18
	SWAP	R22
	ADD		R22, R17
	OUT		PORTD, R22
	RJMP	MAIN // Regresa al loop

INCREMENT: 
	// Lógica de incremento 
	CPI		R17, 0x0F
	BREQ	MAIN
	INC		R17		  // Incrementa el contador 
	RET

DECREMENT:
	// Lógica de decremento
	CPI		R17, 0x00 // Detener si es 0x00
	BREQ	MAIN
	DEC		R17 	  // Decrementar el contador 
	RET

INCREMENT2: 
	// Lógica de incremento 
	CPI		R18, 0x0F
	BREQ	MAIN
	INC		R18 	  // Incrementa el contador 
	RET

DECREMENT2:
	// Lógica de decremento
	CPI		R18, 0x00 // Detener si es 0x00
	BREQ	MAIN
	DEC		R18 	  // Decrementar el contador 
	RET

SUMA: 
	// Sub-rutina de la suma de los contadores
	MOV		R20, R18
	ADD		R20, R17
	OUT		PORTC, R20 // Mostrar la suma en PORTD
	RET

// Lógica Antirebotes
RETARDO: 
	LDI		R19, 0xFF // Aumentar el retardo para mayor estabilidad

DELAY: 
	DEC		R19
	CPI		R19, 0
	BRNE	DELAY // Espera hasta que R19 llegue a 0 
	LDI		R19, 0xFF
DELAY2: 
	DEC		R19
	CPI		R19, 0
	BRNE	DELAY2
	LDI		R19, 0xFF
DELAY3: 
	DEC		R19
	CPI		R19, 0
	BRNE	DELAY3
	RET