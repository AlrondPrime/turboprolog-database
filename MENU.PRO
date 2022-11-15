include "STATICDB.PRO"

DOMAINS
row=integer
key = enter; esc; up_arrow; down_arrow; other
list_str = string*

CONSTANTS
menu_items = ["Print database","Add item to database","Edit database","Delete database item","Save database to file","Load database from file"]
menu_items_count = 6

PREDICATES
key_code(key, integer)
key_code2(key, integer)
main
showmenu(list_str)
render(row)
update_highlight(row, row)
callback(key, row, row)
case(integer)
row_len(row, integer)
row_len(row, integer, list_str)

CLAUSES
row_len(Row,Len):-row_len(Row,Len,menu_items),!.
row_len(_,-1,[]):-_log_(s("Invalid menu items list!")), exit(-1),!.
row_len(0,Len,[Str|_]):-str_len(Str,Len),!.
row_len(Row,Len,[_|Tail]):-
    NextRow=Row-1, row_len(NextRow,Len,Tail),!.
% key code to key name
key_code(Key, 0):-
    readchar(T), char_int(T, Val), key_code2(Key, Val),!. 
key_code(enter, 13).
key_code(esc, 27).
% keys with additional keycode \0
key_code2(up_arrow, 72).
key_code2(down_arrow,80).
key_code2(other,_).
% updating menu's highlighting
update_highlight(Row, NextRow):-
    row_len(Row,Len),
    field_attr(Row,0,Len,7),
    row_len(NextRow,NextLen),
    field_attr(NextRow,0,NextLen,14),!.
% resolving user's choices in menu
callback(esc, _, _):-!, fail.
callback(down_arrow, Row, NextRow):-
    Row=menu_items_count-1,
    NextRow=0, update_highlight(Row, NextRow),!.
callback(down_arrow, Row, NextRow):-
    NextRow=Row+1,update_highlight(Row, NextRow),!.
callback(up_arrow, Row, NextRow):-
    Row=0,
    NextRow=menu_items_count-1, update_highlight(Row, NextRow),!.
callback(up_arrow, Row, NextRow):-
    NextRow=Row-1,update_highlight(Row, NextRow),!.
callback(enter, Row, Row):-
    trap(case(Row), _, error),!.
callback(other, Row, Row):-!.
% menu rows(items)
case(0):-% printing database
    print_db,!.
case(1):-% adding database item
    makewindow(3,7,7,"Item adding", 0,0,25,80),
    write("Enter name:"),readln(Name),
    Name<>"",
    write("Enter Manufacturer(intel/amd):"),readln(Manufacturer),
    Manufacturer<>"", verify_manufacturer(Manufacturer),
    write("Enter Segment(desktop/mobile):"),readln(Segment),
    Segment<>"", verify_segment(Segment),
    write("Enter Total Cores:"),readint(Total_Cores),
    Total_Cores>0,
    write("Enter Total Threads:"),readint(Total_Threads),
    Total_Threads>0,
    write("Enter Base Frequency:"),readreal(Base_Frequency),
    Base_Frequency>0, Base_Frequency<1E+308,
    assert(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    _log_(s("Database is succcessfully edited!")), 
    removewindow(3,1),
    !.
case(2):-% editing database item
    makewindow(3,7,7,"Item editing", 0,0,25,80),
    write("Enter name for editing database item:"),readln(Name),
    processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    print_item(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Enter field which you want to change:"),
    readln(Line),
    edit_field(Line, processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)), 
    _log_(s("Database is succcessfully edited!")),
    removewindow(3,1),
    !.
case(3):-% deleting database item
    makewindow(3,7,7,"Database editing", 0,0,25,80),
    write("Enter Name to delete:"),readln(Name),
    retractall(processor(Name, _, _, _, _, _)),  
    _log_(s("Database item is succcessfully deleted!")), 
    removewindow(3,1),
    !.
case(4):-% saving to file      
    makewindow(3,7,7,"Database saving", 0,0,25,80),
    trap(dir("", "*.*", Filename,1,1,1), _, file_error),
    _save_(FileName),
    _log_(s("Database is succcessfully saved!")),
    removewindow(3,1),
    !.
case(5):-% loading from file
    makewindow(3,7,7,"Database loading", 0,0,25,80),
    trap(dir("", "*.*", Filename,1,1,1), _, file_error),
    _load_(Filename),
    _log_(s("Database is succcessfully loaded!")),
    removewindow(3,1),
    !.

render(Row):-
    readchar(Input),
    char_int(Input, Val),
    key_code(Key, Val),
    callback(Key, Row, NextRow),
    render(NextRow),
    !.

showmenu([]).
showmenu([Str|Tail]):-
    write(Str),nl,
    showmenu(Tail),!.

main:-
    makewindow(1, 7, 14, "Menu", 0, 0, 17, 80),
    makewindow(2, 7, 12, "Message", 17, 0, 8, 80),
    shiftwindow(1),
    %include_static_db,
    showmenu(menu_items),
    update_highlight(0,0),
    render(0).
