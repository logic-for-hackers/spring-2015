Binary Decision Diagrams
========================

A binary decision diagram (BDD) is a way of representing a boolean expression
compactly as a directed acyclic graph (DAG). BDDs have

* a root node from which all other nodes can be reached, with no nodes pointing
  to it
* one or two terminal nodes with no outgoing edges labeled `T` (true) or `F`
  (false)
* a set of non-terminal nodes (which includes the root) each with two outgoing
  edges (one that is `low` and one that is `high`) and with an associated
  variable referred to as `var`. A `low` edge indicates the path to take when
  `var` associated is false, and a `high` edge indicates the path to take when
  `var` is true.

In this assignment, you will deal with reduced, ordered binary decision
diagrams. A BDD is ordered (OBDD) if on all paths through the graph the
variables respect a given linear order x<sub>1</sub> < x<sub>2</sub> < ... <
x<sub>n</sub>. An (O)BDD is reduced (ROBDD) if
* no two distinct nodes `u` and `v` have the same variable name, low edge, and
  high edge, and
* no node `u` has identical low and high edges

ROBDDs provide a compact representation for boolean expressions. Even better,
efficient logical operations exist for ROBDDs. In this assignment, you will
construct ROBDDs from boolean expressions efficiently, without
using the Shannon expansion or explicitly reducing a non-reduced OBDD.

The Assignment
--------------

### 1. Data Structure

Each node in a ROBDD contains four values:  
1. A unique ID, a non-negative integer, referred to as `id`.  
2. A variable name, a non-empty string, referred to as `var`.  
3. A low outgoing edge, another node, referred to as `low`.  
4. A high outgoing edge, another node, referred to as `high`.  

Using the following pseudocode, create a helper function to construct ROBDD
nodes. This function does two things that make sure you've always got a
reduced BDD: it remembers nodes it's already made, so that it can avoid
building duplicate nodes, and it won't generate a new node with the same low
and high children.

```
H := <A mapping from IDs to nodes>
T := <A mapping from (var, low, high) to IDs>
C := 0

function makeNode (var, low, high) {
        if low and high are equal { return low }

        t := <Create a new triple with var, low, and high>
        if t is a key in T {
                return H[T[t]]
        }
        else {
                n := Node(C, t) // Creates a node with ID C and values t
                C = C + 1
                T[t] = n.id
                H[n.id] = n
                return H[n.id]
        }
}
```

### 2. `uApply` and `bApply` Functions

Now we'll build a function that performs Boolean operations on the BDDs
themselves (rather than converting to formulas and back again). One function
handles unary operations (just negation!) and another binary operations (`and`
and `or`).

Here's the logic behind the pseudocode below. Remember the Shannon-expansion
notation: `(x -> t1, t2)` means a BDD whose root branches on variable x, with
subtrees `t1` (for x=1) and `t2` (for x=0). Now there are three cases for applying
a binary operation:

#### Case 1: Suppose t is an arbitrary ROBDD and the other is F or T.

Then binary operations on the two is easy:

```
F or t = t
T or t = T
F and t = F
T and t = t
(and similarly for the reverse.)
```

But what if neither BDD is F or T? This means that they both branch on *some*
variable. The variable isn't necessarily the same.

#### Case 2: Suppose both BDDs branch on the same variable `x`.

Then you can take advantage of the following identity (think of it like a
variation on DeMorgan's Law):

```
(x -> t1, t2) OP (x -> t1', t2') =
    (x -> t1 OP t1', t2 OP t2')
```

This means that you can push the operation into the subtrees, getting a new
BDD that branches on the same variable as the other two. Since BDDs have
finite depth, you can keep performing this operation until you end up at
either Case 1 or (if the subtrees use different variables) Case 3.

#### Case 3: One BDD branches on x, but the other BDD branches on some other variable that is *later* in the ordering.

Then you can still push the operation down, using:

```
(x -> t1, t2) OP t =
    (x -> t1 OP t, t2 OP t)
```

Again, since BDDs are finite, if you follow this rule you'll eventually end up
getting to either Case 1 or Case 2. Note that since BDDs can skip variables,
you need to check which variable is biggest (lexicographically) on every
application of Case 3.

Negation works similarly, only it's even simpler!
On to the pseudocode:

```
function uApply (op, u) {
        if u is terminal {
                return op(u)
        }
        else {
                return makeNode(u.var, uApply(op, u.low), uApply(op, u.high))
        }
}
```

```
function bApply (op, u, v) {
        if u is terminal and v is terminal {
                return op(u, v)
        }
        elif u is terminal or (v is not terminal and u.var > v.var) {
                return makeNode(v.var, bApply(op, u, v.low), bApply(op, u,
                        v.high))
        }
        elif v is terminal or (u is not terminal and u.var < v.var) {
                return makeNode(u.var, bApply(op, u.low, v), bApply(op, u.high,
                        v))
        }
        else {
                return makeNode(u.var, bApply(op, u.low, v.low), bApply(op,
                        u.high, v.high))
        }
}
```


### 3. Construction

Prefix notation shares a one-to-one correspondance with trees. By parsing our
input expression into a stream of tokens, constructing a BDD becomes a recursive
descent problem. Use the following pseudocode as a guide for constructing ROBDDs
with your `apply` functions.

```
function construct (s) { // s is a stream of boolean expression tokens
        n := s.next()
        if n = "&" {
                return bApply(andOp, construct(s), construct(s))
        }
        elif n = "|" {
                return bApply(orOp, construct(s), construct(s))
        }
        elif n = "!" {
                return uApply(notOp, construct(s))
        }
        else {
                return makeNode(n, F, T)
        }
}
```

The operators consumed by `uApply` and `bApply` operate on terminal nodes. For
example, `andOp(T, F) => F` and `orOp(F, T) => T`.

Input Specification
-------------------

Your program should read a boolean expression from standard input. Boolean
expressions contain space-delimited operators and alphabetic variable names in
prefix notation. Your implementation should support the following two binary
operators and one unary operator: and (`&`), or (`|`), and not (`!`). For
example, the properly formatted expression `& | p q & r | p q` denotes the
conventional infix expression `(p or q) and (r and (p or q))`. All testing input
will be well-formed.

Output Specification
--------------------

Your program should traverse the constructed ROBDD in pre-order and print a line
to standard output for each previously unseen node before terminating.  Each
line will have the form `ID VAR LT HT`, where `ID` is the unique non-negative
integer denoting the node, `VAR` is the string corresponding to that node's
variable, `LT` is a boolean end node (`T` or `F`) or an integer ID representing
the node the low edge connects to. `HT` is the analogue for the high edge. For
example, the input `& | p q & r | p q` produces output of the following form:

```
8 p 7 3
7 q F 3
3 r F T
```

Note that there is a single representation of `r F T` and although the node with
ID 3 occurs twice as a child, the node with ID 3 is only printed once.

Handing In
----------

To hand in your assigment, run **`cs195y_handin bdd`** from the directory
containing your implementation. Remember to include a text README with any
significant design decisions.
