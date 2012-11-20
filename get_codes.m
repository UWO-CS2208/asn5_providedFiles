! function    get_codes
! Purpose:    get_codes reads bytecodes from a .miniclass file into a bytecode array in memory
! Parameters: address of filename string (filename of .miniclass file)
!             address of bytecode array
! Calling sequence: address of filename string in %o0
!                   address of bytecode array in %o1
!                   call get_codes 
! Returns:    the number of bytes read in %o0
!             or -1 in %o0 if there was an error in opening or reading the file
! Register Legend:
!       %size_r         the number of bytes read into the array %l0
!       %fptr_r         a pointer to the bytecode file          %l1

        include(macro_defs.m)

        define(size_r, l0)
        define(fptr_r, l1)

        define(ZERO, 0)                 ! constant zero for bytes read
        define(NULL, 0)                 ! null file pointer
        define(ERROR, -1)               ! error return value
        define(MAXSIZE, 100)            ! maximum size of array (assumed)
        define(BYTE, 1)                 ! size of data unit to be read

        .data
fmode:  .asciz  "rb"                    ! file mode for binary read

        .text

        begin_fn(get_codes)

        mov     ERROR, %size_r          ! initialize return value to error

        mov     %i0, %o0                ! pass address of filename
        set     fmode, %o1              ! pass file mode
        call    fopen                   ! open file
        nop

        cmp     %o0, NULL               ! check if null file pointer returned
        be      exit                    ! if so, file not found and return error
        nop

        mov     %o0, %fptr_r            ! save the valid file pointer
                                        
        mov     %i1, %o0                ! pass address of byte array
        mov     BYTE, %o1               ! pass size of each item in the byte array
        mov     MAXSIZE, %o2            ! pass maximum number of items fread will read
        mov     %fptr_r, %o3            ! pass file pointer returned by fopen
        call    fread                   ! read from file
        nop
        
        cmp     %o0, ZERO               ! check if zero bytes read
        be      exit                    ! if so, return error
        nop
        
        mov     %o0, %size_r            ! save number of bytes read
        mov     %fptr_r, %o0            ! close the file
        call    fclose
        nop
exit:
        mov     %size_r, %i0            ! return no. of bytecodes read
        ret
        restore                         
