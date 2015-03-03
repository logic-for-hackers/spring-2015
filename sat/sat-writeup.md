
### SAT Solver 

Your assignment for this week is to implement a basic DPLL SAT-solver in 
the language of your choice. 

Some definitions from class: a "literal" is a positive or negative occurrence
of a Boolean variable, like x1 (a positive literal) or !x2 (a negative
literal). A clause is a set of literals, joined together by "or", like (x1 or
!x3 or x4). DPLL expects as input a  formula in conjunctive normal form, i.e.,
a set of clauses  that are joined together with "and". This means that to
satisfy the input clause set, every clause must be satisfied. We call a clause
with only one literal a "unit clause" and a clause with no literals the "empty
clause", which is the same as falsehood. A literal is "pure" if, whenever it
appears in the clause set, it always has the same sign. A set of unit clauses is
consistent if no two have different signs for the same variable.

When writing a solver, it's convenient to refer to variables as positive
integers. That is, you'd call the first variable 1, the tenth variable 10, and
so on. We'll use this convention here! +/-x means a literal (a variable with
either positive or negative sign). -/+x is therefore the same literal with its
sign flipped; you'll see this in unit propagation.

Pseudocode from class, with some clarifications:

	solve(VARS, F):
		F := propagate-units(F)
		F := pure-elim(F)
		if F contains the empty clause, return the empty clause // call this "unsat" in output
		if F is a consistent set of unit clauses that involves all VARS, return F
		x := pick-a-variable(F, VARS) // do anything reasonable here
		if solve(VARS, F + {x}) isn't the empty clause, return solve(F + {x}) // works to have +x
		else return solve(VARS, F + {-x}) // check -x

	propagate-units(F):
		for each unit clause {+/-x} in F
			remove all instances of -/+x in every clause // flipped sign!
			remove all non-unit clauses containing +/-x

	pure-elim(F):	
		for each variable x
			if +/-x is pure in F
				remove all clauses containing +/-x
				add a unit clause {+/-x}

Clarification: If you do not include "involves all VARS" in the check above,
DPLL will return a *partial* instance that potentially omits values for some
variables. Since we're changing the formula recursively, we need to remember
the original set of variables (VARS).

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

Clarification: An empty set of clauses is equivalent to "true". Since this
input involves no variables, your program should produce an empty set of unit
clauses (*not* "unsat!"). An empty clause is equivalent to "false" and
should result in "unsat".

### Handin:
To hand in your the project run __cs195y_handin sat__ from a directory containing 
your program and a readme explaining any significant design decisions.


