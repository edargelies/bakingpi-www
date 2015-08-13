@ Initialization
.section .init
.globl _start
_start:
@ Credit to user nburman of Raspberry Pi forums who found
@ the new base address and GPIO pin for the ACT LED of the
@ Raspberry Pi 2. 
@ Load the address of the GPIO controller
ldr r0,=0x3f200000
@ enable the 47th GPIO pin
mov r1,#1
lsl r1,#21
str r1,[r0,#16]
@ Turn on the LED
mov r1,#1
lsl r1,#15
str r1,[r0,#32]
@ Give processor loop task
loop$:
b loop$
