/******************************************************************************
*	main.s
*	 by Alex Chadwick
*
*	A sample assembly code implementation of the screen02 operating system, that 
*	renders pseudo random lines to the screen.
*
*	main.s contains the main operating system, and IVT code.
******************************************************************************/

/*
* .globl is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the 
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final 
* result, and so the entry point really doesnt matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point. 
*/
.section .init
.globl _start
_start:

/*
* Branch to the actual main code.
*/
b main

/*
* This command tells the assembler to put this code with the rest.
*/
.section .text

/*
* main is what we shall call our main operating system method. It never 
* returns, and takes no parameters.
* C++ Signature: void main(void)
*/
main:

/*
* Set the stack point to 0x8000.
*/
	mov sp,#0x8000

/* 
* Setup the screen.
*/
	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer

/* 
* Check for a failed frame buffer.
*/
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

/* NEW
* Let our drawing method know where we are drawing to.
*/
	bl SetGraphicsAddress
	
	lastRandom .req r7
	lastX .req r8
	lastY .req r9
	colour .req r10
	x .req r5
	y .req r6
	mov lastRandom,#0
	mov lastX,#0
	mov r9,#0
	mov r10,#0
render$:
	mov r0,lastRandom
	bl Random
	mov x,r0
	bl Random
	mov y,r0
	mov lastRandom,r0

	mov r0,colour
	add colour,#1
	lsl colour,#16
	lsr colour,#16
	bl SetForeColour
		
	mov r0,lastX
	mov r1,lastY
	lsr r2,x,#22
	lsr r3,y,#22

	cmp r3,#768
	bhs render$
	
	mov lastX,r2
	mov lastY,r3
	 
	bl DrawLine

	b render$

	.unreq x
	.unreq y
	.unreq lastRandom
	.unreq lastX
	.unreq lastY
	.unreq colour
