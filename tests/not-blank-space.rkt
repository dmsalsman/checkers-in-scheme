#lang scheme
(require "../checkers.rkt")
;valid moves
(printf "Example of trying to move to a non-blank cell:\n")
(define game (make-game))
(draw-board (get-board game))
(move game 1 5 0 4)
(move game 2 2 1 3)
(move game 0 4 2 2)
(move game 1 1 3 3)
(move game 5 5 4 4)
(move game 3 3 4 4)