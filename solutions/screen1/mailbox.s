.globl GetMailboxBase
GetMailboxBase: 
	ldr r0,=0x3F00B880
	mov pc,lr

.globl MailboxWrite
MailboxWrite: 
	@ Validate the lower 4 bits of the mailbox channel are 0
	tst r0,#0b1111
	movne pc,lr
	@ r1 is a mailbox channel which must be less than 4 bits
	cmp r1,#15
	movhi pc,lr

	channel .req r1
	value .req r2
	mov value,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0
		
	status .req r3
	wait1$:	
		@ Status contains the address of the status register
		@ Address 0x3F00B898 is the status mailbox
		ldr status,[mailbox,#0x18]	
		@ Check that bit 31 is clear (ready to write), if so proceed
		tst status,#0x80000000
		bne wait1$
	.unreq status

	@ Add the value and channel together, now the last 4 bits are filled with the channel
	add value,channel
	.unreq channel
	
	@ Address 0x3F00B8A0 is the write mailbox
	str value,[mailbox,#0x20]
	.unreq value
	.unreq mailbox
	pop {pc}

.globl MailboxRead
MailboxRead: 
	@ r1 is a mailbox channel which must be less than 4 bits
	cmp r0,#15
	movhi pc,lr

	channel .req r1
	mov channel,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0
	
	status .req r2
	rightmail$:
		wait2$:	
			@ Status contains the address of the status register
			@ Address 0x3F00B898 is the status mailbox
			ldr status,[mailbox,#0x18]		
			@ Check that bit 30 is clear (ready to read), if so proceed
			tst status,#0x40000000
			bne wait2$
		.unreq status
		
		
		mail .req r2
		@ Address 0x3F00B880 is the read mailbox
		ldr mail,[mailbox,#0]

		inchan .req r3
		@ The least significant 4 bits are the mailbox channel
		and inchan,mail,#0b1111
		@ Check that it's the channel we expect
		teq inchan,channel
		.unreq inchan
		bne rightmail$
	.unreq mailbox
	.unreq channel

	and r0,mail,#0xfffffff0
	.unreq mail
	pop {pc}
