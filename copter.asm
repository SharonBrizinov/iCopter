;File Name: copter.asm
;;;;;;;;;;;;;;;;;;;;;
;;;Sharon Brizinov;;;
;;;Copter v 1.0   ;;;
;;;Turrbo Asm v5.0;;;
;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100h
.data

;;;;;;;;;;;;;;;;;;Variables;;;;;;;;;;;;;;;;;;

Score 			dw 0
NamePlayer 		db 6 dup (0)
Speed 			db 0
Stage 			db 1
Color			db 9
Key 			db 0
CopterX			dw 5
CopterY 		dw 50
CopterXEnd 		dw 0
CopterYEnd 		dw 0
MiliSec 		db 0
MapX 			dw 0
MapY 			dw 0
Ten 			db 10
DrawWallsUp 		dw 0
DrawWallsDown 		dw 0
DrawWallsX 		dw 50
LoopWallsCounter 	db 0
EndGameBool		db 0

;;;;;;;;;;;;;;;;;;Messeges;;;;;;;;;;;;;;;;;;

WelcomeMsg 		db "Welcome to Copter By Sharon Brizinov $"
SpeedMsg 		db "Please Choose Speed | 1-Fast 2-Normal,3-Slow,4-Too Slow | $"
WrongInputSpeedMsg 	db "You Have Entered Wrong Speed!$"
WrongInputNameMsg 	db "You Have Entered Wrong Letter!$"
NameMsg 		db "Please Write Your Name | You have only 6 letters to write |$"
VictoryMsg 		db "Congratulations ! You Have Faild..$"
PlayerNameMsg 		db "Player Name : $"
PlayerSpeedMsg 		db "Player Speed : $"
PlayerStageMsg		db "Player Stage : $"
PlayerScoreMsg 		db "Your Score Is: $"	
PauseMsg 		db "Pause-p | Exit-Esc $"
OwnerMsg 		db "Cotper - Made By -SharonB- $"	
.code
start:
mov ax ,@data
mov ds,ax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;The Main Program;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call TextMode
	call SetUserSpeed
	call SetUserName
	call GraphicsMode
	call DrawClearCopter
	call DrawMap
	mov ah,0 ; Wait till input
	int 16h
	call Beep

MainGame:
		call StatusBar
		call DrawWallsAll
		call GetKey
		call MoveCopter
		call CheckFailCopter
		cmp EndGameBool,0
		je MainGame

EndGame:
	call TextMode
	call Beep
	call Beep
	call Beep
	call Victory
	mov ah,4ch ;end
	int 21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;End of Main Program;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;Start of Main Functions;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Enter1:
;Jump one line down Function.
	mov dl,10
	call PrintASCII
	mov dl,13
	call PrintASCII
	ret

RandomNum:
;The Function Randomize number 1-89
	call GetTime
	mov MiliSec,dl ;Time For random - MiliSec
	cmp MiliSec,71
	ja RandomNum
	call WaitMiliSec
	xor ax, ax
	mov al,Milisec
	div Ten
	add MiliSec,al
	add MiliSec,ah
	ret

TextMode:
;change graphics state to Text/Normal Function.
	mov ax,2
	int 10h
	ret	

GraphicsMode:
;320*200 Grphic State Function.
	mov ax,13h
	int 10h
	ret

DrawPixel:
;Draw Pixel Function.
	mov ah,0ch
	;al - color
	mov bx,0
	;CX - x Position
	;DX - y Position
	int 10h
	ret

SetCusrorPosition:
;Set Cusror Position Function.
	mov ah,02h
	mov bh,0
	;dl-X Position
	;dh-Y Position
	int 10h
	ret

PrintMessege:
;Print Messege Function
;The user moves to DX the address of the messege (offset/lea) 
	mov ah,09h
	int 21h
	ret

PrintASCIICharWithColor:
;Print ASCII Char With Color Function.
	mov ah,0Eh 
	;al - ASCII Letter
	;bl - Color 
	int 10h
	ret

PrintASCII:
;Print ASCII on the Screen Function.
        mov ah,02h
        int 21h
        ret

InputASCII:
;Input ASCII Function.
	mov ah,01h
	int 21h
	ret

StackPushPop:
;This Function print a number.
;Put in AX what we want to push
	xor bx,bx
	mov bl,'*'
	push bx ;Check POINT - * 
StackPush:
;Divid the number and push each digit
	xor cx,cx
	div Ten   ;ah - units / al rest of the number
	mov cl,ah ;for pushing we need 16 bit
	xor ah,ah
	push cx 
	cmp al,0
	ja StackPush
StackPop:
;Pop and print each digit
	xor dx,dx
	pop dx
	cmp dl,'*'
	je EndStackPop
	add dl,30h
	call PrintASCII
	jmp StackPop
EndStackPop:
	ret

GetTime:
;Get the time function.
	mov ah,02ch
	int 21h
	ret

WaitMiliSec:
;The function stops the program for one MiliSec
	call GetTime
	mov Milisec,dl
WaitMiliSecLoop:
	call GetTime
	cmp MiliSec,dl
	je WaitMiliSecLoop
	ret

Beep:
;Beep Function.
	mov dl,07h
	call PrintASCII
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;End of Main Functions;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetUserSpeed:
;Set The Speed of the Helicopter
	mov dx,offset WelcomeMsg
	call PrintMessege
	call Enter1
	mov dx,offset SpeedMsg
	call PrintMessege
	call Enter1

	call InputASCII
	sub al,48 ;to get the real number
	mov Speed,al
	cmp Speed,1  ;The Speed Should be between 1-4 Only
	jb WrongInputSpeed
	cmp Speed,4
	ja WrongInputSpeed
	jmp EndSetUserSpeed

WrongInputSpeed:
;If the Speed is not between 1-4
	call Enter1
	mov dx,offset WrongInputSpeedMsg
	call PrintMessege
	mov ah,4ch
	int 21h
EndSetUserSpeed:
	ret

SetUserName:
;Set The Name of the Player
	call Enter1
	mov dx,offset NameMsg
	call PrintMessege
	call Enter1
	xor bx,bx
NameInputLoop:
	call InputASCII
	cmp al,65  ;The name should be Letters ONLY
	jb WrongInputName
	cmp al,122
	ja WrongInputName
	mov NamePlayer[bx],al
	inc bx
	cmp bx,6
	jb NameInputLoop
	jmp EndSetUserName
WrongInputName:
	call Enter1
	mov dx,offset WrongInputNameMsg
	call PrintMessege
	mov ah,4ch
	int 21h
EndSetUserName:
	ret

GetKey:
;Get the Key from the player
	mov Key,0
	mov ah,01 ;check if key pressed
	int 16h
	jz EndGetKey ;if no key pressed
	mov ah,00 ;get the key which pressed
	int 16h
	mov Key,ah
CheckPauseKey:
	cmp key,25 ; P - 25
	jne CheckESCKey
	call PauseGame
CheckESCKey:	
	cmp key,01 ; Esc - 25
	jne EndGetKey
	mov EndGameBool,1
EndGetKey:
	ret

PauseGame:
;Pausing the Game	
	mov key,0
	mov dl,35
	mov dh,19
	call SetCusrorPosition 

	mov al,'P' ; P letter
	mov bl,0Eh ;Color 0E  - Yellow  / 8 Grey
	call PrintASCIICharWithColor

	mov ah,01 ;check if key pressed
	int 16h
	jz PauseGame ;if no key pressed
	mov ah,00 ;get the key which pressed
	int 16h
	mov Key,ah
	cmp key,25; P - 112

	jne PauseGame
	mov dl,35
	mov dh,19
	call SetCusrorPosition 

	mov al,'P' ; P letter
	mov bl,8d ;Color 0E  - Yellow  / 8 Grey
	call PrintASCIICharWithColor

	ret

DrawMap:
;Draw The Whole Map - Up and Down-
DrawMapUp:
	mov al,2 ; color -  Green
	mov cx,MapX
	mov dx,MapY
	call DrawPixel

	inc MapX

	cmp MapX,319
	jne DrawMapUp

	mov MapX,0
	inc MapY
	cmp MapY,6
	jne DrawMapUp

	mov MapX,0
	mov MapY,94 ; Map Down
DrawMapDown:
	mov al,2 ; color - Green
	mov cx,MapX
	mov dx,MapY
	call DrawPixel

	inc MapX
	cmp MapX,319
	jne DrawMapDown

	mov MapX,0
	inc MapY
	cmp MapY,100
	jne DrawMapDown
	ret

DrawWallsAll:
;Draw The Walls
	cmp CopterX,318
	jb EndDrawWalls

	mov color,0 ; Black
	call DrawClearCopter

	mov CopterX,0
	call Beep
DrawWalls: 
	call RandomNum
	xor ax,ax
	mov al,MiliSec
	mov DrawWallsUp,ax
	mov DrawWallsDown,ax
	add DrawWallsDown,10 ;for 10 pixels
loopWalls:
	mov al,2 ; color - Green
	mov cx,DrawWallsX    ;X
	mov dx,DrawWallsDown ;Y
	call DrawPixel

	dec DrawWallsDown
	mov ax,DrawWallsUp
	cmp DrawWallsDown,ax
	jne loopWalls

	inc LoopWallsCounter
	inc DrawWallsX 	     ;add 1 for 2 walls
	add DrawWallsDown,10

	cmp LoopWallsCounter,1
	je loopWalls	

	call WaitMilisec
	dec DrawWallsX
	mov LoopWallsCounter,0
	add DrawWallsX,50
	cmp DrawWallsX,300
	jb DrawWalls

	inc Stage
EndDrawWalls:
	mov DrawWallsX,50
	ret

SpeedCopter:
;Slow down the Helicopter depend on the user input
	mov al,Speed
	xor ah,ah
	push ax

SpeedLoop:
	call WaitMiliSec
	dec Speed
	cmp Speed,0
	jne SpeedLoop

	pop ax
	mov Speed,al
	ret

CheckFailCopter:
;Check if the Helicopter is on wrong color - green==>FAILED
	;read pixel
	mov ah,0Dh
	mov bh,0	;320x200
	mov cx,CopterX
	mov dx,CopterY
	int 10h
	cmp al,2
	jne EndCheck
	mov EndGameBool,1
EndCheck:
	ret

MoveCopter:
;Move the Helicopter up/down
	call SpeedCopter

	mov Color,00d ;Black
	call DrawClearCopter

	cmp key,72  	;up Key in keyboard-  72
	je MoveCopterUp

	add CopterX,5   ;move copter down..
	add CopterY,4

	jmp EndMoveCopter

MoveCopterUp:
	add CopterX,3
	sub CopterY,4

EndMoveCopter:
	mov Color,09d ;Blue
	call DrawClearCopter
	ret

DrawClearCopter:
;Draw / Clear 3X3 cube. 
			
	dec CopterY		
	mov ax,CopterY

	mov CopterYEnd,ax
	add CopterYEnd,3  ;one more for the end - third row

	dec CopterX
	mov ax,CopterX

	mov CopterXEnd,ax
	add CopterXEnd,3 ;one more for the end - third row

DrawClearPixelCopter:
	call CheckFailCopter

	mov al,Color ;Clear - Black / Draw - Blue
	mov cx,CopterX
	mov dx,CopterY
	call DrawPixel

	inc CopterX
	mov ax,CopterXEnd
	cmp CopterX,ax
	jne DrawClearPixelCopter

	sub CopterX,3  
	mov ax,CopterX
	mov CopterXEnd,ax

	add CopterXEnd,3
	inc CopterY

	mov ax,CopterYEnd
	cmp CopterY,ax
	jne DrawClearPixelCopter

	inc Score
	
	add CopterX,1 ;return it to the middle
	sub CopterY,2 ;return it to the middle
	ret

StatusBar:
;Gives Information about the Player's Game In REAL Time
PrintRealTimeStage:
	mov dl,1  ;x
	mov dh,16 ;y
	call SetCusrorPosition

	mov dx,offset PlayerStageMsg
	call PrintMessege
	xor ax,ax
	mov al,Stage
	call StackPushPop
PrintRealTimeScore:
	mov dl,1  ;x
	mov dh,18 ;y
	call SetCusrorPosition
	Call PrintScore
StatusBarMesseges:
	mov dl,1  ;x
	mov dh,20 ;y
	call SetCusrorPosition
	mov dx,offset PauseMsg 
	call PrintMessege
	mov dl,1  ;x
	mov dh,22 ;y
	call SetCusrorPosition
	mov dx,offset OwnerMsg 
	call PrintMessege
	ret

;;;;;The Result at the END!;;;;;

Victory:
;Gives Information about the Player's Game at The End
	call enter1
	mov dx,offset VictoryMsg
	call PrintMessege
	call enter1
PrintName:
	mov bx,0
	mov dx,offset PlayerNameMsg
	call PrintMessege
PrintNameLoop:
	mov dl,NamePlayer[bx]
	call PrintASCII
	inc bx
	cmp bx,6
	jb PrintNameLoop
	call enter1
PrintSpeed:
	mov dx,offset PlayerSpeedMsg
	call PrintMessege
	xor ax,ax
	mov al,Speed ;Put in AX what we want to push
	call StackPushPop
	call enter1
PrintStage:
	mov dx,offset PlayerStageMsg
	call PrintMessege
	xor ax,ax
	mov al,Stage ;Put in AX what we want to push
	call StackPushPop
	call enter1
PrintScore:
	mov dx,offset PlayerScoreMsg
	call PrintMessege
	mov ax,Score ; Put in AX what we want to push
	call StackPushPop
	ret
end start