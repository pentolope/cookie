
.org !00010000
:00000000
LDLA %2 %3 @00000002
LDLA %4 %5 @00000003
LDLA %6 %7 @00000004
LDLO %9 $01
LDLO %A $00
MOV_ %D %2
MOV_ %E %3

:00000003
MREB %8 %E
LDLO %F $00
ADDC %2 %D %9
ADDN %3 %E %F
CJMP %6 %7 %8
MOV_ %D %2
MOV_ %E %3
AJMP %4 %5

:00000004
LDLA %A %9 @00000002
LDLO %F $01
SSUB %F %D %A
SSUB %F %E %9

LDLA %2 %3 @00000001
:00000001
AJMP %2 %3


.org !00020000
:00000002
.datab $01
.datab $02
.datab $03
.datab $04
.datab $05
.datab $06
.datab $07
.datab $08
.datab $00