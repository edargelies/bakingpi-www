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
@ Turn on the LED by setting the GPSET1 register
@ With the 15th bit set 47-32=15
mov r1,#1
lsl r1,#15
str r1,[r0,#32]
@ Give processor a flash LED task
loop$:
@ Set the countdown timer
mov r2,#0x3F0000
@ Start counting down
wait1$:
sub r2,#1
cmp r2,#0
bne wait1$
@ When timer expires turn off the LED by setting GPCLR1 register
str r1,[r0,#44]
@ Reset the countdown timer
mov r2,#0x3F0000
wait2$:
sub r2,#1
cmp r2,#0
bne wait2$
@ When timer expires turn on the LED by setting the GPSET1 register
str r1,[r0,#32]
b loop$

