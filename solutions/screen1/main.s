@ Initialization
.section .init
.globl _start
_start:
b main

.section .text
main:
mov sp,#0x8000

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

@ Draw pixels in incremental colors on the screen
render$:
	fbAddr .req r3
	@ Load the pointer to the frame buffer
	ldr fbAddr,[fbInfoAddr,#32]
	@ BCM2836 now uses uncached bus access for DMA subtract the cached alias offset
	sub fbAddr, #0xC0000000

@ Loop line by line to change gradient
	colour .req r0
	y .req r1
	mov y,#768
	drawRow$:
		x .req r2
		mov x,#1024
		drawPixel$:
			strh colour,[fbAddr]
			add fbAddr,#2
			sub x,#1
			teq x,#0
			bne drawPixel$

		sub y,#1
		add colour,#1
		teq y,#0
		bne drawRow$

	b render$

	.unreq fbAddr
	.unreq fbInfoAddr
