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
	mov r4,#0
	loop$:
	ldr r0,=format
	mov r1,#formatEnd-format
	ldr r2,=formatEnd
	lsr r3,r4,#4
	push {r3}
	push {r3}
	push {r3}
	push {r3}
	bl FormatString
	add sp,#16

	mov r1,r0
	ldr r0,=formatEnd
	mov r2,#0
	mov r3,r4

	cmp r3,#768-16
	subhi r3,#768
	addhi r2,#256
	cmp r3,#768-16
	subhi r3,#768
	addhi r2,#256
	cmp r3,#768-16
	subhi r3,#768
	addhi r2,#256

	bl DrawString

	add r4,#16
	b loop$

	.section .data
	format:
	.ascii "%d=0b%b=0x%x=0%o='%c'"
	formatEnd: