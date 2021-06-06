
% Generate the list containing the initial grid
color(X, Y, C):-
dot(C, [X, Y]).

color(X, Y, '-'):-
not(dot(_, [X, Y])).

incrementX(R, C, X, Y, NewX):-
Y =< C,
X < R,
NewX is X + 1.

incrementY(R, C, X, Y, NewY):-
X =< R,
Y < C,
NewY is Y + 1.

resetIndexY(R, C, X, Y, 0):-
X =< R,
Y == C.

resetIndexY(_, _, _, Y, Y).

getGrid(_, R, C, R, C, [X]):-
color(R, C, X).

getGrid(Initial, Index_X, Index_Y, R, C, Grid):-
      Index_Y < C,
      incrementY(R, C, Index_X, Index_Y, NewIndex_Y),
      getGrid(Initial, Index_X, NewIndex_Y, R, C, NewGrid),
      color(Index_X, Index_Y, Color),
      append([Color], NewGrid, Grid).

getGrid(Initial, Index_X, Index_Y, R, C, Grid):-
      Index_X < R,
      incrementX(R, C, Index_X, Index_Y, NewIndex_X),
      resetIndexY(R, C, Index_X, Index_Y, NewIndex_Y),
      getGrid(Initial, NewIndex_X, NewIndex_Y, R, C, NewGrid),
      color(Index_X, Index_Y, Color),
      append([Color], NewGrid, Grid).


% Printing the Grid
printGrid(_, Size, Size, _, _):- !.

printGrid(Grid, Size, Index, BreakLine, Cols):-
Index == BreakLine,
write('\n'),
BreakLine2 is BreakLine + Cols,
printGrid(Grid, Size, Index, BreakLine2, Cols).

printGrid(Grid, Size, Index, BreakLine, Cols):-
Index < Size,
nth0(Index, Grid, X),
write(X),
write('  '),
NewIndex is Index + 1,
printGrid(Grid, Size, NewIndex, BreakLine, Cols).

% Setting the Starting and Goal boolean lists
getColors([], []).

getColors([H | T], [H | Colors]):-
H \== '-',
getColors(T, Colors).

getColors([_ | T], Colors):-
getColors(T, Colors).

remove_duplicates([],[]).

remove_duplicates([H | T], List) :-    
     member(H, T),
     remove_duplicates( T, List).

remove_duplicates([H | T], [H|T1]) :- 
      \+member(H, T),
      remove_duplicates( T, T1).


replace([_|T],0,E,[E|T]).
replace([H|T],P,E,[H|R]) :-
    P > 0, NP is P-1, replace(T,NP,E,R).


side(Current, Index, _, Size):-
Index =< Size,
Current == Index,!.

side(Current, Index, Cols, Size):-
Index =< Size,
Current \== Index,
NewIndex is Index + Cols,
side(Current, NewIndex, Cols, Size),!.

onTheRight(Current, Cols, Size):-
side(Current, -1, Cols, Size).

onTheLeft(Current, Cols, Size):-
side(Current, 0, Cols, Size).

onTheTop(Current, Cols, _):-
Current =< Cols - 1.

onTheBottom(Current, Cols, Size):-
Current > Size - Cols.


% Base Cases
connect(Grid, Size, Cols, Current, Color, Goal, Grid):-
    not(onTheRight(Current, Cols, Size)),
    NextIndex is Current + 1,
    NextIndex == Goal,
    nth0(NextIndex, Grid, RightVal),
    RightVal == Color.

connect(Grid, Size, Cols, Current, Color, Goal, Grid):-
    not(onTheLeft(Current, Cols, Size)),
    NextIndex is Current - 1,
    NextIndex == Goal,
    nth0(NextIndex, Grid, LeftVal),
    LeftVal == Color.

connect(Grid, Size, Cols, Current, Color, Goal, Grid):-
    not(onTheTop(Current, Cols, Size)),
    NextIndex is Current - Cols,
    NextIndex == Goal,
    nth0(NextIndex, Grid, TopVal),
    TopVal == Color.

connect(Grid, Size, Cols, Current, Color, Goal, Grid):-
    not(onTheBottom(Current, Cols, Size)),
    NextIndex is Current + Cols,
    NextIndex == Goal,
    nth0(NextIndex, Grid, BottomVal),
    BottomVal == Color.

% Connect Down
connect(Grid, Size, Cols, Current, Color, Goal, NextGrid):-
    not(onTheBottom(Current, Cols, Size)),
    BottomIndex is Current + Cols,
    nth0(BottomIndex, Grid, BottomVal),
    BottomVal == '-',
    replace(Grid, BottomIndex, Color, NewGrid),
    connect(NewGrid, Size, Cols, BottomIndex, Color, Goal, NextGrid).
    
% Connect Right
connect(Grid, Size, Cols, Current, Color, Goal, NextGrid):-
    not(onTheRight(Current, Cols, Size)),
    RightIndex is Current + 1,
    nth0(RightIndex, Grid, RightVal),
    RightVal == '-',
    replace(Grid, RightIndex, Color, NewGrid),
    connect(NewGrid, Size, Cols, RightIndex, Color, Goal, NextGrid).

% Connect Up
connect(Grid, Size, Cols, Current, Color, Goal, NextGrid):-
    not(onTheTop(Current, Cols, Size)),
    TopIndex is Current - Cols,
    nth0(TopIndex, Grid, TopVal),
    TopVal == '-',
    replace(Grid, TopIndex, Color, NewGrid),
    connect(NewGrid, Size, Cols, TopIndex, Color, Goal, NextGrid).

% Connect Left
connect(Grid, Size, Cols, Current, Color, Goal, NextGrid):-
    not(onTheLeft(Current, Cols, Size)),
    LeftIndex is Current - 1,
    nth0(LeftIndex, Grid, LeftVal),
    LeftVal == '-',
    replace(Grid, LeftIndex, Color, NewGrid),
    connect(NewGrid, Size, Cols, LeftIndex, Color, Goal, NextGrid).

% Go through the Colors List and try to connect all the colors until we reach the goal state or we visit all the states
move(CurrentGrid, [C | _], NextGrid):-
  grid(_, Cols),
  findall(X, nth0(X, CurrentGrid, C), Indices),
  nth0(0, Indices, Start),
  nth0(1, Indices, Goal),
  length(CurrentGrid, Size),
  NewSize is Size - 1,
  connect(CurrentGrid, NewSize, Cols, Start, C, Goal, NextGrid).

removehead([_|Tail], Tail).

%general algorithm

%query of user and takes start state and next state
solve():-
    grid(R, C),
    NewR is R - 1,
    NewC is C - 1,
    getGrid([], 0, 0, NewR, NewC, Grid),
    getColors(Grid, ColorsInit),
    remove_duplicates(ColorsInit, Colors),
    path([[Grid,null]], [], Colors), !.

%main predicate that takes open list, closed list and goal state
path([],_,_):-
    write('\n\nNo solution'),nl,!.

path([[GoalGrid,_] | _], _, []):-
    write('\nGame:\n\n'),
    grid(R, C),
    NewR is R - 1,
    NewC is C - 1,
    getGrid([], 0, 0, NewR, NewC, Grid),
    Size is R * C,
    printGrid(Grid, Size, 0, C, C),
    write('\n\nSolution:\n'), nl ,
    printGrid(GoalGrid, Size, 0, C, C),
    write('\n\n'), !.

path(Open, Closed, Colors):-
    removeFromOpen(Open, [State, Parent], RestOfOpen),
    getchildren(Colors, State, Open, Closed, Children),
    append(Children, RestOfOpen, NewOpen),
    removehead(Colors, NewColors),
    path(NewOpen, [[State, Parent] | Closed], NewColors).

%gets Children of State that aren't in Open or Close
getchildren(Colors, State, Open, Closed, Children):-
    bagof(X, moves(Colors, State, Open, Closed, X), Children),!.
getchildren(_,_,_, []).

%gets head of open list to get its children later
removeFromOpen([State|RestOpen], State, RestOpen).

%gets next state given the current state
moves(Colors, State, Open, Closed, [NextGrid,State]):-
    move(State, Colors, NextGrid),
    \+ member([NextGrid,_], Open),
    \+ member([NextGrid,_], Closed).
