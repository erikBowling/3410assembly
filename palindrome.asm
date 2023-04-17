; Name: Erik Bowling
; Date: April 16, 2023
; palindrome.asm revision

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
    inStr RESB 1024

GLOBAL _start:

SECTION .text

_start:
    _main_loop:
        ; Print prompt to user
        mov eax, SYS_WRITE
        mov ebx, STD_OUT
        mov ecx, prompt
        mov edx, lenPrompt
        int 80h

        ; Read in string from the user
        mov eax, SYS_READ
        mov ebx, STD_IN
        mov ecx, inStr
        mov edx, 1024
        int 80h

        ; If the string entered was empty, exit
        ; eax holds the length of STDIN + 1
        ; Could also check for the value of 10 in the input string for a new line
        cmp eax, DWORD 1
        je _exit

        ; Parameters for is_palindrome. Input string and length
        push inStr ; ebp + 12
        push eax ; ebp + 8

        call is_palindrome

        ; Clean the stack
        add esp, 8

        cmp eax, DWORD 1
        jne _fail

        _succ:
            mov eax, SYS_WRITE
            mov ebx, STD_OUT
            mov ecx, success
            mov edx, lenSuccess
            int 80h

            jmp _restart

        _fail:
            mov eax, SYS_WRITE
            mov ebx, STD_OUT
            mov ecx, failure
            mov edx, lenFailure
            int 80h

        _restart:
            ; prints a new line
            mov eax, SYS_WRITE
            mov ebx, STD_OUT
            mov ecx, newLine
            mov edx, lenNewLine
            int 80h

        ; Jump back to the top
        jmp _main_loop

    _exit:
        mov eax, SYS_WRITE
        mov ebx, STD_OUT
        mov ecx, goodbye
        mov edx, lenGoodbye
        int 80h

        mov eax, SYS_EXIT
        mov ebx, 0
        int 80h

        ; divide by two efficiently
        ; shr eax, 1

is_palindrome:
    push ebp ; Preserve location of ebp
    mov ebp, esp ; Make ebp point to top of the stack

    ; Preserve our caller's esi, ebx registers
    push esi
    push ebx

    mov ecx, DWORD [ebp + 8] ; length of input (including new line)
    mov ebx, DWORD [ebp + 8] ; used to find midpoint of string
    mov esi, DWORD [ebp + 12] ; memory address of input string

    xor edx, edx ; edx will increment though edi
    sub ecx, 2 ; remove newline and zero index it
    dec ebx ; Also remove newline

    shr ebx, 1 ; Easier divide by two.

    _checkLoop:
        mov ah, BYTE [esi + ecx] ; storing characters starting from the end in ah

        cmp ah, BYTE [esi + edx] ; compare ending character to beginning character
        jne _not_pal

        cmp edx, ebx ; If edx exceeds ebx or is equal, then we have a palindrome
        jge _yes_pal

        inc edx
        dec ecx

        jmp _checkLoop

    _not_pal:
        ; return 0 if not palindrome
        xor eax, eax
        jmp _done

    _yes_pal:
        ; return 1 if palindrome
        xor eax, eax
        inc eax

    _done:
        ; Restore esi, and ebx
        pop ebx
        pop esi

        ; Remove local variables and reset ebp
        mov esp, ebp
        pop ebp

    ret