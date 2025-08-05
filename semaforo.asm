.data
	greenT: .word 20	#tiempo que tarda en pasar de luz verde a luz amarilla
	yellowT: .word 10	#tiempo que tarda en pasar de luz amarilla a luz roja
	redT: .word 30		#tiempo que tarda en pasar de luz roja a la luz verde
	
	msjToYellow: .asciiz "\nPulsador activado: en 20 segundos, el semáforo cambiará a amarillo"
	msjToRed: .asciiz "\nSemáforo en amarillo, en 10 segundos, semáforo en rojo"
	msjToGreen: .asciiz "\nSemáforo en rojo, en 30 segundos, semáforo en verde"
	msjStart: .asciiz "\nSemáforo en verde, esperando pulsador: "
	s: .asciiz "s"
	
	pixel: .space 8 # Reservamos 8 bytes para la pantalla (2*pixeles de 32 bits)
	
.text
.globl main
main: 
	
	
	greenligth:
	li $t0,0x00FF00		#color verde
	la $t1, pixel		#direccion de la pantalla
	lw $t2, greenT		#carga el tiempo que tarda en pasar de luz verde a luz amarilla
	jal printPixel		#imprime el pixel
	
	getS:
	li $v0, 4
	la $a0,msjStart		#imprime mensaje para iniciar el semaforo
	syscall
	
	li $v0, 12		#pide tecla para iniciar
	syscall
	
	li $t4, 's'
	bne $v0,$t4,getS	#si la tecla no es valida vuelve a pedir una tacla
	
	li $v0,4
	la $a0,msjToYellow	#imprime el tiempo que necesita pasar de luz verde a luz amarilla
	syscall
	jal espera		#inicia el ciclo de espera correspondiente
	
	yellowligth:
	li $t0,0xFFFF00		#color amarillo
	la $t1, pixel		#direccion de la pantalla
	lw $t2, yellowT		#carga el tiempo que tarda en pasar de luz amarilla a luz roja
	jal printPixel		#imprime el pixel
	li $v0,4
	la $a0,msjToRed		#imprime el tiempo que necesita pasar de luz verde a luz amarilla
	syscall
	jal espera		#inicia el ciclo de espera correspondiente
	
	redligth:
	li $t0,0xFF0000		#color rojo
	la $t1, pixel		#direccion de la pantalla
	lw $t2, redT		#carga el tiempo que tarda en pasar de luz roja al inicio
	jal printPixel		#imprime el pixel
	li $v0,4
	la $a0,msjToGreen	#imprime el tiempo que necesita pasar de luz roja a luz verde
	syscall
	jal espera		#inicia el ciclo de espera correspondiente
	j greenligth		#vuelve a iniciar el ciclo con la luz verde
	
	printPixel:
	li $t3, 4		#pixeles a pintar
	
	cicloPrint:
	beqz $t3, finCicloPrint	#se acaba el ciclo si no hay pixeles que pintar
	sw $t0, 0($t1)		#guarda el color
	addi $t1,$t1,4		#mueve el puntero
	addi $t3,$t3,-1		#resta el indice
	
	finCicloPrint:
	jr $ra			#retorna al ultimo jal
	
	espera:
	li $t3, 0		#inicializa contador
	
	cicloEspera:
	addi $t3,$t3,1			#aumenta el contador
	bge $t3,$t2,finCicloEspera	#verifica que el contador haya llegado a su fin
	li $v0,32			#Pausa el programa
	li $a0,1000			#por 1 segundo (1000 milisegundos)
	syscall
	j cicloEspera			#retorna al ciclo si aun no se ha acabado
	
	finCicloEspera:
	jr $ra				#retorna al ultimo salto
	
	
	
	
