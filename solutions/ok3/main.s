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

@ Turn on the LED by setting the GPSET1 register
@ With the 47th bit set
@ Give processor a flash LED task
loop$:
pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#1
bl SetGpio
.unreq pinNum
.unreq pinVal
@ Set the countdown timer
decr .req r0
mov decr,#0x3F0000
wait1$: 
	sub decr,#1
	teq decr,#0
	bne wait1$
.unreq decr

@ When timer expires turn off the LED by setting GPCLR1 register
pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#0
bl SetGpio
.unreq pinNum
.unreq pinVal

@ Reset the countdown timer
decr .req r0
mov decr,#0x3F0000
wait2$:
	sub decr,#1
	teq decr,#0
	bne wait2$
.unreq decr

@ When timer expires turn on the LED by setting the GPSET1 register
b loop$
