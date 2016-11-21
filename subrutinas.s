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
			ldr r0, =63488
			cmp color, r0
			addeq matrix_counter, #2
			addeq x, #1
			beq draw_pixel
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


@@ Input:
@@ R0: Numero de componente a enseñar
.global draw_bg
draw_bg:
	push {lr}

	mov r5,r0

	@ Aqui se dice que se empieza a dibujar en 0,0
	mov r1, #0
	mov r2, #0

	cmp r5, #1
	ldreq r0, =Image_Matrix_bgfinalAND @ Se carga la direccion de la matriz de colores de la imagen
	ldreq r3, =Width_bgfinalAND @ Se carga el width de la imagen
	ldreq r3, [r3]
	ldreq r4, =Height_bgfinalAND @ Se carga el height de la imagen
	ldreq r4, [r4]
	streq r4, [sp, #-4]!
	beq endDraw_bg

	cmp r5,#2
	ldreq r0, =Image_Matrix_bgfinalOR @ Se carga la direccion de la matriz de colores de la imagen
	ldreq r3, =Width_bgfinalOR @ Se carga el width de la imagen
	ldreq r3, [r3]
	ldreq r4, =Height_bgfinalOR @ Se carga el height de la imagen
	ldreq r4, [r4]
	streq r4, [sp, #-4]!
	beq endDraw_bg

	cmp r5,#3
	ldreq r0, =Image_Matrix_bgfinalNOT @ Se carga la direccion de la matriz de colores de la imagen
	ldreq r3, =Width_bgfinalNOT @ Se carga el width de la imagen
	ldreq r3, [r3]
	ldreq r4, =Height_bgfinalNOT@ Se carga el height de la imagen
	ldreq r4, [r4]
	streq r4, [sp, #-4]!
	beq endDraw_bg

	endDraw_bg:
		bl draw_image @ Se dibuja la imagen

	pop {pc}

@@ Subrutina que dibuja las instrucciones de animacion de los componentes AND y OR
.global draw_instr
draw_instr:
	push {lr}

	ldr r0,=anim_cont @ Se pone una tolerancia, que es el numero de veces que tiene que ingresar a la subrutina para dibujar la siguiente imagen
	ldr r0,[r0]
	ldr r1,=tolerance
	ldr r1,[r1]
	cmp r0, r1
	addne r0, #1
	ldrne r1, =anim_cont
	strne r0, [r1]
	bne draw_instr2
	ldr r0,=anim_turn @ Se revisa que imagen de la animacion toca
	ldr r0,[r0]
	cmp r0, #0
	beq draw_instr_anim1
	cmp r0, #1
	beq draw_instr_anim2

	@ Se cambia el numero de la animacion que toca despues
	draw_instr_anim1:
		mov r0, #1
		ldr r1, =anim_turn
		str r0, [r1]
		b changeAnim
	@ Se cambia el numero de la animacion que toca despues
	draw_instr_anim2:
		mov r0, #0
		ldr r1, =anim_turn
		str r0, [r1]
		b changeAnim
	@ Se reinicia el contador para revisar la tolerancia
	changeAnim:
		ldr r1,=anim_cont
		mov r0, #0
		str r0,[r1]
		b draw_instr2

	@ Se cargan las propiedades de la imagen para dibujarla
	draw_instr2:
		mov r1,#0 @ Aqui se dice que se empieza a dibujar en 0,0
		mov r2,#0 @ Aqui se dice que se empieza a dibujar en 0,0
		ldr r5,=anim_turn
		ldr r5,[r5]
		cmp r5,#0
		ldreq r0,=Image_Matrix_bgCompuerta @ Se carga la direccion de la matriz de colores de la imagen
		ldrne r0,=Image_Matrix_bgCompuertaColor @ Se carga la direccion de la matriz de colores de la imagen
		ldr r3, =Width_bgfinalNOT @ Se carga el width de la imagen
		ldr r3, [r3]
		ldr r4, =Height_bgfinalNOT @ Se carga el height de la imagen
		ldr r4, [r4]
		str r4,[sp,#-4]!
		bl draw_image @ Se dibuja la imagen

	pop {pc}

@@ Subrutina que dibuja la animacion de las instrucciones del componente NOT
.global draw_instrNOT
draw_instrNOT:
	push {lr}

	ldr r0,=anim_cont @ Se pone una tolerancia, que es el numero de veces que tiene que ingresar a la subrutina para dibujar la siguiente imagen
	ldr r0,[r0]
	ldr r1,=tolerance
	ldr r1,[r1]
	cmp r0, r1
	addne r0, #1
	ldrne r1, =anim_cont
	strne r0, [r1]
	bne draw_instr2_NOT
	ldr r0,=anim_turn @ Se revisa que imagen de la animacion toca
	ldr r0,[r0]
	cmp r0, #0
	beq draw_instr_anim1_NOT
	cmp r0, #1
	beq draw_instr_anim2_NOT

	@ Se cambia el numero de la animacion que toca despues
	draw_instr_anim1_NOT:
		mov r0, #1
		ldr r1, =anim_turn
		str r0, [r1]
		b changeAnim_NOT
	@ Se cambia el numero de la animacion que toca despues
	draw_instr_anim2_NOT:
		mov r0, #0
		ldr r1, =anim_turn
		str r0, [r1]
		b changeAnim_NOT
	@ Se reinicia el contador para revisar la tolerancia
	changeAnim_NOT:
		ldr r1,=anim_cont
		mov r0, #0
		str r0,[r1]
		b draw_instr2_NOT

	@ Se cargan las propiedades de la imagen para dibujarla
	draw_instr2_NOT:
		mov r1,#0 @ Aqui se dice que se empieza a dibujar en 0,0
		mov r2,#0 @ Aqui se dice que se empieza a dibujar en 0,0
		ldr r5,=anim_turn
		ldr r5,[r5]
		cmp r5,#0
		ldreq r0,=Image_Matrix_bgCompuerta @ Se carga la direccion de la matriz de colores de la imagen
		ldrne r0,=Image_Matrix_bgCompuertaColorNOT @ Se carga la direccion de la matriz de colores de la imagen
		ldr r3, =Width_bgfinalNOT @ Se carga el width de la imagen
		ldr r3, [r3]
		ldr r4, =Height_bgfinalNOT @ Se carga el height de la imagen
		ldr r4, [r4]
		str r4,[sp,#-4]!
		bl draw_image  @ Se dibuja la imagen

	pop {pc}

@@ Subrutina que dibuja las instrucciones de como leer el resultado
@@ Input:
@@ r0: opcion elegida por el usuario
.global draw_result_instr
draw_result_instr:
	push {lr}

	mov r5,r0

	@ Aqui se dice que se empieza a dibujar desde 0,0
	mov r1, #0
	mov r2, #0


	cmp r5,#3 @ Se carga la direccion de la matriz de colores
	ldrne r0, =Image_Matrix_InstructionsANDOR
	ldreq r0, =Image_Matrix_InstructionsNOT
	ldr r3, =Width_InstructionsANDOR @ Se carga el width de la imagen
	ldr r3, [r3]
	ldr r4, =Height_InstructionsANDOR @ Se carga el height de la imagen
	ldr r4, [r4]
	str r4, [sp, #-4]!
	bl draw_image @ Se dibuja la imagen

	pop {pc}

@ Input:
@ r0: gpio de lectura 1
@ r1: gpio de lectura 2
@ r2: gpio de salida
@ r3: direccion del vector de resultado segun el componente
.global checkAnd
checkAnd:
	push {lr}

	mov r7, r0 @@ gpio de entrada 1
	mov r8, r1 @@ gpio de entrada 2
	mov r9, r2 @@ gpio de salida
	mov r10, r3 @@ direccion del vector de resultados esperados

	dir_tabla .req r2
	dir_tablaAlt .req r3
	dir_res .req r4
	cont .req r5
	resp .req r6

	ldr dir_tabla,= tabla
	ldr dir_tablaAlt,= tablaAlt
	mov dir_res, r10

	mov cont,#0
	mov resp,#1

	loopCheckAnd:
		mov r0, r7
		ldr r1,[dir_tabla],#4
		bl SetGpio

		mov r0, r8
		ldr r1,[dir_tablaAlt],#4
		bl SetGpio

		mov r0, r9
		bl GetGpio

		ldr r1,[dir_res],#4
		cmp r0, r1
		movne resp,#0

		add cont,#1
		cmp cont,#4
		bne loopCheckAnd

	mov r0,resp

	.unreq dir_tabla
	.unreq dir_tablaAlt
	.unreq dir_res
	.unreq cont
	.unreq resp

	pop {pc}
