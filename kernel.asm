;-----------------------------------------------
;  GABRIEL COJOCARU & JARED MUNDY
;-----------------------------------------------
bits 32
;org 0x100
extern _init
extern _taskC
extern _playSong
extern _init_song
extern _atoi
extern _printf
extern _memset
extern _getchar
extern _drawGrid

section .text

;--------------MAIN FUNCTION-----------
; THIS FUNCTION SETS UP THE TASKS
global _main
_main:

    mov	ax, cs
	mov	ds, ax
    
    call _init
    call _init_song

    mov esi, task_main_str
    call _putstring

    ;read char
    mov ah,0
    int 0x16
    
    mov al, 3
    mov ah, 0
    int 0x10
	; main task is always active
	mov byte [task_status], 1

    mov edx, _task_a
	call _spawn_new_task

	mov edx, _task_b
	call _spawn_new_task

    mov edx, _task_c
	call _spawn_new_task

    ;mov edx, _task_d
	;call _spawn_new_task
;-------------END MAIN FUNCTION---------

;--------------MAIN FUNCTION LOOP-------
; THIS IS THE MAIN CODE THAT EXECUTES IN THE MAIN THREAD
loop_forever_main:
    ;-------- YIELD -------
        ;save cursor position

        ;move cursor to the first location of string
        mov dl, 12
        mov dh, 0
        mov bh, 0
        mov ah, 2
        int 0x10

         ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        mov esi, task1_str
        call _putstring

         ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        ;cursor for the second string
        mov dl, 52
        mov dh, 0
        mov bh, 0
        mov ah, 2
        int 0x10

         ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        mov esi, task2_str
        call _putstring

         ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        ;task 3
        mov dl, 29
        mov dh, 16
        mov bh, 0
        mov ah, 2
        int 0x10

        ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        mov esi, task3_str
        call _putstring

        ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        ;task 4
        mov dl, 34
        mov dh, 30
        mov bh, 0
        mov ah, 2
        int 0x10

         ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----

        mov esi, task4_str
        call _putstring


        pusha
        mov ah, 3
        int 0x10

         ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----
        
        ;restore cursor position
        mov ah,2
        int 0x10
        popa

        call _playSong
    ;---------END YIELD-----

	jmp loop_forever_main	
;--------------END MAIN FUNCTION LOOP-------

;-----------------YIELD IMPLEMENTATION-------
;THIS FUNCTION IMPLEMENTS THE YIELD FUNCTIONALITY
;DX CONTAINS THE ADRESS OF THE NEW TASK 
_spawn_new_task:
	; save current stack pointer
	mov ebx, stack_pointers
	add bx, [current_task]
    add bx, [current_task]
    add bx, [current_task]
	add bx, [current_task] ; add twice because we have two bytes
	mov [ebx], esp
	; switch to new stack
	mov cx, 0
	mov cl, byte[current_task]
	inc cl
sp_loop_for_available_stack:
	cmp cl, byte [current_task]
	jne sp_check_for_overflow
	jmp sp_no_available_stack
sp_check_for_overflow:
	cmp cl, 4
	jg sp_reset
	jmp sp_check_if_available
sp_reset:
	mov cl, 0
	jmp sp_loop_for_available_stack
sp_check_if_available:
	mov ebx, task_status
	add bx, cx
	cmp byte [ebx], 0
	je sp_is_available
	inc cx
	jmp sp_loop_for_available_stack
sp_is_available:
	mov ebx, task_status
	add bx, cx
	mov byte [ebx], 1
	; push a fake return address
	mov ebx, stack_pointers
	add bx,cx
    add bx,cx
    add bx,cx
	add bx, cx
	mov esp, [ebx]
	push dx
	; push registers
	pusha
	; push flags
	pushf
	; update stack pointer for task
	mov ebx, stack_pointers
    add bx,cx
    add bx,cx
	add bx, cx
	add bx, cx ; add twice because we have two bytes
	mov [ebx], esp
	; restore to original stack
sp_no_available_stack:
	mov ebx, stack_pointers
	add bx, [current_task]
	add bx, [current_task] ; add twice because we have two bytes
	mov esp, [ebx]
	ret
global _yield
_yield:
	; push registers
	pusha
	; push flags
	pushf
	; save current stack pointer
	mov ebx, stack_pointers
	add bx, [current_task]
    add bx, [current_task]
    add bx, [current_task]
	add bx, [current_task] ; add twice because we have two bytes
	mov [ebx], esp
	; switch to new stack
	mov cx, 0
	mov cl, [current_task]
	inc cl
y_check_for_overflow:
	cmp cl, 4
	jg y_reset
	jmp y_check_if_enabled
y_reset:
	mov cl, 0
	jmp y_check_for_overflow
y_check_if_enabled:
	mov ebx, task_status
	add bx, cx
	cmp byte [ebx], 1
	je y_task_available
	inc cx
	jmp y_check_for_overflow
y_task_available:
	mov bx, cx
	mov [current_task], bx
	; update stack pointer
	mov ebx, stack_pointers
	add bx, [current_task]
    add bx, [current_task]
    add bx, [current_task]
	add bx, [current_task] ; add twice because we have two bytes
	mov esp, [ebx]
	; pop flags
	popf
	; pop registers
	popa
	ret

;----------END YIELD IMPLEMENTATION-------------

;----------TASK 1: RPN CALCULATOR---------------
_task_a: 
    loop_forever_1:
                ;sets the cursor at 20,0
                mov dl,0
                mov dh, 20
                mov bh, 0
                mov ah,2
                int 0x10
                
                jmp _input

            _first_yield:
                
                ;-------- YIELD -------
                ;save cursor position
                    pusha
                    mov ah, 3
                    int 0x10

                    call _yield

                    mov ah,2
                    int 0x10
                    popa

                    jmp _input_continue
                ;---------END YIELD-----

            _input:
                ;print enter expr
                mov esi, str1
                call _putstring
               
                _input_continue:

                ;check if there is anything in the keyboard buffer
                mov ax,0
                mov ah,1
                int 0x16

                jz _first_yield

                ;get the char from keyboard
                mov ah,0
                int 0x16
                mov ah,0
                ;call _getchar
                mov [currChar], al
                
                ;print the char
                cmp al, 13
                je _end_print_input_chars
                jmp _print_input_chars

                cmp al, 10
                je _end_print_input_chars
                jmp _print_input_chars

                _print_input_chars:
             
                mov ah, 0xE
                mov cx, 1
                int 0x10
                
                _end_print_input_chars:

                ;get cursor position
                mov ah, 3
                int 0x10

                ;set cursor position
                inc dl
                mov ah,2
                int 0x10

                ;this procedure checks for '$a' input
                _variable_push_check:
                    cmp byte [currChar], '$'
                    je __cont
                    jmp _end_variable_push_check

                    __cont:
                    ;get the char from keyboard
                    mov ah,0
                    int 0x16
                    mov ah,0
                    mov [currChar], al

                    ;read char
                    mov ah, 0xA
                    mov cx, 1
                    int 0x10

                    ;get cursor position
                    mov ah, 3
                    int 0x10

                    ;set cursor position
                    inc dl
                    mov ah,2
                    int 0x10
                    ;end read char

                    sub al, 97
                    cmp al, 0
                    jge _ge1
                    jmp _end_input
                    _ge1:
                    cmp al, 25
                    jle _le1
                    jmp _end_input
                    _le1:
                    mov esi, alphabet
                    mov ah,0
                    add si, ax

                    push word [esi]

                    mov esi, nrPushed
                    add byte [esi], 1
                    
                    mov byte [justConverted], 1
                _end_variable_push_check:

                ;this procedure checks for '=a' input
                _variable_pop_check:
                    cmp byte [currChar], '='
                    je __cont1
                    jmp _end_variable_pop_check
                    __cont1:
                    mov ah,0
                    int 0x16
                    mov ah,0
                    mov [currChar], al

                    sub al, 97
                    cmp al, 0
                    jge _ge2
                    jmp _end_input
                    _ge2:
                    cmp al, 25
                    jle _le2
                    jmp _end_input
                    _le2:
                    
                    mov edx, alphabet
                    add dl, al

                    mov si, dx
                    pop word[esi]
                
                    mov esi, nrPushed
                    sub byte [esi], 1

                    mov byte [justConverted], 1
                _end_variable_pop_check:

        ;-----------------------------------------
                cmp byte[currChar], '0' ;checking if is greater than char 0
                jge _ge
                jmp _numbercomplete
                _ge:
                cmp byte[currChar], '9' ;checking if less than char 9
                jle _partofnumber ;if yes, it's part of the number
                jmp _numbercomplete

                _partofnumber:
                    mov byte[justConverted], 0
                    mov esi, inString ;add the digit to inString

                    mov edx,0
                    mov dl, byte[i]
                    add esi,edx

                    mov [esi], al
                    add byte [i], 1
                    jmp _input_continue ;jump back to reading from input

                _numbercomplete:


                     ;-------- YIELD -------
            ;save cursor position
            pusha
            mov ah, 3
            mov bh,0
            int 0x10
            pusha

            call _yield
            
            popa
            ;restore cursor position
            mov ah,2
            mov bh,0
            int 0x10
            popa
        ;---------END YIELD-----  


                    cmp byte [justConverted], 1
                    jne _c 
                    jmp _operation ;it's already been converted, must be an operation sign
                    _c:
                    mov byte [justConverted], 1
                    mov byte [i], 0 ;reset the counter to 0
                    
                    push inString
                    call _atoi
                    add esp,4 
            
                    push eax

                    add byte[nrPushed], 1
                    mov byte[i], 0 

                    push 256  ;resetting inString array to 0
                    push 0
                    push inString
                    call _memset
                    add esp, 12
                    jmp _operation

        ;-----------------------------------------
                _operation:
                    ;ADDITION
                    cmp byte [currChar], '+' ;'+'
                    je _addition
                    jmp _end_addition
                    _addition:
                        cmp byte [nrPushed], 2
                        jge _c1
                        jmp _stack_underflow
                        _c1:

                        pop eax
                        pop edx
                        add edx,eax
                        push edx

                        sub byte [nrPushed], 1
                    _end_addition:

                     


        ;-----------------------------------------
                    ;SUBTRACTION
                    cmp byte [currChar], '-'
                    je _subtraction
                    jmp _end_subtraction

                    _subtraction:
                        cmp byte [nrPushed], 2
                        jge _c2
                        jmp _stack_underflow
                        _c2:
                        mov edx,0
                        pop eax
                        pop ebx
                        sub ebx,eax
                        push ebx

                        mov esi, nrPushed
                        sub byte [si], 1
                    _end_subtraction:

                     

        ;-----------------------------------------
                    ;MULTIPLICATION;
                    cmp byte [currChar], '*'
                    je _multiplication
                    jmp _end_multiplication

                    _multiplication:
                        cmp byte [nrPushed], 2
                        jge _c3
                        jmp _stack_underflow
                        _c3:

                        pop eax
                        pop ebx
                        mov edx, 0
                        imul ebx
                        push eax

                        mov esi, nrPushed
                        sub byte [esi], 1
                    _end_multiplication:
                  

        ;-----------------------------------------
                    ;DIVISION;
                    cmp byte [currChar], '/'
                    je _division
                    jmp _end_division

                    _division:
                        cmp byte [nrPushed], 2
                        jge _c4
                        jmp _stack_underflow
                        _c4:
                        mov edx, 0
                        pop ebx
                        pop eax
                        idiv ebx
                        push eax

                        mov esi, nrPushed
                        sub byte [esi], 1
                    _end_division:
                

        ;-----------------------------------------
                    ;NEGATION;
                    cmp byte [currChar], '~'
                    je _negation
                    jmp _end_negation

                    _negation:
                        cmp byte [nrPushed], 1
                        jge _c5
                        jmp _stack_underflow
                        _c5:
                        pop ax
                        not ax
                        add ax,1
                        push ax
                    _end_negation:

                    
        ;-------------------------------------------
            ;-------- YIELD -------
            ;save cursor position
            pusha
            mov ah, 3
            mov bh,0
            int 0x10
            pusha

            call _yield
            
            popa
            ;restore cursor position
            mov ah,2
            mov bh,0
            int 0x10
            popa
        ;---------END YIELD-----    
            ;checking if enter was pressed
            cmp byte [currChar], 13 
            je _end_input
            cmp byte [currChar], 10
            je _end_input
            
            jmp _input_continue
            _end_input:

            push int1
            call _printf
            add esp,8

            mov ah,0
            int 0x16
            mov ah,0

                mov dl,0
                mov dh, 20
                mov bh, 0
                mov ah,2
                int 0x10

                mov ah, 0xA
                mov al, ' '
                mov cx, 160
                int 0x10

                mov dl,0
                mov dh, 20
                mov bh, 0
                mov ah,2
                int 0x10



            jmp _end_stack_underflow
            _stack_underflow:
            _end_stack_underflow:
            jmp _input


;-----------TASK 2: ALPHABET-----------
_task_b:
        ;sets cursor at 5,0
        mov dl, 0
        mov dh, 5
        mov bh, 0
        mov ah, 2
        int 0x10

    loop_forever_2:  
        ;-------- YIELD -------
        ;save cursor position
        pusha
        mov ah, 3
        mov bh,0
        int 0x10
        pusha

        call _yield
        
        popa
        ;restore cursor position
        mov ah,2
        mov bh,0
        int 0x10
        popa
        ;---------END YIELD-----
       
        start:
            call resetdisp
            mov byte[charTask2], 'A'
            jmp looptoz
            
        looptoz:
            call printchar

            mov dx,0
            call waitforprnt
            ;-------- YIELD -------
            ;save cursor position
            pusha
            mov ah, 3
            mov bh,0
            int 0x10
            pusha

            call _yield
            
            popa
            ;restore cursor position
            mov ah,2
            mov bh,0
            int 0x10
            popa
            ;---------END YIELD-----

            cmp byte[charTask2], 'Z'
            je looptoa
            jmp incrementlet

        incrementlet:
            inc byte[charTask2]
            jmp looptoz
            
        looptoa:
            call printchar

            mov dx,0
            call waitforprnt
            
           ;-------- YIELD -------
            ;save cursor position
            pusha
            mov ah, 3
            mov bh,0
            int 0x10
            pusha

            call _yield
            
            popa
            ;restore cursor position
            mov ah,2
            mov bh,0
            int 0x10
            popa
            ;---------END YIELD-----

            cmp byte[charTask2], 'A'
            je looptoz
            jmp decrementlet

        
        decrementlet:
            dec byte[charTask2]
            jmp looptoa

        resetdisp:
            ;clear first row
            mov dh, 5
            mov dl, 0
            mov ah,2
            mov bh,0
            int 0x10

            mov ah, 0x0E
            mov al, ' '
            mov cx, 38
            int 0x10

            ;clear third row
            mov dh, 6
            mov dl, 0
            mov ah,2
            mov bh,0
            int 0x10

            mov ah, 0x0E
            mov al, ' '
            mov cx, 38
            int 0x10

            ;restore cursor to the beginning of second row
            mov dh, 5
            mov dl, 0
            mov ah,2
            mov bh,0
            int 0x10


        waitforprnt:
            ;-------- YIELD -------
            ;save cursor position
            pusha
            mov ah, 3
            mov bh,0
            int 0x10
            pusha

            call _yield
            
            popa
            ;restore cursor position
            mov ah,2
            mov bh,0
            int 0x10
            popa
            ;---------END YIELD-----

            inc dh
            cmp dh, -1
            jne waitforprnt
            ret
            
        printchar:
            ;print the char
            mov ah, 0x0E
            mov al, byte[charTask2]
            mov cx, 1
            int 0x10

            ;get cursor position
            mov ah, 3
            mov bh, 0
            int 0x10
            
            cmp dl, 38
            jge _col_is_38
            jmp _end_row2_and_col38
            _col_is_38:
                cmp dh,6
                jg _row2_and_col38

                ;increment row and reset col
                inc dh
                mov dl,0
                mov bh,0
                mov ah,2
                int 0x10
                jmp _end_row2_and_col38

            _end_col_is_38:

            ;if row == 2 and col == 48
            _row2_and_col38:
                ;move to 1,0
                mov dl, 0
                mov dh, 5
                mov bh, 0
                mov ah,2
                int 0x10
                call resetdisp
            _end_row2_and_col38:

            ret
    jmp loop_forever_2

	; does not terminate or return

;-------TASK 3: GRAPHICS----------
_task_c:
    call _taskC
    jmp _task_c

;-------TASK 4: AUDIO----------
_task_d:
    _repeat_song:
    call _playSong
    jmp _repeat_song
;-------AN IMPLEMENTATION OF PRINTF(%S)----------
_putchar:
	mov ax, dx
	mov ah, 0x0E
	mov cx, 1
	int 0x10
	ret

_putstring:
putstring_while:
	cmp byte [esi], 0
	jne putstring_continue
	jmp pustring_done
putstring_continue:
    
	mov dl, [esi]
	mov dh, 0
	call _putchar
    
	inc esi
	jmp putstring_while
pustring_done:
	ret

SECTION .data
	task_main_str: db "GABRIEL COJOCARU & JARED MUNDY", 13, 10, 0
    task1_str: db "TASK 1: Alphabet", 0
    task2_str: db "TASK 2: Graphics", 0
    task3_str: db "TASK 3: RPN Calculator", 0
    task4_str: db "TTASK 4: Sound", 0

	current_task: db 0
	stacks: times (4096 * 4) db 0 ; 31 fake stacks of size 256 bytes
	task_status: times 5 db 0 ; 0 means inactive, 1 means active
	stack_pointers: dd 0 ; the first pointer needs to be to the real stack !
					dd stacks + (4096 * 1)
					dd stacks + (4096 * 2)
					dd stacks + (4096 * 3)
					dd stacks + (4096 * 4)

charTask2: db 'A'
positive: db 1
multiplier: dw 1
prev_multiplier: db 1
temp1: dw 0
temp2: dq 0
alphabet: TIMES 26 dq 1
justConverted: db 0
currChar: db 0
nrPushed: db 0
nrDigits: db 0
i: db 0
nr: dd 0
j: db 0
inString: TIMES 256 db 0
str1: db "Enter an expression: ",0
underflow: db "Stack underflow error. Bye.", 0
int1: db "The result is: %d             -> (Press ENTER to resume)", 0
strFormat: db "%s",0
