! This program implements a small subset of the instructions of the
! Java Virtual Machine (JVM). The instructions are read from the keyboard.
!
! based on code written for CS208 by Chris Snow
! modified by A. Downing Nov. 2009
! modified by Jeff Shantz Mar. 2012
!
! Register Legend
!
!  stkptr_r             %l7     Points to the top element in the stack
!  op1_r                %l0     Stores the first operand for math operations
!  op2_r                %l1     Stores the second operand for math operations

include(macro_defs.m)

! Register Definitions

define(stkptr_r,%l7)    ! points to current top of stack
define(op1_r,%l0)       ! stores first operand for math operations
define(op2_r,%l1)       ! stores second operand for math operations

! Constants

define(MAXSIZE,20)      ! max. number of stack elements
define(LEN,4)           ! size of each stack element
define(EOL,10)          ! newline character

! Constants for bytecode operations

define(BIPUSH,16)       ! push (param 1) onto the operand stack
define(POP,87)          ! pop the top element from the operand stack
define(IADD,96)         ! (2nd from top) + (top), result onto stack
define(ISUB,100)        ! (2nd from top) - (top), result onto stack
define(IMUL,104)        ! (2nd from top) * (top), result onto stack
define(IDIV,108)        ! (2nd from top) / (top), result onto stack
define(RETURN,177)      ! return (exit from the program)
define(IPRINT,187)      ! print top element on operand stack

        .data

! divide by zero error message

div_by_zero:    .asciz "ERROR: Divide by zero. Terminating\n"   
        
        .text

        local_var
        var(stack_s,LEN,LEN*MAXSIZE)            ! offset for the operand stack

        begin_main

! set up the operand stack

init:   add     %fp, stack_s, stkptr_r          ! point to start of stack memory
        add     stkptr_r, LEN*MAXSIZE, stkptr_r ! move pointer to 'bottom' of stack

! start processing bytecodes

top:    call    writeChar                       ! print prompt
        mov     '>', %o0                        ! [DELAY SLOT FILLED]

        call    writeChar                       ! print spacing
        mov     ' ', %o0                        ! [DELAY SLOT FILLED]

        call    readInt                         ! get the bytecode from the user
        nop

        cmp     %o0, RETURN                     ! the 'return' command? (177)
        be      quit
        nop

        cmp     %o0, IPRINT                     ! the 'iprint' command? (187)
        be      iprint
        nop
        
        cmp     %o0, BIPUSH                     ! the 'bipush' command? (16)
        be      bipush
        nop

        cmp     %o0, POP                        ! the 'pop' command? (87)
        be      pop
        nop

        cmp     %o0, IADD                       ! the 'iadd' command? (96)
        be      iadd
        nop

        cmp     %o0, ISUB                       ! the 'isub' command? (100)
        be      isub
        nop

        cmp     %o0, IMUL                       ! the 'imul' command? (104)
        be      imul
        nop

        cmp     %o0, IDIV                       ! the 'idiv' command? (108)
        be      idiv
        nop

! assume that there are no illegal bytecodes in the bytecode stream,
! so should never get here by dropping through all the compares

! Execute bytecodes:
! push a value (specified as an extra parameter) onto the stack

bipush: call    readInt                         ! get the extra parameter
        nop
        
        dec     LEN, stkptr_r                   ! push the parameter onto the stack
        st      %o0, [stkptr_r]

        ba      top                             ! back to read next command
        nop

! pop the top element off the operand stack

pop:    inc     LEN, stkptr_r                   ! move stack ptr and go back
        ba      top                             
        nop
        
! add the top two stack elements and put the result back on the stack

iadd:   ld      [stkptr_r], op2_r               ! get first operand
        inc     LEN, stkptr_r
        ld      [stkptr_r], op1_r               ! get second operand
                                                ! (NOTE: don't shift the pointer)
        add     op1_r, op2_r, op1_r             ! do the addition
        st      op1_r, [stkptr_r]               ! put the result back on the stack

        ba      top                             ! back to the start
        nop

! subtraction: (2nd from the top) - (top), put the result back on the stack

isub:   ld      [stkptr_r], op2_r               ! load first operand
        inc     LEN, stkptr_r
        ld      [stkptr_r], op1_r               ! load second operand
                                                ! (NOTE: don't shift the pointer)
        sub     op1_r, op2_r, op1_r             ! do the subtraction
        st      op1_r, [stkptr_r]               ! put the result back on the stack

        ba      top                             ! back to the start
        nop

! multiply the top two stack elements, and put the result back on the stack

imul:   ld      [stkptr_r], %o1                 ! load first operand
        inc     LEN, stkptr_r
        ld      [stkptr_r], %o0                 ! load second operand
                                                ! (NOTE: don't shift the pointer)
        call    .mul                            ! do the multiplication
        nop
        st      %o0, [stkptr_r]                 ! put the result back on the stack

        ba      top                             ! back to the start
        nop

! (2nd from the top) / (top), result back on the stack

idiv:   ld      [stkptr_r], %o1                 ! load first operand
        inc     LEN, stkptr_r

        tst     %o1                             ! make sure it's not divide by zero
        be      div_error
        nop

        ld      [stkptr_r], %o0                 ! load second operand
                                                ! (NOTE: don't shift the pointer)
        call    .div                            ! do the division
        nop
        st      %o0, [stkptr_r]                 ! put the result back on the stack

        ba      top                             ! back to the start
        nop

! print the number at the top of the operand stack

iprint: call    writeInt                        ! print value at top of stack
        ld      [stkptr_r], %o0                 ! [DELAY SLOT FILLED]

        call    writeChar                       ! print blank line
        mov     EOL, %o0                        ! [DELAY SLOT FILLED]

        ba      top                             ! get next command
        nop

! Error: division by zero
 
div_error:
        set     div_by_zero, %o0
        call    printf                          ! print an error msg and exit
        nop

! exit the program

quit:   ret
        restore

