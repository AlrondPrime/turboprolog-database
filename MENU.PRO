include "STATICDB.PRO"

DOMAINS
row=integer
list_str = string*

CONSTANTS
menu_items = ["Print database","Add item to database","Edit database","Delete database item","Save database to file","Load database from file"]
menu_items_count = 6
root_dir=""
file_mask="*.csv"

PREDICATES
main
showmenu(list_str)
render(row)
update_highlight(row, row)
callback(key, row, row)
case(row)
row_len(row, integer, list_str)

CLAUSES
% length of menu item lines
row_len(_,-1,[]):-_log_(s("Invalid menu items list!\n"),1), exit(-1),!.
row_len(0,Len,[Str|_]):-str_len(Str,Len),!.
row_len(Row,Len,[_|Tail]):-NextRow=Row-1, row_len(NextRow,Len,Tail),!.
% updating menu's highlight
update_highlight(Row, NextRow):-
    row_len(Row,Len,menu_items),
    field_attr(Row,0,Len,7),
    row_len(NextRow,NextLen,menu_items),
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
    shiftwindow(2),
    clearwindow,
    shiftwindow(1),
    trap(case(Row), _, error),
    !.
callback(other, Row, Row):-!.
% menu rows(items)
case(0):-% printing database
    makewindow(3,7,7,"Database", 0,0,25,80),
    print_db,
    readchar(_), 
    removewindow(3,1),
    !.
case(1):-% adding database item
    makewindow(3,7,7,"Item adding", 0,0,25,80),
    write("Enter Name:"),readln(Name),
    verify_name(Name),
    write("Enter Manufacturer(intel/amd):"),readln(Manufacturer),
    verify_manufacturer(Manufacturer),
    write("Enter Segment(desktop/mobile):"),readln(Segment),
    verify_segment(Segment),
    write("Enter Total Cores:"),read_int(Total_Cores),
    verify_int(Total_Cores),
    write("Enter Total Threads:"),read_int(Total_Threads),
    verify_int(Total_Threads),
    write("Enter Base Frequency:"),readreal(Base_Frequency),
    verify_real(Base_Frequency),
    assert(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),  
    _log_(s("Database is succcessfully edited!\n"),1), 
    removewindow(3,1),
    !.
case(2):-% editing database item
    makewindow(3,7,7,"Item editing", 0,0,25,80),
    write("Enter name for editing database item:"),readln(Name),
    search(processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)),
    print_item(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency),
    write("Enter field which you want to change:"),
    readln(Line),
    edit_field(Line, processor(Name, Manufacturer, Segment, Total_Cores, Total_Threads, Base_Frequency)), 
    _log_(s("Database is succcessfully edited!"),1),
    removewindow(3,1),
    !.
case(3):-% deleting database item
    makewindow(3,7,7,"Database editing", 0,0,25,80),
    write("Enter Name to delete:"),readln(Name),
    search(processor(Name, _, _, _, _, _)),
    retractall(processor(Name, _, _, _, _, _)),  
    _log_(s("Database item is succcessfully deleted!\n"),1), 
    removewindow(3,1),
    !.
case(4):-% saving to file      
    makewindow(3,7,7,"Database saving", 0,0,25,80),
    dir(root_dir, file_mask, Filename,1,1,1),
    _save_(FileName),
    _log_(s("Database is succcessfully saved!\n"),1),
    removewindow(3,1),
    !.
case(5):-% loading from file
    makewindow(3,7,7,"Database loading", 0,0,25,80),
    dir(root_dir, file_mask, Filename,1,1,1),
    _load_(Filename),
    _log_(s("Database is succcessfully loaded!\n"),1),
    removewindow(3,1),!.
case(_):-
    existwindow(3),
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
    makewindow(1, 7, 14, "Menu", 0, 0, 16, 80),
    makewindow(2, 7, 12, "Message", 16, 0, 9, 80),
    shiftwindow(1),
    include_static_db,
    showmenu(menu_items),
    update_highlight(0,0),
    render(0).
