 ; Lab3P1.s
 ;
 ; Created: 1/30/2018 4:15:16 AM
 ; Author : Eugene Rockey
 ; Copyright 2018, All Rights Reserved


.section ".data"					;student comment here
.equ	DDRB,0x04					;student comment here
.equ	DDRD,0x0A					;student comment here
.equ	PORTB,0x05					;student comment here
.equ	PORTD,0x0B					;student comment here
.equ	U2X0,1						;student comment here
.equ	UBRR0L,0xC4					;student comment here
.equ	UBRR0H,0xC5					;student comment here
.equ	UCSR0A,0xC0					;student comment here
.equ	UCSR0B,0xC1					;student comment here
.equ	UCSR0C,0xC2					;student comment here
.equ	UDR0,0xC6					;student comment here
.equ	RXC0,0x07					;student comment here
.equ	UDRE0,0x05					;student comment here
.equ	ADCSRA,0x7A					;student comment here
.equ	ADMUX,0x7C					;student comment here
.equ	ADCSRB,0x7B					;student comment here
.equ	DIDR0,0x7E					;student comment here
.equ	DIDR1,0x7F					;student comment here
.equ	ADSC,6						;student comment here
.equ	ADIF,4						;student comment here
.equ	ADCL,0x78					;student comment here
.equ	ADCH,0x79					;student comment here
.equ	EECR,0x1F					;student comment here
.equ	EEDR,0x20					;student comment here
.equ	EEARL,0x21					;student comment here
.equ	EEARH,0x22					;student comment here
.equ	EERE,0						;student comment here
.equ	EEPE,1						;student comment here
.equ	EEMPE,2						;student comment here
.equ	EERIE,3						;student comment here

.global HADC				;student comment here
.global LADC				;student comment here
.global ASCII				;student comment here
.global DATA				;student comment here
.global EEPROMAL

.set	temp,0				;student comment here

.section ".text"			;student comment here
.global Mega328P_Init
Mega328P_Init:
		ldi	r16,0x07		;PB0(R*W),PB1(RS),PB2(E) as fixed outputs
		out	DDRB,r16		;student comment here
		ldi	r16,0			;student comment here
		out	PORTB,r16		;student comment here
		out	U2X0,r16		;initialize UART, 8bits, no parity, 1 stop, 9600
		ldi	r17,0x0			;student comment here
		ldi	r16,0x67		;student comment here
		sts	UBRR0H,r17		;student comment here
		sts	UBRR0L,r16		;student comment here
		ldi	r16,24			;student comment here
		sts	UCSR0B,r16		;student comment here
		ldi	r16,6			;student comment here
		sts	UCSR0C,r16		;student comment here
		ldi r16,0x87		;initialize ADC
		sts	ADCSRA,r16		;student comment here
		ldi r16,0x40		;student comment here
		sts ADMUX,r16		;student comment here
		ldi r16,0			;student comment here
		sts ADCSRB,r16		;student comment here
		ldi r16,0xFE		;student comment here
		sts DIDR0,r16		;student comment here
		ldi r16,0xFF		;student comment here
		sts DIDR1,r16		;student comment here
		ret					;student comment here
	
.global LCD_Write_Command
LCD_Write_Command:
	call	UART_Off		;turn the uart RX and TX off
	ldi		r16,0xFF		;PD0 - PD7 as outputs
	out		DDRD,r16		;how many bit out puts
	lds		r16,DATA		;load the data to be writen in r16
	out		PORTD,r16		;load the value into the send register
	ldi		r16,4			;load value 4 into r16 
	out		PORTB,r16		;send the data to the board (e = 1)
	call	LCD_Delay		;wait a short moment
	ldi		r16,0			;load 0  into r16
	out		PORTB,r16		;send the data to the board (e = 0)
	call	LCD_Delay		;wait a short momment
	call	UART_On			;turn the uart  back on
	ret						;return

.global LCD_Delay
LCD_Delay:
	ldi		r16,0xFA		;load value of 0xFA to r16
D0:	ldi		r17,0xFF		;load value of 0xFF to r17
D1:	dec		r17				;dec the value in r17
	brne	D1				;brach if value in r17 is not negative to D1
	dec		r16				;dec the value in r16
	brne	D0				;barnch if value in r16 is not negative to D0
	ret						;return

.global LCD_Write_Data
LCD_Write_Data:
	call	UART_Off		;turn of uart connection
	ldi		r16,0xFF		;load 0xFF to 16 to set number of bits
	out		DDRD,r16		;set transmit to number of bits to 8
	lds		r16,DATA		;load 8 bit data to r16
	out		PORTD,r16		;load data into the0 
	ldi		r16,6			;load 6 to r16
	out		PORTB,r16		;load 6 to port b write data
	call	LCD_Delay		;wait a momment
	ldi		r16,0			;load 0 to r16
	out		PORTB,r16		;clear stop writing
	call	LCD_Delay		;wait a momment
	call	UART_On			;turn uart back on
	ret						;return

.global LCD_Read_Data
LCD_Read_Data:
	call	UART_Off		;turn uart off
	ldi		r16,0x00		;load 0x00 ro r16
	out		DDRD,r16		;set bits to input
	out		PORTB,4			;enable
	in		r16,PORTD		;load value
	sts		DATA,r16		;store loaded value to data variable
	out		PORTB,0			;clear portb
	call	UART_On			;turn uart back on
	ret						;return

.global UART_On
UART_On:
	ldi		r16,2				;load 2 to r16
	out		DDRD,r16			;2 bits as output
	ldi		r16,24				;load 24 to r16
	sts		UCSR0B,r16			;set rx and tx high
	ret							;return

.global UART_Off
UART_Off:
	ldi	r16,0					;load 0x00 to r16
	sts UCSR0B,r16				;set rx and tx low
	ret							;return

.global UART_Clear
UART_Clear:
	lds		r16,UCSR0A			;load uart settings to r16
	sbrs	r16,RXC0			;if the data recieved bit is high skip next
	ret							;return
	lds		r16,UDR0			;load data do nothing
	rjmp	UART_Clear			;relative jump to same functions

.global UART_Get
UART_Get:
	lds		r16,UCSR0A			;load uart settings A
	sbrs	r16,RXC0			;if data recieved bit is high skip next
	rjmp	UART_Get			;loop top of function
	lds		r16,UDR0			;load data to r16
	sts		ASCII,r16			;pass data to ascii varaible
	ret							;return

.global UART_Inte
UART_Inte:
	lds		r16,UCSR0A			;load uart a settings
	sbrc	r16,RXC0			; if data recieved bit is low skip next
	sts		ASCII,r16			;pass data to ascii variable
	ret							;return

.global UART_Put
UART_Put:
	lds		r17,UCSR0A			;0xC0 load uart setting into r17
	sbrs	r17,UDRE0			;0x05 if ready to recieve data bit is high skip next
	rjmp	UART_Put			;jump to top of function
	lds		r16,ASCII			;load ascii to r16
	sts		UDR0,r16			;load ascii data to usrt data register
	ret							;reutn

.global ADC_Get
ADC_Get:
		ldi		r16,0xC7			;student comment here
		sts		ADCSRA,r16			;student comment here
A2V1:	lds		r16,ADCSRA			;student comment here
		sbrc	r16,ADSC			;student comment here
		rjmp 	A2V1				;student comment here
		lds		r16,ADCL			;student comment here
		sts		LADC,r16			;student comment here
		lds		r16,ADCH			;student comment here
		sts		HADC,r16			;student comment here
		ret							;student comment here

.global EEPROM_Write
EEPROM_Write:      
		sbic    EECR,EEPE
		rjmp    EEPROM_Write		; Wait for completion of previous write
		ldi		r18,0x00			; Set up address (r18:r17) in address register
		lds		r17,EEPROMAL 
		lds		r16, ASCII			; Set up data in r16    
		out     EEARH, r18      
		out     EEARL, r17			      
		out     EEDR,r16			; Write data (r16) to Data Register  
		sbi     EECR,EEMPE			; Write logical one to EEMPE
		sbi     EECR,EEPE			; Start eeprom write by setting EEPE
		ret 

.global EEPROM_Read
EEPROM_Read:					    
		sbic    EECR,EEPE    
		rjmp    EEPROM_Read			; Wait for completion of previous write
		ldi		r18,0x00			; Set up address (r18:r17) in EEPROM address register
		lds		r17,EEPROMAL
		ldi		r16,0x00   
		out     EEARH, r18   
		out     EEARL, r17		   
		sbi     EECR,EERE			; Start eeprom read by writing EERE
		in      r16,EEDR			; Read data from Data Register
		sts		ASCII,r16  
		ret

.global SetParity
SetParity:
		call	UART_Off
		lds		r16, UCSR0C
		lds		r17, DATA
		ldi		r18, 0xff
		or		r16, r17
		eor		r17, r18
		and		r16, r17
		sts		UCSR0C, r16
		call	UART_On
		ret

.global SetDataBits
SetDataBits:
		call	UART_Off
		lds		r16, UCSR0B
		lds		r17, UCSR0C
		lds		r18, ASCII
		cbr		r16, 0xfb
		sbrc	r18, 0x3
		sbr		r16, 0x4
		lds		r18, DATA
		cbr		r17, 0xfd
		cbr		r17, 0xfd
		add		r17, r18
		sts		UCSR0B,r16
		sts		UCSR0C,r17
		call	UART_On
		ret

.global SetStop
SetStop:
		call	UART_Off
		lds		r16, ASCII
		lds		r17, UCSR0C
		lsl		r16
		lsl		r16
		lsl		r16
		cbr		r17,0xf7
		add		r17, r16
		sts		UCSR0C, r17
		call	UART_On
		ret

.global SetBaud
SetBaud:
		call	UART_Off
		lds		r16, UBRR0H
		lds		r17, ASCII
		lds		r18, DATA
		swap	r18
		mov		r19, r18
		cbr		r19, 0x0f
		cbr		r16, 0xf0
		add		r16, r19
		cbr		r18, 0xf0
		add		r17, r18
		sts		UBRR0H, r16
		sts		UBRR0L, r17
		call	UART_On
		ret

.global ADC_Init
ADC_Init:
		ldi		r16, 0b11100111
		ldi		r17, 0x00
		sts		ADCSRB, r17
		sts		ADCSRA, r16
		ret

.global ADC_Get_Free
ADC_Get_Free:
		lds		r16, ADCL
		lds		r17, ADCH
		sts		LADC, r16
		sts		HADC, r17
		ret

.global ADC_Free_End
ADC_Free_End:
		lds		r18, ADCSRA
		cbr		r18, 0x7f
		sts		ADCSRA, r18
		ret

		.end

