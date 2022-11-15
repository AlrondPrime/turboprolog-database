include "HELPERS.PRO"

DOMAINS
file = out; in
name, manufacturer, segment = string
total_cores = integer
total_threads = integer
base_frequency = real

CONSTANTS
header = "Name;Manufacturer;Segment;Total Cores;Total Threads;Base Frequency;\n"

DATABASE - processors
processor(name, manufacturer, segment, 
total_cores, total_threads, base_frequency)

PREDICATES
print_db
print_item(name, manufacturer, segment, 
total_cores, total_threads, base_frequency)
print_next
save_next
next_sep(string, integer, integer, string)
parse_next(string)
read_header(string, string)
edit_field(string, processors)
verify_manufacturer(manufacturer)
verify_segment(segment)
verify_char(char)
_save_(string)
_load_(string)

CLAUSES
read_header(Data, Rest):-
    str_len(header, Len),
    frontstr(Len, Data, Header, Rest),
    Header=header.
verify_char(Ch):-
    Ch >= '0' and Ch <= '9', ! or
    Ch >= 'a' and Ch <= 'z', ! or
    Ch >= 'A' and Ch <= 'Z', ! or
    Ch = '-', ! or 
    Ch = '_', ! or
    Ch = ';', ! or
    Ch = '.', ! or
    Ch = ' ', ! or
    Ch = '\n', !.
verify_char(Ch):-
    _log_(s("Unexpected char \'"),1),
    str_char(Str,Ch),
    _log_(s(Str),0),
    _log_(s("\' in database file!\m"),0),
    !,fail.
next_sep("",Index,0,""):-
    _log_(s("Expected semicolon in this line:\n"),0),
    !,fail.
next_sep(Str, Index, Result, Rest):-
    frontchar(Str,NextChar,NextStr),   
    verify_char(NextChar),
    NextChar<>';',
    NextIndex=Index+1,
    next_sep(NextStr, NextIndex, Result, Rest),
    !.
next_sep(Str, Index, Result, Rest):-
    frontchar(Str,NextChar,Rest),
    NextChar=';',
    Result=Index.
parse_next("").
parse_next(Data):-
    next_sep(Data,0,Index1,Rest1),
    frontstr(Index1,Data,Name,_),
    
    next_sep(Rest1,0,Index2,Rest2),
    frontstr(Index2,Rest1,Manufacturer,_),

    next_sep(Rest2,0,Index3,Rest3),
    frontstr(Index3,Rest2,Segment,_),

    next_sep(Rest3,0,Index4,Rest4),
    frontstr(Index4,Rest3,Cores,_),
    str_int(Cores,Total_Cores),
    
    next_sep(Rest4,0,Index5,Rest5),
    frontstr(Index5,Rest4,Threads,_),
    str_int(Threads,Total_Threads),
    
    next_sep(Rest5,0,Index6,Rest6),
    frontstr(Index6,Rest5,Fr,_),
    fronttoken(Fr,Ch,Ghz),
    Ghz="Ghz",
    str_real(Ch,Base_Frequency),
    
    % skipping newline character
    frontchar(Rest6,_,Rest),
    
    retractall(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),
    assert(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),
    parse_next(Rest).
parse_next(Data):-
    shiftwindow(2),
    cursor(R,C),
    R1=R+1,
    field_str(R,0,78,Data),
    cursor(R1,0),
    shiftwindow(1),
    fail.

_load_(Filename):-
    openread(in, Filename),
    readdevice(in),
    file_str(Filename, Data),
    read_header(Data, Rest),
    parse_next(Rest),
    closefile(in),
    readdevice(keyboard),
    !.
_load_(_):-
    closefile(in),
    readdevice(keyboard),
    _log_(s("Error loading database from file!\n"),0),
    fail.
save_next:-
    processor(Name, Manufacturer, Segment, 
        Total_Cores, Total_Threads, Base_Frequency),   
    write(Name, ";"),
    write(Manufacturer, ";"),
    write(Segment, ";"),
    write(Total_Cores, ";"),
    write(Total_Threads, ";"),
    write(Base_Frequency, "Ghz;"),
    write('\n'),
    fail.
save_next.
_save_(Filename):-
    openwrite(out, Filename), !,
    writedevice(out), 
    write(header),
    save_next,
    writedevice(screen),
    closefile(out),
    !.
_save_(_).
print_item(Name, Manufacturer, Segment, 
        Total_Cores, Total_Threads, Base_Frequency):-
    write("Name:",Name, "  "),
    write("Manufacturer:",Manufacturer, "  "),
    write("Segment:",Segment, '\n'),
    write("Total Cores:",Total_Cores, "  "),
    write("Total Threads:",Total_Threads, "  "),
    write("Base Frequency:",Base_Frequency, "GHz\n"),
    write('\n').

print_next:-
    processor(Name, Manufacturer, Segment, 
        Total_Cores, Total_Threads, Base_Frequency),
    write("Name:",Name, "  "),
    write("Manufacturer:",Manufacturer, "  "),
    write("Segment:",Segment, '\n'),
    write("Total Cores:",Total_Cores, "  "),
    write("Total Threads:",Total_Threads, "  "),
    write("Base Frequency:",Base_Frequency, "GHz\n"),
    write('\n'),
    fail.
print_next.
print_db:-
    makewindow(3,7,7,"Database", 0,0,25,80),
    clearwindow,
    print_next,readchar(_), 
    removewindow(3,1),
    !.

edit_field("Name", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Name:"),readln(Name1),
    Name1<>"",
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name1, Manufacturer, Segment , Total_Cores, Total_Threads, Base_Frequency)),  
    !.
edit_field("Manufacturer", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Manufacturer:"),readln(Manufacturer1), 
    Manufacturer1<>"", verify_manufacturer(Manufacturer1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer1, Segment , Total_Cores, Total_Threads, Base_Frequency)),  
    !.
edit_field("Segment", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Segment:"),readln(Segment1),
    Segment1<>"", verify_segment(Segment1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment1 , Total_Cores, Total_Threads, Base_Frequency)),  
    !.
edit_field("Total Cores", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Total Cores:"),readint(Total_Cores1),
    Total_Cores1>0,
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment, Total_Cores1, Total_Threads, Base_Frequency)),  
    !.
edit_field("Total Threads", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Total Threads:"),readint(Total_Threads1),
    Total_Threads1>0,
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment , Total_Cores, Total_Threads1, Base_Frequency)),  
    !.
edit_field("Base Frequency", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Base Frequency:"),readreal(Base_Frequency1),
    Base_Frequency1>0, Base_Frequency<1.7E+308,
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment , Total_Cores, Total_Threads, Base_Frequency1)),  
    !.
edit_field(_, _):-
    cursor(Row, Column),
    field_attr(Row,Column,11,64),
    field_str(Row,Column,11,"Wrong field name!"),
    readchar(_),
    !,fail.
verify_manufacturer("amd").
verify_manufacturer("amd").
verify_manufacturer(_):-_log_(s("Illegal manufacturer\n"),1),fail.
verify_segment("mobile").
verify_segment("desktop").
verify_segment(_):-_log_(s("Illegal segment\n"),1),fail.
