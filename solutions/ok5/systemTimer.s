.globl GetSystemTimerAddress
GetSystemTimerAddress: 
	ldr r0,=0x3F003000
	mov pc,lr

.globl GetTimestamp
GetTimestamp:
	push {lr}
	bl GetSystemTimerAddress
	@ Get current the counter value
	ldrd r0,r1,[r0,#4]
	pop {pc}

.globl Wait
Wait:
	start .req r3
	period .req r2
	push {lr}
	mov period,r0
	bl GetTimestamp
	@ Start time in r3 (start), delay period in r2 (period)
	mov start,r0

	loop$:
		bl GetTimestamp
		elapsed .req r1
		@ Subtract start time from most recent timestamp to get elapsed time
		sub elapsed,r0,start
		cmp elapsed,period
		.unreq elapsed
		@ If elapsed time is less than wait period loop again
		bls loop$
	@ Elapsed time is greater than wait period so return	
	.unreq period
	.unreq start
	pop {pc}
