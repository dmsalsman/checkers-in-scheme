#lang scheme
(require 2htdp/image)
(require 2htdp/universe)
(provide (all-defined-out))

(define (make-board)
  (vector
   (list->vector '(P2 OFF P2 OFF P2 OFF P2 OFF))
   (list->vector '(OFF P2 OFF P2 OFF P2 OFF P2))
   (list->vector '(P2 OFF P2 OFF P2 OFF P2 OFF))
   (list->vector '(OFF BLANK OFF BLANK OFF BLANK OFF BLANK))
   (list->vector '(BLANK OFF BLANK OFF BLANK OFF BLANK OFF))
   (list->vector '(OFF P1 OFF P1 OFF P1 OFF P1))
   (list->vector '(P1 OFF P1 OFF P1 OFF P1 OFF))
   (list->vector '(OFF P1 OFF P1 OFF P1 OFF P1))))

(define (get-state board x y)
  (vector-ref (vector-ref board y) x))

(define (set-state! board x y state)
  (vector-set! (vector-ref board y) x state))

(define (make-game)
  (vector (make-board) 'P1))

(define (get-board game)
  (vector-ref game 0))

(define (set-board! game board)
  (vector-set! game 0 board))

(define (get-player game)
  (vector-ref game 1))

(define (set-player! game player)
  (vector-set! game 1 player))

(define (get-opposing-player game)
  (cond 
    [(equal? (get-player game) 'P1) 'P2] 
    [(equal? (get-player game) 'P2) 'P1] 
    [#t 'NIL]))

(define (change-player game)
  (set-player! game (get-opposing-player game)))
        
(define (opposing? state1 state2)
  (cond [(equal? state1 'P1) (equal? state2 'P2)]
        [(equal? state1 'P2) (equal? state2 'P1)]
        [#t #f]))

(define (get-player-string game)
  (cond [(equal? (get-player game) 'P1) "P1"]
        [(equal? (get-player game) 'P2) "P2"]
        [#t "nil"]))

(define (blank? board x y)
  (equal? 'BLANK (get-state board x y)))

(define (average x y)
  (/ (+ x y) 2))

(define (get-state-between board x1 y1 x2 y2)
  (get-state board (average x1 x2) (average y1 y2)))

(define (set-state-between! board x1 y1 x2 y2 state)
  (set-state! board (average x1 x2) (average y1 y2) state))

(define (move game start-x start-y end-x end-y)
  (let ((board (get-board game)))
    (printf (string-append (get-player-string game) " moved (" (number->string start-x) "," (number->string start-y) ")->(" (number->string end-x) "," (number->string end-y) "):\n"))
    (unless (blank? board end-x end-y)
      (error move "The cell you're trying to move to is not blank!"))
    (unless (equal? (get-player game) (get-state board start-x start-y))
      (error move "That's not your piece!"))
    (cond [(and
            (= 1 (if (equal? (get-player game) 'P1) (- start-y end-y) (- end-y start-y)))
            (= 1 (abs (- start-x end-x))))
           (set-state! board end-x end-y (get-player game))
           (set-state! board start-x start-y 'BLANK)]
          [(and
            (= 2 (if (equal? (get-player game) 'P1) (- start-y end-y) (- end-y start-y)))
            (= 2 (abs (- start-x end-x))))
           (unless (opposing? (get-player game) (get-state-between board start-x start-y end-x end-y))
             (error move "You cannot jump your own pieces!"))
           (set-state! board start-x start-y 'BLANK)
           (set-state-between! board start-x start-y end-x end-y 'BLANK)
           (set-state! board end-x end-y (get-player game))])
    (change-player game)
    (set-board! game board)
    (draw-board board)))

(define (OFF width)
  (rectangle width width 'solid 'black))

(define (BLANK width)
  (rectangle width width 'solid 'red ))

(define (P1 width)
  (overlay (circle (/ (* 3 width) 8) 'solid 'black)
           (BLANK width)))

(define (P2 width)
  (overlay (circle (/ (* 4 width) 14) 'solid 'red)
  (overlay (circle (/ (* 3 width) 8) 'solid 'black)
           (BLANK width))))

(define (get-image board x y width)
  (cond [(equal? (get-state board x y) 'OFF) (OFF width)]
        [(equal? (get-state board x y) 'BLANK) (BLANK width)]
        [(equal? (get-state board x y) 'P1) (P1 width)]
        [(equal? (get-state board x y) 'P2) (P2 width)]))

(define (draw-board board)
  (let* ([width 48]
        [scene (empty-scene (* width 9) (* width 9))])
        (do ((i 0 (+ i 1))) ((> i 7))
          (do ((j 0 (+ j 1))) ((> j 7))
            (set! scene (place-image (get-image board j i width) (* (+ j 0.5) width) (* (+ i 0.5) width) scene)))
          (set! scene (place-image (text (number->string i) (quotient (* 2 width) 3.0) 'black) (* 8.5 width) (* (+ i 0.5) width) scene))
          (set! scene (place-image (text (number->string i) (quotient (* 2 width) 3.0) 'black) (* (+ i 0.5) width) (* 8.5 width) scene)))
   (display scene)
   (printf "\n")))