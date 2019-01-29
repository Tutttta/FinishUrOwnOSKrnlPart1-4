; �û�����
;---------------------------------------
SECTION header vstart=0 
	program_len		dd program_end ; 0x00

	code_entry		dw start ; 0x04
				dd section.code1.start ; 0x06
 
	realloc_items		dw (header_end-code1Segment)/4 ; 0x0a
	; �ض�λ��
	code1Segment		dd section.code1.start ; 0x0c
	data1Segment		dd section.data1.start ; 0x10
	stackSegment		dd section.stack.start ; 0x14
	snakeSegment		dd section.snake.start ; 0x18
	snakeDataSegment	dd section.snakeData.start ; 0x1c
header_end:


;---------------------------------------
; ̰���ߴ����
;	food		dw 0
;	dct		dw 0
;	body  times 400 dw 0
;---------------------------------------
SECTION snake align=16 vstart=0
GameStart:
	; �������ݶ�
	mov ax, [snakeDataSegment]
	mov ds, ax

	; ����es�μĴ������������Դ�λ��
	mov ax, 0xb800
	mov es, ax

	; ����
	call ClearBg

	; ����Χǽ
	call putWall
	
	; ��ʼ���߸տ�ʼ�˶��ķ��� ��ʼ��Ϊ����
	mov ax, 0x4d00
	mov [dct], ax

	mov cx, 4
	mov bl, 4
	mov bh, 3
	mov si, 4
	; ����ĳ�ʼ��(���ĺ�������)
SnakeInit:
	mov [si], bx
	add si, 2
	inc bl
	loop SnakeInit
	; si == 4 + 8 == 12
	call putSnake



	hlt

Game:
	; ��ѭ��
	jmp Game

GameEnd:
	mov ax, 0x4c00
	int 21h


putSnake:
	mov si, 4
	mov bx, [si]
	mov dl, ' '
	mov dh, 0x70
	mov cx, 3
snakeBody:
	call putChar
	add si, 2
	mov bx, [si]
	loop snakeBody

	; �ı���ɫ
	mov bx, [si]
	mov dh, 0x44
	call putChar
	ret

putWall:
	push dx
	push cx
	push bx
	mov dl, ' '
	mov dh, 0x70
	mov cx, 22
	xor bx, bx

row:
	call putChar
	add bh, 21
	call putChar
	sub bh, 21
	inc bl
	loop row

	mov cx, 20
	mov bh, 1
	xor bl, bl
col:
	call putChar
	add bl, 21
	call putChar
	sub bl, 21
	inc bh
	loop col
	
	pop bx
	pop cx
	pop dx
	ret




; ����: bl == �� bh == �У� dl == ascii dh == ����
putChar:
	push ax
	push bx
	mov al, 80
	mul bh ; ��������ax
	add bl, bl
	xor bh, bh
	add ax, bx
	add ax, ax

	push si
	mov si, ax
	mov [es:si], dl
	mov [es:si+1], dh
	mov [es:si+2], dl
	mov [es:si+3], dh
	pop si

	pop bx
	pop ax
	ret

ClearBg:
	xor ah, ah
	mov al, 3
	int 0x10
	ret
	

;---------------------------------------
; ̰�������ݶ�
SECTION snakeData align=16 vstart=0
	food		dw 0
	dct		dw 0
	body  times 400 dw 0
snakeDataEnd:
;---------------------------------------
SECTION code1 align=16 vstart=0
; ��ʾ�ַ��������
start:
	mov ax, [stackSegment]
	mov ss, ax
	mov ax, stack_pointer
	mov sp, ax

	xor ah, ah
	mov al, 3
	int 0x10
	mov ah, 0x13
	mov al, 1
	xor bh, bh
	mov bl, 0x04
	mov cx, data1_end - msg1
	mov dh, 12
	mov dl, 25
	mov bp, msg1
	push ax
	mov ax, [data1Segment]
	mov es, ax
	pop ax
	int 0x10
	push word [snakeSegment]
	push word GameStart
	retf 
	
;---------------------------------------
SECTION data1 align=16 vstart=0
; 
	msg1 db 'The game is going to start...', 0
data1_end:
;---------------------------------------
SECTION stack align=16 vstart=0
	resb 256
stack_pointer:
;---------------------------------------
SECTION tail align=16
program_end:
;---------------------------------------