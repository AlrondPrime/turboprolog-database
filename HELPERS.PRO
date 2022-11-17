DOMAINS
msg=s(string);i(integer);r(real);c(char)
key = enter; esc; up_arrow; down_arrow; other

PREDICATES
key_code(key, integer)
key_code2(key, integer)
error
file_error
_log_(msg, integer)
logImpl(msg)
clr(integer)
read_int(integer)

CLAUSES
% key code to key name
key_code(Key, 0):-
    readchar(T), char_int(T, Val), key_code2(Key, Val),!. 
key_code(enter, 13).
key_code(esc, 27).
% keys with additional keycode \0
key_code2(up_arrow, 72).
key_code2(down_arrow,80).
key_code2(other,_).
_log_(Msg, Clearwindow):-
    writedevice(WDev),readdevice(RDev),   
    writedevice(screen),readdevice(keyboard),
    makewindow(WNum,_,_,_,_,_,_,_),
    shiftwindow(2),
    clr(Clearwindow),
    logImpl(Msg),
    %    readchar(_),
    writedevice(WDev),readdevice(RDev),
    shiftwindow(WNum),
    !.
logImpl(s(Msg)):-write(Msg),!.
logImpl(i(Msg)):-write(Msg),write(' '),!.
logImpl(r(Msg)):-write(Msg),write(' '),!.
logImpl(c(Msg)):-write(Msg),write(' '),!.
clr(0):-!.
clr(_):-clearwindow,!.
error:-
    makewindow(WNum,_,_,_,_,_,_,_),
    removewindow(WNum,1),
    _log_(s("Wrong data!\n"),0),
    readchar(_),
    exit(-1),!.
file_error:-
    makewindow(WNum,_,_,_,_,_,_,_),
    removewindow(WNum,1),
    _log_(s("Error: corrupted file!\n"),0),
    readchar(_),
    exit(-1).
read_int(Val):-
    readint(Val),
    !.
read_int(_):-
    _log_(s("Error: illegal integer value!\n"),0),
    !,fail.