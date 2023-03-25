BITS 32

SECTION .data
    ; System calls
    SYS_WRITE EQU 4
    SYS_READ EQU 3
    SYS_EXIT EQU 1

    ; STD
    STD_OUT EQU 1
    STD_IN EQU 0

    ; prompt
    prompt DB "Please enter a string (If you wish to stop, enter the empty string): ", 0xa
    lenPrompt EQU $ - prompt

    ; Is a palindrome message
    success DB "** The string IS a palindrome! **", 0xa
    lenSuccess EQU $ - success

    ; Is not a palindrome message
    failure DB "** The string IS NOT a palindrome! **", 0xa
    lenFailure EQU $ - failure

    ; Goodbye
    goodbye DB "Goodbye!", 0xa
    lenGoodbye EQU $ - goodbye

    ; New line
    newLine DB '', 0xa
    lenNewLine EQU $ - newLine

SECTION .bss
    inputString RESB 1024
    reverseString RESB 1024
    inputLength RESB 1

GLOBAL _start:

SECTION .text

_start:
    _mainLoop:
        ; Prompts user and takes in string
        call InitialPrompt

        ; If the string entered was empty, exit
        ; eax holds the length of STDIN input + 1 for the zero terminator
        cmp eax, BYTE 1
        je _exit

        ; Store length of the input string into inputLength
        mov [inputLength], BYTE eax

        ; String locations
        mov esi, inputString
        mov edi, reverseString

        ; ecx is used to decrement the loop, and grab the end of the input string
        ; ebx will be the position for the beginning of reverse string
        ; dec ecx to account for the zero terminator char in inputstring
        mov ecx, eax
        dec ecx
        xor ebx, ebx

        ; Loops through the input string and stores the reverse of it in reverseString
        _reverseLoop:
            dec ecx
            mov ah, BYTE [esi + ecx]
            mov BYTE [edi + ebx], ah
            inc ebx
            inc ecx
        loop _reverseLoop
        
        ; Check if the input string is a palindrome
        call is_palindrome
        
        ; After the check for palindrome, if ecx == ebx then it is a palindrome.
        cmp ecx, ebx
        je _yes
        jne _no

        ; If ecx == ebx or if all characters match
        _yes:
            call printSuccess
            jmp _mainLoop

        ; If ecx != ebx or if not all characters match
        _no:
            call printFailure
            jmp _mainLoop

    _exit:
        ; Print goodbye
        mov eax, SYS_WRITE
        mov ebx, STD_OUT
        mov ecx, goodbye
        mov edx, lenGoodbye
        int 80h

        ; Exit
        mov eax, SYS_EXIT
        mov ebx, 0
        int 80h

; **** FUNCTIONS ****

InitialPrompt:
    ; Print prompt to user
    mov eax, SYS_WRITE
    mov ebx, STD_OUT
    mov ecx, prompt
    mov edx, lenPrompt
    int 80h

    ; Read in string from the user
    mov eax, SYS_READ
    mov ebx, STD_IN
    mov ecx, inputString
    mov edx, 1024
    int 80h

    ret

printSuccess:
    ; Print success message
    mov eax, SYS_WRITE
    mov ebx, STD_OUT
    mov ecx, success
    mov edx, lenSuccess
    int 80h

    ; Print new line
    mov eax, SYS_WRITE
    mov ebx, STD_OUT
    mov ecx, newLine
    mov edx, lenNewLine
    int 80h

    ret 

printFailure:
    ; Print failure message
    mov eax, SYS_WRITE
    mov ebx, STD_OUT
    mov ecx, failure
    mov edx, lenFailure
    int 80h

    ; Print new line
    mov eax, SYS_WRITE
    mov ebx, STD_OUT
    mov ecx, newLine
    mov edx, lenNewLine
    int 80h

    ret

is_palindrome:
    ; Assumes input string is stored in esi and reverseString is stored in edi
    ; Grab the length, put it in ebx, and zero out ecx
    mov ebx, [inputLength]
    dec ebx
    xor ecx, ecx

    ; Loop through the length of the input string
    ; Compare reversed string and input string byte by byte
    _checkLoop:
        ; If ecx made it through the whole string without finding a mismatched character, it's a palindrome
        cmp ecx, ebx
        je _exit_is_palindrome

        mov ah, BYTE [esi + ecx]
        mov al, BYTE [edi + ecx]

        ; Print Failure message if character doesn't match
        cmp ah, al
        jne _exit_is_palindrome

        inc ecx
        jmp _checkLoop

    _exit_is_palindrome:
        ret