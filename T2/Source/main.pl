%------------------------------------------------
% Module: main as m
% Section: definition
%
%------------------------------------------------
:- module(m,  [
                at/2,
                is_dead/1,
                energy/2,
                visited/1,
                is_adjacent/2,
                get_adjacent/3,
                get_adjacent_list/3,
                    ]).
:- dynamic([
              at/2,
              visited/1,
              energy/2,
              safe/1,
                  ]).
%------------------------------------------------
%
% Exported Predicates
%
%------------------------------------------------
  %Verify if the two positions are adjacent.
  is_adjacent(Position1, Position2):-
    get_adjacent( _ , Adj_p , Position1), Adj_p , Adj_p == Position2.

  %Returns the position adjacent to the given pos(x,y) at specific direction
    %Direction: North%
    get_adjacent(north, pos(X , NewY), pos(X , Y)):-
        NewY is Y-1, pos(X , NewY).
    %Direction: South%
    get_adjacent(south, pos(X , NewY), pos(X , Y)):-
        NewY is Y+1, pos(X , NewY).
    %Direction: East%
    get_adjacent(east, pos(NewX , Y), pos(X , Y)):-
        NewX is X+1, pos(NewX , Y).
    %Direction: West%
    get_adjacent(south, pos(NewX , Y), pos(X , Y)):-
        NewX is X-1, pos(NewX , Y).

  %Return a list with all, not known to be safe, adjacent postions to the given pos(x,y)
  get_adjacent_list(Direction, Position, List):-
    findall(Adj_p, (get_adjacent(Direction, Adj_p, Position), not(safe(Adj_p)), List), !.

  %Mark each one with elements of the list as Potential_Danger or Danger, depending on the knowledge about the position.
  danger_adjacent_list(_, _, []).
  danger_adjacent_list(Potential_Danger, Danger, [Head|Tail]):-
    ((not(at(Potential_Danger, Head)), assertz(at(Potential_Danger, Head)));
     (retract(at(Potential_Danger, Head)), assertz(at(Danger, Head)))
    ), danger_adjacent_list(Potential_Danger, Danger, Tail), !.

  %Correct positions surrounding the agent's current position to be safe.
  correct_safe:-
    at(agent, Position),
    get_adjacent(_, NewPosition, Position), NewPosition,
    (not(safe(NewPosition)), assertz(safe(NewPosition))).

  %Verify if the char is dead
  is_dead(char):-
      energy(char, Energy_points),
      Energy_points=<0.

  %Pensar nos casos de testes, buraco, cheiro, brisa e grito%
  check_unsafe_hole(breeze, Position):-
    at(breeze, Position),
      retract(at(breeze, Position)),
      get_adjacent_list(_ , Position, [Head|Tail]),
      ((length(Tail, 0) , assertz(at(hole, Head)));
        danger_adjacent_list(potential_hole, hole, [Head|Tail])
      ).


%------------------------------------------------
%
% DEFAULT CONFIG FOR AGENT
%
%------------------------------------------------
    %By definition the agent always starts on the position [1,1]%
    at(agent, pos(1,1)).

    %By definition the agent always starts with 100 points of life %
    energy(agent, 100).

    %We have to mark as visited the start position of the agent%
    visited(pos(1,1)).

%------------------------------------------------
%
% DEFAULT CONFIG FOR MONSTERS
%
%------------------------------------------------
    %By definition the monster01 always starts on the position [coordinate_X,coordinate_Y]%
    at(monster01, pos(random[ 1, 12), random[ 1, 12))).

    %By definition the monster02 always starts on the position [coordinate_X, coordinate_Y]%
    at(monster02, pos(random[ 1, 12), random[ 1, 12))).

    %By definition the monster01 always starts with 100 points of life %
    energy(monster01, 100).

    %By definition the monster01 always starts with 100 points of life %
    energy(monster02, 100).