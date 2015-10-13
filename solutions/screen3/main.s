@ Initialization
.section .init
.globl _start
_start:
b main

.section .text
main:
	mov sp,#0x9000

	@ Initialize the framebuffer
	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer

	teq r0,#0
	bne noError$
	
	@ Signal for a failed initialization	
	mov r0,#47
	mov r1,#1
	bl SetGpioFunction

	mov r0,#47
	mov r1,#1
	bl SetGpio

	error$:
		b error$

	noError$:

	fbInfoAddr .req r4
	mov fbInfoAddr,r0

@ Draw the command line
	bl SetGraphicsAddress

	mov r0,#9
	bl FindTag
	ldr r1,[r0]
	lsl r1,#2
	sub r1,#8
	add r0,#8
	mov r2,#0
	mov r3,#0
	bl DrawString

loop$:
	b loop$
