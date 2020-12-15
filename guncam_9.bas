DEFINT A-Y
ON ERROR GOTO failure
DIM taulukkoa(600, 450) AS INTEGER
DIM taulukkob(600, 450) AS INTEGER

RANDOMIZE TIMER
handle& = _NEWIMAGE(400, 300, 32)
yiffi& = _NEWIMAGE(400, 300, 256)

FOR ei = 0 TO 255
    _PALETTECOLOR ei, _RGB32(ei, ei, ei), yiffi&
NEXT
count = 1000
rlenth = 5
SCREEN handle&

FOR i = 1 TO _DEVICES
NEXT


DO
    LOCATE 1
    PRINT "Press record button": _DISPLAY

    d& = _DEVICEINPUT
    IF d& THEN '             the device number cannot be zero!
        REM        PRINT "Found"; d&;
        FOR b = 1 TO _LASTBUTTON(d&)
            IF _BUTTONCHANGE(b) = 1 THEN nro = b: dnro = d&: eteenp = 1: PRINT "Device "; dnro; " button "; nro; " selected.": _DISPLAY: _DELAY 1
        NEXT
        PRINT
    END IF
LOOP UNTIL eteenp = 1

zoom = 0

alku:
_LIMIT 240
IF TIMER > zaika AND painettu = 0 THEN
    COLOR 255
    LOCATE 1: PRINT "STOPPED":
    PRINT "Focus this program to change settings"
    PRINT
    PRINT "+ and - change brightness"
    PRINT "/ and * change contrast"
    PRINT "WASD moves camera"
    PRINT "JL aspect ratio"
    PRINT "IK zoom"
    PRINT "1-9 rec length"
    PRINT "V sound on/off"

    _DISPLAY
END IF

r$ = INKEY$
r$ = LCASE$(r$)
IF r$ = "+" THEN expy = expy + 1
IF r$ = "-" THEN expy = expy - 1
IF r$ = "/" THEN cont = cont + 1
IF r$ = "*" THEN cont = cont - 1
IF r$ = "w" THEN yoff = yoff - 2
IF r$ = "s" THEN yoff = yoff + 2
IF r$ = "a" THEN xoff = xoff - 2
IF r$ = "d" THEN xoff = xoff + 2
IF r$ = "i" AND zoom < 20 THEN zoom = zoom + 1
IF r$ = "k" AND zoom > 0 THEN zoom = zoom - 1
IF r$ = "j" THEN aspect = aspect - 1
IF r$ = "1" THEN rlenth = 1
IF r$ = "2" THEN rlenth = 2
IF r$ = "3" THEN rlenth = 3
IF r$ = "4" THEN rlenth = 4
IF r$ = "5" THEN rlenth = 5
IF r$ = "6" THEN rlenth = 6
IF r$ = "7" THEN rlenth = 7
IF r$ = "8" THEN rlenth = 8
IF r$ = "9" THEN rlenth = 9
IF r$ = "v" AND volume = 1 THEN volume = 0: r$ = ""
IF r$ = "v" AND volume = 0 THEN volume = 1: r$ = "": PLAY "T255V05O2L64E"





d& = _DEVICEINPUT

IF d& = dnro THEN
    kuk% = _BUTTON(nro)
    IF kuk% <> 0 AND painettu = 0 THEN zaika = TIMER + rlenth: painettu = 1: PLAY "T255V05O2L64E"
    IF TIMER > zaika AND kuk% = 0 AND painettu = 1 THEN
        painettu = 0
        PLAY "T255V05O2L64C"
        name$ = "cmd /c gifsicle.exe --delay=8 --loop --multifile *.giftemp > " + DATE$ + "-" + LTRIM$(STR$(TIMER * 100)) + ".gif"
        SHELL _HIDE name$
        SHELL _HIDE "del *.giftemp"
        count = 1000
        FOR i = 1 TO _DEVICES
        NEXT
    END IF

END IF


REM     IF zaika > TIMER THEN LOCATE 1: PRINT "recording": _DISPLAY

frametime = frametime + 1
REM IF painettu = 1 AND frametime < 5 THEN GOTO alku
IF painettu = 0 AND frametime < 60 THEN GOTO alku

frametime = 0:


xee = _DESKTOPWIDTH * (1 + zoom / 50)
yee = _DESKTOPHEIGHT * (1 + zoom / 50)
scxa = INT(0.395 * xee) + xoff - aspect
scxb = INT(0.603 * xee) + xoff + aspect
scya = INT(0.361 * yee) + yoff
scyb = INT(0.637 * yee) + yoff

SCREEN handle&

i& = _SCREENIMAGE(scxa, scya, scxb, scyb)
_PUTIMAGE (0, 0)-(400, 300), i&

FOR u% = 0 TO 400
    FOR o% = 0 TO 300
        a& = POINT(u%, o%)

        r% = _RED(a&)
        g% = _GREEN(a&)
        b% = _BLUE(a&)
        e% = (r% + g% + b%) / 3
        f = ABS(e% - 120)
        f = f ^ (1.2 + (cont / 10))
        IF e% - 128 < 0 THEN e% = e% - f ELSE e% = e% + f
        e% = e% + (expy * 5)
        IF e% > 255 THEN e% = 255: IF e% < 0 THEN e% = 0
        taulukkoa(u%, o%) = e%
    NEXT
NEXT

FOR kek = 1 TO 2
    REM blur
    FOR u% = 1 TO 399
        FOR o% = 1 TO 299
            SHIT% = (taulukkoa(u%, o%) + taulukkoa(u% + 1, o%) + taulukkoa(u% - 1, o%) + taulukkoa(u%, o% + 1) + taulukkoa(u%, o% - 1) + taulukkoa(u% + 1, o% + 1) + taulukkoa(u% - 1, o% + 1) + taulukkoa(u% + 1, o% - 1) + taulukkoa(u% - 1, o% - 1)) / 9
            taulukkob(u%, o%) = SHIT%
        NEXT
    NEXT
    FOR u% = 0 TO 400
        FOR o% = 0 TO 300
            taulukkoa(u%, o%) = taulukkob(u%, o%)
            IF taulukkoa(u%, o%) < 0 THEN taulukkoa(u%, o%) = 0
            IF taulukkoa(u%, o%) > 255 THEN taulukkoa(u%, o%) = 255

        NEXT
    NEXT
NEXT


SCREEN yiffi&
REM FOR i = 0 TO 255
REM PSET (i, 10), i
REM NEXT
REM _DISPLAY
REM SLEEP


FOR u% = 0 TO 400
    FOR o% = 0 TO 300
        e% = (taulukkoa(u%, o%))
        REM         PSET (u%, o%), _RGB32(e%, e%, e%)
        PSET (u%, o%), e%
        REM     _DISPLAY

    NEXT
NEXT



_DISPLAY
REM IF zaika > TIMER THEN count = count + 1: nimi$ = "F:\sturmosshots\" + STR$(count): SaveImage 0, nimi$
REM IF zaika > TIMER AND painettu = 1 THEN count = count + 1: nimi$ = STR$(count): SaveImage 0, nimi$
IF zaika > TIMER AND painettu = 1 THEN count = count + 1: nimi$ = LTRIM$(STR$(count) + ".giftemp"): MakeGIF nimi$, 0, 0, 399, 299, 256
_FREEIMAGE i&

GOTO alku

failure:
BEEP
expy = 0

cont = 0

yoff = 0
xoff = 0
zoom = 0
aspect = 1

RESUME alku


'$INCLUDE: 'GIFcreate.BM'

