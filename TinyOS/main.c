
 // Lab3P1.c
 //
 // Created: 1/30/2018 4:04:52 AM
 // Author : me
 // Copyright 2018, All Rights Reserved
 
 //no includes, no ASF, no libraries
 
 
 const char MS1[] = "\r\nECE-412 ATMega328P Tiny OS";
 const char MS2[] = "\r\nby Eugene Rockey Copyright 2018, All Rights Reserved";
 const char MS3[] = "\r\nMenu: (L)CD, (A)CD, (E)EPROM (U)ART\r\n";
 const char MS4[] = "\r\nReady: ";
 const char MS5[] = "\r\nInvalid Command Try Again...";
 const char MS6[] = "Volts\r";
 const char MS7[] = "\r\nMenu: (B)aud, (D)ata, (P)arity, (S)top\r\n";
 
 

void LCD_Init(void);			//external Assembly functions
void UART_Init(void);
void UART_Clear(void);
void UART_Get(void);
void UART_Put(void);
void UART_Inte(void);
void LCD_Write_Data(void);
void LCD_Write_Command(void);
void LCD_Delay(void);
void LCD_Read_Data(void);
void Mega328P_Init(void);
void ADC_Get(void);
void EEPROM_Read(void);
void EEPROM_Write(void);
void SetParity(void);
void SetDataBits(void);
void SetStop(void);
void SetBaud(void);

void Command(void);

unsigned char ASCII;			//shared I/O variable with Assembly
//unsigned char ASCII2;
unsigned char DATA;				//shared internal variable with Assembly
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly
unsigned char EEPROMAL;

char volts[5];					//string buffer for ADC output
int Acc;						//Accumulator for ADC use

void UART_Puts(const char *str)	//Display a string in the PC Terminal Program
{
	while (*str)
	{
		ASCII = *str++;
		UART_Put();
	}
}

void LCD_Puts(const char *str)	//Display a string on the LCD Module
{
	while (*str)
	{
		
		DATA = *str++;
		LCD_Write_Data();
	}
}


void Banner(void)				//Display Tiny OS Banner on Terminal
{
	UART_Puts(MS1);
	UART_Puts(MS2);
	UART_Puts(MS4);
}

void HELP(void)						//Display available Tiny OS Commands on Terminal
{
	UART_Puts(MS3);
}

void LCD(void)						//Lite LCD demo
{
	DATA = 0x1;
	LCD_Write_Command();
	DATA = 0x38;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x08;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x02;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x06;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x0f;
	LCD_Write_Command();
	LCD_Puts("Team Ten");
	
	ASCII = '\0';
	DATA = 0X18;
	
	while(ASCII == '\0')
	{
		UART_Inte();
		LCD_Write_Command();
		for(int i = 14;i>0;i--)
		{
			LCD_Delay();
		}
		UART_Inte();
		UART_Clear();
	}
	
	/*
	Re-engineer this subroutine to have the LCD endlessly scroll a marquee sign of 
	your Team's name either vertically or horizontally. Any key press should stop
	the scrolling and return execution to the command line in Terminal. User must
	always be able to return to command line.
	*/
}

void ADC(void)						//Lite Demo of the Analog to Digital Converter
{
	UART_Puts("\r\n");
	volts[0x1]='.';
	volts[0x3]=' ';
	volts[0x4]= 0;
	ADC_Get();
	ASCII = HADC+ 0x30;
	UART_Put();
	ASCII = LADC;
	UART_Put();
	
	Acc = (((int)HADC) * 0x100 + (int)(LADC))*0xA;
	volts[0x0] = 48 + (Acc / 0x7FE);
	Acc = Acc % 0x7FE;
	volts[0x2] = ((Acc *0xA) / 0x7FE) + 48;
	Acc = (Acc * 0xA) % 0x7FE;
	if (Acc >= 0x3FF) volts[0x2]++;
	if (volts[0x2] == 58)
	{
		volts[0x2] = 48;
		volts[0x0]++;
	}
	UART_Puts(volts);

	UART_Puts(MS6);
	
		/*Re-engineer this subroutine to display temperature in degrees Fahrenheit on the Terminal.
		The potentiometer simulates a thermistor, its varying resistance simulates the
		varying resistance of a thermistor as it is heated and cooled. See the thermistor
		equations in the lab 3 folder. User must always be able to return to command line.
	*/
	
}

void ASCIItoHEX(void)
{
	ASCII = ASCII - 0x30;
	if(ASCII > 9)
	{
		ASCII= ASCII -0x11;
	}
	if(ASCII>0x0f)
	{
		ASCII = ASCII - 0x20;
	}
	if(ASCII>0x0f)
	{
		UART_Puts(MS5);
		Command();
	}
	
}

void EEPROM(void)
{
	UART_Puts("\r\nEEPROM Write and Read.");
	
	/*Re-engineer this subroutine so that a byte of data can be written to any address in EEPROM
	during run-time via the command line and the same byte of data can be read back and verified after the power to
	the Xplained Mini board has been cycled. Ask the user to enter a valid EEPROM address and an
	8-bit data value. Utilize the following two given Assembly based drivers to communicate with the EEPROM. You
	may modify the EEPROM drivers as needed. User must be able to always return to command line.*/
	
	UART_Puts("\r\nHigher 4 bits of address in hex.\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	UART_Put();
	ASCIItoHEX();
	EEPROMAL = ASCII;
	EEPROMAL=EEPROMAL<<4;
	
	UART_Puts("\r\nLower 4 bits of address in hex.\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	UART_Put();
	ASCIItoHEX();
	EEPROMAL = EEPROMAL + ASCII;
	
	
	UART_Puts("\r\n(S)ave or (L)oad from this address.\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	
	switch (ASCII)
	{
		case 's'|'S' : 
		UART_Puts("\r\nWhat char would you like to save\r\n");
		ASCII = '\0';
		while (ASCII == '\0')
		{
			UART_Get();
		}
		EEPROM_Write();
		UART_Put();
		break;
		case 'l'|'L' : 
		EEPROM_Read();
		UART_Put();
		break;
		default:
		UART_Puts(MS5);
		Command();
		break;
	}

	
}

void Baud(void)
{
	UART_Puts("\r\n Enter three hexadecimal values for the baud rate.\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	UART_Put();
	ASCIItoHEX();
	DATA = ASCII;
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	UART_Put();
	ASCIItoHEX();
	DATA = (DATA<<4) + ASCII;
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	UART_Put();
	ASCIItoHEX();
	SetBaud();
}

void DataBits(void)
{
	UART_Puts("\r\n(5) bits, (6) bits, (7) bits, (8) bits, or (9) bits\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case '9': DATA = 0x06;
		break;
		case '8':DATA = 0x06;
		ASCII = ASCII -1;
		break;
		case '7': DATA = 0x04;
		break;
		case '6': DATA = 0x02;
		break;
		case '5': DATA = 0x0;
		break;
		default:
		UART_Puts(MS5);
		Command();
		break;
	}
	SetDataBits();
}

void Parity(void)
{
	UART_Puts("\r\n(D)isable, (E)ven, (O)dd\r\n");	
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case 'D' | 'd' : DATA = 0x00;
		SetParity();
		UART_Puts("\r\nParity Disabled\r\n");
		break;
		case 'E' | 'e' : DATA = 0x10;
		SetParity();
		UART_Puts("\r\nParity set to Even\r\n");
		break;
		case 'O' | 'o' : DATA = 0x18;
		SetParity();
		UART_Puts("\r\nParity set to Odd\r\n");
		break;
		default:
		UART_Puts("\r\nThis shouldn't happen\r\n");
		Command();
		break;
	}
}

void Stop(void)
{
	UART_Puts("\r\n(1) bit or (2) bits\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	
	switch(ASCII)
	{
		
		case '1' | '2':
		ASCII = ASCII - 0x31;
		SetStop();
		break;
		default:
		UART_Puts(MS5);
		break;
	}
	
}

void UART(void)
{
	UART_Puts(MS7);
	ASCII='\0';
	while (ASCII=='\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case 'B' | 'b' : Baud();
		break;
		case 'D' | 'd' : DataBits();
		break;
		case 'P' | 'p' : Parity();
		break;
		case 'S' | 's' : Stop();
		break;
		default:
		UART_Puts(MS5);
		break;
	}
}

void Command(void)					//command interpreter
{
	UART_Puts(MS3);
	ASCII = '\0';						
	while (ASCII == '\0')
	{
		UART_Get();
	}
	UART_Put();
	switch (ASCII)
	{
		case 'L' | 'l': LCD();
		break;
		case 'A' | 'a': ADC();
		break;
		case 'E' | 'e': EEPROM();
		break;
		case 'U' | 'u': UART();
		break;
		default:
		UART_Puts(MS5);
		HELP();
		break;  			//Add a 'USART' command and subroutine to allow the user to reconfigure the 						//serial port parameters during runtime. Modify baud rate, # of data bits, parity, 							//# of stop bits.
	}
}

int main(void)
{
	Mega328P_Init();
	Banner();
	while (1)
	{
		Command();				//infinite command loop
	}
}

