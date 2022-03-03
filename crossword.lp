#const width=13.

dim(1..width).

tile_type(wall;blank).

1 {at(X,Y,T) : tile_type(T)} 1
  :- dim(X), dim(Y).

#show at/3.

step(0,1).
step(0,-1).
step(1,0).
step(-1,0).

% Radial symmetry 
twin(X, Y, X2, Y2)
  :-  dim(X), dim(Y),
      X-1 = Dx,
      Y-1 = Dy,
      width-Dx = X2,
      width-Dy = Y2.

:- at(X,Y,T), twin(X,Y,X2,Y2), not at(X2,Y2,T).

% at least 5/6 blank tiles
5*width*width/6 {at(X,Y,blank) : dim(X), dim(Y) }.
% at least [width] wall tiles
width {at(X,Y,wall) : dim(X), dim(Y) }.

% horizontal string of blank tiles
left_terminated(Y, 1) :- dim(Y).
left_terminated(Y, X+1) :- at(X,Y,wall).

right_terminated(Y, width) :- dim(Y).
right_terminated(Y, X) :- at(X+1,Y,wall).

% string(Y,X,N) means there's a consecutive string of N blanks on row Y starting at pos X
string_of_blanks(Y, X, 1) :- left_terminated(Y,X), at(X,Y,blank).
string_of_blanks(Y, X, N+1)
  :- string_of_blanks(Y, X, N), at(X+N,Y,blank).

segment_of_blanks(Y,X,N) :-
  string_of_blanks(Y,X,N), right_terminated(Y, X+N-1).

% #show segment_of_blanks/3.

% no horizontal segments of length < 3
:- dim(X), dim(Y), segment_of_blanks(Y,X,N), N < 3.
% or > 8
% :- dim(X), dim(Y), segment_of_blanks(Y,X,N), N > 8.

% vertical version
% vertical strings of blank tiles
top_terminated(X, 1) :- dim(X).
top_terminated(X, Y+1) :- at(X,Y,wall).

bottom_terminated(X, width) :- dim(X).
bottom_terminated(X, Y) :- at(X, Y+1, wall).

stack_of_blanks(X, Y, 1) :- top_terminated(X,Y), at(X,Y,blank).
stack_of_blanks(X, Y, N+1)
  :- stack_of_blanks(X, Y, N), at(X, Y+N, blank). 

vseg_of_blanks(X,Y,N) :-
  stack_of_blanks(X,Y,N), bottom_terminated(X, Y+N-1).

% no vertical segments of length < 3
:- dim(X), dim(Y), vseg_of_blanks(X,Y,N), N < 3.
% or > 8
% :- dim(X), dim(Y), vseg_of_blanks(X,Y,N), N > 8.

% showing the word set
% word(X,Y,N,Dir) means there's an N-letter word at pos(X,Y) in the Dir direction
word(X,Y,N,across) :- segment_of_blanks(Y,X,N).
word(X,Y,N,down) :- vseg_of_blanks(X,Y,N).
% #show word/4.

% next step: make the puzzle connected
% pick a random blank spot (or maybe the "minimal" one in the puzzle?)
% define what it means to be able to reach one X,Y from another
% require that there must be no blank spot in the puzzle that the chosen blank spot cannot reach

step(0,1; 0,-1; 1,0; -1,0).

1 {start(X,Y) : at(X,Y,blank) } 1.

% #show start/2.

reachable(X,Y) :- start(X,Y).
reachable(NX, NY) :-
  reachable(X,Y),
  step(DX, DY),
  NX = X+DX,
  NY = Y+DY,
  at(NX, NY, blank).

:- at(X,Y,blank), not reachable(X,Y).

