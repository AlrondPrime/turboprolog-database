include "DATABASE.PRO"

PREDICATES
include_static_db

CLAUSES
include_static_db:-
    retractall(_, processors),
    assert(processor("i7-8700", "intel", "desktop", 6, 12, 3.2)),
    %assert(processor("i5-10500", "intel", "desktop", 6, 12, 3.1)),
    %assert(processor("Ryzen 5 5600H", "amd", "mobile", 6, 12, 3.3)),
    %assert(processor("AMD PRO A6-8580", "amd", "desktop", 2, 2, 3.8)),
    !.