nasm -g -f elf -F dwarf -o palindrome.o palindrome.asm
ld palindrome.o -m elf_i386 -o palindrome

./palindrome