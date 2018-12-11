# NOTE: [pseudocode] ascii(n) returns the ascii character with decimal representation n
# NOTE: if you intend to customize this code while maintaining behavior, pay close attention to the ascii values checked in conditional branches
.data
  emptyInput:   .asciiz "Input is empty."
  invalidInput: .asciiz "Invalid base-33 number."
  longInput:    .asciiz "Input is too long."
  userInput:    .space  512

.text
err_empty_input:
  la $a0, emptyInput
  li $v0, 4
  syscall
  j exit

err_invalid_input:
  la $a0, invalidInput
  li $v0, 4
  syscall
  j exit

err_long_input:
  la $a0, longInput
  li $v0, 4
  syscall
  j exit

main:
  li $v0, 8
  la $a0, userInput
  li $a1, 100
  syscall

delete_left_pad:
	li $t8, 32 # space
	lb $t9, 0($a0)
	beq $t8, $t9, delete_first_char
	move $t9, $a0
	jr $ra

delete_first_char:
	addi $a0, $a0, 1
	jal delete_left_pad

input_len:
	addi $t0, $t0, 0
	addi $t1, $t1, 10
	add $t4, $t4, $a0

len_iteration:
	lb $t2, 0($a0)
	beqz $t2, after_len_found
	beq $t2, $t1, after_len_found
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	j len_iteration

after_len_found:
	beqz $t0, err_empty_input
	slti $t3, $t0, 5
	beqz $t3, err_long_input
	move $a0, $t4
	j check_str

check_str:
	lb $t5, 0($a0)
	beqz $t5, prepare_for_conversion
	beq $t5, $t1, prepare_for_conversion
	# if char < ascii(48),  input invalid,   ascii(48) = 0
		slti $t6, $t5, 48                 
		bne $t6, $zero, err_invalid_input
	# if char < ascii(58),  input is valid,  ascii(58) = 9
		slti $t6, $t5, 58                 
		bne $t6, $zero, step_char_forward
	# if char < ascii(65),  input invalid,   ascii(97) = A
		slti $t6, $t5, 65                 
		bne $t6, $zero, err_invalid_input
	# if char < ascii(88),  input is valid,  ascii(88) = X
		slti $t6, $t5, 88                 
		bne $t6, $zero, step_char_forward
	# if char < ascii(97),  input invalid,   ascii(97) = a
		slti $t6, $t5, 97                 
		bne $t6, $zero, err_invalid_input
	# if char < ascii(120), input is valid, ascii(120) = x
		slti $t6, $t5, 120                
		bne $t6, $zero, step_char_forward
	# if char > ascii(119), input invalid,  ascii(119) = w
		bgt $t5, 119, err_invalid_input   

step_char_forward:
	addi $a0, $a0, 1
	j check_str

prepare_for_conversion:
	move $a0, $t4
	addi $t7, $t7, 0
	add $s0, $s0, $t0
	addi $s0, $s0, -1	
	li $s3, 3
	li $s2, 2
	li $s1, 1
	li $s5, 0

base_convert_input:
	lb $s4, 0($a0)
	beqz $s4, print_result
	beq $s4, $t1, print_result
	slti $t6, $s4, 58
	bne $t6, $zero, base_ten_conv
	slti $t6, $s4, 88
	bne $t6, $zero, base_33_upper_conv
	slti $t6, $s4, 120
	bne $t6, $zero, base_33_lower_conv

base_ten_conv:
	addi $s4, $s4, -48
	j serialize_result

base_33_upper_conv:
	addi $s4, $s4, -55
	j serialize_result

base_33_lower_conv:
	addi $s4, $s4, -87

serialize_result:
	beq $s0, $s3, first_digit
	beq $s0, $s2, second_digit
	beq $s0, $s1, third_digit
	beq $s0, $s5, fourth_digit

first_digit:
	li $s6, 35937
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input

second_digit:
	li $s6, 1089
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input

third_digit:
	li $s6, 33
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input

fourth_digit:
	li $s6, 1
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7

print_result:
	li $v0, 1
	move $a0, $t7
	syscall

exit:
  li $v0, 10
  syscall
