## Problem 1

In this exercise, you'll get some practice writing expressions and constraints
for a simple multilevel address book, similar to the one seen in Chapter 2 of
the Jackson book. By "multilevel" we mean that entries can reference groups
and aliases rather than just addresses directly.  Consider a set `Addr` of
addresses, and a set `Name` consisting of two disjoint subsets `Alias` and
`Group`.

The mapping from `Name`s to addresses is represented by a relation `address`.
A `Name` can map directly to an `Addr` or to another `Name`. `Alias`es
map to at most one target, but `Group`s can map to a *set* of targets.
There is a template to help you below.

Write the following *invariants*--constraints which you'd expect an address book to 
satisfy:

	(a) There are no naming cycles; a `Name` can never contain a reference to itself, not even indirectly.
	(b) All names eventually denote at least one address.
	
Now, write the following simulation constraints, which you might add during
the exploration of a model in order to see more interesting instances (or
check that a class of instances are excluded by constraints you've written):

	(c) The address book has at least two levels. 
	(d) Some groups are non-empty.
	
Finally, write expressions for each of the following (as Alloy functions or predicates that recognize valid maps), 
without using comprehension syntax (recall that comprehensions are 
expressions like `{x : A | ...}`):

	(e) the set of names that are members of groups;
	(f) the set of groups that are empty;
	(g) the mapping from aliases to the addresses they refer to, directly 
		or indirectly;
	(h) the mapping from names to addresses which, when a name maps to some
		addresses directly, and some other addresses indirectly, includes 
		only the direct addresses.

Here's how to use the analyzer to help you with this problem. Take the 
following template, which declares the various sets and the address relation,
and fill in the invariants and simulation constraints:

	abstract sig Name { 
		address: set Addr + Name 
		}
	sig Alias, Group extends Name {} 
	sig Addr {}
	fact {
		... invariants 
		}
	run {
		... simulation constraints 	
		}

	pred groupMembers[n: Name] { ... }
	pred emptyGroups[g: Group] { ... }
	...  


As you fill them in, execute the run command; the tool will generate sample
instances. Then, when you have an interesting instance, enter a candidate 
expression into the evaluator, and the tool will show you its value for that 
particular instance. You may find that you need to add more simulation 
constraints to obtain an instance that nicely illustrates the meaning of an 
expression.


## Problem 2

This is a famous problem invented by the mathematician Paul Halmos. Solving 
the problem by constructing a logical argument is quite challenging, but 
finding a solution with Alloy is easy.

	Alice and Bob invited four other couples over for a party. Some of them 
	knew each other and some didn't; some were polite and some were not. So 
	there was some handshaking, although not every pair of guests shook hands 
	(and of course nobody shook their own hand or their partner's hand). Being 
	curious, Alice went round and asked at the end of the party how many hands
	each person had shaken. She got nine different answers from the nine 
	people. How many hands did Bob shake?

(a) Solve the problem by modeling it in Alloy, and using the analyzer to find
	a solution. Solving for 10 people will take longer than solving for 4 or
	6, so use a smaller number until you are confident that your model makes
	sense. (You may safely assume that there are no single guests, and that
	guests are each part of exactly one couple.)

(b) Might there be another solution, in which Bob shook a different number of
	hands than the answer you found in part (a)? `Check` whether this is
	possible with an `assert` in Alloy.


## Problem 3

A *state machine* is a directed graph that models how a system moves from
state to state as it executes. It has one or more initial (or starting)
states, and edges connecting each state to its successor(s).
Construct an Alloy model of a state machine, then write predicates that constrain
Alloy to produce examples of the following types of machine: 

	(a) a deterministic machine, in which there is one starting state and each state has at most one successor
	(b) a nondeterministic machine, in which there are multiple starting states, or where some states have more than one successor
	(c) a machine with unreachable states
	(d) a machine without unreachable states
	(e) a connected machine in which every state is reachable from every other state
	(f) a machine with a deadlock: a reachable state that has no successors
	(g) a machine with a livelock: the possibility of an infinite execution in
		which a state that is always reachable is never reached.

It will be easier to define a separate `pred` (containing appropriate
constraints) for each of these. For instance, you should have a `pred
deterministic { ... }` for (a), etc. You may represent valid moves 
from state to state however you would like.
	
## Handing In
 To hand in your homework run __cs195y_handin alloy4__ from a directory 
 containing an Alloy file for each of the problems.

## Credit
Exercises borrowed or adapted from Appendix A of Daniel Jackson's [Software Abstractions](http://mitpress.mit.edu/books/software-abstractions).
