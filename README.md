# x86-masm-temperature-sorter
An x86 assembly - MASM tool that reads in temperature measurements from a file, and prints them out with their order corrected

# Program Description
* Implement and test three macros for I/O. These macros should use Irvine’s ReadString to get input from the user, and WriteString and WriteChar procedures to display output.
    * mGetString:  Display a prompt (input, reference), then get the user’s keyboard input into a memory location (output, reference). You may also need to provide a count (input, value) for the length of input string you can accommodate and provide a number of bytes read (output, value) by the macro.
    * mDisplayString:  Print the string which is stored in a specified memory location (input, reference).
    * mDisplayChar:  Print an ASCII-formatted character which is provided as an immediate or constant (input; immediate, constant, or register).
* Implement and test the following two procedures which use string primitive instructions
    * ParseTempsFromString: {parameters: fileBuffer (reference, input), tempArray (reference, output)}
        * 1. fileBuffer will contain a number (TEMPS_PER_DAY (CONSTANT)) of string-formatted integer values, separated by a delimiter. The DELIMITER must be defined as a character CONSTANT so that we can change it during testing.
TEMPS_PER_DAY should be initially set to 24
DELIMITER should be initially set to the comma character ,
        * 2. Convert (using string primitives) the string of ascii-formatted numbers to their numeric value representations. Some values will be negative and others will be positive.
        * 3. Store the converted temperatures in an SDWORD array (output parameter, by reference).
    * WriteTempsReverse: {parameters: tempArray (reference, input)} 
       * 1. Print an SDWORD integer array to the screen, separated by a CONSTANT-defined DELIMITER character.
       * 2. The integers must be printed in the reverse order that they are stored in the array. 
       * 3. Invoke the mDisplayChar macro to print the DELIMITER character.
* Write a test program (in main) which uses the ParseTempsFromString and WriteTempsReverse procedures above to:
    * 1. Invoke the mGetString macro (see parameter requirements above) to get a file name from the user.
    * 2. Open this file and read the contents into a file buffer (BYTE array). File formatting follows...
        * The file will contain a series of positive or negative ASCII-format integers, separated by a DELIMITER.
        * Each line of numbers will have TEMPS_PER_DAY values.
        * The last number of each line also has a DELIMITER after it.
  * 3. Use ParseTempsFromString to parse the first line of temperature readings, convert them from ASCII to numeric value, and store the numeric values in an array. 
  * 4. Use WriteTempsReverse to print the temperature values in the reverse order that they were stored in the file (print to the terminal window). Crazy interns!
# Program Requirements
1. WriteInt may be used to print the SDWORD array.
2. mDisplayString must be used to display all strings.
3. Conversion routines must appropriately use the LODSB and/or STOSB operators for dealing with strings.
4. You may not use ParseInteger32 or other similar pre-written procedures to parse the temperatures.
5. All procedure parameters must be passed on the runtime stack using the STDCall calling convention (see Module 7, Exploration 1 - Passing Parameters on the Stack). Strings also must be passed by reference.
6. Prompts, identifying strings, and other memory locations must be passed by address to the macros.
7. Used registers must be saved and restored by the called procedures and macros.
8. The stack frame must be cleaned up by the called procedure.
9. Procedures (except main) must not reference data segment variables by name. There is a significant penalty attached to violations of this rule.  Some global constants (properly defined using EQU, =, or TEXTEQU and not redefined) are allowed. These must fit the proper role of a constant in a program (nominally static values used throughout a program which may dictate its execution method, similar to MIN_TEMP and MAX_TEMP in Project 5).
10. The program must use Register Indirect addressing or string primitives (e.g. STOSD) for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.
11. Procedures may use local variables when appropriate.
12. The program must be fully documented and laid out according to the CS271 Style Guide. This includes a complete header block for identification, description, etc., a comment outline to explain each section of code, and proper procedure headers/documentation.

# Example Execution
```
Welcome to the intern error-corrector! I'll read a ','-delimited file storing a series of temperature values.
The file must be ASCII-formatted. I'll then reverse the ordering and provide the corrected temperature
ordering as a printout!
Enter the name of the file to be read: Temps090124.txt

Here's the corrected temperature order!
-1,+2,+5,+10,+15,+20,+25,+30,+34,+38,+42,+45,+40,+35,+30,+25,+20,+15,+10,+7,+3,+0,-2,-3,

Hope that helps resolve the issue, goodbye!
Press any key to continue . . .
```
