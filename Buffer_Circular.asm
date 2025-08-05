.data
buffer:         .space 100        # Buffer circular de 100 bytes
buffer_size:    .word 100         # Tama�o del buffer
head:           .word 0           # Puntero de escritura
tail:           .word 0           # Puntero de lectura
time_counter:   .word 0           # Contador de tiempo (en segundos)
interval:       .word 20          # Intervalo de 20 segundos
mmio_addr:      .word 0xffff0000  # Direcci�n MMIO del teclado
header: .asciiz "\nContenido del buffer (20 segundos):\n"
newline: .asciiz "\n"

.text
.globl main

main:
    # Inicializaci�n de registros
    la $s0, buffer         # $s0 = direcci�n del buffer
    lw $s1, buffer_size    # $s1 = tama�o del buffer
    lw $s2, head           # $s2 = puntero head
    lw $s3, tail           # $s3 = puntero tail
    lw $s4, mmio_addr      # $s4 = direcci�n MMIO
    li $s5, 0              # $s5 = contador de tiempo (segundos)
    li $s6, 20             # $s6 = intervalo (20 segundos)

main_loop:
    # Esperar 50ms para no saturar la CPU
    li $v0, 32
    li $a0, 50
    syscall

    # Verificar si hay entrada de teclado
    lw $t0, 0($s4)         # Cargar registro de control
    andi $t0, $t0, 1       # Comprobar bit de ready
    beqz $t0, check_time   # Si no hay entrada, verificar tiempo

    # Leer el car�cter del teclado
    lw $t1, 4($s4)         # Leer dato del teclado

    # Almacenar en buffer circular
    add $t2, $s0, $s2      # Calcular posici�n de escritura
    sb $t1, 0($t2)         # Almacenar el car�cter

    # Actualizar head con wrap-around
    addi $s2, $s2, 1       # Incrementar head
    blt $s2, $s1, no_wrap  # Verificar si necesita wrap-around
    li $s2, 0              # Reiniciar head si alcanza el l�mite
no_wrap:
    sw $s2, head           # Actualizar head en memoria

check_time:
    # Incrementar contador de tiempo cada 1000ms (1 segundo)
    addi $s7, $s7, 50      # Acumular los 50ms de espera
    blt $s7, 1000, main_loop # Si no ha pasado 1 segundo, continuar

    addi $s5, $s5, 1       # Incrementar contador de segundos
    li $s7, 0              # Reiniciar acumulador de ms

    # Verificar si ha pasado el intervalo
    blt $s5, $s6, main_loop # Si no han pasado 20s, continuar

    # Mostrar contenido del buffer
    jal print_buffer

    # Reiniciar contadores
    li $s5, 0              # Reiniciar contador de tiempo
    j main_loop            # Repetir proceso

print_buffer:
    # Imprimir encabezado
    li $v0, 4
    la $a0, header
    syscall

print_loop:
    # Verificar si buffer est� vac�o (head == tail)
    beq $s2, $s3, end_print

    # Leer car�cter del buffer
    add $t3, $s0, $s3      # Calcular posici�n de lectura
    lb $a0, 0($t3)         # Leer el car�cter

    # Imprimir car�cter
    li $v0, 11
    syscall

    # Actualizar tail con wrap-around
    addi $s3, $s3, 1       # Incrementar tail
    blt $s3, $s1, no_wrap_tail # Verificar si necesita wrap-around
    li $s3, 0              # Reiniciar tail si alcanza el l�mite
no_wrap_tail:
    sw $s3, tail           # Actualizar tail en memoria

    j print_loop

end_print:
    # Imprimir nueva l�nea al final
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra
