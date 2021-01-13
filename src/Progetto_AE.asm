# PROGETTO MIPS ASSEMBLY PER IL CORSO DI ARCHITETTURE DEGLI ELABORATORI
# - A.A. 2018/2019 -
 
# Title: Messaggi Cifrati
# Author: Gioele Dimilta - Alberto Brogi
# Email: gioele.dimilta@stud.unifi.it - alberto.brogi@stud.unifi.it
# Description: Progetto MIPS Assembly - Architetture degli Elaboratori
# Input: messaggio.txt, chiave.txt
# Output: messaggioDecifrato.txt, messaggioCifrato.txt
# Filename: BRO-DIM-Codice-sorgente.asm
# Date: 29/05/2019

# # # # # # # # # # # # # # # # # # #
#				INDICE				#
# # # # # # # # # # # # # # # # # # #
# open_f 				 - line 120 #
# read_f				 - line 132 #
# write_f				 - line 154 #
# close_f				 - line 164 #
# orc_f					 - line 172 #
# owc_f					 - line 207 #
#									#
# encrypt_and_decrypt	 - line 243 #
# choose_algorithm		 - line 296 #
#									#
# change_ascii_value	 - line 359 #
# insert_index			 - line 387 #
# insert_character		 - line 421 #
#									#
# algorithm_A			 - line 440 #
# algorithm_B			 - line 457 #
# algorithm_C			 - line 473 #
# algorithm_D			 - line 489 #
# algorithm_encrypt_E	 - line 509 #
# algorithm_decrypt_E	 - line 616 #
# # # # # # # # # # # # # # # # # # #





# # # # # # # # # # # # # # # # # # # # #
#	      	  DATA SEGMENT			    #
# # # # # # # # # # # # # # # # # # # # #
.data
size_message:		.word 0
sizes_arrays_E:		.word 0 657 2773 13010 67205

jump_table:			.word L_A, L_B, L_C, L_D, L_E

file_not_found:		.asciiz "Execution terminated with errors - File not found."
sbrk_error:			.asciiz "Execution terminated with errors - Heap allocating error."

chiave:				.asciiz "messaggi-cifrati/input/chiave.txt"
messaggio:			.asciiz	"messaggi-cifrati/input/messaggio.txt"
messaggioCifrato:	.asciiz	"messaggi-cifrati/output/messaggioCifrato.txt"
messaggioDecifrato:	.asciiz	"messaggi-cifrati/output/messaggioDecifrato.txt"



# # # # # # # # # # # # # # # # # # # # #
#	     	   CODE SEGMENT		        #
# # # # # # # # # # # # # # # # # # # # #
.text
.globl main

main:
														# # # # # # # # # # # # # #
	addi $sp, $sp, -8									#   Memorizzo il valore   #					
	sw $s0, 4($sp)										# dei registri permanenti #
	sw $ra, 0($sp)										#   e del registro $ra.   #
														# # # # # # # # # # # # # #
	
	la $a0, chiave										# $a0 = &(chiave)
	li $a1, 5											# La chiave ha un massimo di 4 caratteri ma allocando 5 bytes sono sicuro che la stringa
														# terminera' con il carattere '\0'										
	jal orc_f
	move $s0, $v1										# $s0 = key
														# $v0 = lunghezza dell'array chiave
	
	la $a0, messaggio									# $a0 = &(chiave)
	li $a1, 128											# Il messaggio ha un massimo di 128 caratteri
	jal orc_f
	sw $v0, size_message								# *size_message = $v0
														# $v1 = input_text
	
	move $a0, $v1 										# $a0 = input_text
	move $a1, $s0 										# $a1 = key
	jal encrypt_and_decrypt		
		
end_program:					
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										# Ripristino il contenuto #
	lw $s0, 4($sp)										# dei registri permanenti #
	addi $sp, $sp, 8									#   e del registro $ra.   #
														# # # # # # # # # # # # # #
	 
	li $v0, 10    	 									# L'intero 10 identifica l'operazione di chiusura del programma
    syscall
	
	
	
# # # # # # # # # # # # # # # # # # # # #
#		  		  ERRORI		        #
# # # # # # # # # # # # # # # # # # # # #	
error:
														# $a0 = Indirizzo della stringa da stampare
	li $v0, 4											# L'intero 4 identifica l'operazione di stampa su stdin di una stringa
	syscall 
	
	j end_program
	
	
	
	
	
# # # # # # # # # # # # # # # # # # # # #
#		  		  FILE			        #
# # # # # # # # # # # # # # # # # # # # #      
open_f:
														# $a0 = Indirizzo di partenza del nome del file
														# $a1 = Flag di modalita' (0 = lettura, 1 = scrittura)
	
	li $v0, 13											# L'intero 13 identifica l'operazione di apertura del file
	li $a2, 0											# Nel caso di creazione automatica di un file, $a2 contiene i permessi da attribuire a tale file
	syscall
														# $v0 = File descriptor
	la $a0, file_not_found								# $a0 = Indirizzo della stringa di errore da stampare								
	bltz $v0, error										# In caso di errore durante l'apertura del file, la syscall restituisce -1
	jr $ra

read_f:
	move $t0, $a0										# $t0 = File Descriptor	
	move $t1, $a1										# $t1 = Numero massimo di bytes da leggere dal file
	
	li 	$v0, 9											# L'intero 9 identifica l'operazione di allocazione di bytes nell'Heap
	move   	$a0, $t1									# Numero di bytes da allocare
	syscall
	
	la $a0, sbrk_error									# $a0 = Indirizzo della stringa di errore da stampare
	bltz $v0, error										# Se $v0 = -1, significa che c'e' stato un errore durante l'allocazione di memoria
	move $t2, $v0										# $t2 = Indirizzo di partenza del chunk allocato nell'Heap
	
	li	$v0, 14											# L'intero 14 identifica l'operazione di lettura da file
	move	$a0, $t0									# $a0 = File Descriptor	
	move 	$a1, $t2									# $a1 = Indirizzo di partenza del chunk allocato nell'Heap
	move	$a2, $t1									# $a2 = Numero massimo di byte da leggere dal file 
	syscall
														# $v0 = Numero di bytes effettivamente letti da file
	move $v1, $t2 										# $v1 = Indirizzo di partenza del messaggio letto dal file 
	
	jr $ra
	
write_f:
														# $a0 = File Descriptor
														# $a1 = Indirizzo di partenza del messaggio da scrivere nel file
				
	li $v0, 15											# L'intero 15 identifica l'operazione di scrittura su file
	lw $a2, size_message								# Numero di bytes da estrapolare dall'Heap e scrivere nel file		
	syscall
	
	jr $ra
  
close_f:
														# $a0 = File Descriptor
	
	li $v0, 16											# L'intero 16 identifica l'operazione di chiusura del file
	syscall
	
	jr $ra

orc_f:
	addi $sp, $sp, -16									# # # # # # # # # # # # # #
	sw $s2, 12($sp)										#   Memorizzo il valore   #
	sw $s1, 8($sp)										# dei registri permanenti #
	sw $s0, 4($sp)										#   e del registro $ra.   #
	sw $ra, 0($sp)										# # # # # # # # # # # # # #
							
														# $a0 = Indirizzo di partenza del nome del file	
	move $s0, $a1										# $a1 = Numero massimo di byte da leggere dal file		
	
	move $a1, $zero										# Flag di modalita' (0 = lettura, 1 = scrittura)
	jal open_f	
	move $s1, $v0										# Memorizzo temporaneamente il valore del File Descriptor perche' servira' piu' avanti 
														# per chiudere il file
	
	move $a0, $s1										# $a0 = File Descriptor
	move $a1, $s0										# $a1 = Numero massimo di byte da leggere dal file
	jal read_f
	move $s2, $v0										# $s2 = Numero di bytes effettivamente letti da file
	move $s0, $v1										# $s0 = Indirizzo di partenza del messaggio letto dal file
	
	move $a0, $s1										# $a0 = File Descriptor
	jal close_f
	
	move $v0, $s2										# $v0 = Numero di bytes effettivamente letti da file
	move $v1, $s0										# $v1 = Indirizzo di partenza del messaggio letto dal file
						
	lw $ra, 0($sp)										# # # # # # # # # # # # # #
	lw $s0, 4($sp)										# Ripristino il contenuto #
	lw $s1, 8($sp)										# dei registri permanenti #
	lw $s2, 12($sp)										#   e del registro $ra.   #
	addi $sp, $sp, 16									# # # # # # # # # # # # # #
	
	jr $ra
	
owc_f:
	addi $sp, $sp, -12									# # # # # # # # # # # # # #	
	sw $s1, 8($sp)										#   Memorizzo il valore   #
	sw $s0, 4($sp)										# dei registri permanenti #
	sw $ra, 0($sp)										#   e del registro $ra.   #
														# # # # # # # # # # # # # #
							
														# $a0 = Indirizzo di partenza del nome del file	
	move $s0, $a1										# $s0 = Indirizzo di partenza del messaggio memorizzato nell'Heap	
	
	li $a1, 1											# Flag di modalita' (0 = lettura, 1 = scrittura)
	jal open_f	
	move $s1, $v0										# Memorizzo temporaneamente il valore del File Descriptor perche' servira' piu' avanti per 
														# chiudere il file	

	move $a0, $s1										# $a0 = File Descriptor
	move $a1, $s0										# $a1 = Indirizzo di partenza del messaggio da scrivere nel file
	jal write_f
	
	move $a0, $s1										# $a0 = File Descriptor
	jal close_f
	
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										# Ripristino il contenuto #
	lw $s0, 4($sp)										# dei registri permanenti #
	lw $s1, 8($sp)										#   e del registro $ra.   #
	addi $sp, $sp, 12									# # # # # # # # # # # # # #					
	
	jr $ra

	
	
	
# # # # # # # # # # # # # # # # # # # # #
#				 GESTIONE  		        #
# # # # # # # # # # # # # # # # # # # # #
encrypt_and_decrypt:
	addi $sp, $sp, -20									# # # # # # # # # # # # # #
	sw $s3, 16($sp)										#			  			  #
	sw $s2, 12($sp)										#   Memorizzo il valore   #
	sw $s1, 8($sp)										# dei registri permanenti #
	sw $s0, 4($sp)										#   e del registro $ra.   #
	sw $ra, 0($sp)										#			  			  #
														# # # # # # # # # # # # # #
				
	move $s0, $a0 										# $s0 = input_text
	move $s1, $a1 										# $s1 = key
	move $s2, $zero 									# $s2 = i
	li $s3, 1											# $s3 = increase
	
	loop__encrypt_and_decrypt:
		add $t0, $s1, $s2 								# $t0 = key + i
		lb $t1, 0($t0)									# $t0 = key[i]
		bnez $t1, else__encrypt_and_decrypt				# IF (key[i] != '\0')
		
		la $a0, messaggioCifrato						# $a0 = &(messaggioCifrato)	
		move $a1, $s0									# $a1 = input_text
		jal owc_f
		
		li $s3, -1										# increase = -1
		add $s2, $s2, $s3								# i = i + increase
		
		else__encrypt_and_decrypt:
		add $t0, $s1, $s2								# $t0 = key + i
		lb $t1, 0($t0)									# $t1 = key[i]
		
		move $a0, $s0									# $a0 = input_text
		move $a1, $s3									# $a1 = encrypt
		move $a2, $t1									# $a2 = key[i]
		jal choose_algorithm
		move $s0, $v0									# $v0 = input_text
			
		add $s2, $s2, $s3								# i = i + increase
		bgez $s2, loop__encrypt_and_decrypt				# while(i >= 0)
		
	la $a0, messaggioDecifrato							# $a0 = &(messaggioDecifrato)
	move $a1, $s0										# $a1 = input_text
	jal owc_f	
	
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										#			  			  #
	lw $s0, 4($sp)										# Ripristino il contenuto #
	lw $s1, 8($sp)										# dei registri permanenti #
	lw $s2, 12($sp)										#   e del registro $ra.   #
	lw $s3, 16($sp)										#			  			  # 
	addi $sp, $sp, 20									# # # # # # # # # # # # # #					
	
	jr $ra
        
choose_algorithm:
														# # # # # # # # # # # # # #
	addi $sp, $sp, -8									#   Memorizzo il valore   #
	sw $s0, 4($sp)										# dei registri permanenti #
	sw $ra, 0($sp)										#   e del registro $ra.   #
														# # # # # # # # # # # # # #
							
														# $a0 = input_text
														# $a1 = encrypt
														# $a2 = character
	
	blt $a2, 'A', exit_switch							# IF (character < 'A')
	bgt $a2, 'E', exit_switch							# IF (character > 'E')
	
	addi $t0, $a2, -0x41								# $t0 = character - 'A'
	sll $t0, $t0, 2										# $t0 = (character - 'A') * 4 (without overflow)
	la $t1, jump_table									# $t1 = &(jump_table)
	add $t0, $t1, $t0									# $t0 = ((character - 'A') * 4) + &(jump_table)
	lw $t1, 0($t0)										# $t1 = jump_table[(character - 'A')]
									
	move $s0, $a0										# $s0 = input_text
	jr $t1
	
	L_A:												# L_A = jump_table[0]
		jal algorithm_A
		j exit_switch
	L_B:												# L_B = jump_table[1]
		jal algorithm_B
		j exit_switch
	L_C:												# L_C = jump_table[2]
		jal algorithm_C
		j exit_switch
	L_D:												# L_D = jump_table[3]
		jal algorithm_D
		j exit_switch
	L_E:												# L_E = jump_table[4]
		bltz $a1, L_E_decrypt							# IF (encrypt < 0)
		jal algorithm_encrypt_E
		j end_L_E
		
		L_E_decrypt:
			jal algorithm_decrypt_E
			
		end_L_E:
			move $s0, $v0								# $s0 = input_text
			
	exit_switch:
	move $v0, $s0										# $v0 = input_text
	
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										# Ripristino il contenuto #
	lw $s0, 4($sp)										# dei registri permanenti #
	addi $sp, $sp, 8									#   e del registro $ra.   #
														# # # # # # # # # # # # # #
	
	jr $ra
	
	
	
	
# # # # # # # # # # # # # # # # # # # # #
#				 CALCOLO  		        #
# # # # # # # # # # # # # # # # # # # # #
change_ascii_value:
														# $a0 = input_text
														# $a1 = encrypt
														# $a2 = reminder

	lw $t0, size_message								# $t0 = *size_message
	add $t0, $a0, $t0									# end_text = input_text + *size_message
	sll $a1, $a1, 2										# encrypt = encrypt * 4
	
	loop__change_ascii_value:
		li $t1, 2										# $t1 = 2
		div $a0, $t1									# input_text / 2
		mfhi $t1 										# $t1 = input_text % 2
		
		beq $t1, $a2, true_if__change_ascii_value		# IF ((input_text % 2) == reminder)
		bne $a2, -1, end_loop__change_ascii_value		# IF (remainder != -1)
		
		true_if__change_ascii_value:
		lbu $t1, 0($a0)									# $t1 = *input_text
        	add $t1, $t1, $a1							# $t1 = $t1 + encrypt
        	sb $t1, 0($a0)								# *input_text = $t1
        	
        end_loop__change_ascii_value:
        addi $a0, $a0, 1								# input_text = input_text + 1	
        bne $a0, $t0, loop__change_ascii_value			# IF (input_text != end_text)
	
	jr $ra						
	
insert_index:
														# $a0 = &(output_text[length-1])
														# $a1 = length
														# $a2 = index
	
	move $t0, $a2										# temp = index
	move $t1, $zero 									# digits_index = 0
	
	count_digits__insert_index:
		div $t0, $t0, 10								# temp = temp / 10;		
		add $t1, $t1, 1									# digits_index = digits_index + 1
		bnez $t0, count_digits__insert_index			# WHILE (temp != 0)
		 
	add	$a0, $a0, $t1									# $a0 = &(output_text[length-1]) + digits_index = &(output_text[(length-1) + digits_index])
	move $t0, $a0										# end_text = &(output_text[(length-1) + digits_index])
	
	li 	$t2, 10											# $t2 = 10
	
	loop__insert_index:	
		div $a2, $t2									# index / 10
		mflo $a2										# index = index / 10
		mfhi $t3										# $t3 = index % 10
		
		add $t3, $t3, '0'								# $t3 = (index % 10) + '0'
		sb $t3, 0($t0)									# *output_text = (index % 10) + '0'
		
		sub $t0, $t0, 1									# end_text = end_text - 1
		bnez $a2, loop__insert_index					# WHILE (index != 0)
	
	move $v0, $a0										# $v0 = &(output_text[(length-1) + digits_index])
	add $v1, $a1, $t1 									# $v1 = length + digits_index
	
	jr $ra
							
insert_character:
														# $a0 = &(output_text[length-1])
														# $a1 = length
														# $a2 = character
	
	addi $a0, $a0, 1									# $a0 = &(output_text[(length-1) + 1]) = &(output_text[length])
	
	sb $a2, 0($a0)										# output_text[length] = character				
	addi $a1, $a1, 1									# length = length + 1			
	
	move $v0, $a0										# $v0 = output_text[length - 1]		
	move $v1, $a1										# $v1 = length		
	
	jr $ra
	
	
# # # # # # # # # # # # # # # # # # # # #
#				ALGORITMI  		        # 
# # # # # # # # # # # # # # # # # # # # #
algorithm_A:
														# # # # # # # # # # # # # #
	addi $sp, $sp, -4									#   Memorizzo il valore   #
	sw $ra, 0($sp)										#    del registro $ra.    #
														# # # # # # # # # # # # # #
							
														# $a0 = input_text
														# $a1 =	encrypt
	li $a2, -1											# $a2 = reminder		
	jal change_ascii_value
									
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										# Ripristino il contenuto #
	addi $sp, $sp, 4									#    del registro $ra.    #
														# # # # # # # # # # # # # #
        jr $ra
        	
algorithm_B:
														# # # # # # # # # # # # # #
	addi $sp, $sp, -4									#   Memorizzo il valore   #
	sw $ra, 0($sp)										#    del registro $ra.    #
														# # # # # # # # # # # # # #
							
														# $a0 = input_text
														# $a1 =	encrypt
	li $a2, 0 											# $a2 = reminder
	jal change_ascii_value
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										# Ripristino il contenuto #
	addi $sp, $sp, 4									#    del registro $ra.    #
														# # # # # # # # # # # # # #
	jr $ra
	
algorithm_C:
														# # # # # # # # # # # # # #
	addi $sp, $sp, -4									#   Memorizzo il valore   #
	sw $ra, 0($sp)										#    del registro $ra.    #
														# # # # # # # # # # # # # #
							
														# $a0 = input_text	
														# $a1 =	encrypt	
	li $a2, 1											# $a2 = reminder
	jal change_ascii_value
														# # # # # # # # # # # # # #
	lw $ra, 0($sp)										# Ripristino il contenuto #
	addi $sp, $sp, 4									#    del registro $ra.    #
														# # # # # # # # # # # # # #
	jr $ra
	
algorithm_D:
														# $a0 = input_text
	
	lw $t0, size_message 								# $t0 = *size_message
	addi $t0, $t0, -1									# $t0 = *size_message - 1
	add $t0, $a0, $t0  									# end_text = input_text + (*size_message - 1)
	
	loop__D:
		lbu $t1, 0($a0)									# temp = *input_text 
		lbu $t2, 0($t0)									# $t2 = *end_text
		
		sb $t2, 0($a0)									# *input_text = *end_text
		sb $t1, 0($t0)									# *end_text = temp
		
		addi $a0, $a0, 1								# input_text = input_text + 1
		addi $t0, $t0, -1								# end_text = end_text - 1
		blt $a0, $t0, loop__D							# IF (input_text < end_text)
		
	jr $ra
	
algorithm_encrypt_E:
	addi $sp, $sp, -24									# # # # # # # # # # # # # #
	sw $s4, 20($sp)										#			  			  #
	sw $s3, 16($sp)										#   Memorizzo il valore   #
	sw $s2, 12($sp)										# dei registri permanenti #
	sw $s1, 8($sp)										#   e del registro $ra.   #
	sw $s0, 4($sp)										#			  			  #
	sw $ra, 0($sp)										# # # # # # # # # # # # # #		
																							
														# $a0 = input_text
								
	move $s0, $a0										# $s0 = input_text					
	move $s1, $zero										# $s1 = i
	move $s2, $zero										# $s2 = j
	lw $s3, size_message 								# $s3 = *size_message	
	move $s4, $zero										# $s4 = character
	move $v1, $zero										# $v1 = length
	
	la $t0, sizes_arrays_E								# $t0 = sizes_arrays_E 
	lw $t1, 0($t0)										# $t1 = sizes_arrays_E[0]
	addi $t1, $t1, 1									# $t1 = sizes_arrays_E[0] + 1
	sll $t1, $t1, 2										# $t1 = (sizes_arrays_E[0] + 1) * 4
	add $t1, $t0, $t1									# $t1 = sizes_arrays_E + ((size_arrays_E[0] + 1) * 4) = sizes_arrays_E[size_arrays_E[0] + 1]
	lw $t2, 0($t1)										# $t2 = sizes_arrays_E[size_arrays_E[0] + 1]
						
	li $v0, 9											# L'intero 9 identifica l'operazione di allocazione di bytes nell'Heap
	move $a0, $t2 										# Numero di bytes da allocare
	syscall
		
	la $a0, sbrk_error									# $a0 = Indirizzo della stringa di errore da stampare								
	bltz $v0, error										# Se $v0 = -1, significa che c'e' stato un errore durante l'allocazione di memoria									
	addi $v0, $v0, -1									# output_text = output_text - 1
	
	loop_1__encrypt_E:
		lbu $t0, 0($s0)									# $t0 = input_text[0]
		add $t1, $s0, $s2								# $t1 = &(input_text[j])
		lb $s4, 0($t1)									# character = input_text[j]
		
		beqz $s2, true_if__encrypt_E					# IF (j == 0)
		beq $s4, $t0, end_loop_1__encrypt_E				# IF (character == input_text[0])
		
		true_if__encrypt_E:					
		move $a0, $v0									# $a0 = output_text
		move $a1, $v1									# $a1 = length
		move $a2, $s4									# $a2 = character
		jal insert_character
		
		move $s1, $s2									# i = j
		
		loop_2__encrypt_E:
			add $t0, $s0, $s1							# $t0 = &(input_text[i])
			lb $t1, 0($t0)								# $t1 = input_text[i]
			bne $s4, $t1, end_loop_2__encrypt_E			# IF (character != input_text[i])
							
			move $a0, $v0								# $a0 = output_text
			move $a1, $v1								# $a1 = length	
			li $a2, '-'									# $a2 = '-'
			jal insert_character
			
			move $a0, $v0								# $a0 = output_text
			move $a1, $v1								# $a1 = length	
			move $a2, $s1								# $a2 = i
			jal insert_index
			
			lbu $t0, 0($s0)								# $t0 = input_text[0]
			add $t1, $s0, $s1							# $t1 = &(input_text[i])
			sb $t0, 0($t1)								# input_text[i] = input_text[0]
			
		end_loop_2__encrypt_E:
			addi $s1, $s1, 1							# i = i + 1
			blt $s1, $s3, loop_2__encrypt_E				# IF (i < *size_message)
						
			move $a0, $v0								# $a0 = output_text
			move $a1, $v1								# $a1 = length
			li $a2, ' '									# $a2 = '-'
			jal insert_character
			
	end_loop_1__encrypt_E:
		addi $s2, $s2, 1								# j = j + 1
		blt $s2, $s3, loop_1__encrypt_E					# IF (j < *size_message)
		
	la $t0, sizes_arrays_E								# $t0 = size_arrays_E
	lw $t1, 0($t0)										# $t1 = size_arrays_E[0]
	add $t1, $t1, 1										# $t1 = size_arrays_E[0] + 1
	sw $t1, 0($t0)										# size_arrays_E[0] = $t1
		 
	sll $t1, $t1, 2										# $t1 = size_arrays_E[0] * 4
	add $t0, $t0, $t1									# sizes_arrays_E = sizes_arrays_E + $t1
	sw $s3, 0($t0)										# sizes_arrays_E + $t1 = size_message
		
	la $t0, size_message								# $t0 = &(size_message)					
	addi $t1, $v1, -1									# $t1 = length - 1
	sw $t1, 0($t0)										# *size_message = length - 1
						
	sub $v0, $v0, $v1									# output_text = output_text - length					
	addi $v0, $v0, 1									# output_text = output_text + 1					
							
	lw $ra, 0($sp)										# # # # # # # # # # # # # #
	lw $s0, 4($sp)										#			  			  #
	lw $s1, 8($sp)										# Ripristino il contenuto #
	lw $s2, 12($sp)										# dei registri permanenti #
	lw $s3, 16($sp)										#   e del registro $ra.   #
	lw $s4, 20($sp)										#			  			  #
	addi $sp, $sp, 24									# # # # # # # # # # # # # #
														
	jr $ra	
	
algorithm_decrypt_E:			 							
			 											# $a0 = input_text
			 							
	move $t0, $a0										# $t0 = input_text
	li $t1, 1											# $t1 = i
	lw $t2, size_message 								# $t2 = *size_message
	li $t3, 0											# $t3 = index
	
	la $t4, sizes_arrays_E								# $t4 = &(sizes_arrays_E)							  
	lw $t5, 0($t4)										# $t5 = sizes_arrays_E[0]							  
	sll $t5, $t5, 2										# $t5 = sizes_arrays_E[0] * 4							  
	add $t4, $t4, $t5									# $t4 = &(sizes_arrays_E) + (sizes_arrays_E[0] * 4)				  
	lw $t5, 0($t4)										# $t5 = sizes_arrays_E[sizes_arrays_E[0]]					  
 	
	li $v0, 9											# L'intero 9 identifica l'operazione di allocazione di bytes nell'Heap		  
	move $a0, $t5										# Numero bytes da allocare							  
	syscall															 	  
	
	la $a0, sbrk_error									# $a0 = Indirizzo della stringa di errore da stampare
	bltz $v0, error										# Se $v0 = -1, significa che c'e' stato un errore durante l'allocazione di memoria
	move $t4, $v0										# $t4 = output_text								  			
	
	lbu $t5, 0($t0)										# character = input_text[0]
	sb $t5, 0($t4)										# output_text[0] = character
	
	loop__decrypt_E:				
		add $t6, $t0, $t1								# $t6 = input_text + i
				
		addi $t7, $t6, -1								# $t7 = (input_text + i) - 1					
		lbu $t8, 0($t7)									# $t8 = input_text[i-1]
		bne $t8, ' ', else_if__decrypt_E				# IF (input_text[i-1] != ' ')
						
		addi $t7, $t6, 1								# $t7 = (input_text + i) + 1
		lbu $t8, 0($t7)									# $t8 = input_text[i+1]
		bne $t8, '-', else_if__decrypt_E				# IF (input_text[i+1] != '-')
							
		lbu $t5, 0($t6)									# $t5 = input_text[i]					
		j end_loop__decrypt_E
		
		else_if__decrypt_E:				
			lbu $t7, 0($t6)								# $t7 = input_text[i]
						
			beq $t7, ' ', if_true__decrypt_E			# IF (input_text[i] == ' ')			
			bne $t7, '-', else__decrypt_E				# IF (input_text[i] != '-') != 0)
			
			if_true__decrypt_E:	
			beqz $t3, end_loop__decrypt_E				# IF (index == 0)
						
			add $t7, $t4, $t3							# $t7 = output_text + index
			sb $t5, 0($t7)								# output_text[index] = character
			move $t3, $zero								# index = 0
			j end_loop__decrypt_E
			
		else__decrypt_E:					
			lbu $t7, 0($t6)								# $t7 = input_text[i]		
			addi $t7, $t7, -48 							# $t7 = input_text[i] - '0'	
			mul $t8, $t3, 10							# $t8 = index * 10		
			add $t3, $t8, $t7							# index = (index * 10) + (input_text[i] - '0')
            		
	end_loop__decrypt_E:	
		addi $t1, $t1, 1								# i = i + 1
		blt $t1, $t2, loop__decrypt_E					# IF (i < *size_message)
		
	add $t0, $t4, $t3									# $t0 = output_text + index
	sb $t5, 0($t0)										# output_text[index] = character;
		
	la $t0, sizes_arrays_E								# $t0 = &(size_message)
	lw $t1, 0($t0)										# $t1 = size_message[0]
	sll $t2, $t1, 2										# $t2 = size_message[0] * 4
	add $t2, $t0, $t2									# $t2 = size_message + (size_message[0] * 4)
	lw $t3, 0($t2)										# $t3 = sizes_arrays_E[sizes_arrays_E[0]]
	sw $t3, size_message								# size_message = sizes_arrays_E[sizes_arrays_E[0]]
	
	addi $t1, $t1, -1									# $t1 = sizes_arrays_E[0] - 1;
	sw $t1, 0($t0)										# sizes_arrays_E[0] = sizes_arrays_E[0] - 1
	
	move $v0, $t4										# $v0 = output_text
	
	jr $ra
	
