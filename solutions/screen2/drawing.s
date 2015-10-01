.section .data
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
	movhs pc,lr
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
	ldr addr,=graphicsAddress
	ldr addr,[addr]
	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	cmp py,height
	movhi pc,lr
	.unreq height

	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	cmp px,width
	movhi pc,lr

	ldr addr,[addr,#32]
	add width,#1
	mla px,py,width,px
	.unreq width
	.unreq py
	add addr, px,lsl #1
	.unreq px

	fore .req r3
	ldr fore,=foreColour
	ldrh fore,[fore]

	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr
