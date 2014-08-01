
/*
  bfcompiler v0.3.0b
  by Brandon Yannoni
  Started in 2012
  Updated December 3, 2012
  0.3.0b:
    Translated to GAS syntax
  0.2.0b:
    Added nested loop support
*/

.globl _start
.data
headerStr: .ascii ".globl _start\n.data\narr:\n.rept 30000;.byte 0;.endr\n.text\n_start:\nmov $arr, %esi\ninc %edx\n"
_headerLen = . - headerStr
endStr:	.ascii "mov $1, %eax\nxor %ebx, %ebx\nint $0x80\n"
_endLen = . - endStr
prompt: .ascii "Enter a file name: "
_promptLen = . - prompt
incValStr: .ascii "incb (%esi)\n"
_incValStrLen = . - incValStr
decValStr: .ascii "decb (%esi)\n"
_decValStrLen = . - decValStr
incAddrStr: .ascii "inc %esi\n"
_incAddrStrLen = . - incAddrStr
decAddrStr: .ascii "dec %esi\n"
_decAddrStrLen = . - decAddrStr
startLoopStr1: .ascii "startLoop"
_startLoopStr1Len = . - startLoopStr1
startLoopStr2: .ascii ":\ncmp $0, (%esi)\njz endLoop"
_startLoopStr2Len = . - startLoopStr2
endLoopStr1: .ascii "jnz startLoop"
_endLoopStr1Len = . - endLoopStr1
endLoopStr2: .ascii "\nendLoop"
_endLoopStr2Len = . - endLoopStr2
endLoopStr3: .ascii ":\n"
_endLoopStr3Len = . - endLoopStr3
printValStr: .ascii "mov $4, %eax\nmov $1, %ebx\nmov %esi, %ecx\nint $0x80\n"
_printValStrLen = . - printValStr
getValStr: .ascii "mov $3, %eax\nxor %ebx, %ebx\nmov %esi, %ecx\nint $0x80\n"
_getValStrLen = . - getValStr
newLine: .ascii "\n"

currLoopNum: .int 0
highLoopNum: .int 0
loopStr: .rept 45; .byte 0; .endr
hfile1: .int 0
hfile2: .int 0
currChar: .byte 0

outputFile: .asciz "a.asm"
fname: .rept 64; .byte 0; .endr

.text
_start:
  mov $4, %eax
  mov $1, %ebx
  mov $prompt, %ecx
  mov $_promptLen, %edx
  int $0x80
  mov $3, %eax
  xor %ebx, %ebx
  mov $fname, %ecx
  int $0x80
  mov %ecx, %ebx
  mov %ecx, %edi
  xor %al, %al
  xor %ecx, %ecx
  not %ecx
  repne scasb
  movb $0, -2(%edi)
  mov $5, %eax
  xor %ecx, %ecx
  int $0x80
  test %eax, %eax /* error */
  js close_files
  mov %eax, (hfile1)
  mov $5, %eax
  mov $outputFile, %ebx
  mov $03101, %ecx
  mov $0640, %edx
  int $0x80
  test %eax, %eax /* error */
  js close_files
  mov %eax, (hfile2)
  mov %eax, %ebx
  mov $4, %eax
  mov $headerStr, %ecx
  mov $_headerLen, %edx
  int $0x80
readfile:
  mov $3, %eax
  mov (hfile1), %ebx
  mov $currChar, %ecx
  mov $1, %edx
  int $0x80
  cmp $0, %eax
  je finish
  mov (currChar), %dl
  cmpb $0x3E, %dl
  je incAddr
  cmpb $0x3C, %dl
  je decAddr
  cmpb $0x2B, %dl
  je incVal
  cmpb $0x2D, %dl
  je decVal
  cmpb $0x2E, %dl
  je printVal
  cmpb $0x2C, %dl
  je getVal
  cmpb $0x5B, %dl
  je startLoop
  cmpb $0x5D, %dl
  je endLoop
  jmp readfile
finish:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $endStr, %ecx
  mov $_endLen, %edx
  int $0x80
close_files:
  mov $6, %eax
  mov (hfile1), %ebx
  int $0x80
  mov $6, %eax
  mov (hfile2), %ebx
  int $0x80
exit:
  mov $1, %eax
  xor %ebx, %ebx
  int $0x80

incAddr:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $incAddrStr, %ecx
  mov $_incAddrStrLen, %edx
  int $0x80
  jmp readfile

decAddr:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $decAddrStr, %ecx
  mov $_decAddrStrLen, %edx
  int $0x80
  jmp readfile

incVal:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $incValStr, %ecx
  mov $_incValStrLen, %edx
  int $0x80
  jmp readfile

decVal:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $decValStr, %ecx
  mov $_decValStrLen, %edx
  int $0x80
  jmp readfile

printVal:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $printValStr, %ecx
  mov $_printValStrLen, %edx
  int $0x80
  jmp readfile

getVal:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $getValStr, %ecx
  mov $_getValStrLen, %edx
  int $0x80
  jmp readfile

strlen:
  xor %al, %al
  xor %ecx, %ecx
  not %ecx
  repne scasb
  not %ecx
  dec %ecx
  ret

itoa:
  push %ebx
  xor %ecx, %ecx
  mov $10, %ebx
get_list$:
  cmp $0, %eax
  jnl make_str$
  div %ebx
  inc %ecx
  add $0x30, %edx
  push %edx
  jmp get_list$
make_str$:
  mov %ecx, %eax
  xor %ecx, %ecx
make_str_loop$:
  cmp %ecx, %eax
  je done$
  pop %edx
  movb %dl, (%edi, %ecx)
  inc %ecx
  jmp make_str_loop$
done$:
  pop %ebx
  mov %ecx, %edx
  mov %edi, %ecx
  ret

printLoopNum:
  push %eax
  push %ecx
  push %edx
  mov $loopStr, %edi
  call strlen
  movb $0, (%edi, %ecx)
  loop . - 1
  mov (currLoopNum), %eax
  call itoa
  mov $4, %eax
  int $0x80
  pop %edx
  pop %ecx
  pop %eax
  ret

startLoop:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $startLoopStr1, %ecx
  mov $_startLoopStr1Len, %edx
  int $0x80
  incw (highLoopNum)
  mov (highLoopNum), %eax
  mov %eax, (currLoopNum)
  call printLoopNum
  mov $4, %eax
  mov $startLoopStr2, %ecx
  mov $_startLoopStr2Len, %edx
  int $0x80
  call printLoopNum
  mov $4, %eax
  mov $newLine, %ecx
  mov $1, %edx
  int $0x80
  jmp readfile

endLoop:
  mov $4, %eax
  mov (hfile2), %ebx
  mov $endLoopStr1, %ecx
  mov $_endLoopStr1Len, %edx
  int $0x80
  call printLoopNum
  mov $4, %eax
  mov $endLoopStr2, %ecx
  mov $_endLoopStr2Len, %edx
  int $0x80
  call printLoopNum
  mov $4, %eax
  mov $endLoopStr3, %ecx
  mov $_endLoopStr3Len, %edx
  int $0x80
  decw (currLoopNum)
  jmp readfile

