define(BYTE,1)                          ! size of a byte in bytes
define(SIZE,100)                        ! size of bytecode array (assumed)

include(macro_defs.m)

local_var
var(byte_stream_s,BYTE,SIZE*BYTE)       ! array for storing bytecode stream

        begin_main

        ! need to pass filename as first parameter to get_codes (REMOVE THIS COMMENT)
        add     %fp,byte_stream_s,%o1   ! pass address of bytecode array
        call    get_codes               ! read bytecodes from file into array
        nop

        mov     %o0,%o1                 ! pass number of bytes in bytecode stream
        add     %fp,byte_stream_s,%o0   ! pass address of bytecode array
        call    execute_codes           ! execute instructions in bytecode
        nop

        ! are you remembering your return value to the operating system?  (REMOVE THIS COMMENT)

        ret                             ! exit
        restore

