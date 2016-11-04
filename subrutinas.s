/* ********************************************************************************************************************************** 
   subrutinas.s

      Por: Diego Castaneda,   Carnet: 15151
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

.global AndOrSetting
AndOrSetting:

/*--------------------------Pines para obtencion de resultado esperado---------------------------*/
	@GPIO para lectura puerto 04
	mov r0,#4
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}

	@GPIO para lectura puerto 13
	mov r0,#13
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 22
	mov r0,#22
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 18
	mov r0,#18
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	

/*--------------------------Pines de escritura ---------------------------*/
	@GPIO para escritura puerto 02
	mov r0,#2
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 03
	mov r0,#3
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 05
	mov r0,#5
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 06
	mov r0,#6
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 17
	mov r0,#17
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 27
	mov r0,#27
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 14
	mov r0,#14
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 15
	mov r0,#15
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
.global NotSetting
NotSetting:

/*--------------------------Pines para obtencion de resultado esperado---------------------------*/
	@GPIO para lectura puerto 03
	mov r0,#3
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 05
	mov r0,#5
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 13
	mov r0,#13
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 27
	mov r0,#27
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 14
	mov r0,#14
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para lectura puerto 18
	mov r0,#18
	mov r1,#0
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
/*--------------------------Pines de emision de senal---------------------------*/
	@GPIO para escritura puerto 02
	mov r0,#2
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 04
	mov r0,#4
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 06
	mov r0,#6
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 17
	mov r0,#17
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 22
	mov r0,#22
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	
	@GPIO para escritura puerto 15
	mov r0,#15
	mov r1,#1
	push {lr}
	bl SetGpioFunction}
	pop {lr}
	

