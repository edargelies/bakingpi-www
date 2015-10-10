@ Creates a psuedo random number using the previous x and y coordinate as a seed
@ x_sub(n+1)=a*x_sub(n)^2+b*x_sub(n)+c*mod2^32
.globl Random
Random:
	xnm .req r0
	a .req r1
	
	mov a,#0xef00
	mul a,xnm
	mul a,xnm
	add a,xnm
	.unreq xnm
	add r0,a,#73
	
	.unreq a
	mov pc,lr
