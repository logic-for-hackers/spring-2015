
### SAT Solver 

Your assignment for this week is to implement a basic DPLL SAT-solver in 
the language of your choice. 

Some definitions from class: a "literal" is a positive or negative
occurrence of a Boolean variable, like x or !y. A clause is a set of literals,
implicitly joined together by "or", like (x or !y or z). DPLL expects as input a 
formula in conjunctive normal form, i.e., a set of clauses 
that are joined together with "and". This means that to satisfy the input clause set,
every clause must be satisfied. We call a clause with only one literal a "unit
clause" and a clause with no literals the "empty clause", which is the same as
falsehood. A literal is "pure" if, whenever it appears in the clause set, it
always has the same sign.

We've also included some pseudo-code from class below to help you out. We use
+/-x to mean a literal (a variable with either positive or negative sign).
-/+x is therefore the same literal with its sign flipped; you'll see this in
unit propagation.

	solve(F):
		if F contains the empty clause, return false
		if F is a consistent set of unit clauses, return F
		F := propagate-units(F)
		F := pure-elim(F)
		x := pick-a-variable(F) // do anything reasonable here
		return solve(F + {x}) or solve(F + {!x})

	propagate-units(F):
		for each unit clause {+/-x} in F
			remove all instances of -/+x in every clause
			remove all non-unit clauses containing +/-x

	pure-elim(F):	
		for each variable x
			if +/-x is pure in F
				remove all clauses containing +/-x
				add a unit clause {+/-x}

You're free to choose any reasonable method of picking variables to branch on.
You might randomly select a variable, pick the variable that occurs the most
in the formula, or even just take the alphabetically-next variable. By
"reasonable" we mean a method that leads to correct results.

### INPUT specification: 
Your program should take in a formula from standard input, where a formula 
is a list of clauses separated by semicolons and each clause is a list of 
literals separated by spaces. Literals should be represented as numbers where
a positive number denotes that the variable must be true and a negative 
number denotes it must be false. There is an implicit "or" between each literal and an 
implicit "and" between clauses. (You may assume that your program will not 
be given any literal that wouldn't fit in a 32-bit signed integer.)

For example: 

	-1 2;2 3

represents an input formula with two clauses. The first says that either
variable 1 is false or variable 2 is true; the second says that either
variable 2 or variable 3 is true.

### OUTPUT specification:
Your program should output "unsat" if a formula is unsatisfiable, and if it is 
satisfiable a solution in the form

	list of true literals
	list of false literals

where each literal is separated by a space and there is a newline between lists.

For example:

	2 3
	-1

gives an instance for the above example input. Variables 2 and 3 are true, and variable 1 is false.

### Handin:
To hand in your the project run __cs195y_handin sat__ from a directory containing 
your program and a readme explaining any significant design decisions.


