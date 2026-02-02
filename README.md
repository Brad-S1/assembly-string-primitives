# String Primitives & Low-Level I/O

**MASM x86 Assembly implementation of numeric I/O without standard library functions**

A systems programming project demonstrating manual string-to-integer and integer-to-string conversion using x86 string primitive instructions, proper calling conventions, and comprehensive input validation—all without relying on standard library conversion functions.

## Overview

This program implements custom numeric input/output procedures in x86 assembly language, replacing standard library functions (`ReadInt`, `ReadDec`, `WriteInt`, `WriteDec`) with manual implementations using string primitives. The program collects 10 signed integers from the user, validates each input at the byte level, and displays the numbers along with their sum and truncated average.

**Why This Matters:** This project demonstrates understanding of data representation, CPU flags, calling conventions, and bit-level manipulation—fundamental skills for embedded systems, OS development, and hardware-software interfaces.

## Key Technical Features

### 1. String Primitive-Based Conversion
- **`LODSB`** for byte-by-byte ASCII-to-integer conversion
- **`STOSB`** for integer-to-ASCII conversion with reverse string building
- Direction flag management (`STD`) for bidirectional string operations

### 2. Comprehensive Input Validation
- Character-level validation: only digits and leading `+`/`-` signs accepted
- 32-bit signed integer bounds checking (`-2,147,483,648` to `2,147,483,647`)
- CPU flag-based overflow detection using `JO` instruction
- Empty input detection and graceful error recovery

### 3. Edge Case Handling
- **INT32_MIN (-2³¹) Overflow Solution**: The notorious case where negating -2,147,483,648 causes overflow. Implemented via systematic 2's complement manipulation:
  ```asm
  NEG     EAX                ; Attempt negation
  JNO     _noOverflow        ; Check overflow flag
  ; Handle overflow: increment, negate, adjust final digit
  MOV     EAX, [EBP+8]
  INC     EAX                ; Now fits in register as 2^31-1
  NEG     EAX
  MOV     isOverflow, 1
  ```

### 4. STDCall Calling Convention Compliance
- Stack-based parameter passing
- Callee-side stack cleanup (`RET 28`)
- Proper register preservation (PUSH/POP)
- Local variable allocation using `LOCAL` directive

### 5. Macro-Based I/O Abstraction
- `mGetString`: User input abstraction using Irvine's `ReadString`
- `mDisplayString`: Output abstraction using `WriteString`
- Register state preservation within macros

## Technical Implementation Details

### ReadVal Procedure
Converts ASCII string input to signed 32-bit integer (SDWORD):

1. **Input Acquisition**: Invokes `mGetString` macro to capture user input
2. **Character Validation**: 
   - First position: accepts `+`, `-`, or digit
   - Remaining positions: digits only (ASCII 48-57)
3. **Conversion Algorithm**:
   - Iterates through string using `LODSB`
   - Converts each digit: `digit_value = ASCII_char - 48`
   - Accumulates: `result = result + digit × 10^position`
4. **Overflow Detection**: Uses `JO` to check arithmetic overflow flag after each addition/subtraction
5. **Sign Handling**: Tracks sign with custom flag, applies via subtraction for negative numbers

### WriteVal Procedure  
Converts signed 32-bit integer to ASCII string:

1. **Sign Detection**: Checks if number is negative, prepends `-` if needed
2. **Special Case**: Handles -2³¹ overflow via increment-negate-adjust technique
3. **Digit Extraction**:
   - Repeatedly divides by 10 using `IDIV`
   - Converts remainder to ASCII: `ASCII_char = remainder + 48`
4. **Reverse Building**: Uses `STOSB` with direction flag set to build string backwards
5. **Null Termination**: Properly terminates string for display

## Building and Running

### Prerequisites
- Microsoft Macro Assembler (MASM)
- Irvine32 library
- Visual Studio with MASM integration (or MASM command-line tools)
- Windows environment (32-bit assembly)

### Build Instructions

**Using Visual Studio:**
1. Create new project (Empty Project)
2. Add `Proj6_sommerbr.asm` to project
3. Configure for MASM (Build Dependencies > Build Customizations > masm)
4. Link against Irvine32.lib and kernel32.lib
5. Build and run (F5)

## Skills Demonstrated

| Category | Skills |
|----------|--------|
| **Assembly Language** | MASM x86, string primitives (LODSB/STOSB), conditional jumps, arithmetic operations |
| **Low-Level Concepts** | Stack frames, calling conventions (STDCall), register management, CPU flags |
| **Data Representation** | ASCII encoding, two's complement arithmetic, integer overflow handling |
| **Systems Programming** | Manual I/O implementation, input validation, error handling without exceptions |
| **Software Engineering** | Modular design with procedures, macro abstraction, comprehensive documentation |

## Implementation Constraints

This project intentionally avoids high-level conveniences to demonstrate low-level proficiency:

- ❌ No `ReadInt`, `ReadDec`, `WriteInt`, or `WriteDec` (Irvine library functions)
- ❌ No standard library conversion functions (e.g., `atoi`, `itoa`)
- ✅ Manual byte-by-byte processing with string primitives
- ✅ Arithmetic operations only (no conversion shortcuts)
- ✅ CPU flag-based validation

## Design Decisions

### Why String Primitives?
String primitives (`LODSB`, `STOSB`) provide efficient byte-level access with automatic pointer advancement, making them ideal for character-by-character string processing. They're commonly used in low-level string operations in OS kernels and embedded systems.

### Why Manual Conversion?
Understanding numeric conversion at the bit level is fundamental to systems programming. This implementation reveals how high-level operations (like `printf("%d", num)`) work under the hood—knowledge essential for debugging, optimization, and working with custom protocols or file formats.

### Why STDCall Convention?
STDCall is widely used in Windows API programming and demonstrates understanding of ABI (Application Binary Interface) requirements—critical knowledge for interoperability between different programming languages and system components.

## Learning Outcomes

This project reinforced:
- How numeric data is represented and manipulated at the machine level
- The role of CPU condition flags in validation and control flow
- Proper stack frame management and calling convention adherence
- Handling arithmetic overflow in constrained environments
- The relationship between assembly and higher-level language constructs

## Academic Context

**Course:** CS271 - Computer Architecture and Assembly Language  
**Institution:** Oregon State University  
**Project:** Portfolio Project (Project 6)  
**Date:** December 2023

This was the culminating project for the course, requiring integration of all semester concepts: procedures, macros, stack operations, string processing, and arithmetic operations.

## Author

**Brad Sommer**  
Mechanical Engineer | Computer Science Graduate  
Specialized in systems programming, embedded systems, and low-level software

- GitHub: [@Brad-S1](https://github.com/Brad-S1)
- LinkedIn: [Brad Sommer](https://www.linkedin.com/in/sommer-brad/)

## License

Academic project - provided for educational and portfolio purposes.

---

*This project demonstrates proficiency in assembly language programming, low-level system concepts, and manual data representation—skills applicable to embedded systems development, operating systems programming, and hardware-software interface design.*
