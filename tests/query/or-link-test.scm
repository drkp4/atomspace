;
; or-link-test.scm -- Verify that OrLink produces sums during search.
;

(use-modules (opencog) (opencog exec))
(use-modules (opencog test-runner))

(opencog-test-runner)
(define tname "or-link-space-test")
(test-begin tname)

; Initial data. Note the (stv 1 1) is necessary, because the IsTrueLink
; will fail with the default TruthValue of (stv 1 0) (true but not
; confident).
(State (Concept "you") (Concept "thirsty"))
(Evaluation (stv 1 1) (Predicate "cold") (Concept "me"))
(Evaluation (Predicate "tired") (Concept "her"))

(define qr4
	(Get (TypedVariable (Variable "someone") (Type 'Concept))
		(Or
			(Present (State (Variable "someone") (Concept "thirsty")))
			(And
				(Present (Evaluation (Predicate "cold") (Variable "someone")))
				(IsTrue (Evaluation (Predicate "cold") (Variable "someone")))))))


(test-assert "thirsty or cold"
	(equal? (cog-execute! qr4) (Set (Concept "you") (Concept "me"))))

; ------------
(define qr5
	(Get (TypedVariable (Variable "someone") (Type 'Concept))
		(Or
			(Present (State (Variable "someone") (Concept "thirsty")))
			(IsTrue (Evaluation (Predicate "cold") (Variable "someone")))
			(IsTrue (Evaluation (Predicate "tired") (Variable "someone"))))))

(test-assert "thirsty or cold but not tired"
	(equal? (cog-execute! qr5) (Set (Concept "you") (Concept "me"))))

; ------------
; Add the stv to force it to be strictly true.
(Evaluation (stv 1 1) (Predicate "tired") (Concept "her"))

(test-assert "thirsty or cold or tired"
	(equal? (cog-execute! qr5)
		(Set (Concept "you") (Concept "me") (Concept "her"))))

(test-end tname)
