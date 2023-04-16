; Name: Erik Bowling
; Date: April 16, 2023
; Palindrome.asm revision

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
    revStr RESB 1024
    lenInStr RESD 1

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
        cmp eax, DWORD 1
        je _exit
        
        ; Store the length of the input str
        mov [lenInStr], eax

        ; Parameters for reverse string. Input string, revStr, and length of input string
        push inStr ; ebp + 16
        push revStr ; ebp + 12
        push DWORD [lenInStr] ; ebp + 8

        call is_palindrome

        cmp eax, DWORD 1
        jne _fail

        _succ:
            mov eax, SYS_WRITE
            mov ebx, STD_OUT
            mov ecx, success
            mov edx, lenSuccess
            int 80h

            jmp _clean_up

        _fail:
            mov eax, SYS_WRITE
            mov ebx, STD_OUT
            mov ecx, failure
            mov edx, lenFailure
            int 80h

        _clean_up:
            mov eax, SYS_WRITE
            mov ebx, STD_OUT
            mov ecx, newLine
            mov edx, lenNewLine
            int 80h

            ; Clears the stack. Not sure the best convention for this.
            pop eax
            pop eax
            pop eax

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

is_palindrome:
    push ebp ; Preserve location of ebp
    mov ebp, esp ; Make ebp point to top of the stack

    sub esp, 8 ; Make space for esi, edi

    mov [ebp - 4], esi
    mov [ebp - 8], edi

    mov ecx, DWORD [ebp + 8] ; length of input
    mov edi, DWORD [ebp + 12] ; revStr Memory Address
    mov esi, DWORD [ebp + 16] ; inStr Memory Address

    xor edx, edx ; edx will increment though edi

    ; Loops backwards through the input string appending each letter to revStr
    _reverseLoop:
        dec ecx 
        mov ah, BYTE [esi + ecx]
        mov BYTE [edi + edx], ah

        inc edx

        cmp ecx, DWORD 0
        jne _reverseLoop

    mov ecx, DWORD [ebp + 8]
    xor edx, edx

    ; Check if each character in reverse string = input string
    _check_same_loop:
        dec ecx

        mov ah, BYTE [edi+edx]
        mov al, BYTE [esi+edx]

        cmp ah, al
        jne _not_pal

        inc edx

        cmp ecx, DWORD 0
        je _yes_pal

        jmp _check_same_loop

    _not_pal:
        ; return 0 if not palindrome
        xor eax, eax
        jmp _done

    _yes_pal:
        ; return 1 if palindrome
        xor eax, eax
        inc eax

    _done:
        ; Restore edi and esi
        mov esi, [ebp - 4]
        mov edi, [ebp - 8]

        ; Remove local variables and reset ebp
        mov esp, ebp
        pop ebp

    ret


