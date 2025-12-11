; ------------------------------------------------------------------------------
; Author: Tess Ellis
; Last Modified: 03/01/25
; OSU email address: elliste@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6       Due Date: 03/16/25
; Description: A program that reads a file of temperature values and prints them out with
;			   their order corrected. The program is divided into three macros, mGetString,
;			   mDisplayString, and mDisplayChar; and three procedures (apart from main),
;			   ParseTempsFromString, WriteTempsReverse, and ParseInteger.
; ------------------------------------------------------------------------------

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------------
; Defining as constants
; ------------------------------------------------------------------------------
TEMPS_PER_DAY = 24
DELIMITER = ','
BUFFER_SIZE = 256
; ------------------------------------------------------------------------------
; Declaring Data
; ------------------------------------------------------------------------------
.data
TestOutput DWORD 4 DUP(0)
Greeting BYTE "Welcome to the intern error-corrector! I'll read a ','-delimited file storing a series of temperature values.!", 13,10,0
FilePrompt BYTE "Enter the name of the file to be read: ", 13,10,0
TempResults BYTE "Here's the corrected temperature order!", 13,10,0
Goodbye BYTE "Hope that helps resolve the issue, goodbye!", 13,10,0
FileName BYTE 256 DUP(0)
FileHandle DWORD ?
FileBuffer BYTE BUFFER_SIZE DUP(0)

.code

; ------------------------------------------------------------------------------
; Name: mGetString
; Copy our string to be used in procedures
; Preconditions: pompt, output should be offset to a string
; Postconditions:  prompt is written to screen, string is read into the output variable
; Receives Returns: none
; ------------------------------------------------------------------------------
mGetString MACRO prompt, output, count
	mDisplayString prompt
	MOV EDX, OFFSET output
	MOV ECX, count
	CALL ReadString
ENDM

; ------------------------------------------------------------------------------
; Name: mDisplayString
; Prints the given prompt to the screen
; Preconditions: pompt is an offset of string
; Postconditions: string is displayed
; Receives Returns: none
; ------------------------------------------------------------------------------
mDisplayString MACRO prompt
	MOV EDX, OFFSET prompt
	CALL WriteString 
ENDM

; ------------------------------------------------------------------------------
; Name: mDisplayChar
; Prints a character to the screen
; Preconditions: none
; Postconditions: a char is displayed to the screen
; Receives Returns: none
; ------------------------------------------------------------------------------
mDisplayChar MACRO char
	MOV AL, char
	CALL WriteChar 
ENDM

; ------------------------------------------------------------------------------
; Name: PraseTempsString
; Converts ASCCI-formattes characters to their numerical value and stores the converted
; characters in a SDWORD array.
; Preconditions: string of temps, array to hold temps (both on stack)
; Postconditions: string is parsed, values are held in the array
; Receives Returns: none
; ------------------------------------------------------------------------------
ParseTempsFromString PROC
	POP ESI								; storing return address

	POP EBX								; output reference (tempArray)
	POP EDI								; input reference (string)
; moving to the next integer
next_int:
	MOV EDX, EDI						; moving current address of edi into edx
	MOV ECX, 0	
; moving to the next char
next_char:
	MOV AL, [EDI]
	CMP AL, DELIMITER					; comparing current char with delimeter
	JE parse_int						; if we reach delimeter, move to parsing int
	INC ECX								; add 1 num to count
	INC EDI								; move to next char
	JMP next_char						
; parsing integer while storing on the stack (PUSH) and restoring the stack (POP)
parse_int:
	PUSH EBX
	PUSH ECX
	PUSH EDX
	PUSH EDI
	PUSH ESI

	PUSH EDX
	PUSH ECX
	CALL ParseInteger

	POP ESI
	POP EDI
	POP EDX
	POP ECX
	POP EBX 

	MOV [EBX], EAX						; putting result into next spot in ebx
	ADD EBX, 4							; moving ebx to new spot
	INC EDI								; moving past delimeter
	MOV AL, [EDI]
	CMP AL, 0						
	JNE next_int						; jump if not equal

	PUSH ESI							; restoring return address
	RET
ParseTempsFromString ENDP

; ------------------------------------------------------------------------------
; Name: WriteTempsReverse
; Reverses the temperatures and writes them to the screen
; Preconditions: input array
; Postconditions: temps are reversed and printed to the screen
; Receives Returns: none
; ------------------------------------------------------------------------------
WriteTempsReverse PROC
	POP ESI

	POP EDI								; holding our input array
	MOV ECX, TEMPS_PER_DAY				; holding 24 (TEMP_PER_DAY)
	ADD EDI, 4 * (TEMPS_PER_DAY - 1)			; moving forward through temps
; printing temps
print_loop:
	MOV EAX, [EDI]						; moving the value at EDI into EAX
	CALL WriteInt
	mDisplayChar DELIMITER				; using the mDisplayChar MACRO with Delimiter
	DEC ECX								; counting down temps
	SUB EDI, 4							; moving EDI back to the beginning by one integer
	CMP ECX, 0							; moving to the end of the list
	JG print_loop						

	PUSH ESI
	RET
WriteTempsReverse ENDP

; ------------------------------------------------------------------------------
; Name: ParseInteger
; Parses integers without the use of ParseInteger32 as per the instructions
; Preconditions: string and num of chars in integer
; Postconditions: parsed integer is returned
; Receives Returns: eax
; ------------------------------------------------------------------------------
ParseInteger PROC
	POP ESI

	POP ECX								; holding count
	POP EDX								; holding string
	MOV EAX, 0							; default return zero
	PUSH ESI							; restores the return value
	MOV ESI, 10				
	CMP ECX, 0							; if empty
	JE integer_exit

	MOV EDI, 1							; assuming positive
	MOV BL, [EDX]						; move first char into EBX
	CMP BL, '-'							; checking if negative (BL holds the lower 8 bits of EBX)
	JNE positive_integer
	MOV EDI, -1							; making EDI negative 
	INC EDX
	DEC ECX
	JMP integer_number
; if positive
positive_integer:
	CMP BL, '+'
	JNE integer_number
	INC EDX
	DEC ECX
; parsing
integer_number:
	MOV BL, [EDX]
	SUB BL, 48							; value that represent zero in ASCII
	PUSH EDX
	MUL ESI								; EAX * 10
	POP EDX
	ADD AL, BL 
	INC EDX
	DEC ECX
	CMP ECX, 0
	JG integer_number
	MUL EDI 

integer_exit:
	
	RET
ParseInteger ENDP

; ------------------------------------------------------------------------------
; Name: main
; Calls macros for printing strings to the screen and getting strings
; Preconditions: none
; Postconditions: Greeting, file prompt, and goodbye messages are displayed to the screen
; Receives Returns: none
; ------------------------------------------------------------------------------
main PROC
	; Greeting and FilePrompt
	mDisplayString OFFSET Greeting
	mGetString OFFSET FilePrompt, OFFSET FileName, 256
	MOV EDX, OFFSET FileName
	CALL OpenInputFile
	MOV FileHandle, EAX

	; Reading File
	MOV EDX, OFFSET FileBuffer
	MOV ECX, BUFFER_SIZE
	CALL ReadFromFile

	; Parsing Temps from File
	PUSH OFFSET FileBuffer
	PUSH OFFSET TestOutput
	CALL ParseTempsFromString
	CALL CrLf 
	
	; Displaying TempResults Reversed (corrected order)
	mDisplayString OFFSET TempResults
	PUSH OFFSET TestOutput
	CALL WriteTempsReverse
	CALL CrLf 
	CALL CrLf 

	; Closing file
	MOV EAX, FileHandle
	CALL CloseFile

	; Goodbye Message
	mDisplayString OFFSET Goodbye
main ENDP


END main

