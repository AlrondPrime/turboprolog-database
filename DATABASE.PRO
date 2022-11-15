include "DEBUG.PRO"

DOMAINS
file = out; in
name, manufacturer, segment = string
total_cores = integer
total_threads = integer
base_frequency = real

DATABASE - processors
processor(name, manufacturer, segment, 
total_cores, total_threads, base_frequency)

PREDICATES
print_db
print_item(name, manufacturer, segment, 
total_cores, total_threads, base_frequency)
print_next
save_next
comma_index(string, integer, integer, string)
parse_next(string)
edit_field(string, processors)
verify_manufacturer(manufacturer)
verify_segment(segment)
_save_(string)
_load_(string)

CLAUSES
comma_index(Str, Index, Result, Rest_):-
    frontchar(Str,NextChar,Rest),
    NextChar<>';',
    NextIndex=Index+1,
    comma_index(Rest, NextIndex, Result, Rest_),
    !.
comma_index(Str, Index, Result, Rest_):-
    frontchar(Str,_,Rest_),
    Result=Index,
    !.

parse_next("").
parse_next(Line):-
    comma_index(Line,0,Index1,Rest1),
    frontstr(Index1,Line,Name,_),
    %_log_(s(Name)),
    
    comma_index(Rest1,0,Index2,Rest2),
    frontstr(Index2,Rest1,Manufacturer,_),
    %_log_(s(Man)),

    comma_index(Rest2,0,Index3,Rest3),
    frontstr(Index3,Rest2,Segment,_),
    %_log_(s(Seg)),

    comma_index(Rest3,0,Index4,Rest4),
    frontstr(Index4,Rest3,Cores_,_),
    str_int(Cores_,Total_Cores),
    %_log_(i(Total_Cores)),
    
    comma_index(Rest4,0,Index5,Rest5),
    frontstr(Index5,Rest4,Threads_,_),
    str_int(Threads_,Total_Threads),
    %_log_(i(Total_Threads)),

    comma_index(Rest5,0,Index6,Rest6),
    frontstr(Index6,Rest5,Fr_,_),
    fronttoken(Fr_,Val,Ghz),
    Ghz="Ghz",    
    str_real(Val,Base_Frequency),
    %_log_(r(Base_Frequency)),

    frontchar(Rest6,_,Rest),

    assert(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),
    parse_next(Rest).

_load_(Filename):-
    openread(in, Filename), !,
    readdevice(in),
    file_str(Filename, Line),
    parse_next(Line),
    closefile(in),
    readdevice(keyboard),
    !.
_load_(_):-
    _log_(s("Error loading file")),!.
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
    write("Name;Manufacturer;Segment;Total Cores;Total Threads;Base Frequency;\n"),
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
    field_str(Row,Column,11,"Wrong data!"),
    readchar(_),
    exit(-1),
    !.
verify_manufacturer("amd").
verify_manufacturer("amd").
verify_manufacturer(_):-!,fail.
verify_segment("mobile").
verify_segment("desktop").
verify_segment(_):-!,fail.
