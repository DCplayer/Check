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

	@Se dibuja el background
	ldr r0,=bgCont
	ldr r0,[r0]
	bl draw_bg

	/*-------------LEDS---------------------*/
	@GPIO para escritura puerto 20
	mov r0,#20
	mov r1,#1
	bl SetGpioFunction

	@GPIO para escritura puerto 21
	mov r0,#21
	mov r1,#1
	bl SetGpioFunction

/*--------------------------Pines para obtencion de resultado esperado---------------------------*/


	@GPIO para lectura puerto 22
	mov r0,#22
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura puerto 18
	mov r0,#18
	mov r1,#1
	bl SetGpioFunction


	@GPIO para escritura puerto 27
	mov r0,#27
	mov r1,#1
	bl SetGpioFunction


/*----------------------------------------------------------------------------------------------------------------*/
	@ Se apaga la led verde
	mov r0, #20
	mov r1, #0
	bl SetGpio

	@ Se apaga la led roja
	mov r0, #21
	mov r1, #0
	bl SetGpio

	checkMenu:
		bl getkey

		cmp r0, #'C'
		beq rightKey

		cmp r0, #'D'
		beq leftKey

		cmp r0, #' '
		beq checkOption

		b checkMenu

		rightKey:
			ldr r0,=bgCont
			ldr r0, [r0]

			cmp r0, #1
			addeq r0, #1
			ldreq r1, =bgCont
			streq r0, [r1]
			bleq draw_bg
			beq checkMenu

			cmp r0,#2
			addeq r0, #1
			ldreq r1, =bgCont
			streq r0, [r1]
			bleq draw_bg
			b checkMenu

		leftKey:
			ldr r0,=bgCont
			ldr r0,[r0]

			cmp r0, #2
			subeq r0, #1
			ldreq r1, =bgCont
			streq r0, [r1]
			bleq draw_bg
			beq checkMenu

			cmp r0, #3
			subeq r0, #1
			ldreq r1, =bgCont
			streq r0, [r1]
			bleq draw_bg
			b checkMenu


	checkOption:
		ldr r0,=bgCont
		ldr r0,[r0]

		cmp r0, #1
		beq optionAND

		cmp r0, #2
		beq optionOR

		cmp r0, #3
		beq optionNOT

	optionAND:
			@ valores iniciales en los puertos 18 y 27 iniciales 1, 1
			mov r0, #18
			mov r1, #1
			bl SetGpio

			mov r0, #27
			mov r1, #1
			bl SetGpio

			mov r0, #22
			bl GetGpio

			cmp r0, #1
			beq optionAND2
			bne apagado

			optionAND2:

				@ valores iniciales en los puertos 18 y 27 iniciales 0, 1
				mov r0, #18
				mov r1, #0
				bl SetGpio

				mov r0, #27
				mov r1, #1
				bl SetGpio

				mov r0, #22
				bl GetGpio

				cmp r0, #0
				beq optionAND3
				bne apagado

				optionAND3:
					@ valores iniciales en los puertos 18 y 27 iniciales 1, 0
					mov r0, #18
					mov r1, #1
					bl SetGpio

					mov r0, #27
					mov r1, #0
					bl SetGpio

					mov r0, #22
					bl GetGpio

					cmp r0, #0
					beq optionAND4
					bne apagado

					optionAND4:

						@ valores iniciales en los puertos 18 y 27 iniciales 0, 0
						mov r0, #18
						mov r1, #0
						bl SetGpio

						mov r0, #27
						mov r1, #0
						bl SetGpio

						mov r0, #22
						bl GetGpio

						cmp r0, #0
						beq prendido
						bne apagado


	optionOR:
		@ valores iniciales en los puertos 18 y 27 iniciales 1, 1
		mov r0, #18
		mov r1, #1
		bl SetGpio

		mov r0, #27
		mov r1, #1
		bl SetGpio

		mov r0, #22
		bl GetGpio

		cmp r0, #1


		beq optionOR2
		bne apagado

		optionOR2:

			@ valores iniciales en los puertos 18 y 27 iniciales 0, 1
			mov r0, #18
			mov r1, #0
			bl SetGpio

			mov r0, #27
			mov r1, #1
			bl SetGpio

			mov r0, #22
			bl GetGpio

			cmp r0, #1
			beq optionOR3
			bne apagado

			optionOR3:
				@ valores iniciales en los puertos 18 y 27 iniciales 1, 0
				mov r0, #18
				mov r1, #1
				bl SetGpio

				mov r0, #27
				mov r1, #0
				bl SetGpio

				mov r0, #22
				bl GetGpio

				cmp r0, #1
				beq optionOR4
				bne apagado

				optionOR4:

					@ valores iniciales en los puertos 18 y 27 iniciales 0, 0
					mov r0, #18
					mov r1, #0
					bl SetGpio

					mov r0, #27
					mov r1, #0
					bl SetGpio

					mov r0, #22
					bl GetGpio

					cmp r0, #0
					beq prendido
					bne apagado

	optionNOT:
		mov r0, #18
		mov r1, #1
		bl SetGpioFunction

		mov r0, #27
		mov r1, #0
		bl SetGpioFunction

		mov r0, #18
		mov r1, #1
		bl SetGpio

		mov r0, #27
		bl GetGpio

		cmp r0, #0
		beq optionNOT2
		bne apagado

		optionNOT2:
			mov r0, #18
			mov r1, #0
			bl SetGpio

			mov r0, #27
			bl GetGpio

			cmp r0, #1
			beq prendido
			bne apagado

	prendido:
		mov r0, #18
		mov r1, #0
		bl SetGpio

		mov r0, #27
		mov r1, #0
		bl SetGpio

		mov r0, #20
		mov r1, #1
		bl SetGpio

		mov r0, #21
		mov r1, #0
		bl SetGpio
		b secure_exit

	apagado:
		mov r0, #18
		mov r1, #0
		bl SetGpio

		mov r0, #27
		mov r1, #0
		bl SetGpio

		mov r0, #20
		mov r1, #0
		bl SetGpio

		mov r0, #21
		mov r1, #1
		bl SetGpio
		b secure_exit


	secure_exit:
		bl secure_leave

	/* ----------------------------------------------------------------------------- */

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
	alternado: .word 1, 0, 1, 0
	otro: .word      1, 1, 0, 0

	@ ----- Variables del background -------
	bgCont: .word 2
