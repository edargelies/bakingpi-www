@ Initialization
.section .init
.globl _start
_start:
b main

.section .text
main:
mov sp,#0x8000

@ Credit to user nburman of Raspberry Pi forums who found
@ the new base address and GPIO pin for the ACT LED of the
@ Raspberry Pi 2.

@ Set the GPIO pin
pinNum .req r0
pinFunc .req r1
@ Put 47 in the for the pin number
mov pinNum,#47
@ We want to set the pin high, function 1
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

ptrn .req r4
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
reset .req r6
mov seq,#0

@ Turn on the LED by setting the GPSET1 register
@ With the 47th bit set
@ Give processor a flash LED task
loop$:

pinNum .req r0
pinVal .req r1
mov pinVal,#1
lsl pinVal,seq
and pinVal,ptrn
mov pinNum,#47
bl SetGpio
.unreq pinNum
.unreq pinVal

@ Set the countdown timer
delay .req r0
ldr delay,=250000
bl Wait
.unreq delay

add seq,seq,#1
cmp seq,#32
moveq seq,#0
@ When timer expires turn on the LED by setting the GPSET1 register
b loop$

.unreq seq

.section .data
.align 2
pattern:
.int 0b00000000010101011101110111010101
