DEFINT A-Y
_SCROLLLOCK OFF
ON ERROR GOTO failure
DIM taulukkoa(600, 450) AS INTEGER
DIM taulukkob(600, 450) AS INTEGER

RANDOMIZE TIMER
handle& = _NEWIMAGE(400, 600, 32)
yiffi& = _NEWIMAGE(400, 600, 256)

PLAY "V05"
volume = 1
bluramount = 2
FOR ei = 0 TO 255
    _PALETTECOLOR ei, _RGB32(ei, ei, ei), yiffi&
NEXT
count = 1001
rlenth = 8
SCREEN handle&

FOR i = 1 TO _DEVICES
NEXT

DO
    LOCATE 1
    PRINT "Jorqell's Guncam 1.05  17.12.2020"
    PRINT "Choose record button": _DISPLAY

    d& = _DEVICEINPUT
    IF d& THEN '             the device number cannot be zero!
        REM        PRINT "Found"; d&;
        FOR b = 1 TO _LASTBUTTON(d&)
            IF _BUTTONCHANGE(b) = 1 THEN nro = b: dnro = d&: eteenp = 1: PRINT "Device"; dnro; "button"; nro; "selected.": PRINT "Starting test recording"; _DISPLAY: _DELAY 2
        NEXT
        PRINT
    END IF
LOOP UNTIL eteenp = 1
zaika = TIMER
zoom = 50
autob = 1
cont = 0
vakain = 1
siirros = 0
alku:
_LIMIT 240
COLOR 255
LOCATE 20:
IF count = 1000 THEN PRINT "STOP                               ": ELSE PRINT "REC, frame"; count - 1000
PRINT
PRINT "Focus this program to change settings"
PRINT
PRINT "+ and - change brightness"
PRINT "/ and * change contrast"
PRINT "WASD moves camera"
PRINT "JL aspect ratio"
PRINT "IK zoom"
PRINT "V sound toggle"
IF vakain = 1 THEN PRINT "Z image 'stabilizer' ON/off" ELSE PRINT "Z image 'stabilizer' on/OFF"

PRINT "Scroll Lock continous recording"
IF autob = 1 THEN PRINT "E autobrightness ON/off" ELSE PRINT "E autobrightness on/OFF"

REM PRINT zurvo
IF count > 1000 THEN PRINT INT((count - 1000) / (TIMER - zaika)); "fps                     "
_DISPLAY
'
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
REM IF r$ = "," AND bluramount > 0 THEN bluramount = bluramount - 1
REM IF r$ = "." THEN bluramount = bluramount + 1

IF r$ = "i" AND zoom < 50 THEN zoom = zoom + 1
IF r$ = "k" AND zoom > 400 THEN zoom = zoom - 1
IF r$ = "j" THEN aspect = aspect - 1
IF r$ = "v" AND volume = 1 THEN volume = 0: r$ = "": PLAY "V0"
IF r$ = "v" AND volume = 0 THEN volume = 1: r$ = "": PLAY "T255V05O2L64E"
IF r$ = "e" AND autob = 1 THEN autob = 0: r$ = ""
IF r$ = "e" AND autob = 0 THEN autob = 1: r$ = ""
IF r$ = "z" AND vakain = 1 THEN vakain = 0: r$ = ""
IF r$ = "z" AND vakain = 0 THEN vakain = 1: r$ = ""


IF count = 1100 THEN
    IF TIMER < zaika THEN zaika = 10
    IF TIMER > zaika THEN
        zaika = 100 / (TIMER - zaika)
        zaika = 100 / zaika
        REM        LOCATE 10: PRINT "Delayarvo"; zaika: _DISPLAY: _DELAY 1
    END IF

END IF


IF count >= 1100 THEN GOSUB giffer
d& = _DEVICEINPUT

IF d& = dnro THEN
    kuk% = _BUTTON(nro)
    LOCATE 1: PRINT kuk%: _DISPLAY
    IF kuk% <> 0 AND count = 1000 THEN count = 1001: PLAY "T255O2L64E": zaika = TIMER

END IF


IF _SCROLLLOCK = -1 AND count = 1000 THEN count = 1001: zaika = TIMER



frametime = frametime + 1

IF count = 1000 AND frametime < 20 THEN GOTO alku

frametime = 0:


xee = _DESKTOPWIDTH
yee = _DESKTOPHEIGHT
scxa = INT(0.395 * xee * (zoom / 50)) + xoff - aspect
scxb = INT(0.603 * xee / (zoom / 50)) + xoff + aspect
scya = INT(0.361 * yee * (zoom / 50)) + yoff - siirros
scyb = INT(0.637 * yee / (zoom / 50)) + yoff - siirros
IF scxa < 0 THEN scxa = 0: xoff = xoff + 2
IF scxb > _DESKTOPWIDTH THEN scxb = _DESKTOPWIDTH - scxb: xoff = xoff - 2
IF scya < 0 THEN scya = 0: yoff = yoff + 2
IF scyb > _DESKTOPHEIGHT THEN scyb = _DESKTOPHEIGHT - scyb: yoff = yoff - 2

SCREEN handle&

i& = _SCREENIMAGE(scxa, scya, scxb, scyb)
_PUTIMAGE (0, 0)-(400, 300), i&

GOSUB manipuli

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
IF vakain = 1 THEN GOSUB kuvanvakain


_DISPLAY
REM IF zaika > TIMER THEN count = count + 1: nimi$ = "F:\sturmosshots\" + STR$(count): SaveImage 0, nimi$
REM IF zaika > TIMER AND painettu = 1 THEN count = count + 1: nimi$ = STR$(count): SaveImage 0, nimi$
IF count > 1000 THEN count = count + 1: nimi$ = LTRIM$(STR$(count) + ".giftemp"): MakeGIF nimi$, 0, 0, 399, 299, 256
_FREEIMAGE i&

GOTO alku

failure:
PLAY "o1l64ccccc"
LOCATE 1: PRINT "Crashed, restarting": _DISPLAY: _DELAY 1
expy = 0
autob = 1
cont = 0
contnu = 0
yoff = 0
xoff = 0
zoom = 50
aspect = 1
count = 1000
vakain = 0
siirros = 0
RESUME alku


giffer:
PLAY "T255O2L64C"
zaika = INT(zaika)
name$ = "cmd /c gifsicle.exe --delay=" + LTRIM$(STR$(zaika)) + " --loop --multifile *.giftemp > " + DATE$ + "-" + LTRIM$(STR$(TIMER * 100)) + ".gif"
SHELL _HIDE name$
SHELL _HIDE "del *.giftemp"
count = 1000
FOR i = 1 TO _DEVICES
NEXT
d& = _DEVICEINPUT
kuk% = _BUTTON(nro)
RETURN

manipuli:
zurvo = 0
FOR u% = 0 TO 400 'check
    FOR o% = 0 TO 300
        zurvo = zurvo + taulukkoa(u%, o%)
    NEXT
NEXT
zurvo = INT((zurvo / (400 * 300)) - 128) / 4

FOR u% = 0 TO 400
    FOR o% = 0 TO 300
        a& = POINT(u%, o%)

        r% = _RED(a&)
        g% = _GREEN(a&)
        b% = _BLUE(a&)
        e% = (r% + g% + b%) / 3
        IF autob = 1 THEN e = e - zurvo

        f = ABS(e% - 128)


        f = f ^ (1.2 + (cont / 10))

        IF e% - 128 < 0 THEN e% = e% - f ELSE e% = e% + f
        e% = e% + (expy * 5)
        IF e% > 255 THEN e% = 255: IF e% < 0 THEN e% = 0
        taulukkoa(u%, o%) = e%
    NEXT
NEXT

FOR kek = 1 TO bluramount 'blur
    FOR u% = 1 TO 399
        FOR o% = 1 TO 299
            REM             SHIT% = (taulukkoa(u%, o%) + taulukkoa(u% + 1, o%) + taulukkoa(u% - 1, o%) + taulukkoa(u%, o% + 1) + taulukkoa(u%, o% - 1) + taulukkoa(u% + 1, o% + 1) + taulukkoa(u% - 1, o% + 1) + taulukkoa(u% + 1, o% - 1) + taulukkoa(u% - 1, o% - 1)) / 9
            SHIT% = (taulukkoa(u%, o%) + taulukkoa(u% + 1, o%) + taulukkoa(u% - 1, o%) + taulukkoa(u%, o% + 1) + taulukkoa(u%, o% - 1)) / 5
            taulukkob(u%, o%) = SHIT%
        NEXT
    NEXT
NEXT


FOR u% = 0 TO 400 'check
    FOR o% = 0 TO 300
        taulukkoa(u%, o%) = taulukkob(u%, o%)
        IF taulukkoa(u%, o%) < 0 THEN taulukkoa(u%, o%) = 0
        IF taulukkoa(u%, o%) > 255 THEN taulukkoa(u%, o%) = 255
    NEXT
NEXT
RETURN

kuvanvakain:
vaka = 0
vakb = 0

FOR kekkuli = 0 TO 200
    arvo = taulukkoa(200, 300 - kekkuli)
    IF arvo > 50 THEN vaka = vaka + 1
    IF arvo < 50 THEN vakb = vakb + 1
NEXT
IF vakb > siirros + 10 THEN siirrosm = siirrosm + (vakb / 20)
IF vakb < siirros - 10 THEN siirrosm = siirrosm - 10
IF vakb > siirros - 10 AND vakb < siirros + 10 THEN siirrosm = siirrosm * 0.2
siirros = siirros + siirrosm
IF siirros <= 0 THEN siirros = 0
IF siirros > 200 THEN siirros = 200

REM COLOR 255: LINE (0, 300 - vakb)-(400, 300 - siirros)

RETURN



'$INCLUDE: 'GIFcreate.BM'


