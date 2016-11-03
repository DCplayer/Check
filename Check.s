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


	bl GetGpioAddress @solo se llama una vez

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

/*--------------------------Pines de emision de senal---------------------------*/	
	@GPIO para lectura puerto 02
	mov r0,#2
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 03
	mov r0,#3
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 05
	mov r0,#5
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 06
	mov r0,#6
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 17
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 27
	mov r0,#27
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 14
	mov r0,#14
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 15
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
	@GPIO para lectura puerto 02
	mov r0,#2
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 04
	mov r0,#4
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 06
	mov r0,#6
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 17
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 22
	mov r0,#22
	mov r1,#1
	bl SetGpioFunction	

	@GPIO para lectura puerto 15
	mov r0,#15
	mov r1,#1
	bl SetGpioFunction	

