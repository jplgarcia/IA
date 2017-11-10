%------------------------------------------------%
% Module: main as m                              %
%------------------------------------------------%

%------------------------------------------------
%Definitions
%------------------------------------------------
:- module(m,  [
                at/2,
                is_dead/1,
                energy/2,
                visited/1,
                is_adjacent/2,
                get_adjacent/3,
                get_adjacent_list/3,
                correct_safe/0,
                pos/2
                    ]).
%Obs: Pra que server esse comando module?
%R: Serve para modularizar e exportar os predicados que vamos usar em outros modulos.%

:- dynamic([
              at/2,
              visited/1,
              energy/2,
              safe/1,
			  agentfacing/2
                  ]).
%Obs: Pra que server esse comando dynamic?
%R: Vai falar pro prolog que certos predicados são mutáveis em tempo de execução.%

%------------------------------------------------%
%                                                %
% Exported Predicates                            %
%                                                %
%------------------------------------------------%
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
    findall(Adj_p, (get_adjacent(Direction, Adj_p, Position ), not(safe(Adj_p))), List), !.

  %Mark each element of the list as Potential_Danger or Danger, depending on the knowledge about the position.
  danger_adjacent_list(_, _, []).
  danger_adjacent_list(Potential_Danger, Danger, [Head|Tail]):-
    ((not(at(Potential_Danger, Head)), assertz(at(Potential_Danger, Head)));
     (retract(at(Potential_Danger, Head)), assertz(at(Danger, Head)))
    ), danger_adjacent_list(Potential_Danger, Danger, Tail), !.

  %Correct positions surrounding the agent's current position to be unsafe.
  correct_as_unsafe:-
    at(agent, Position),
    (check_hole(breeze, Position); true),
    (check_noises(noises, Position); true),
    (check_stench(stench, Position); true).

  %Correct positions surrounding the agent's current position to be safe.
  correct_as_safe:-
    at(agent, Position),
    get_adjacent(_, NewPosition, Position), NewPosition,
    (not(safe(NewPosition)), assertz(safe(NewPosition))).

  %Verify if the char is dead
  is_dead(char):-
      energy(char, Energy_points),
      Energy_points =< 0.

  %These cases right below it will explain how do we check if there's any potential danger at adjacent houses.%
  %If a potential danger appear twice times on the same list we assume that's a real danger%
  %Nao aguento mais comentar as coisas, meu deus...%
  %Case: BREEZE%
  check_hole(breeze, Position):-
    at(breeze, Position),
      retract(at(breeze, Position)),
      get_adjacent_list(_ , Position, [Head|Tail]),
      ((length(Tail, 0) , assertz(at(hole, Head)));
        danger_adjacent_list(potential_hole, hole, [Head|Tail])
      ).
  %Case: NOISES%
  check_noises(noises, Position):-
    at(noises, Position),
    retract(at(noises, Position)),
    get_adjacent_list(_ , Position, [Head|Tail]),
    ((length(Tail, 0), assertz(at(noises, Head)));
      danger_adjacent_list(potential_monster, monster, [Head|Tail])
    ).
  %Case: STENCH%
  check_stench(stench, Position):-
    at(stench, Position),
    retract(at(stench, Position)),
    get_adjacent_list(_, Position, [Head|Tail]),
    ((length(Tail, 0), assertz(at(stench, Head)));
      danger_adjacent_list(potential_monster, monster, [Head|Tail])
    ).

/**
	AGENT MOVEMENT
*/

step() :-
	at(agent,pos( Xaxis,Yaxis )),
	agentfacing( Xunit,Yunit ),
	X is Xaxis + Xunit,
	Y is Yaxis + Yunit,
	move( X,Y ),
	format("position(~a,~a)",[ X,Y ]).

move( X,Y ) :-
	retract(at(agent,pos( _ , _ ))),
	assertz(at(agent,pos( X,Y ))).

turn(right) :-
	agentfacing( Xunit,Yunit ),
	X is Yunit,
	Y is -Xunit,
	retract(agentfacing( _ , _ )),
	assertz(agentfacing( X,Y )),
	format("agentfacing(~a,~a)",[ X,Y ]).

turn(left) :-
	agentfacing( Xunit,Yunit ),
	X is - Yunit,
	Y is Xunit,
	retract(agentfacing( _ , _ )),
	assertz(agentfacing( X,Y )),
	format("agentfacing(~a,~a)",[ X,Y ]).

/**
	OTHER NAMES FOR turn( X )
 */
turn( X ) :-
	(
		(
			X == l;
			X == e;
			X == esquerda;
			X == cc;
			X == counter_clockwise),	%% cc = "counter clockwise"
		turn(left),!				%% "!" é para não continuar a avaliação (como um return)
	);
	(
		(
			X == r;
			X == d;
			X == direita;
			X == c;					%% c = "clockwise"
			X == clockwise),
		turn(right),!
	).
%------------------------------------------------
%
% DEFAULT CONFIG FOR AGENT
%
%------------------------------------------------

	 %By definition the agents allways starts facing the right
	  agentfacing(1,0).

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
    %As posições dos monstros são sorteadas através do python e inseridas pelo comando assert.
    %By definition the monster01 always starts with 100 points of life %
    energy(monster01, 100).

    %By definition the monster02 always starts with 100 points of life %
    energy(monster02, 100).

    %By definition the monster01 always starts with 100 points of life %
    energy(monster03, 100).

    %By definition the monster02 always starts with 100 points of life %
    energy(monster04, 100).

%------------------------------------------------
%
% DEFAULT CONFIG FOR POSITIONS
%
%------------------------------------------------
    pos(1, 1).
    pos(2, 1).
    pos(3, 1).
    pos(4, 1).
    pos(5, 1).
    pos(6, 1).
    pos(7, 1).
    pos(8, 1).
    pos(9, 1).
    pos(10, 1).
    pos(11, 1).
    pos(12, 1).
    pos(1, 2).
    pos(2, 2).
    pos(3, 2).
    pos(4, 2).
    pos(5, 2).
    pos(6, 2).
    pos(7, 2).
    pos(8, 2).
    pos(9, 2).
    pos(10, 2).
    pos(11, 2).
    pos(12, 2).
    pos(1, 3).
    pos(2, 3).
    pos(3, 3).
    pos(4, 3).
    pos(5, 3).
    pos(6, 3).
    pos(7, 3).
    pos(8, 3).
    pos(9, 3).
    pos(10, 3).
    pos(11, 3).
    pos(12, 3).
    pos(1, 4).
    pos(2, 4).
    pos(3, 4).
    pos(4, 4).
    pos(5, 4).
    pos(6, 4).
    pos(7, 4).
    pos(8, 4).
    pos(9, 4).
    pos(10, 4).
    pos(11, 4).
    pos(12, 4).
    pos(1, 5).
    pos(2, 5).
    pos(3, 5).
    pos(4, 5).
    pos(5, 5).
    pos(6, 5).
    pos(7, 5).
    pos(8, 5).
    pos(9, 5).
    pos(10, 5).
    pos(11, 5).
    pos(12, 5).
    pos(1, 6).
    pos(2, 6).
    pos(3, 6).
    pos(4, 6).
    pos(5, 6).
    pos(6, 6).
    pos(7, 6).
    pos(8, 6).
    pos(9, 6).
    pos(10, 6).
    pos(11, 6).
    pos(12, 6).
    pos(1, 7).
    pos(2, 7).
    pos(3, 7).
    pos(4, 7).
    pos(5, 7).
    pos(6, 7).
    pos(7, 7).
    pos(8, 7).
    pos(9, 7).
    pos(10, 7).
    pos(11, 7).
    pos(12, 7).
    pos(1, 8).
    pos(2, 8).
    pos(3, 8).
    pos(4, 8).
    pos(5, 8).
    pos(6, 8).
    pos(7, 8).
    pos(8, 8).
    pos(9, 8).
    pos(10, 8).
    pos(11, 8).
    pos(12, 8).
    pos(1, 9).
    pos(2, 9).
    pos(3, 9).
    pos(4, 9).
    pos(5, 9).
    pos(6, 9).
    pos(7, 9).
    pos(8, 9).
    pos(9, 9).
    pos(10, 9).
    pos(11, 9).
    pos(12, 9).
    pos(1, 10).
    pos(2, 10).
    pos(3, 10).
    pos(4, 10).
    pos(5, 10).
    pos(6, 10).
    pos(7, 10).
    pos(8, 10).
    pos(9, 10).
    pos(10, 10).
    pos(11, 10).
    pos(12, 10).
    pos(1, 11).
    pos(2, 11).
    pos(3, 11).
    pos(4, 11).
    pos(5, 11).
    pos(6, 11).
    pos(7, 11).
    pos(8, 11).
    pos(9, 11).
    pos(10, 11).
    pos(11, 11).
    pos(12, 11).
    pos(1, 12).
    pos(2, 12).
    pos(3, 12).
    pos(4, 12).
    pos(5, 12).
    pos(6, 12).
    pos(7, 12).
    pos(8, 12).
    pos(9, 12).
    pos(10, 12).
    pos(11, 12).
    pos(12, 12).
