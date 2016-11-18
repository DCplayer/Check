/* **********************************************************************************************************************************
   subrutinas.s

      Por:
	 Diego Castaneda,   Carnet: 15151
  	 Alejandro Chaclan, Carnet: 15018
	 Carlos Calderon,   Carnet: 15219
     Taller de Assembler, Seccion: 30

     Taller de Assembler
     Universidad del Valle de Guatemala

   ******************************************************************************************************************************* */
/*--CODIGO *************************************************************************************************************************/
.data
.align 2
/*--*****************************************************SUBRUTINAS PARA COMPONENTES********************************************************************/
/* NEW
* GetGpioAddress returns the base address of the GPIO region as a physical address
* in register r0.
* C++ Signature: void* GetGpioAddress()
*/
.global GetGpioAddress
GetGpioAddress:
	gpioAddr .req r0
	push {lr}
	@ldr gpioAddr,=0x20200000
	ldr gpioAddr,=0x3F200000 @GPIO base para raspberry 2
	@modificaciones para utilizar la memoria virtual
	bl phys_to_virt
 	mov r7, r0  @ r7 points to that physical page
 	ldr r6, =myloc
 	str r7, [r6] @ save this
	pop {pc}
	.unreq gpioAddr

/* NEW
* SetGpioFunction sets the function of the GPIO register addressed by r0 to the
* low  3 bits of r1.
* C++ Signature: void SetGpioFunction(u32 gpioRegister, u32 function)
*/
.global SetGpioFunction
SetGpioFunction:
    pinNum .req r0
    pinFunc .req r1
	cmp pinNum,#53
	cmpls pinFunc,#7
	movhi pc,lr

	push {lr}
	mov r2,pinNum
	.unreq pinNum
	pinNum .req r2
	@bl GetGpioAddress no se llama la funcion sino
	ldr r6, =myloc
 	ldr r0, [r6] @ obtener direccion
	gpioAddr .req r0

	functionLoop$:
		cmp pinNum,#9
		subhi pinNum,#10
		addhi gpioAddr,#4
		bhi functionLoop$

	add pinNum, pinNum,lsl #1
	lsl pinFunc,pinNum

	mask .req r3
	mov mask,#7					/* r3 = 111 in binary */
	lsl mask,pinNum				/* r3 = 11100..00 where the 111 is in the same position as the function in r1 */
	.unreq pinNum

	mvn mask,mask				/* r3 = 11..1100011..11 where the 000 is in the same poisiont as the function in r1 */
	oldFunc .req r2
	ldr oldFunc,[gpioAddr]		/* r2 = existing code */
	and oldFunc,mask			/* r2 = existing code with bits for this pin all 0 */
	.unreq mask

	orr pinFunc,oldFunc			/* r1 = existing code with correct bits set */
	.unreq oldFunc

	str pinFunc,[gpioAddr]
	.unreq pinFunc
	.unreq gpioAddr
	pop {pc}

/* NEW
* SetGpio sets the GPIO pin addressed by register r0 high if r1 != 0 and low
* otherwise.
* C++ Signature: void SetGpio(u32 gpioRegister, u32 value)
*/
.global SetGpio
SetGpio:
    pinNum .req r0
    pinVal .req r1

	cmp pinNum,#53
	movhi pc,lr
	push {lr}
	mov r2,pinNum
    .unreq pinNum
    pinNum .req r2
	@bl GetGpioAddress no se llama la funcion sino
	ldr r6, =myloc
 	ldr r0, [r6] @ obtener direccion
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

.global GetGpio
GetGpio:
	push {lr}
	push {r5-r8}
	mov r8,r0

	ldr r6,=myloc
	ldr r0,[r6]
	ldr r5,[r0,#0x34]

	mov r7,#1
	lsl r7,r8
	and r5,r5,r7
	cmp r5,#0
	moveq r0,#0
	movgt r0,#1

	pop {r5-r8}
	pop {pc}
/*--CODIGO *************************************************************************************************************************/

/*
* R0, Direccion de memoria a la matriz
* R1, X inicial
* R2, Y inicial
* R3, Width de la matriz
* Stack-1 Height de la matriz
* Codigo Basado en el proporcionado en blackboard
*/
.global draw_image
draw_image:
	ldr r5, [sp], #4
	mov r4, r3
	mov r6, r0
	push {lr}

	add r4, r1
	add r5, r2
	x .req r1
	y .req r2
	color .req r3
	finalx .req r4
	finaly .req r5
	matrix_addr .req r6
	matrix_counter .req r7
	temp .req r8

	mov matrix_counter, #0
	mov temp, x

	next_x:
		mov x, temp
		draw_pixel:
			cmp x, finalx
			bge next_y
			ldrh color, [matrix_addr, matrix_counter]
			ldr r0, =pixelAddr
			ldr r0, [r0]
			push {r0-r12}
			bl pixel
			pop {r0-r12}
			add matrix_counter, #2 @ Se suma dos debido a que esta en depth 16
			add x, #1
			b draw_pixel

	next_y:
		add y, #1
		teq y, finaly
		bne next_x

		.unreq x
		.unreq y
		.unreq color
		.unreq finalx
		.unreq finaly
		.unreq matrix_addr
		.unreq matrix_counter
		.unreq temp

	pop {pc}


@@ R0: Numero de componente a enseñar
.global draw_bg
draw_bg:
	push {lr}

	mov r5,r0

	mov r1, #0
	mov r2, #0

	cmp r5, #1
	ldreq r0, =Image_Matrix_bgfinalAND
	ldreq r3, =Width_bgfinalAND
	ldreq r3, [r3]
	ldreq r4, =Height_bgfinalAND
	ldreq r4, [r4]
	streq r4, [sp, #-4]!
	beq endDraw_bg

	cmp r5,#2
	ldreq r0, =Image_Matrix_bgfinalOR
	ldreq r3, =Width_bgfinalOR
	ldreq r3, [r3]
	ldreq r4, =Height_bgfinalOR
	ldreq r4, [r4]
	streq r4, [sp, #-4]!
	beq endDraw_bg

	cmp r5,#3
	ldreq r0, =Image_Matrix_bgfinalNOT
	ldreq r3, =Width_bgfinalNOT
	ldreq r3, [r3]
	ldreq r4, =Height_bgfinalNOT
	ldreq r4, [r4]
	streq r4, [sp, #-4]!
	beq endDraw_bg

	endDraw_bg:
		bl draw_image

	pop {pc}
