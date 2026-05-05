;
; Laboratorio 2.asm
;
; Created: 2/10/2025 5:03:58 PM
; Author : Ervin Gomez 231226
;

.include "M328Pdef.inc"
.cseg
.org	0x0000
.def COUNTER = R24

TABLA7SEG:	.DB		0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47 //Orden de los numeros
					//0	   1	 2	    3	  4	    5    6     7	  8	    9	 10	   11	 12	  13     14	   15
//Configuración de la pila 
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16

SETUP: 
	//CONFIGURACIONES INICIALES
	//Configuracion del timer0
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16
	LDI		R16, (1 << CLKPS2)
	STS		CLKPR, R16
	LDI		R16, (1<<CS02) | (1<<CS00)
	OUT		TCCR0B, R16
	LDI		R16, 158
	OUT		TCNT0, R16

	//Configuracion de los puertos 
	LDI		R16, 0x00
	OUT		DDRB, R16 //Configuración del puerto B como entrada 
	LDI		R16, 0xFF
	OUT		PORTB, R16 //Se enciende los pull-ups 
	LDI		R16, 0xFF
	OUT		DDRD, R16 //PortD como salida del 7segmentos
	OUT		DDRC, R16 //PORTC como salida del contador de 4 bits
	LDI		R16, 0x00
	OUT		PORTD, R16
	OUT		PORTC, R16

	LDI		R16, 0x00
	STS		UCSR0B, R16

	//Inicialización todos los registros en 0, para evitar errores en el programa
	LDI		R16, 0x00
	LDI		R17, 0x00	
	LDI		R21, 0x00 
	LDI		R18, 0x00 
	LDI		R22, 0x00	
	LDI		R20, 0x00 
	LDI		R23, 0x00 
	LDI		R19, 0x00
	CALL	INICIAL

MAIN: 
	// Loop infinito
	//Contador de 4 bits por segundo
	IN		R16, TIFR0
	SBRS	R16, TOV0
	RJMP	SEG7
	SBI		TIFR0, TOV0
	LDI		R16, 158
	OUT		TCNT0, R16
	INC		COUNTER
	CPI		COUNTER, 10
	BRNE	SEG7
	CLR		COUNTER
	CALL	COMP
	CALL	ConTIMER0
	
SEG7: 
	//Logica para los cambios de valor del Display 
	IN		R20, PINB // Guardando el estado de PORTB
	CP		R21, R20 //Comparar estados de los botones
	BREQ	MAIN
	CALL	DELAY
	IN		R20, PINB
	CP		R21, R20 //Verificar el estado del boton
	BREQ	MAIN
	MOV		R21, R20
	SBIS	PINB, 0 // Verifica el estado del boton 1
	CALL	INCREMET
	SBIS	PINB, 1 // Verifica el estado del boton 2
	CALL	DECREMT
	LPM		R22, Z
	OUT		PORTD, R22 // Muestres los cambios en el puetoD
	CPI		R23, 0x00
	RJMP	MAIN

INICIAL: 
	//Inicio del contador del Display
	LDI		ZL, LOW(TABLA7SEG <<1)
	LDI		ZH, HIGH(TABLA7SEG <<1)
	RET

ConTIMER0: 
	//Inicio del contador asociado con el TIMER0
	INC		R19
	CPI		R19, 0x10
	BRNE	OVER1
	LDI		R19, 0x00
OVER1:
	OUT		PORTC, R19
	RET

INCREMET: 
	//Logica para aumentar el valor del Display
	INC		R23
	ADIW	Z, 1
	CPI		R23, 0x10	//Compara el valor del contador asociado con el Display
	BRNE	OVER		//si esto no sucede regresar al main. 
	CALL	INICIAL		//reinicia el contador del display
	LDI		R23, 0x00 
	RET
OVER:
	RET
	
DECREMT: 
	CPI		R23, 0x00 //Compara el registro
	BREQ	UNDER		//Cuando ocurre un underflow
	DEC		R23
	SBIW	Z, 1
	RET
UNDER: 
	LDI		R23, 0x0F 
	CALL	INICIAL //reinici el contador el display
	ADIW	Z, 15	//Deja el contador en la direccion 15
	RET

COMP: 
	MOV		R24, R23 
	CP		R19, R24 //compara los valores de ambos contadores
	BREQ	ALARM	//Si son iguales va a ALARM
	RET
ALARM: 
	SBI		PINB, PB3 //Se asigana el bit 7 de D para la led de alarma 
	OUT		PORTC, R19
	RET
	
//Logica del antirebore de los botones
DELAY:
	LDI R18, 0xFF
SUB_DELAY1:
	DEC R18
	CPI R18, 0
	BRNE SUB_DELAY1
	LDI R18, 0xFF
SUB_DELAY2:
	DEC R18
	CPI R18, 0
	BRNE SUB_DELAY2
	LDI R18, 0xFF
SUB_DELAY3:
	DEC R18
	CPI R18, 0
	BRNE SUB_DELAY3
	RET
