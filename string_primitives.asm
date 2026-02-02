TITLE Project_6    (Proj6_sommerbr.asm)

; Author: Bradley Sommer
; Last Modified: 12/07/2023
; OSU email address: sommerbr@oregonstate.edu
; Course number/section:   CS271 Section 408
; Project Number: Project 6                Due Date: 12/10/2023
; Description: This program asks the user to enter 10ea. numbers that will fit within a 32-bit register.
;				The program will verify that the user's input only consists of characters representing decimal numbers or 
;				'+' and '-' in first position. Verification that the entry will fit within a 32-bit register is also performed. 
;				If the input is invalid the user asked to re-enter a valid character. 
;				The program will then convert the user's input strings from ASCII to decimal. MASM MACROs are used to obtain 
;				input from the user and to display all necessary strings. String primitives are used during conversion processes.
;				Converted decimal entries are stored in an array. 
;				The stored user's input is then converted from decimal to ASCII and displayed. The sum of all entries and the 
;				truncated average is then computed and displayed.

INCLUDE Irvine32.inc

  ; ---------------------------------------------------------------------------------
  ; Name: mGetString
  ;
  ; Display a prompt then gets the user's keyboard input and store it in a memory location.
  ; Uses Irvine Library's ReadString.
  ;
  ; Preconditions:	None
  ;
  ; Receives:
  ;		prompt			= (reference, input),	string to prompt user for input
  ;		count			= (value, input),		max allowed length of input string 
  ;
  ; returns: 
  ;		stored_input	= (reference, output),	array to store the string of ASCII input by user
  ;		bytes_read		= (reference, output),	records the number of bytes long the string is the user entered
  ; ---------------------------------------------------------------------------------
mGetString MACRO prompt, stored_input, count, read:REQ
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	; display prompt
	mDisplayString prompt

	; read input
	MOV		EDX, stored_input
	MOV		ECX, count
	ADD		ECX, 2				; allows string to be larger for comparisons
	CALL	ReadString

	; store input
	MOV		stored_input, EDX
	MOV		[read], EAX
	
	POP		EAX
	POP		ECX
	POP		EDX
ENDM


  ; ---------------------------------------------------------------------------------
  ; Name: mDisplayString
  ;
  ; Prints a string that is stored in a memory location. Uses Irvine Library's WriteString.
  ;
  ; Preconditions: None
  ;
  ; Receives:
  ;	string_loc	= (reference, input),	memory location of string to be printed
  ;
  ; returns: None
  ; ---------------------------------------------------------------------------------
mDisplayString MACRO string_loc:REQ
	PUSH	EDX
	MOV		EDX, string_loc
	CALL	WriteString
	POP		EDX
ENDM


; constant value definitions
	NUM_LENGTH	= 10			; length of 2^31 decimal, max size of signed int for 32-bit register
	VALID_INTS	= 10			; number of ints requested from the user

.data

;	strings and prompts used in this program
	prog_title			BYTE	"		==== String Primitives and Macros	----	 by Brad Sommer ====			",13,10,0
	intro1				BYTE	"Please enter 10ea. signed integers. Each int must fit within a 32-bit register",13,10,\
								"After all ints are entered, I will show a list of the ints as well as their sum and average.",13,10,13,10,0
	prompt_disp			BYTE	"Please enter a signed integer: ",0
	input_error_disp	BYTE	"Your input is not a signed number or it is too large.",13,10,0
	reprompt_disp		BYTE	"Try again: ",0
	numbers_entered		BYTE	13,10,"The following valid integers were entered: ",13,10,0
	sum_disp			BYTE	13,10,"The sum of your numbers is: ",0
	avg_disp			BYTE	13,10,"The truncated average of your numbers is: ",0
	padding				BYTE	", ",0
	cr_lf				BYTE	13,10,0

;	arrays and variables used in this program
	user_input			BYTE	NUM_LENGTH	DUP(?)		; holds the string of numbers input by the user
	bytes_read			DWORD	?
	converted_array		SDWORD	VALID_INTS	DUP(0)		; an array of ints converted from ascii
	ascii_array			BYTE	NUM_LENGTH	DUP(?)		; holds the conversion of an value from int to ascii
	sum					SDWORD	?
	average				SDWORD	?


.code
main PROC
	; introduce the program
	PUSH	OFFSET	prog_title	; reference, input
	PUSH	OFFSET	intro1		; reference, input
	CALL	introduction

	; -----------------------------------------------------------------------------
	;	Test program: 
	;		1. Loops ReadVal LENGTHOF converted_array (10) times. This will ask the user to enter 10 valid ints.
	;		2. Converts and stores each valid entry in array: converted_array 
	;		3. Displays these ints to the user as well as their sum and truncated average
	;
	; -----------------------------------------------------------------------------
	; -- loop ReadVal -- : Store the user's converted int values in converted_array
	MOV		ECX, LENGTHOF converted_array
	MOV		EBX, OFFSET converted_array
_readValLoop:

	; preserve registers prior to calling ReadVal
	PUSH	ECX
	PUSH	EBX

	; parameters for ReadVal
	PUSH	EBX					; address of converted_array
	PUSH	OFFSET	reprompt_disp
	PUSH	OFFSET	input_error_disp
	PUSH	OFFSET	bytes_read
	PUSH	OFFSET	prompt_disp
	PUSH	OFFSET	user_input
	PUSH	NUM_LENGTH
	CALL	ReadVal

	; restore registers and loop again
	POP		EBX
	POP		ECX
	DEC		ECX
	ADD		EBX, TYPE converted_array
	CMP		ECX, 0
	JNE		_readValLoop


	; -- loop WriteVal -- :  convert each number from dec to ASCII and display the user-entered numbers
	mDisplayString	OFFSET numbers_entered
	MOV		ECX, LENGTHOF converted_array
	MOV		EAX, OFFSET converted_array
_writeValLoop:

	; preserve registers prior to calling WriteVal
	MOV		EBX, [EAX]
	PUSH	EAX
	PUSH	ECX

	; parameters for WriteVal
	PUSH	OFFSET ascii_array
	PUSH	EBX				; decimal value to convert
	CALL	WriteVal

	; restore registers and loop again
	POP		ECX
	POP		EAX
	DEC		ECX
	CMP		ECX, 0			; last num, don't print padding
	JE		_lastNum
	mDisplayString OFFSET padding	; comma and space separation between numbers

	; the last printed number does not get padding after it
_lastNum:
	ADD		EAX, TYPE converted_array
	CMP		ECX, 0
	JNE		_writeValLoop

	
	; -- Find sum and avg -- : Call a separate procedure (ArrayStats) to compute the sum and average of the valid user-entered numbers
	PUSH	OFFSET	sum
	PUSH	OFFSET	average
	MOV		EAX, TYPE converted_array
	PUSH	EAX
	MOV		EAX, LENGTHOF converted_array 
	PUSH	EAX
	PUSH	OFFSET converted_array
	CALL	ArrayStats


	; use WriteVal to convert the decimal sum to ASCII and display it
	mDisplayString OFFSET sum_disp
	PUSH	OFFSET ascii_array
	PUSH	sum				; decimal value to convert
	CALL	WriteVal


	; use WriteVal to convert the decimal average to ASCII and display it
	mDisplayString OFFSET avg_disp
	PUSH	OFFSET ascii_array
	PUSH	average				; decimal value to convert
	CALL	WriteVal
	mDisplayString OFFSET cr_lf


	Invoke ExitProcess,0	; exit to operating system
main ENDP

  ; ---------------------------------------------------------------------------------
  ; Name: ReadVal
  ;
  ; 1. Invokes the mGetString macro to get user input in the form of a string of digits. 
  ; 2. Converts (using string primitives) the string from ASCII digits to its numeric value
  ; representation (SDWORD) validating the user's input is a valid number. 
  ; Uses string primitive LODSB for conversion.
  ; 3. Stores this value in a memory variable.
  ;
  ; Preconditions: None
  ;
  ; Postconditions: Changes registers 
  ;
  ; Receives:	
  ;		converted_input	= +32	(reference, input), converted numerical representation from ASCII to dec
  ;		reprompt_disp	= +28	(reference, input), string to re-prompt user for input
  ;		input_error_disp= +24	(reference, input), string to notify user of invalid input
  ;		bytes_read		= +20	(reference, input), used to keep track of bytes read by mGetString
  ;		prompt_disp		= +16	(reference, input), passed to mGetString
  ;		user_input		= +12	(reference, input), passed to mGetString
  ;		NUM_LENGTH		= +8	(value,		input), passed to mGetString 
  ;
  ;	Local variables: 
  ;		convertedDigit	= holds the current digit that has been converted from ASCII to dec
  ;		decimalPlaces	= the number of decimal places over that the current digit is
  ;		isNegative		= custom flag to retain if the string being converted represents a negative number or not
  ;
  ; returns: 
  ;		numeric_rep	=	(reference, output), numeric value representation of ASCII string
  ; ---------------------------------------------------------------------------------
ReadVal PROC
	LOCAL	convertedDigit:SDWORD, decimalPlaces:DWORD, isNegative:BYTE ; 0 for +, 1 for -
_start:
	mGetString [EBP+16], [EBP+12], [EBP+8], [EBP+20] ; prompt_disp, user_input, NUM_LENGTH, bytes_read

	; check if no number was entered
	MOV		EAX, [EBP+20]	; bytes_read
	CMP		EAX, 0
	JE		_incorrectInput

	; loop to convert ascii string to decimal
	MOV		ESI, [EBP+12]
	MOV		ECX, [EBP+20]
	MOV		EAX, 0		; clear EAX prior to LODSB
_convertLoop:
	LODSB	; puts byte into AL

		MOV		EBX, [EBP+20]
		CMP		ECX, EBX		; check if 1st character in string
		JNE		_notFirst
		
		; checking for characters '+' or '-' in the first byte
		CMP		AL, 43	; ASCII for +
		MOV		isNegative, 0
		JE		_sign
		CMP		AL, 45	; ASCII for -
		MOV		isNegative, 1
		JE		_sign
		MOV		isNegative, 0
		
		; checks if too many bytes were entered, preserves character in AL
		PUSH	EAX
		MOV		EAX, [EBP+20]	; bytes_read
		MOV		EBX, [EBP+8]
		CMP		EAX, EBX		; too many bytes
		POP		EAX
		JG		_incorrectInput
		JMP		_notFirst

_sign:
		; takes into account the '+' or '-' character and checks for bytes read
		MOV		EAX, [EBP+20]	; bytes_read
		MOV		EBX, [EBP+8]
		INC		EBX				; to account for "+" or "-" char
		CMP		EAX, EBX		; too many bytes
		JG		_incorrectInput	

		JMP		_goLoop

		; not the first character in the string, check if character can be converted to decimal
_notFirst:
		CMP		AL, 57	; ASCII for 9
		JG		_incorrectInput
		CMP		AL, 48	; ASCII for 0
		JL		_incorrectInput

		; at this point we only know we have a valid character. proceed with conversion
		
		; nested loop: convert each ascii to dec, compare to ECX, loop until they are equal
		PUSH	ECX
		MOV		ECX, 10
		; if ECX = AL-48 then val is ECX
		SUB		AL, 47	; actual difference is 48, 47 is used because 0 doesn't iterate in LOOP
		MOVZX	EBX, AL
		MOV		EAX, EBX
_convASCIILoop:
			CMP		EAX, ECX
			JNE		_nextASCII
			DEC		EAX		; this is the number we want
			MOV		convertedDigit, EAX
			JMP		_foundASCII
_nextASCII:
			LOOP	_convASCIILoop
_foundASCII:
		POP		ECX
		
		; take EAX, multiply it by 10^(ECX-1) and ADD/SUB result to [EBP+32]
		MOV		decimalPlaces, ECX
		DEC		decimalPlaces
		CMP		decimalPlaces, 0	; no need to multiply by 10^(ECX-1), jump to ADD/SUB
		JE		_finalDigit
		
		; nested loop: use ECX to determine how many times to move the decimal point over. find 1*10^(ECX-1) and multiply by convertedDigit
		PUSH	ECX
		MOV		ECX, decimalPlaces
		MOV		EBX, 10
		MOV		EAX, 1
_powerOf10:
			MUL		EBX
			LOOP	_powerOf10
		POP		ECX
		MUL		convertedDigit
_finalDigit:

		; adds each converted digit to converted_input
		MOV		EBX, [EBP+32]
		CMP		isNegative, 1
		JE		_negative
		ADD		[EBX], EAX

		; checking if signed number is too large for 32-bit register
		JO		_incorrectInput
		JMP		_goLoop
_negative:
		SUB		[EBX], EAX
		JO		_incorrectInput

	; Loop again, LODSB at top of loop will move to next char in string
_goLoop:
	DEC		ECX
	CMP		ECX, 0
	JNE		_convertLoop
	JMP		_end

	; incorrect input was received, essentially starts procedure over and asks for another number
_incorrectInput:
	MOV		EDX, [EBP+24]	; display error
	mDisplayString	[EBP+24]
	MOV		EAX, [EBP+28]
	MOV		[EBP+16], EAX	; move reprompt so it will be printed by mGetString
	
	; clear memory where converted_input was being stored
	MOV		EBX, [EBP+32]
	MOV		EAX, 0
	MOV		[EBX], EAX
	JMP		_start

_end:
	RET		28
ReadVal ENDP


  ; ---------------------------------------------------------------------------------
  ; Name: WriteVal
  ;
  ; 1. Converts a numeric SDWORD value to a string of ASCII digits. Uses STOSB during conversion.
  ;	2. Invokes the mDisplayString macro to print the ASCII representation of the SDWORD value
  ;
  ; Preconditions: None
  ;
  ; Postconditions: Changes registers 
  ;
  ; Receives:
  ;		ascii_array = +12 (reference, input), holds the ascii representation
  ;		numeric_rep	= +8 (value, input), integer to be converted to ASCII
  ;
  ; Local variables:
  ;		ten			= holds the decimal value 10. Used to multiply converted decimals by powers of 10. Frees up register use.
  ;		tempVal		= holds the quotient after performing signed int division so EAX can be used by STOSB
  ;		isOverflow	= custom flag used if number is -2^31. Negative numbers are negated before converted so this will cause overflow
  ;
  ; returns:	None
  ; ---------------------------------------------------------------------------------
WriteVal PROC
	LOCAL	ten:SDWORD, tempVal:SDWORD, isOverflow:DWORD
	MOV		EAX, [EBP+8]	; numeric_rep
	MOV		EDI, [EBP+12]	; ascii array
	MOV		ten, 10
	MOV		ECX, 0
	MOV		isOverflow, 0

	; count decimal digits for use as an offset
_countChars:
	CDQ
	IDIV	ten
	INC		ECX		; number of digits in number, e.g. chars in string
	CMP		EAX, 0
	JNE		_countChars

	; set up indices to build string in reverse
	MOV		EAX, [EBP+8]		; numeric_rep
	ADD		EDI, ECX			; offset EDI by number of chars
	MOV		DWORD PTR [EDI], 0	; null terminate string
	DEC		EDI
	STD							; set direction flag to build string in reverse

	; check if number is negative
	CMP		EAX, 0
	JGE		_storeString
	NEG		EAX					; 2's compliment negation
	JNO		_noOverflow			; will only overflow here if number = -2^31
	MOV		EAX, [EBP+8]
	INC		EAX					; increment negative number so when negated it will fit in 32-bit reg (e.g. 2^31-1)
	NEG		EAX
	MOV		isOverflow, 1
_noOverflow:
	INC		EDI					; make room for '-' char, shift destination pointer one byte
	MOV		EBX, [EBP+12]		; start of ascii_array
	MOV		DWORD PTR [EBX], 45	; ascii for '-' char

	; divide number by 10 and convert remainder to ascii
	MOV		ECX, 0
_storeString:
	CDQ
	IDIV	ten
	MOV		tempVal, EAX
	MOV		EAX, EDX
	ADD		EAX, 48	; conversion from dec to ascii
	CMP		ECX, 0
	JNE		_noOVadjust
	CMP		isOverflow, 1
	JNE		_noOVadjust
	INC		EAX				; increment digit that was modified earlier to fit in register
_noOVadjust:
	INC		ECX
	STOSB
	MOV		EAX, tempVal
	CMP		EAX, 0			; if quotient is 0
	JNE		_storeString

	; display the final int->ascii string
	mDisplayString [EBP+12]

	RET		8
WriteVal ENDP


  ; ---------------------------------------------------------------------------------
  ; Name: introduction
  ;
  ; Displays the program title and introduces the user to the program. Calls mDisplayString to display strings. 
  ;
  ; Preconditions: None
  ;
  ; Postconditions: Restores register EBP
  ;
  ; Receives:
  ;		prog_title	= +12	(reference, input), program title
  ;		intro1		= +8	(reference, input), program introduction
  ;
  ; returns: none
  ; ---------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	mDisplayString [EBP+12] ; prog_title
	mDisplayString [EBP+8]  ; intro1
	POP		EBP
	RET		8
introduction ENDP


  ; ---------------------------------------------------------------------------------
  ; Name: ArrayStats
  ;
  ; Computes the sum and truncated average of an array of signed ints
  ;
  ; Preconditions: None
  ;
  ; Postconditions: Changes registers EAX, ECX, EBX. Restores register EBP
  ;
  ; Receives:
  ;		TYPE some_array		= +16	(value, input),		used to increase the address of some_array to access the mem address of the next element
  ;		LENGTHOF some_array	= +12	(value, input),		used to set loop counter ECX when computing the sum. Also used to compute average
  ;		some_array			= +8	(reference, input),	array of ints to sum and average
  ;
  ; returns:
  ;		sum					= +24	(reference, output),	sum of the elements in some_array
  ;		average				= +20	(reference, output),	truncated average of the elements in some_array
  ; ---------------------------------------------------------------------------------
ArrayStats PROC
	PUSH	EBP
	MOV		EBP, ESP

	; loop over each array element and add it to EAX. Store result at memory address [EBP+24]
	MOV		EBX, [EBP+8]	; some_array
	MOV		ECX, [EBP+12]	; LENGTHOF some_array
	MOV		EAX, 0			; clear EAX before finding sum
_findSum:
	ADD		EAX, [EBX]
	ADD		EBX, [EBP+16]	; TYPE some_array
	LOOP	_findSum
	MOV		EBX, [EBP+24]	; sum
	MOV		[EBX], EAX

	; using the found sum, compute the average. Store result at memory address [EBP+20]
	CDQ
	IDIV	SDWORD PTR [EBP+12]	; LENGTHOF some_array
	MOV		EBX, [EBP+20]		; average
	MOV		[EBX], EAX

	POP		EBP
	RET		20
ArrayStats ENDP

END main
