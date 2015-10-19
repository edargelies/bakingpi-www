.globl GetGpioAddress
GetGpioAddress:
ldr r0,=0x3F200000
mov pc,lr

.globl SetGpioFunction
SetGpioFunction:
    @ Make sure pin number and function are valid
    cmp r0,#53
    cmpls r1,#7
    @ If invalid return back to the code that called
    movhi pc,lr

    @ Store the link register, the address to return to, in the stack
    push {lr}
    @ Put the pin number into r2
    mov r2,r0

    bl GetGpioAddress
    functionLoop$:
        cmp r2,#9
        subhi r2,#10
        addhi r0,#4
        bhi functionLoop$

    add r2, r2,lsl #1
    lsl r1,r2
    str r1,[r0]
    pop {pc}

.globl SetGpio
SetGpio:
    pinNum .req r0
    pinVal .req r1

    cmp pinNum,#53
    movhi pc,lr
    push {lr}
    mov r2,pinNum
    .unreq pinNum
    pinNum .req r2
    bl GetGpioAddress
    gpioAddr .req r0

    pinBank .req r3
    lsr pinBank,pinNum,#5
    lsl pinBank,#2
    add gpioAddr,pinBank
    .unreq pinBank

    and pinNum,#31
    setBit .req r3
    mov setBit,#1
    lsl setBit,pinNum
    .unreq pinNum

    teq pinVal,#0
    .unreq pinVal
    streq setBit,[gpioAddr,#40]
    strne setBit,[gpioAddr,#28]
    .unreq setBit
    .unreq gpioAddr
    pop {pc}

.globl Debug
Debug:
    @ Signal for a failed initialization
    @ Set the GPIO pin
    mov r0,#47
    mov r1,#1
    bl SetGpioFunction

    ptrn .req r4
    ldr ptrn,=pattern
    ldr ptrn,[ptrn]
    seq .req r5
    reset .req r6
    mov seq,#0

    @ Turn on the LED by setting the GPSET1 register
    @ With the 47th bit set
    @ Give processor a flash LED task
    loop$:

        pinNum .req r0
        pinVal .req r1
        mov pinVal,#1
        lsl pinVal,seq
        and pinVal,ptrn
        mov pinNum,#47
        bl SetGpio
        .unreq pinNum
        .unreq pinVal

        @ Set the countdown timer
        delay .req r0
        ldr delay,=250000
        bl Wait
        .unreq delay

        add seq,seq,#1
        cmp seq,#32
        moveq seq,#0
        @ When timer expires turn on the LED by setting the GPSET1 register
    b loop$

    .unreq seq

.section .data
.align 2
@TO-DO Create additional patterns to signal different errors
pattern:
.int 0b00000000010101011101110111010101
