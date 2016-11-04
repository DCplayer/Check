/******************************************************************************
*	Check.s
*	Programa principal del proyecto de Assembler
*	Por: Diego Castaneda,   Carnet: 15151
*   	 Alejandro Chaclan, Carnet: 15377
*        Carlos Calderon,   Carnet: 15219
*   Taller de Assembler, Seccio: 30
*******************************************************************************/

@Utilizar la biblioteca GPIO (gpio0_2.s)
@PUERTOS DE GPIO
@@-----ENTRADA-----
@ GPIO 02 = Pin 13 componente
@ GPIO 03 = Pin 12 componente
@ GPIO 04 = Pin 11 componente
@ GPIO 05 = Pin 10 componente
@ GPIO 06 = Pin 09 componente

@ GPIO 17 = Pin 01 componente
@ GPIO 27 = Pin 02 componente
@ GPIO 22 = Pin 03 componente
@ GPIO 14 = Pin 04 componente
@ GPIO 15 = Pin 05 componente

@@-------SALIDA--------

@ GPIO 03 = Pin 12 componente
@ GPIO 04 = Pin 11 componente
@ GPIO 05 = Pin 10 componente
@ GPIO 13 = Pin 08 componente
@ GPIO 27 = Pin 02 componente
@ GPIO 22 = Pin 03 componente
@ GPIO 14 = Pin 04 componente
@ GPIO 18 = Pin 06 componente

@ GPIO 20 = Pin de salida para led verde
@ GPIO 21 = Pin de salida para led rojo

/*Existen pines que no se colocaron en ambos lados y es que algunos pines no cambian de funcion a pesar */
/* que el componente haya cambiado (tomando unicamnete ANDs ORs y NOTs)*/

.text
.align 2
.global main
main:

	bl handle_ctrl_c
	mov r0, #0
	bl getScreenAddr
	ldr r1,=pixelAddr
	str r0,[r1]

 	@solo se llama una vez
	bl GetGpioAddress

	@ Configurar la consola de linux para leer el teclado
	bl enable_key_config


	/*-------------LEDS---------------------*/
	@GPIO para escritura puerto 20
	mov r0,#20
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 21
	mov r0,#21
	mov r1,#1
	bl SetGpioFunction


AndOrSetting:

/*--------------------------Pines para obtencion de resultado esperado---------------------------*/
	@GPIO para lectura puerto 04
	mov r0,#4
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 13
	mov r0,#13
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 22
	mov r0,#22
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 18
	mov r0,#18
	mov r1,#0
	bl SetGpioFunction

/*--------------------------Pines de escritura ---------------------------*/
	@GPIO para escritura puerto 02
	mov r0,#2
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 03
	mov r0,#3
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 05
	mov r0,#5
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 06
	mov r0,#6
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 17
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 27
	mov r0,#27
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 14
	mov r0,#14
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 15
	mov r0,#15
	mov r1,#1
	bl SetGpioFunction


NotSetting:

/*--------------------------Pines para obtencion de resultado esperado---------------------------*/
	@GPIO para lectura puerto 03
	mov r0,#3
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 05
	mov r0,#5
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 13
	mov r0,#13
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 27
	mov r0,#27
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 14
	mov r0,#14
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 18
	mov r0,#18
	mov r1,#0
	bl SetGpioFunction

/*--------------------------Pines de emision de senal---------------------------*/
	@GPIO para escritura puerto 02
	mov r0,#2
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 04
	mov r0,#4
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 06
	mov r0,#6
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 17
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 22
	mov r0,#22
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 15
	mov r0,#15
	mov r1,#1
	bl SetGpioFunction

	/* ----------------------------------------------------------------------------- */

	@ Se imprime el menu
	ldr r0, =texto1
	bl printf
	ldr r0, =texto2
	bl printf
	ldr r0, =texto3
	bl printf
	ldr r0, =texto4
	bl printf

	@ Se lee la respuesta del usuario
	menuOptions:
		bl getkey

		cmp r0,#'1'
		beq optionAND

		cmp r0,#'2'
		beq optionOR

		cmp r0,#'3'
		beq optionNOT

		b menuOptions

	optionAND:
		b secure_exit

	optionOR:
		b secure_exit

	optionNOT:
		b secure_exit

	secure_exit:
		ldr r0,=texto5
		bl printf
		bl secure_leave

.data
	@ -------------------------------------
	.global pixelAddr
	pixelAddr: .word 0
	.global myloc
	myloc: .word 0

	@ ----- Variables temporales de texto ---------
	texto1: .asciz "Elija una opcion:\n"
	texto2: .asciz "1. Componente AND\n"
	texto3: .asciz "2. Componente OR\n"
	texto4: .asciz "3. Componente NOT\n"
	texto5: .asciz "fin\n"
