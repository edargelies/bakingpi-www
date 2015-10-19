.section .data
.align 8
font:
	.incbin "font.bin"

.align 1
foreColour:
	.hword 0xFFFF

.align 2
graphicsAddress:
	.int 0

.section .text
.globl SetForeColour
SetForeColour:
	cmp r0,#0x10000
	movhi pc,lr
	moveq pc,lr

	ldr r1,=foreColour
	strh r0,[r1]
	mov pc,lr

.globl SetGraphicsAddress
SetGraphicsAddress:
	ldr r1,=graphicsAddress
	str r0,[r1]
	mov pc,lr

.globl DrawPixel
DrawPixel:
	px .req r0
	py .req r1
	addr .req r2
	@ Load the graphics address which is an unsigned integer
	ldr addr,=graphicsAddress
	ldr addr,[addr]
	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	@ Make sure y axis is within range
	cmp py,height
	movhi pc,lr
	.unreq height

	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	@ Make sure x axis is within range
	cmp px,width
	movhi pc,lr

	ldr addr,[addr,#32]
	@ Subtract the uncached bus access alias from the GPU pointer address
	sub addr, #0xC0000000
	add width,#1
	@ Multply y axis with width, add x axis and store in px
	mla px,py,width,px
	.unreq width
	.unreq py
	@ Logical shift left one position is effectively multiply by two, the pixel size
	add addr, px,lsl #1
	.unreq px

	fore .req r3
	@ Load the fore color
	ldr fore,=foreColour
	ldrh fore,[fore]

	@ Store it in the calculated pixel address.  This paints the pixel
	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr


@ Bresenhams Line Algorithm
.globl DrawLine
DrawLine:
	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	x0 .req r4
	y0 .req r5
	x1 .req r6
	y1 .req r7

	deltax .req r8
	deltay .req r9
	stepx .req r10
	stepy .req r11
	error .req r12

	mov x0,r0
	mov y0,r1
	mov x1,r2
	mov y1,r3

	cmp x1,x0
	subge deltax,x1,x0
	movge stepx,#1
	sublt deltax,x0,x1
	movlt stepx,#-1

	cmp y1,y0
	subge deltay,y0,y1
	movge stepy,#-1
	sublt deltay,y1,y0
	movlt stepy,#1

	add error,deltax,deltay
	add x1,stepx
	add y1,stepy

	lineLoop$:
		teq x0,x1
		teqne y0,y1
		@ We are done
		popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

		mov r0,x0
		mov r1,y0
		bl DrawPixel

		cmp deltax,error,lsl #1
		addge y0,stepy
		addge error,deltax

		@neg deltay,deltay
		cmp deltay,error,lsl #1
		addle x0,stepx
		addle error,deltay

		b lineLoop$

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq deltax
	.unreq deltay
	.unreq stepx
	.unreq stepy
	.unreq error

.globl DrawCharacter
DrawCharacter:
	x .req r4
	y .req r5
	charAddr .req r6

	@ Check the range of ASCII values
	cmp r0,#0x7F
	bhi Debug
	movhi pc,lr

	mov x,r1
	mov y,r2

	push {r4,r5,r6,r7,r8,lr}
	ldr charAddr,=font
	@ Left shift the ASCII Number by 4 (16 bits) the size of a character
	add charAddr, r0,lsl #4
	
	charLoop$:
		bits .req r7
		bit .req r8
		ldrb bits,[charAddr]		
		mov bit,#8

		charPixelLoop$:
			subs bit,#1
			blt charPixelLoopEnd$
			lsl bits,#1
			tst bits,#0x100
			beq charPixelLoop$

			add r0,x,bit
			mov r1,y
			bl DrawPixel

			teq bit,#0
			bne charPixelLoop$
		charPixelLoopEnd$:

		.unreq bit
		.unreq bits
		add y,#1
		add charAddr,#1
		tst charAddr,#0b1111
		bne charLoop$

	.unreq x
	.unreq y
	.unreq charAddr

	width .req r0
	height .req r1
	mov width,#8
	mov height,#16

	pop {r4,r5,r6,r7,r8,pc}
	.unreq width
	.unreq height

.globl DrawString
DrawString:
	x .req r4
	y .req r5
	x0 .req r6
	string .req r7
	length .req r8
	char .req r9
	
	push {r4,r5,r6,r7,r8,r9,lr}

	mov string,r0
	mov x,r2
	mov x0,x
	mov y,r3
	mov length,r1

	stringLoop$:
		subs length,#1
		blt stringLoopEnd$

		ldrb char,[string]
		add string,#1

		mov r0,char
		mov r1,x
		mov r2,y
		bl DrawCharacter
		cwidth .req r0
		cheight .req r1

		teq char,#'\n'
		moveq x,x0
		addeq y,cheight
		beq stringLoop$

		teq char,#'\t'
		addne x,cwidth
		bne stringLoop$

		add cwidth, cwidth,lsl #2
		x1 .req r1
		mov x1,x0
			
		stringLoopTab$:
			add x1,cwidth
			cmp x,x1
			bge stringLoopTab$
		mov x,x1
		.unreq x1	
		b stringLoop$
	stringLoopEnd$:
	.unreq cwidth
	.unreq cheight
	
	pop {r4,r5,r6,r7,r8,r9,pc}
	.unreq x
	.unreq y
	.unreq x0
	.unreq string
	.unreq length
