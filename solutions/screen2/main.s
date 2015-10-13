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

@ Draw Random lines
	bl SetGraphicsAddress
	lastRandom .req r5
	color .req r6
	lastx .req r7
	lasty .req r8
	nextx .req r9
	nexty .req r10

	mov lastRandom,#0
	mov color,#0
	mov lastx,#0
	mov lasty,#0
draw$:
	mov r0,lastRandom
	bl Random
	mov nextx,r0
	bl Random
	mov nexty,r0
	mov lastRandom,r0

	mov r0,color
	add color,#1
	lsl color,#16
	lsr color,#16
	bl SetForeColour

	mov r0,lastx
	mov r1,lasty
	lsr r2,nextx,#22
	lsr r3,nexty,#22

	cmp r3,#768
	bhs draw$

	mov lastx,r2
	mov lasty,r3

	bl DrawLine

	b draw$

	.unreq lastRandom
	.unreq color
	.unreq lastx
	.unreq lasty
	.unreq nextx
	.unreq nexty
