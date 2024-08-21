
# Author: Alice Vo
# Date: 11/28/23
# Description: PacSnake is a simple game that involves a 2D grid where a player controls a character (the snake) 
# and interacts with various game elements. The goal is to navigate the snake within the boundaries, 
# avoid collisions with obstacles (walls, ghosts, the snake itself), and collect food to increase the score. 
# The game features user input to control the snake's movement and ends when the player reaches a game-over condition.


.data
# colors for bitmap display
red: .word 0x00FF0000

green: .word 0x0000FF00

blue: .word 0x000000FF

cyan: .word 0x0000FFFF

magenta: .word 0x00FF00FF

black: .word 0x00000000

yellow: .word 0x00FFFF00

white: .word 0x00FFFFFF

orange: .word 0x00FFA500

snakeBodyX: .space 400				# 100 spaces for snakeBodyX and snakeBodyY
snakeBodyY: .space 400

snakeX: .word 0 				# Define variables (snakeX, snakeY, foodX, foodY, score, gameOverFlag, etc.)
snakeY: .word 0
foodX:  .word 8
foodY:  .word 11
score:	.word 0
gameOverFlag: 	.word 0
direction:	.word 0 			
MAX_BODY_LENGTH:	.word 100
bodyLength:	.word 0
lfsr:	.word 0x55AAFF00
n:	.word 0
isGhostVulnerable:	.word 0
vulnerabilityDuration:	.word 5000

scorePrompt:	.asciiz "Score: "
gameOverPrompt:	.asciiz "Press p to play again or press x to quit\n"
newLine:	.asciiz "\n"

ghost1x: .word 11 
ghost1y: .word 5
ghost1BitmapAddress: .word 0	 

ghost2x: .word 12
ghost2y: .word 5
ghost2BitmapAddress: .word 0

ghost3x: .word 13
ghost3y: .word 5
ghost3BitmapAddress: .word 0

ghostDx: .word	0, 0, -1, 1
ghostDy: .word	-1, 1, 0, 0
        
HEIGHT: .word 18
WIDTH: 	.word 26

map: 
	.asciiz "##########################"
        .asciiz "#                       ##"
        .asciiz "# # # ### ### # # ### # ##"
        .asciiz "# # # ###       # ### # ##"
        .asciiz "# # #     #####         ##"
        .asciiz "# # # # # #   # # # # # ##"
        .asciiz "# # # # # ## ## # # # # ##"
        .asciiz "#                       ##"
        .asciiz "# # ### # # # # # ### # ##"
        .asciiz "# # ### # # # # # ### # ##"
        .asciiz "#                       ##"
        .asciiz "# ## # ########### #######"
        .asciiz "# ## #                   #"
        .asciiz "# ## # # ########### # # #"
        .asciiz "# ## # # #           # # #"
        .asciiz "# ## # # # ########### # #"
        .asciiz "#                        #"
        .asciiz "##########################"
	

.text

main:
	jal	setupGame
	
gameLoop:
	lw 	$t0, gameOverFlag			
	beq 	$t0, $zero, gameNotOver			# if(gameOverFlag)
	j 	gameLoopEnd				# game ends
    
gameLoopEnd:
	li 	$t1, 1
	li 	$v0, 4
	la 	$a0, gameOverPrompt			# prints game over prompt, score prompt, score
	syscall
	
	li	$v0, 4
	la	$a0, scorePrompt
	syscall
	
	li	$v0, 1
	lw	$t0, score
	la	$a0, ($t0)
	syscall

	la	$a0, newLine
	li	$v0, 4
	syscall
	
whileInvalidInput:	
	lw	$t3, 0xffff0004
	bne	$t3, 90, inputIsP			# resets game if input is p or P
	sw	$zero, gameOverFlag
	j	resetGame
	
inputIsP:
	bne	$t3, 112, inputIsx					
	sw	$zero, gameOverFlag
	j	resetGame

inputIsx:
	bne	$t3, 88, inputIsX
	sw	$t1, gameOverFlag
	j	exit
	
inputIsX:
	bne	$t3, 120, whileInvalidInput
	sw	$t1, gameOverFlag
	j	exit
	
gameNotOver:
	jal	bitmapDraw
	jal	getInput
	jal 	update
	
	# $a0 = ghostx, $a1 = ghosty, $a2 = ghostx address, $a3 = ghosty address
	
	#lw	$a0, ghost2x
	#lw	$a1, ghost2y
	#la	$a2, ghost2x
	#la	$a3, ghost2y
	
	#jal	moveGhost
	
	#lw	$a0, ghost1x
	#lw	$a1, ghost1y
	#la	$a2, ghost1x
	#la	$a3, ghost1y
	
	#jal	moveGhost
	
	#lw	$a0, ghost3x
	#lw	$a1, ghost3y
	#la	$a2, ghost3x
	#la	$a3, ghost3y
	
	#jal	moveGhost

	jal 	isGameOver
	lw	$v0, gameOverFlag
	bne	$v0, $zero, gameLoopEnd			# if(!gameOverFlag)
	
	lw	$t0, lfsr				# updating the seed every time the game loops
	addi	$t0, $t0, 4
	sw	$t0, lfsr
	
	li	$v0, 32					# sleep for 200 ms
	li	$a0, 200
	syscall
	
	j 	gameLoop
	
setupGame:
	li	$t0, 12
	li	$t1, 10
	
	sw	$t0, snakeX
	sw	$t1, snakeY
	
	li	$t2, 6					# foodX
	li	$t3, 12					# foodY
	li	$t4, 0					# score
	li	$t5, 0					# gameOverFlag
	li	$t6, 1					# direction
	
	sw	$t2, foodX
	sw	$t3, foodY
	sw	$t4, score
	sw	$t5, gameOverFlag
	sw	$t6, direction
	
	li	$t0, 1					# body length
	li	$t1, 11					# ghost1x
	li	$t2, 5					# ghost1y, ghost2y, ghost3y
	li	$t3, 12					# ghost2x
	li	$t4, 13					# ghost3x
	li	$t5, 0					# isGhostVulnerable
	li	$t6, 0					# vulnerabilityDuration
							
	sw	$t0, bodyLength
	sw	$t1, ghost1x
	sw	$t2, ghost1y
	sw	$t3, ghost2x
	sw	$t2, ghost2y
	sw	$t4, ghost3x
	sw	$t2, ghost3y
	sw	$t5, isGhostVulnerable	
	sw	$t6, vulnerabilityDuration
	
	li	$v0, 4
	la	$a0, scorePrompt
	syscall
	
	li	$v0, 1
	lw	$t0, score				# print score
	la	$a0, ($t0)
	syscall

	la	$a0, newLine
	li	$v0, 4
	syscall
	
	jr	$ra
	
resetGame:
	jal	setupGame
	j	gameLoop

update:
	lw	$t0, direction
	li	$t1, 0
	li	$t2, 1
	li	$t3, 2
	li	$t4, 3
	
goUp:
	bne	$t0, $t1, goLeft			# if(direction = 0)
	lw	$t5, snakeY				# snakeY++
	subi	$t5, $t5, 1
	sw	$t5, snakeY
	j	updateBody
	
goLeft:							
	bne	$t0, $t2, goDown			# if(direction = 1)
	lw	$t5, snakeX				# snakeX--
	subi	$t5, $t5, 1
	sw	$t5, snakeX
	j	updateBody

goDown:
	bne	$t0, $t3, goRight			# if(direction = 2)
	lw	$t5, snakeY				# snakeY--
	addi	$t5, $t5, 1
	sw	$t5, snakeY
	j	updateBody

goRight:
	bne	$t0, $t4, updateBody			# if(direction = 3)
	lw	$t5, snakeX				# snakeX++
	addi	$t5, $t5, 1
	sw	$t5, snakeX
	j	updateBody
    
updateBody:						
	lw	$s0, bodyLength				
	la	$s1, snakeBodyX
	la	$s2, snakeBodyY
	
bodyFor:						# for (int i = bodyLength; i > 0; i--)
	ble	$s0, $zero, updateHead			# if(i > 0)
	li	$s3, 4
	mul	$s4, $s0, $s3				# offset for i
	subi	$s5, $s4, 4				# offset for i - 1
	
	add	$s6, $s1, $s4				# body[i].x address
	add	$s7, $s2, $s4				# body[i].y address

	add	$t4, $s1, $s5				# body[i-1].x address
	add	$t5, $s2, $s5				# body[i-1].y address
	lw	$t0, 0($t4)
	lw	$t1, 0($t5)
	
	sw	$t0, 0($s6)				# body[i] = body[i - 1]
	sw	$t1, 0($s7)				
	
    	subi	$s0, $s0, 1
    	j	bodyFor
    	
updateHead:			
	lw	$t1, snakeX
	lw	$t2, snakeY
	
	la	$t3, snakeBodyX
	la	$t4, snakeBodyY
	
	lw	$t5, bodyLength
	
	ble	$t5, $zero, snakeEatsFood		# if (bodyLength > 0) 
	
	sw	$t1, 0($t3)
	sw	$t2, 0($t4)

snakeEatsFood:
	lw	$t0, snakeY
	lw	$t1, snakeX
	lw	$t2, foodX
	lw	$t3, foodY
	
	bne	$t0, $t3, vulnerableGhost		# if (snakeX == foodX && snakeY == foodY)
	bne	$t1, $t2, vulnerableGhost
	
	lw	$t0, score
	addi	$t0, $t0, 1				# score++
	sw	$t0, score
	
	li	$t0, 1
	sw	$t0, isGhostVulnerable
	li	$t0, 10
	sw	$t0, vulnerabilityDuration
	
	addi	$sp, $sp, -4				# save ra to stack
	sw	$ra, 0($sp)		
							
	jal	newFood					# generate new food coords
	
	lw	$ra, 0($sp)				# loads ra from stack
	addi	$sp, $sp, 4
	
	li	$v0, 4
	la	$a0, scorePrompt
	syscall
	
	li	$v0, 1
	lw	$t0, score				# print score after eating
	la	$a0, ($t0)
	syscall

	la	$a0, newLine
	li	$v0, 4
	syscall
	
	lw	$a0, bodyLength
	lw	$a1, MAX_BODY_LENGTH
	bge	$a0, $a1, vulnerableGhost		# if (bodyLength < MAX_BODY_LENGTH)
	addi	$a0, $a0, 1				# bodyLength++
	
	sw	$a0, bodyLength
	
vulnerableGhost:					
	lw	$t0, isGhostVulnerable
	beq	$t0, $zero, snakeEatsGhost		# if (isGhostVulnerable != 0)
	
	lw	$t1, vulnerabilityDuration
	
	bgt	$t1, $zero, updateVulnerability		# if (vulnerabilityDuration <= 0)
	li	$t0, 0	
	sw	$t0, isGhostVulnerable			# isGhostVulnerable = 0
	li	$t2, 20				
	sw	$t2, vulnerabilityDuration		# vulnerabilityDuration = 10
							# resets vulnerability and duration
	j	snakeEatsGhost
		
updateVulnerability:	
	lw	$t1, vulnerabilityDuration
	subi	$t1, $t1, 1				# vulnerabilityDuration -= 1
	sw	$t1, vulnerabilityDuration
	
	j	snakeEatsGhost

snakeEatsGhost:
	lw	$t0, snakeY
	lw	$t1, snakeX

	lw	$t2, isGhostVulnerable
	beq	$t2, $zero, afterUpdate			# if (isGhostVulnerable != 0)

eatGhost1:
	lw	$t2, ghost1y
	lw	$t3, ghost1x
	
	bne	$t0, $t2, eatGhost2			# if(snakeX == ghost1.x && snakeY == ghost1.y)
	bne	$t1, $t3, eatGhost2
	
	addi	$t2, $zero, 6				# reset ghost coordinates
	addi	$t3, $zero, 11
	
	sw	$t2, ghost1y
	sw	$t3, ghost1x
	
	lw	$t2, score				# update score
	addi	$t2, $t2, 5
	sw	$t2, score
	
	j	afterUpdate

eatGhost2:
	lw	$t2, ghost2y
	lw	$t3, ghost2x

	bne	$t0, $t2, eatGhost3			# if(snakeX == ghost2.x && snakeY == ghost2.y)
	bne	$t1, $t3, eatGhost3
	
	addi	$t2, $zero, 6				# reset ghost coordinates
	addi	$t3, $zero, 12
	
	sw	$t2, ghost2y
	sw	$t3, ghost2x
		
	lw	$t2, score				# update score
	addi	$t2, $t2, 5
	sw	$t2, score
	
	j	afterUpdate

eatGhost3:
	lw	$t2, ghost3y
	lw	$t3, ghost3x
	
	bne	$t0, $t2, afterUpdate			# if(snakeX == ghost1.x && snakeY == ghost1.y)
	bne	$t1, $t3, afterUpdate
	
	addi	$t2, $zero, 6				# reset ghost coordinates
	addi	$t3, $zero, 13
	
	sw	$t2, ghost3y
	sw	$t3, ghost3x
		
	lw	$t2, score				# update score
	addi	$t2, $t2, 5
	sw	$t2, score
	
	j	afterUpdate
	
afterUpdate:
	jr	$ra


getInput:
	lw	$t4, 0xffff0004
	lw	$t5, direction
	
	li 	$t6, 0					# up
	li 	$t7, 1					# left
	li 	$t8, 2					# down
	li 	$t9, 3					# right
	
	beq 	$t4, 119, up				# if input = w
	beq 	$t4, 97, left				# if input = a
	beq 	$t4, 115, down				# if input = s
	beq 	$t4, 100, right				# if input = d
	beq	$t4, 0, left				# starts left
	
input_after:	
	jr	$ra

up:	
	beq	$t5, $t8, input_after			# if (direction != DOWN)
	li	$t0, 0
	sw 	$t0, direction				# direction = up
	j 	input_after	
left:	
	beq	$t5, $t9, input_after			# if (direction != RIGHT)
	li	$t0, 1					# direction = left
	sw 	$t0, direction		
	j 	input_after
down: 	
	beq	$t5, $t6, input_after			# if (direction != UP)
	li	$t0, 2					# direction = down
	sw 	$t0, direction
	j 	input_after
right: 	
	beq	$t5, $t7, input_after			# if (direction != LEFT)
	li	$t0, 3					# direction = right
	sw 	$t0, direction
	j	input_after
	

isGameOver:
	lw 	$t0, snakeX
	lw	$t1, snakeY
	li	$t2, 24					# width - 2
	li	$t3, 16					# height - 2
	li	$t8, 1					
	li	$t9, 1
		
	slt 	$t4, $t0, $t8				# snakeX < 1
	slt	$t5, $t2, $t0				# snakeX > 24
	slt	$t6, $t1, $t9				# snakeY < 1
	slt	$t7, $t3, $t1				# snakeY > 17
	
	or	$t4, $t4, $t5				# if(snakeX < 1 || snakeX > WIDTH - 2|| snakeY < 2 || snakeY > HEIGHT - 2)
	or	$t4, $t4, $t6				
	or	$t4, $t4, $t7
	
	bne	$t4, $zero, yesGameOver			# game over if snake goes out of bounds
	
	li	$t2, 1					# i counter
	lw	$t3, bodyLength
	
checkBodyCollision:
	bge	$t2, $t3, ifNotVulnerable
	
	lw	$t0, snakeX
	lw	$t1, snakeY
	la	$t4, snakeBodyX
	la	$t5, snakeBodyY
	
	li	$t6, 4
	mul	$t7, $t2, $t6				# offset i * 4
	add	$t8, $t4, $t7				# body[i].x address
	add	$t9, $t5, $t7				# body[i].y address
	
	lw	$t6, 0($t8)				# body[i].x value
	lw	$t7, 0($t9)				# body[i].y value
	
	bne	$t0, $t6, afterCheckBodyCollision	# if (snakeX == body[i].x && snakeY == body[i].y)
	bne	$t1, $t7, afterCheckBodyCollision
	j	yesGameOver				
	
afterCheckBodyCollision:
	addi	$t2, $t2, 1
	j	checkBodyCollision
	
ifNotVulnerable:
	lw	$t5, isGhostVulnerable
	beq	$t5, $zero, ghost1Collision		# if(!isGhostVulnerable)
	jr	$ra					# else return

ghost1Collision:
	lw	$t2, ghost1x
	lw	$t3, ghost1y
	bne	$t0, $t2, ghost2Collision		# if(snakeX == ghost1.x && snakeY == ghost1.y)
	bne	$t1, $t3, ghost2Collision		# when snake eats ghost1
	j	yesGameOver
	
ghost2Collision:
	lw	$t2, ghost2x
	lw	$t3, ghost2y
	bne	$t0, $t2, ghost3Collision		# if(snakeX == ghost2.x && snakeY == ghost2.y)
	bne	$t1, $t3, ghost3Collision		# when snake eats ghost2
	j	yesGameOver

ghost3Collision:
	lw	$t2, ghost3x
	lw	$t3, ghost3y
	bne	$t0, $t2, after				# if(snakeX == ghost3.x && snakeY == ghost3.y)
	bne	$t1, $t3, after				# when snake eats ghost1
	j	yesGameOver
	
after:	li	$v0, 0					# gameOverFlag = 0
	sw	$v0, gameOverFlag
	jr	$ra					
	
yesGameOver:						# gameOverFlag = 1
	li	$v0, 1
	sw	$v0, gameOverFlag
	jr	$ra
	
gameOver:
	li	$v0, 1
	sw	$v0, gameOverFlag
	j	gameLoopEnd

exit:	
	li	$v0, 10
	syscall
	
# base address for display = 0x10008000, 256x256 display	
bitmapDraw:
	la	$t0, map				# base
	li	$t2, 0					# row counter
	lw	$t4, HEIGHT
	lw	$t5, WIDTH				# aka numcols
	
	li 	$k0, 0x10008000 			# s3 = address of first pixel					
	
bitmapRowLoop:
	bge	$t2, $t4, bitmapDrawEnd			# if(row < height)
	li	$t3, 0					# column counter

bitmapColumnLoop:
	bge	$t3, $t5, updateRow			# if(column < width)
	
	mul	$t6, $t3, 4				# column offset
	add	$s3, $k0, $t6				# base + offset
	
	lb	$t1, 0($t0)				# load current char into $t1
	
bitmapIfGhost1:						
	lw	$t6, ghost1y
	lw	$t7, ghost1x
	
	bne	$t6, $t2, bitmapIfGhost2		# if (i == ghost1.y && j == ghost1.x)
	bne	$t7, $t3, bitmapIfGhost2
	
	lw	$s0, magenta				# loads color
	sw	$s0, 0($s3)				# stores that color to the current address of the bitmap display
	sw	$s3, ghost1BitmapAddress
	
	j	bitmapAfterDraw
	
bitmapIfGhost2:						
	lw	$t6, ghost2y
	lw	$t7, ghost2x
	
	bne	$t6, $t2, bitmapIfGhost3		# if (i == ghost2.y && j == ghost2.x)
	bne	$t7, $t3, bitmapIfGhost3
	
	lw	$s0, cyan
	sw	$s0, 0($s3)
	sw	$s3, ghost2BitmapAddress

	j	bitmapAfterDraw
	
bitmapIfGhost3:						
	lw	$t6, ghost3y
	lw	$t7, ghost3x
	
	bne	$t6, $t2, bitmapIfSnakeHead		# if (i == ghost3.y && j == ghost3.x)
	bne	$t7, $t3, bitmapIfSnakeHead
	
	lw	$s0, orange
	sw	$s0, 0($s3)
	sw	$s3, ghost3BitmapAddress

	j	bitmapAfterDraw

bitmapIfSnakeHead:	
																			
	lw	$t6, snakeY
	lw	$t7, snakeX
	
	lw	$t8, ($s3)				# loads color of current address				
	lw	$t9, blue
	
	bne	$t6, $t2, bitmapIfFood			# if (i == snakeY && j == snakeX)
	bne	$t7, $t3, bitmapIfFood
	
	beq	$t8, $t9, gameOver			# compares current color to blue, ends the game when they are equal
	
	lw	$s0, green
	sw	$s0, 0($s3)				# stores color to current address
 
	j	bitmapAfterDraw

bitmapIfFood:							
	lw	$t6, foodY
	lw	$t7, foodX
	
	bne	$t6, $t2, bitmapIfBody			# if (i == foodY && j == foodX)
	bne	$t7, $t3, bitmapIfBody			
	
checkValidFood:
	lw	$t8, ($s3)				# loads the color of the current address
	lw	$t9, blue				# wall color
	
	bne	$t8, $t9, ifGhostPen			# checks if the food is not on a wall
	j	generateFood
	
ifGhostPen:
	beq	$t6, 5, checkX				# checks if y coordinates are in the ghost pen
	beq	$t6, 6, checkX
	j	foodOnBody	
				
checkX:
	beq	$t7, 11, generateFood			# checks x coordinates
	beq	$t7, 12, generateFood			# if in ghost pen generate new food coordinates
	beq	$t7, 13, generateFood
	
	j	foodOnBody
	
foodOnBody:						
	lw	$s1, bodyLength
	li	$s2, 0					# k = 0
	
checkBodyFor:
	bge	$s2, $s1, drawFood			# if(k < bodyLength)
	la	$s6, snakeBodyX
	la	$s4, snakeBodyY
	li	$s5, 4
	mul	$t7, $s2, $s5				# offset
	
	add	$t8, $s6, $t7				# body[k].x
	lw	$t8, 0($t8)
	add	$t9, $s4, $t7				# body[k].y
	lw	$t9, 0($t9)
	
	bne	$t3, $t8, afterCheckBody		# if (i == body[k].y && j == body[k].x)
	bne	$t2, $t9, afterCheckBody
	
	j	generateFood				# generates new coordinates if food spawns on a body segment
	
	
afterCheckBody:
	addi	$s2, $s2, 1
	j	checkBodyFor
	
drawFood:
	lw	$s0, yellow				# load color
	sw	$s0, 0($s3)				# store to address
	
	j	bitmapAfterDraw
	
generateFood:
	addi	$sp, $sp, -4				# save ra to stack
	sw	$ra, 0($sp)		
	
	addi	$sp, $sp, -4				# save $s3 to stack because it is used in randomNum function inside newFood function
	sw	$s3, 0($sp)
	
	jal	newFood					
	
	lw	$s3, 0($sp)				# load $s3
	addi	$sp, $sp, 4
	
	lw	$ra, 0($sp)				# load ra
	addi	$sp, $sp, 4
	
	j	bitmapIfBody
	
bitmapIfBody:						
	lw	$s1, bodyLength
	li	$s2, 0					# k = 0
	
bitmapDrawBodyFor:
	bge	$s2, $s1, bitmapIfWall			# if(k < bodyLength)
	la	$s6, snakeBodyX
	la	$s4, snakeBodyY
	li	$s5, 4
	mul	$t7, $s2, $s5				# offset
	
	add	$t8, $s6, $t7				# body[k].x
	lw	$t8, 0($t8)
	add	$t9, $s4, $t7				# body[k].y
	lw	$t9, 0($t9)
	
	
bitmapDrawBody:
	bne	$t3, $t8, afterDrawBody			# if (i == body[k].y && j == body[k].x)
	bne	$t2, $t9, afterDrawBody
	
	li	$t6, 35
	
	beq	$t1, $t6, bitmapIfWall			# if(currentChar != '#')
							
	lw	$s0, green				# draw green
	sw	$s0, 0($s3)

	j	bitmapAfterDraw
                
afterDrawBody:
	addi	$s2, $s2, 1
	j	bitmapDrawBodyFor

bitmapIfWall:							
	li	$t8, 35
	
	bne	$t1, $t8, bitmapEmpty			# if(currentChar == '#')
	
	lw	$s0, blue				# draw blue
	sw	$s0, 0($s3)
	
wallCollision:
	lw	$t6, snakeY
	lw	$t7, snakeX
	
	bne	$t6, $t2, bitmapEmpty			
	bne	$t7, $t3, bitmapEmpty	
	
	j	gameLoopEnd
	
bitmapEmpty:
	li	$t8, 32					
	bne	$t1, $t8, bitmapAfterDraw		# if(currentChar == ' ')
	
	li	$s0, 0					# draw black pixel
	sw	$s0, 0($s3)
	
	j	bitmapAfterDraw

bitmapAfterDraw:
	addi	$t3, $t3, 1				# increment map column counter
	addi	$t0, $t0, 1				# next character
	
	
	j	bitmapColumnLoop
	
updateRow:
	addi	$t0, $t0, 1				# skip null char	
	addi	$t2, $t2, 1				# increment map row counter
	
	li	$k0, 0x10008000				# base of bitmap display
	mul	$s4, $t2, 128				# offset for rows 
	add	$k0, $s4, $k0				
	
	j	bitmapRowLoop
	
bitmapDrawEnd:
		
	li	$v0, 32					# sleep for 100 ms to slow down flashing enough to see
	li	$a0, 100
	syscall
	
	lw	$t0, isGhostVulnerable
	beq	$t0, $zero, ghostNotVulnerable		# if(isGhostVulnerable)
	
	lw	$t1, white	
	lw	$t2, ghost1BitmapAddress		
	lw	$t3, ghost2BitmapAddress		
	lw	$t4, ghost3BitmapAddress
	
	sw	$t1, ($t2)				# stores white to the ghosts' bitmap addresses
	sw	$t1, ($t3)				# creates a flashing effect indicating whether the ghost is vulnerable or not
	sw	$t1, ($t4)

ghostNotVulnerable:	
	
	
	jr	$ra
	
	
isValidMove:
	# $a2 = x, $a3 = y
	addi	$sp, $sp, -4				# saving $a0 to stack
	sw	$a0, 0($sp)
	
	addi	$sp, $sp, -4				# saving $a1 to stack
	sw	$a1, 0($sp)		
	
	addi	$sp, $sp, -4				# saving $a2 to stack
	sw	$a2, 0($sp)		
	
	addi	$sp, $sp, -4				# saving $a3 to stack
	sw	$a3, 0($sp)	
	
	addi	$sp, $sp, -4				# save ra to stack
	sw	$ra, 0($sp)		
	
	lw	$a0, WIDTH
	move	$a1, $a2				# arguments for arrayAddress function map[row][col] [y][x]
	move	$a2, $a3				# $a0 = num cols $a1 = col $a2 = row, $a3 = base address of the array
	la	$a3, map
							
	jal	arrayAddress				# gets value from an array
	
	lw	$ra, 0($sp)				# loads ra from stack
	addi	$sp, $sp, 4
	
	lw	$a3, 0($sp)				# loads $a3 from stack
	addi	$sp, $sp, 4 
	
	lw	$a2, 0($sp)				# loads $a2 from stack
	addi	$sp, $sp, 4
	
	lw	$a1, 0($sp)				# loads $a1 from stack
	addi	$sp, $sp, 4
	
	lw	$a0, 0($sp)				# loads $a0 from stack
	addi	$sp, $sp, 4
	
							# address in $k1
	lb	$s6, ($k1)
	
	lw	$s0, WIDTH
	lw	$s1, HEIGHT
	sge	$s2, $a2, $zero				# if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT && pacmanMap[y][x] != '#')
	slt	$s3, $a2, $s0
	sge	$s4, $a3, $zero
	slt	$s5, $a3, $s1
	
	bne	$s6, '#', notEqual
	li	$s6, 0					# false when equal
	j	continue

notEqual:
	li	$s6, 1					# true when not equal
	
continue:
	and	$s2, $s2, $s3				
	and	$s2, $s2, $s4
	and	$s2, $s2, $s5
	and	$s2, $s2, $s6
	
	beq	$s2, $zero, notValidMove
	li	$v0, 1					# return true
	
	jr	$ra
	
notValidMove:
	li	$v0, 0					# return false
	jr	$ra


	# $a0 = ghostx, $a1 = ghosty, $a2 = ghostx address, $a3 = ghosty address
moveGhost:
	lw	$t0, isGhostVulnerable
	li	$t1, 1
	bne	$t0, $t1, ghostIsNotVulnerable		# if(isGhostVulnerable)
	lw	$t3, snakeX
	lw	$t4, snakeY
	
ghostIsVulnerable:	
	addi	$sp, $sp, -4				# saving ra to stack
	sw	$ra, 0($sp)		
							
	jal	randomNum				# generates random number
	
	lw	$ra, 0($sp)				# loads ra from stack
	addi	$sp, $sp, 4
	
	move	$t0, $s2
	
	li	$t1, 4
	
	div	$t2, $t0, $t1
	mfhi	$t2					# int awayDirection = rand() % 4
	li	$t5, 4
	mul	$t2, $t2, $t5				# offset
	
	la	$t5, ghostDx
	add	$t5, $t5, $t2				# dx[awayDirection]
	lw	$t9, ($t5)
	add	$t5, $a0, $t9				# int nx = ghost->x + dx[awayDirection]
	
	la	$t6, ghostDy
	add	$t6, $t6, $t2				# dy[awayDirection]
	lw	$t9, ($t6)
	add	$t6, $a1, $t9				# int ny = ghost->y + dy[awayDirection]
	
	
	addi	$sp, $sp, -4				# saving ra to stack
	sw	$ra, 0($sp)		
	
	addi	$sp, $sp, -4				# saving ghostx address
	sw	$a2, 0($sp)		
	
	addi	$sp, $sp, -4				# ghost y address
	sw	$a3, 0($sp)		
	
	move	$a3, $t6				# arguments for isValidMove function
	move	$a2, $t5				# a2 = x, a3 = y				
							
	jal	isValidMove				# checks if move is valid
	
	la	$a3, 0($sp)				# loads ghost y address
	addi	$sp, $sp, 4
	
	la	$a2, 0($sp)				# loads ghost x adress
	addi	$sp, $sp, 4
	
	lw	$ra, 0($sp)				# loads ra from stack
	addi	$sp, $sp, 4
	
	beq	$v0, $zero, afterMoveGhost		# if (isValidMove(nx, ny))
	
	sw	$t5, 0($a2)				# ghostx = nx
	sw	$t6, 0($a3)				# ghosty = ny
	
	j	afterMoveGhost

ghostIsNotVulnerable:
	li	$t7, 0					# counter (i)
	li	$t8, 4					# i<4
	
moveGhostLoop:
	bge	$t7, $t8, afterMoveGhost
	
	mul	$t0, $t7, $t8				# i * 4
	
	la	$t5, ghostDx
	add	$t5, $t5, $t0				# dx[i]
	lw	$t9, ($t5)
	add	$t5, $a0, $t9				# int nx = ghost->x + dx[i];
							# next horizontal position
	la	$t6, ghostDy				
	add	$t6, $t6, $t0				# dy[i]
	lw	$t9, ($t6)				
	add	$t6, $a1, $t9				# int ny = ghost->y + dy[i];
							# next vertical position	
							
	addi	$sp, $sp, -4				# saving ghostx address
	sw	$a2, 0($sp)		
	
	addi	$sp, $sp, -4				# ghost y address
	sw	$a3, 0($sp)								
	
	addi	$sp, $sp, -4				# saving ra to stack
	sw	$ra, 0($sp)
	
	move	$a2, $t5				# arguments for isValidMove($t5, $t6)
	move	$a3, $t6		
							
	jal	isValidMove				# checks if move is valid
	
	lw	$ra, 0($sp)				# loads ra from stack
	addi	$sp, $sp, 4
		
	la	$a3, 0($sp)				# loads ghost y address
	addi	$sp, $sp, 4
	
	la	$a2, 0($sp)				# loads ghost x adress
	addi	$sp, $sp, 4
	
	beq	$v0, $zero, invalidMove
	
	sub	$t0, $t5, $t3				
	abs	$t0, $t0				# abs(nx - targetX)
	
	sub	$t1, $t6, $t4				
	abs	$t1, $t1				# abs(ny - targetY)
	
	add	$t0, $t0, $t1				# int distance = abs(nx - targetX) + abs(ny - targetY);
							
	sub	$t1, $a0, $t3
	abs	$t1, $t1				# abs(ghost->x - targetX)
	
	sub	$t9, $a1, $t4
	abs	$t9, $t9				# abs(ghost->y - targetY)
	
	add	$t1, $t1, $t9				# int currentDistance = abs(ghost->x - targetX) + abs(ghost->y - targetY)					
	 
	bge	$t0, $t1, invalidMove			# if (distance < currentDistance)
	sw	$a0, 0($a2)				# ghostx = nx
	sw	$a1, 0($a3)				# ghosty = ny
	
	jr	$ra
	
invalidMove:	
	addi	$t7, $t7, 1
	j	moveGhostLoop
	
afterMoveGhost:
	jr	$ra
	
newFood:
	addi	$sp, $sp, -4				# save ra to stack
	sw	$ra, 0($sp)
			
	jal	randomNum				
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	li	$a0, 17					# height - 1
	li	$a1, 25					# width - 1
	move	$a2, $s2				
	div	$a2, $a2, $a1				# foodX = rand() % (WIDTH - 1) + 1
	mfhi	$a2
	abs	$a2, $a2
	addi	$a2, $a2, 1
	
	sw	$a2, foodX
	
	
	addi	$sp, $sp, -4				# saving ra to stack
	sw	$ra, 0($sp)
			
	jal	randomNum
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	move	$a3, $s2				
	div	$a3, $a3, $a0				# foodY = rand() % (HEIGHT - 1) + 1
	mfhi	$a3
	abs	$a3, $a3
	addi	$a3, $a3, 1

	sw	$a3, foodY
	
	jr	$ra
	
													
randomNum:						# Random Number Generator
	li	$s0, 0					# counter	
	lw	$s2, lfsr				# load lfsr into $t2
	lw	$s3, n
	
generate_num:
	beq	$s3, $zero, branch			# if n != 0, skip lfsr update
	add	$s2, $zero, $s3				# lfsr = n

branch:
	srl 	$s4, $s2, 0    				# right shift by 0 bits
	srl 	$s5, $s2, 10    			# right shift by 10 bit
	srl 	$s6, $s2, 30    			# right shift by 30 bits
	srl 	$s7, $s2, 31    			# right shift by 31 bits

	xor 	$s4, $s4, $s5   			# XOR results
	xor 	$s4, $s4, $s6
	xor 	$s4, $s4, $s7
	andi 	$s4, $s4, 1     			# extract the least significant bit

	srl 	$s5, $s2, 1     			# right shift lfsr by 1 bit
	sll 	$s4, $s4, 31    			# left shift new bit by 31 bits
	or 	$s2, $s5, $s4   			# OR with the generated bit
	
	jr 	$ra
	
# $a0 = num cols, $a1 = col $a2 = row, $a3 = base address of the array
arrayAddress:
	mul 	$k0, $a2, $a0	# $k0 = row * num cols
	add	$k0, $k0, $a1	# $k0 + col
	
	sll	$k0, $k0, 2	# $k0 * 4
	add	$k1, $k0, $a3	# base + offset
	
	jr	$ra

