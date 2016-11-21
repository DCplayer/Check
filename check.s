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
	


/*----------------------------------------------------------------------------------------------------------------*/
	@ Se apaga la led verde
	mov r0, #20
	mov r1, #0
	bl SetGpio

	@ Se apaga la led roja
	mov r0, #21
	mov r1, #0
	bl SetGpio

	
	@Se dibuja el background
	ldr r0,=bgCont
	ldr r0,[r0]
	bl draw_bg

	@ En el menu principal se revisa si el usuario presiona la flecha izquierda o derecha para moverse
	@ y dibuja el background correspondiente y se guarda la opcion elegida
	checkMenu:
		bl getkey

		cmp r0, #'C'
		beq rightKey

		cmp r0, #'D'
		beq leftKey

		cmp r0, #' '
		beq showAnimation

		b checkMenu

		@ Background a dibujar si presiona la tecla derecha, guarda la opcion actual
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

		@ Background a dibujar si presiona la tecla izquierda, guarda la opcion actual
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

	@@ Se muestran las primeras instrucciones con animacion, muestra la siguiente hasta que precione espacio
	showAnimation:
		bl getkey

		cmp r0, #' '
		beq showInstructions

		@Carga el valor de la opcion elegida y muestra las siguientes instrucciones segun eso
		ldr r0,=bgCont
		ldr r0,[r0]
		cmp r0, #3
		blne draw_instr
		cmp r0, #3
		bleq draw_instrNOT

		b showAnimation

	@@ Se muestran las instrucciones de como saber el resultado segun la opcion elegida
	showInstructions:
		ldr r0,=bgCont
		ldr r0,[r0]
		bl draw_result_instr

		b checkOption

	@@ Se revisa la opcion del usuario
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
		
		/*Set all gpio functions according to the role they play on the component */

		/*Cluster no. 1 gpio*/
		@GPIO para escritura puerto 14
		mov r0,#14
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para escritura puerto 15
		mov r0,#15
		mov r1,#1
		bl SetGpioFunction

		@GPIO para lectura puerto 18
		mov r0,#18
		mov r1,#0 
		bl SetGpioFunction

		/*Cluster no. 2 gpio*/	
		@GPIO para escritura puerto 02
		mov r0,#2
		mov r1,#1
		bl SetGpioFunction
		
		@GPIO para escritura puerto 03
		mov r0,#3
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 04
		mov r0,#4
		mov r1,#0
		bl SetGpioFunction
		
		/*Cluster no. 3 gpio*/
		@GPIO para escritura puerto 23
		mov r0,#23
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para escritura puerto 24
		mov r0,#24
		mov r1,#1
		bl SetGpioFunction
		
		@GPIO para lectura puerto 25
		mov r0,#25
		mov r1,#0 
		bl SetGpioFunction
	
		/*Cluster no. 4 gpio*/
		@GPIO para escritura puerto 10
		mov r0,#10
		mov r1,#1
		bl SetGpioFunction
		
		@GPIO para escritura puerto 09
		mov r0,#9
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 11
		mov r0,#11
		mov r1,#0
		bl SetGpioFunction
		
	/*--------------------------------------------------------------------------------*/	

	
/*Clustet No. 1*/
	And1C1: 

	mov r0, #14
	mov r1, #0
	bl SetGpio

	mov r0, #15
	mov r1, #0
	bl SetGpio

	mov r0, #18
	bl GetGpio

	mov r9, r0
	cmp r9, #0	
	beq And2C1

	cmp r9, #0
	blne apagado
	
	cmp r9, #0
	bne And1C2

	And2C1: 
		mov r0, #14
		mov r1, #1
		bl SetGpio

		mov r0, #15
		mov r1, #0
		bl SetGpio

		mov r0, #18
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		beq And3C1

		cmp r9, #0
		blne apagado
		
		cmp r9, #0
		bne And1C2

		And3C1: 
			mov r0, #14
			mov r1, #0
			bl SetGpio

			mov r0, #15
			mov r1, #1
			bl SetGpio

			mov r0, #18
			bl GetGpio

			mov r9, r0
			cmp r9, #0
			beq And4C1

			cmp r9, #0
			blne apagado
			
			cmp r9, #0
			bne And1C2

			And4C1: 
				mov r0, #14
				mov r1, #1
				bl SetGpio

				mov r0, #15
				mov r1, #1
				bl SetGpio

				mov r0, #18
				bl GetGpio

				mov r9, r0
				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado

				b And1C2
	
	/*Clustet No. 2*/
	And1C2: 

	mov r0, #2
	mov r1, #0
	bl SetGpio

	mov r0, #3
	mov r1, #0
	bl SetGpio

	mov r0, #4
	bl GetGpio

	mov r9, r0
	cmp r9, #0	
	beq And2C2

	cmp r9, #0
	blne apagado
	
	cmp r9, #0
	bne And1C3

	And2C2: 
		mov r0, #2
		mov r1, #1
		bl SetGpio

		mov r0, #3
		mov r1, #0
		bl SetGpio

		mov r0, #4
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		beq And3C2

		cmp r9, #0
		blne apagado
		
		cmp r9, #0
		bne And1C3

		And3C2: 
			mov r0, #2
			mov r1, #0
			bl SetGpio

			mov r0, #3
			mov r1, #1
			bl SetGpio

			mov r0, #4
			bl GetGpio

			mov r9, r0
			cmp r9, #0
			beq And4C2

			cmp r9, #0
			blne apagado
			
			cmp r9, #0
			bne And1C3

			And4C2: 
				mov r0, #2
				mov r1, #1
				bl SetGpio

				mov r0, #3
				mov r1, #1
				bl SetGpio

				mov r0, #4
				bl GetGpio

				mov r9, r0
				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado

				b And1C3
	
	/*Clustet No. 3*/
	And1C3: 

	mov r0, #23
	mov r1, #0
	bl SetGpio

	mov r0, #24
	mov r1, #0
	bl SetGpio

	mov r0, #25
	bl GetGpio

	mov r9, r0
	cmp r9, #0	
	beq And2C3

	cmp r9, #0
	blne apagado
	
	cmp r9, #0
	bne And1C4

	And2C3: 
		mov r0, #23
		mov r1, #1
		bl SetGpio

		mov r0, #24
		mov r1, #0
		bl SetGpio

		mov r0, #25
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		beq And3C3

		cmp r9, #0
		blne apagado
		
		cmp r9, #0
		bne And1C4

		And3C3: 
			mov r0, #23
			mov r1, #0
			bl SetGpio

			mov r0, #24
			mov r1, #1
			bl SetGpio

			mov r0, #25
			bl GetGpio

			mov r9, r0
			cmp r9, #0
			beq And4C3

			cmp r9, #0
			blne apagado
			
			cmp r9, #0
			bne And1C4

			And4C3: 
				mov r0, #23
				mov r1, #1
				bl SetGpio

				mov r0, #24
				mov r1, #1
				bl SetGpio

				mov r0, #25
				bl GetGpio

				mov r9, r0
				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado

				b And1C4
	
	/*Cluster No. 4*/
	And1C4: 

	mov r0, #10
	mov r1, #0
	bl SetGpio

	mov r0, #9
	mov r1, #0
	bl SetGpio

	mov r0, #11
	bl GetGpio

	mov r9, r0

	cmp r9, #0
	beq And2C4

	cmp r9, #0
	blne apagado

	cmp r9, #0		
	bne secure_exit

	And2C4: 
		mov r0, #10
		mov r1, #1
		bl SetGpio

		mov r0, #9
		mov r1, #0
		bl SetGpio

		mov r0, #11
		bl GetGpio

		mov r9, r0

		cmp r9, #0
		beq And3C4

		cmp r9, #0
		blne apagado
		
		cmp r9, #0
		bne secure_exit

		And3C4: 
			mov r0, #10
			mov r1, #0
			bl SetGpio

			mov r0, #9
			mov r1, #1
			bl SetGpio

			mov r0, #11
			bl GetGpio

			mov r9, r0

			cmp r9, #0
			beq And4C4

			cmp r9, #0
			blne apagado
			
			cmp r9, #0
			bne secure_exit

			And4C4: 
				mov r0, #10
				mov r1, #1
				bl SetGpio

				mov r0, #9
				mov r1, #1
				bl SetGpio

				mov r0, #11
				bl GetGpio

				mov r9, r0

				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado
				
				b secure_exit
	optionOR:

		/*Set all gpio functions according to the role they play on the component*/

		/*Cluster no. 1 gpio*/
		@GPIO para escritura puerto 14
		mov r0,#14
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para escritura puerto 15
		mov r0,#15
		mov r1,#1
		bl SetGpioFunction

		@GPIO para lectura puerto 18
		mov r0,#18
		mov r1,#0 
		bl SetGpioFunction

		/*Cluster no. 2 gpio*/	
		@GPIO para escritura puerto 02
		mov r0,#2
		mov r1,#1
		bl SetGpioFunction
		
		@GPIO para escritura puerto 03
		mov r0,#3
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 04
		mov r0,#4
		mov r1,#0
		bl SetGpioFunction
		
		/*Cluster no. 3 gpio*/
		@GPIO para escritura puerto 23
		mov r0,#23
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para escritura puerto 24
		mov r0,#24
		mov r1,#1
		bl SetGpioFunction
		
		@GPIO para lectura puerto 25
		mov r0,#25
		mov r1,#0 
		bl SetGpioFunction
	
		/*Cluster no. 4 gpio*/
		@GPIO para escritura puerto 10
		mov r0,#10
		mov r1,#1
		bl SetGpioFunction
		
		@GPIO para escritura puerto 09
		mov r0,#9
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 11
		mov r0,#11
		mov r1,#0
		bl SetGpioFunction
		
	/*--------------------------------------------------------------------------------*/	
	/*Clustet No. 1*/
	Or1C1: 

	mov r0, #14
	mov r1, #0
	bl SetGpio

	mov r0, #15
	mov r1, #0
	bl SetGpio

	mov r0, #18
	bl GetGpio

	mov r9, r0
	cmp r9, #0	
	beq Or2C1

	cmp r9, #0
	blne apagado
	
	cmp r9, #0
	bne Or1C2

	Or2C1: 
		mov r0, #14
		mov r1, #1
		bl SetGpio

		mov r0, #15
		mov r1, #0
		bl SetGpio

		mov r0, #18
		bl GetGpio

		mov r9, r0
		cmp r9, #1
		beq Or3C1

		cmp r9, #1
		blne apagado
		
		cmp r9, #1
		bne Or1C2

		Or3C1: 
			mov r0, #14
			mov r1, #0
			bl SetGpio

			mov r0, #15
			mov r1, #1
			bl SetGpio

			mov r0, #18
			bl GetGpio

			mov r9, r0
			cmp r9, #1
			beq Or4C1

			cmp r9, #1
			blne apagado
			
			cmp r9, #1
			bne Or1C2

			Or4C1: 
				mov r0, #14
				mov r1, #1
				bl SetGpio

				mov r0, #15
				mov r1, #1
				bl SetGpio

				mov r0, #18
				bl GetGpio

				mov r9, r0
				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado

				b Or1C2
	
	/*Clustet No. 2*/
	Or1C2:  

	mov r0, #2
	mov r1, #0
	bl SetGpio

	mov r0, #3
	mov r1, #0
	bl SetGpio

	mov r0, #4
	bl GetGpio

	mov r9, r0
	cmp r9, #0	
	beq Or2C2

	cmp r9, #0
	blne apagado
	
	cmp r9, #0
	bne Or1C3

	Or2C2: 
		mov r0, #2
		mov r1, #1
		bl SetGpio

		mov r0, #3
		mov r1, #0
		bl SetGpio

		mov r0, #4
		bl GetGpio

		mov r9, r0
		cmp r9, #1
		beq Or3C2

		cmp r9, #1
		blne apagado
		
		cmp r9, #1
		bne Or1C3

		Or3C2: 
			mov r0, #2
			mov r1, #0
			bl SetGpio

			mov r0, #3
			mov r1, #1
			bl SetGpio

			mov r0, #4
			bl GetGpio

			mov r9, r0
			cmp r9, #1
			beq Or4C2

			cmp r9, #1
			blne apagado
			
			cmp r9, #1
			bne Or1C3

			Or4C2: 
				mov r0, #2
				mov r1, #1
				bl SetGpio

				mov r0, #3
				mov r1, #1
				bl SetGpio

				mov r0, #4
				bl GetGpio

				mov r9, r0
				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado

				b Or1C3
	
	/*Clustet No. 3*/
	Or1C3: 

	mov r0, #23
	mov r1, #0
	bl SetGpio

	mov r0, #24
	mov r1, #0
	bl SetGpio

	mov r0, #25
	bl GetGpio

	mov r9, r0
	cmp r9, #0	
	beq Or2C3

	cmp r9, #0
	blne apagado
	
	cmp r9, #0
	bne Or1C4

	Or2C3: 
		mov r0, #23
		mov r1, #1
		bl SetGpio

		mov r0, #24
		mov r1, #0
		bl SetGpio

		mov r0, #25
		bl GetGpio

		mov r9, r0
		cmp r9, #1
		beq Or3C3

		cmp r9, #1
		blne apagado
		
		cmp r9, #1
		bne Or1C4

		Or3C3: 
			mov r0, #23
			mov r1, #0
			bl SetGpio

			mov r0, #24
			mov r1, #1
			bl SetGpio

			mov r0, #25
			bl GetGpio

			mov r9, r0
			cmp r9, #1
			beq Or4C3

			cmp r9, #1
			blne apagado
			
			cmp r9, #1
			bne Or1C4

			Or4C3: 
				mov r0, #23
				mov r1, #1
				bl SetGpio

				mov r0, #24
				mov r1, #1
				bl SetGpio

				mov r0, #25
				bl GetGpio

				mov r9, r0
				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado

				b Or1C4
	Or1C4: 

	mov r0, #10
	mov r1, #0
	bl SetGpio

	mov r0, #9
	mov r1, #0
	bl SetGpio

	mov r0, #11
	bl GetGpio

	mov r9, #0

	cmp r9, #0
	beq Or2C4

	cmp r9, #0
	blne apagado

	cmp r9, #0		
	bne secure_exit

	Or2C4: 
		mov r0, #10
		mov r1, #1
		bl SetGpio

		mov r0, #9
		mov r1, #0
		bl SetGpio

		mov r0, #11
		bl GetGpio

		mov r9, r0

		cmp r9, #1
		beq Or3C4

		cmp r9, #1
		blne apagado
		
		cmp r9, #1
		bne secure_exit

		Or3C4: 
			mov r0, #10
			mov r1, #0
			bl SetGpio

			mov r0, #9
			mov r1, #1
			bl SetGpio

			mov r0, #11
			bl GetGpio

			mov r9, r0

			cmp r9, #1
			beq Or4C4

			cmp r9, #1
			blne apagado
			
			cmp r9, #1
			bne secure_exit

			Or4C4: 
				mov r0, #10
				mov r1, #1
				bl SetGpio

				mov r0, #9
				mov r1, #1
				bl SetGpio

				mov r0, #11
				bl GetGpio

				mov r9, r0

				cmp r9, #1
				bleq prendido

				cmp r9, #1
				blne apagado
				
				b secure_exit


	optionNOT:
		
		/*Set all gpio functions according to the role they play on the */

		/*Cluster no. 1 gpio*/
		@GPIO para escritura puerto 14
		mov r0,#14
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para Lectura puerto 15
		mov r0,#15
		mov r1,#0
		bl SetGpioFunction

		/*Cluster no. 2 gpio*/
		@GPIO para escritura puerto 18
		mov r0,#18
		mov r1,#1
		bl SetGpioFunction

			
		@GPIO para lectura puerto 02
		mov r0,#2
		mov r1,#0
		bl SetGpioFunction
		
		/*Cluster no. 3 gpio*/
		@GPIO para escritura puerto 03
		mov r0,#3
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 04
		mov r0,#4
		mov r1,#0
		bl SetGpioFunction
		
		/*Cluster no. 4 gpio*/
		@GPIO para escritura puerto 23
		mov r0,#23
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 24
		mov r0,#24
		mov r1,#0
		bl SetGpioFunction
		
		/*Cluster no. 5 gpio*/
		@GPIO para escritura puerto 25
		mov r0,#25
		mov r1,#1
		bl SetGpioFunction
	
		
		@GPIO para lectura puerto 10
		mov r0,#10
		mov r1,#0
		bl SetGpioFunction
		
		/*Cluster no. 6 gpio*/
		@GPIO para escritura puerto 09
		mov r0,#9
		mov r1,#1 
		bl SetGpioFunction
	
		@GPIO para lectura puerto 11
		mov r0,#11
		mov r1,#0
		bl SetGpioFunction
		
	/*--------------------------------------------------------------------------------*/	

	/*Cluster No. 1*/

	Not1C1: 

	mov r0, #14
	mov r1, #0
	bl SetGpio

	mov r0, #15
	bl GetGpio

	mov r0, r9
	cmp r9, #1
	beq Not2C1

	cmp r9, #0 
	blne apagado

	cmp r9, #0
	bne Not1C2

	Not2C1: 
		mov r0, #14
		mov r1, #1
		bl SetGpio

		mov r0, #15
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		bleq prendido

		cmp r9, #0
		blne apagado

		b Not1C2
	
	/*Cluster No. 2*/

	Not1C2: 

	mov r0, #18
	mov r1, #0
	bl SetGpio

	mov r0, #2
	bl GetGpio

	mov r0, r9
	cmp r9, #1
	beq Not2C2

	cmp r9, #0 
	blne apagado

	cmp r9, #0
	bne Not1C3

	Not2C2: 
		mov r0, #18
		mov r1, #1
		bl SetGpio

		mov r0, #02
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		bleq prendido

		cmp r9, #0
		blne apagado

		b Not1C3

	/*Cluster No. 3*/

	Not1C3: 

	mov r0, #3
	mov r1, #0
	bl SetGpio

	mov r0, #4
	bl GetGpio

	mov r0, r9
	cmp r9, #1
	beq Not2C3

	cmp r9, #0 
	blne apagado

	cmp r9, #0
	bne Not1C4

	Not2C3: 
		mov r0, #3
		mov r1, #1
		bl SetGpio

		mov r0, #4
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		bleq prendido

		cmp r9, #0
		blne apagado

		b Not1C4

	/*Cluster No. 4*/

	Not1C4: 

	mov r0, #23
	mov r1, #0
	bl SetGpio

	mov r0, #24
	bl GetGpio

	mov r0, r9
	cmp r9, #1
	beq Not2C4

	cmp r9, #0 
	blne apagado

	cmp r9, #0
	bne Not1C5

	Not2C4: 
		mov r0, #23
		mov r1, #1
		bl SetGpio

		mov r0, #24
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		bleq prendido

		cmp r9, #0
		blne apagado

		b Not1C5

	/*Cluster No. 5*/

	Not1C5: 

	mov r0, #25
	mov r1, #0
	bl SetGpio

	mov r0, #10
	bl GetGpio

	mov r0, r9
	cmp r9, #1
	beq Not2C5

	cmp r9, #0 
	blne apagado

	cmp r9, #0
	bne Not1C6

	Not2C5: 
		mov r0, #25
		mov r1, #1
		bl SetGpio

		mov r0, #10
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		bleq prendido

		cmp r9, #0
		blne apagado

		b Not1C6

	/*Cluster No. 6*/

	Not1C6: 

	mov r0, #9
	mov r1, #0
	bl SetGpio

	mov r0, #11
	bl GetGpio

	mov r0, r9
	cmp r9, #1
	beq Not2C6

	cmp r9, #0 
	blne apagado

	cmp r9, #0
	bne secure_exit

	Not2C6: 
		mov r0, #9
		mov r1, #1
		bl SetGpio

		mov r0, #11
		bl GetGpio

		mov r9, r0
		cmp r9, #0
		bleq prendido

		cmp r9, #0
		blne apagado

		b secure_exit

	


	wait: 	
	push {lr}									@Subrutina de delay
	ldr r0, =bign	 @ big number
	ldr r0, [r0]
	sleepLoop:
	sub r0,#1
	cmp r0, #0
	bne sleepLoop @ loop delay
	pop {pc} 


	prendido: 
		push {lr}
		mov r0, #20
		mov r1, #1
		bl SetGpio
		
		mov r0, #21
		mov r1, #0
		bl SetGpio
		
		
		push {lr}
		bl wait
		pop {lr}

		mov r0, #20
		mov r1, #0
		bl SetGpio
		
		pop {pc}
	
	apagado: 

		push {lr}

		mov r0, #20 
		mov r1, #0 
		bl SetGpio
		
		mov r0, #21
		mov r1, #1
		bl SetGpio
			
		push {lr}
		bl wait
		pop {lr} 

		mov r0, #21
		mov r1, #0
		bl SetGpio
		
		

		push {lr}
		bl wait
		pop {lr} 
		
		pop {pc}

	cancelacion: 

		mov r0, #20 
		mov r1, #0 
		push {lr}
		bl SetGpio
		pop {lr}
		

		mov r0, #21
		mov r1, #0
		push {lr}
		bl SetGpio
		pop {lr}
		
		push {lr}
		bl wait
		pop {lr} 

		push {lr}
		bl wait
		pop {lr} 

		mov pc, lr 
		

	secure_exit:
		mov r0, #20
		mov r1, #0
		bl SetGpio

		mov r0, #21
		mov r1, #0
		bl SetGpio


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
	
	@ --------- Variables de animacion compuertas AND y OR ------------
	.global tolerance
	tolerance: .word 17
	.global anim_cont
	anim_cont: .word 0
	.global anim_turn
	anim_turn: .word 0

	.global tabla
	tabla: .word 1, 1, 0, 0
	.global tablaAlt
	tablaAlt: .word 1, 0, 1, 0
	.global resAnd
	resAnd: .word 1, 0, 0, 0
	.global resOr
	resOr: .word 1, 1, 1, 0
	formato: .asciz "%d"
	
	@ ----- Variables del background -------
	bgCont: .word 2
	bign: .word 180000000
