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
search(processors)
print_db
print_item(name, manufacturer, segment, 
total_cores, total_threads, base_frequency)
save_next
next_sep(string, integer, integer, string)
parse_data(string)
read_header(string, string)
edit_field(string, processors)
verify_manufacturer(manufacturer)
verify_segment(segment)
verify_name(string)
verify_char(char)
verify_int(integer)
verify_real(real)
_save_(string)
_load_(string)
get_fragment(string,string)
check_newline(string,string)
read_name(string,string,string)
read_manufacturer(string,string,string)
read_segment(string,string,string)
read_cores(string,integer,string)
read_threads(string,integer,string)
read_frequency(string,real,string)

CLAUSES
read_header(Data, Rest):-
    str_len(header, Len),
    frontstr(Len, Data, Header, Rest),
    Header=header,
    !.
read_header(Data, _):-
    _log_(s("Corrupted header of database file!\n"),1),
    !,fail.
verify_char(Ch):-
    Ch >= '0' and Ch <= '9', ! or
    Ch >= 'a' and Ch <= 'z', ! or
    Ch >= 'A' and Ch <= 'Z', ! or
    Ch = '-', ! or 
    Ch = '_', ! or
    Ch = '.', ! or
    Ch = ';', ! or
    Ch = ' ', 
    !.
verify_char(Ch):-
    _log_(s("Unexpected character \'"),1),
    str_char(Str,Ch),
    _log_(s(Str),0),
    _log_(s("\' in database file!\n"),0),
    !,fail.
next_sep("",Index,0,""):-
    _log_(s("Error: expected semicolon\n"),0), 
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
    Result=Index,
    !.
check_newline(Data,Rest):-
    frontchar(Data,Ch,Rest),
    Ch='\n',!.
check_newline(Data,_):-
    _log_(s("Error: expected line break\n"),0),
    !,fail.
parse_data("").
parse_data(Data):- 
    read_name(Data,Name,Rest1),
    read_manufacturer(Rest1,Manufacturer,Rest2),
    read_segment(Rest2,Segment,Rest3),
    read_cores(Rest3,Total_Cores,Rest4),
    read_threads(Rest4,Total_Threads,Rest5),
    read_frequency(Rest5,Base_Frequency,Rest6),

    % skipping newline character
    check_newline(Rest6,Rest),
    
    retractall(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),
    assert(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),
    !,parse_data(Rest),
    !.
parse_data(Data):-
    shiftwindow(2),
    _log_(s("Cannot parse this line:\n"),0),
    write('\"'),
    get_fragment(Data,Line),
    write(Line),
    write("\"\n"),
    shiftwindow(1),
    !,fail.
read_name(Data,Name,Rest):-
    next_sep(Data,0,Index,Rest),
    frontstr(Index,Data,Name,_),
    verify_name(Name),
    !.
read_name(_,_,_):-
    _log_(s("Error: cannot read name\n"),0),
    !,fail.
read_manufacturer(Data,Manufacturer,Rest):-
    next_sep(Data,0,Index,Rest),
    frontstr(Index,Data,Manufacturer,_),
    verify_manufacturer(Manufacturer),
    !.
read_manufacturer(_,_,_):-
    _log_(s("Error: cannot read manufacturer\n"),0),
    !,fail.
read_segment(Data,Segment,Rest):-
    next_sep(Data,0,Index,Rest),
    frontstr(Index,Data,Segment,_),
    verify_segment(Segment),
    !.
read_segment(_,_,_):-
    _log_(s("Error: cannot read segment\n"),0),
    !,fail.
read_cores(Data,Total_Cores,Rest):-
    next_sep(Data,0,Index,Rest),
    frontstr(Index,Data,Cores,_),
    str_int(Cores,Total_Cores),
    verify_int(Total_Cores),
    !.
read_cores(_,_,_):-
    _log_(s("Error: cannot read cores\n"),0),
    !,fail.
read_threads(Data,Total_Threads,Rest):-
    next_sep(Data,0,Index,Rest),
    frontstr(Index,Data,Threads,_),
    str_int(Threads,Total_Threads),
    verify_int(Total_Threads),
    !.
read_threads(_,_,_):-
    _log_(s("Error: cannot read threads\n"),0),
    !,fail.
read_frequency(Data,Base_Frequency,Rest):-
    next_sep(Data,0,Index,Rest),
    frontstr(Index,Data,Frequency,_),
    fronttoken(Frequency,Value,Ghz),
    Ghz="Ghz",
    str_real(Value,Base_Frequency),
    verify_real(Base_Frequency),
    !.
read_frequency(_,_,_):-
    _log_(s("Error: cannot read frequency\n"),0),
    !,fail.
_load_(Filename):-
    openread(in, Filename),
    readdevice(in),
    file_str(Filename, Data),
    read_header(Data, Rest),
    Rest<>"",
    parse_data(Rest),
    closefile(in),
    readdevice(keyboard).
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
print_db:-
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
print_db.
edit_field("Name", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Name:"),readln(Name1), 
    verify_name(Name1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name1, Manufacturer, Segment , Total_Cores, Total_Threads, Base_Frequency)),  
    !.
edit_field("Manufacturer", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Manufacturer:"),readln(Manufacturer1), 
    verify_manufacturer(Manufacturer1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer1, Segment , Total_Cores, Total_Threads, Base_Frequency)),  
    !.
edit_field("Segment", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Segment:"),readln(Segment1),
    verify_segment(Segment1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment1 , Total_Cores, Total_Threads, Base_Frequency)),  
    !.
edit_field("Total Cores", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Total Cores:"),read_int(Total_Cores1),
    verify_int(Total_Cores1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment, Total_Cores1, Total_Threads, Base_Frequency)),  
    !.
edit_field("Total Threads", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Total Threads:"),read_int(Total_Threads1),
    verify_int(Total_Threads1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment , Total_Cores, Total_Threads1, Base_Frequency)),  
    !.
edit_field("Base Frequency", processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Edit Base Frequency:"),readreal(Base_Frequency1),
    verify_real(Base_Frequency1),
    retract(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    assert(processor(Name, Manufacturer, Segment , Total_Cores, Total_Threads, Base_Frequency1)),  
    !.
edit_field(_, _):-
    _log_(s("Illegal field name!\n"),1),
    !,fail.
verify_manufacturer("amd"):-!.
verify_manufacturer("intel"):-!.
verify_manufacturer(_):-
    _log_(s("Illegal manufacturer\n"),1),
    fail.
verify_segment("mobile"):-!.
verify_segment("desktop"):-!.
verify_segment(_):-
    _log_(s("Illegal segment\n"),1),
    fail.
verify_int(Val):-
    Val>0,!.
verify_int(_):-
    _log_(s("Illegal value\n"),1),
    fail.
verify_real(Val):-
    Val>0, Val<1E+308,!.
verify_real(_):-
    _log_(s("Illegal value\n"),1),
    fail.
search(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)):-
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),!.
search(_):-
    _log_(s("There is no processor with this name!\n"),1),
    fail.
verify_name(Name):-
    Name<>"",!.
verify_name(_):-
    _log_(s("Illegal name\n"),1),
    fail.
get_fragment(In,Out):-
    str_len(In,Len),
    Len<=75,
    Out=In,
    !.
get_fragment(In,Out):-
    frontstr(75,In,Out,_),
    !.