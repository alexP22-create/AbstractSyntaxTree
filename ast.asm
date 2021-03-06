;; POSTOLACHE Alexandru-Gabriel
section .data
    space db " ", 0
    zero dd 0

section .bss
    root resd 1
    data resd 1 ; contains the word which is going to be added to every node's data
    finnished resd 1
    isOperator resd 1
    i resd 1
    j resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern malloc
extern strcpy
extern strtok
extern strcat
extern strlen

global create_tree
global iocla_atoi


setNegative:
    neg eax
    ;; the variable which is telling us which number is negative will reset itself
    mov dword[finnished], 0
    jmp ready

negativeNumber:
    mov dword[finnished], 1
    jmp reapply

aduna:
	;; the case when the first character is "-"
    cmp byte[edx+ecx], 45
    je negativeNumber

    push ebx
    xor ebx, ebx
    mov bl, byte[edx+ecx]
    add eax, ebx
    sub eax, 48
    pop ebx

    cmp [j], ebx
    je reapply

    mov dword[i], 10
    imul eax, dword[i]    
    jmp reapply
    ret

iocla_atoi: 

    mov edx, eax
    push edx
    push eax
    call strlen
    add esp, 4

    ;; the number of characters will be put in ebx
    mov ebx, eax    
    xor eax, eax
    pop edx
    mov dword[j], 0

    ;; browse all the characters from left to the right    
label:
    mov ecx, dword[j]
    add dword[j], 1
    cmp byte[edx+ecx-1], 47
    jg isFigure
isFigure:
    cmp byte[edx+ecx-1], 58
    jl aduna
reapply:
    cmp [j], ebx
    jl label

    ;; when the next variable is 1 it means the number is negative
    cmp dword[finnished], 1
    je setNegative
ready:
        
    ret

create_tree:
    enter 0, 0
    xor eax, eax
    push eax
    push ebx
    push ecx
    push edx

    push space
    push dword[ebp+8]
    call strtok
    add esp, 8
    mov [data], eax

    ;; alloc for string
    push 4
    call malloc
    add esp, 4

    ;; copy the string
    push dword[data]
    push eax
    call strcpy
    add esp, 8
    mov ebx, eax

    ;; alloc for one node
    push 12
    call malloc
    add esp, 4

    mov dword[eax], ebx
    mov dword[eax+4], 0
    mov dword[eax+8], 0
    mov edx, eax
    mov [root], eax 

    ;; set the left child tree
    push edx
    call recFunction
    pop edx

    ;; set the right child tree
    ;; the adress must be saved
    push edx
    call recFunction2
    pop edx

    pop edx
    pop ecx
    pop ebx
    pop eax

    mov eax, [root] 

    leave
    ret


recFunction:
    push ebp
    mov ebp, esp
    push space
    push dword[zero]
    call strtok
    add esp, 8

    ;; check if the read element is an operator
    cmp byte[eax], 42 
    je markOperator1
    cmp byte[eax], 43
    je markOperator1
    cmp byte[eax], 45
    je markOperator1
    cmp byte[eax], 47
    je markOperator1
backInFunction1:

    ;;save the element    
    mov [data], eax
                                        
    ;; alocc for a string
    push 4
    call malloc
    add esp, 4
    ;; copy the string
    push dword[data]
    push eax
    call strcpy
    add esp, 8
    mov ebx, eax
    ;; alocc for a node
    push 12
    call malloc
    add esp, 4

    mov dword[eax], ebx
    mov dword[eax+4], 0
    mov dword[eax+8], 0
    mov edx, [ebp+8]    
    mov dword[edx+4], eax
    ;; save on the stack the left child
    pop ebp
    
    ;; if the read character was an operand we must reaply the function
    cmp dword[isOperator], 1
    je callAgain1
    jmp stopCall1

callAgain1:
    ;;reseted
    mov dword[isOperator], 0
    ;; when the current node is an operator we must set both of his children
    push eax
    call recFunction
    pop eax
    push eax
    call recFunction2
    pop eax

stopCall1:
    ret

markOperator1:
    ;verify if it's a negative number or an operator
    cmp byte[eax+1], 48
    jg continueVerif
    jmp contMarkOperator1

continueVerif:
    cmp byte[eax+1], 58
    jl backInFunction1

contMarkOperator1:
    mov dword[isOperator], 1    
    jmp backInFunction1

markOperator2:
    cmp byte[eax+1], 48
    jg continueVerif2
    jmp contMarkOperator2

continueVerif2:
    cmp byte[eax+1], 58
    jl backInFunction2

contMarkOperator2:
    mov dword[isOperator], 1
    jmp backInFunction2    

recFunction2:
    push ebp
    mov ebp, esp
    push space
    push dword[zero]
    call strtok
    add esp, 8

    cmp byte[eax], 42
    je markOperator2
    cmp byte[eax], 43
    je markOperator2
    cmp byte[eax], 45
    je markOperator2
    cmp byte[eax], 47
    je markOperator2

backInFunction2:    
    mov [data], eax
                                        
    push 4
    call malloc
    add esp, 4

    push dword[data]
    push eax
    call strcpy
    add esp, 8
    mov ebx, eax

    push 12
    call malloc
    add esp, 4

    mov dword[eax], ebx
    mov dword[eax+4], 0
    mov dword[eax+8], 0
    mov edx, [ebp+8]    
    mov dword[edx+8], eax
   
    pop ebp

    cmp dword[isOperator], 1
    je callAgain2
    jmp stopCall2

callAgain2:
    mov dword[isOperator], 0    
    push eax
    call recFunction
    pop eax
    push eax
    call recFunction2
    pop eax

stopCall2:
    ret    