# Idris

So far, we have used tools (Alloy, Z3, Spin) with embedded logics to analyze
the properties of our conceptual understandings of algorithms and protocols.
However, one potential pitfall with this approach is that, when you actually
go to _implement_ your algorithm in, say, Java, you have no guarantee that
what you wrote actually reflects the abstract algorithm you have determined
to be correct.

[Idris](http://www.idris-lang.org/)
is a programming language with an embedded logic strong enough to prove
the correctness of actual executable algorithms you write. On the surface,
Idris looks a lot like a functional language like OCaml or Haskell (from which
it derives most of its syntactic conventions). Don't worry though, you don't
need to be a functional programming whiz to learn the basics.

Time for some bad news: unlike the other tools we have used, Idris is much less
automatic than tools such as Z3 - proofs are largely manual. There is good news
though: with enough effort, you are limited only by your own ability to prove
things - you will never get stuck because of the analysis not being complete.

## The basics

Okay, let's get started. Idris has a
[REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
which we can use to play around. You can run it with `idris --total` on the
command line.

```idris
Idris>
```

We can do basic arithmetic like you would expect:

```idris
Idris> 3 + 4
7 : Integer
```

Here, Idris tell us the result of our computation, `7`, and its _type_,
`Integer`. As in any statically typed language, all values have types. In Idris
though, types can be much more precise than in "normal" languages.

Now, let's define some functions. For this, we'll need to store our code in a
file - the REPL won't cut it anymore. Use your favorite editor to write
`Tutorial.idr`. First, we'll do something really boring: adding one to
an integer:

```idris
addOne : Integer -> Integer
addone x = x + 1
```

For every function we define, we'll need to tell Idris its type. In this case,
`Integer -> Integer` means that it takes in an integer and returns an integer.
The second line actually defines our function. It says that for any integer
`x`, `addOne x` is `x + 1`. No surprise there. What might be more surprising
is that in Idris, we don't use lots of punctuation to call functions. Instead
of `f(x, y, z)`, we say `f x y z`. Note that then, if we want to use a function
call in some larger expression, we very often have to wrap the whole thing in
parenthesis. Instead of `f(x, g(y), z)`, we have `f x (g y) z`.

Enough theory, you're probably wondering how we actually get our file into
Idris. You can use `:l <filename>` to load a file, and `:r` to reload it once
you've loaded it. As you're working, you'll probably want to keep both your
editor and REPL open and reload every time you make a change in your editor.

If all goes well, Idris will tell you that your code type checks:

```idris
Idris> :l Tutorial.idr
Type checking ./Tutorial.idr
*Tutorial>
```

The new prompt at the bottom tells us all the definitions in our file are
available at the REPL so now,

```idris
*Tutorial> addOne 3
4 : Integer
```

That's all good, but what happens if we screw up our types?

```idris
addOne : Integer -> Integer
addone x = "Oh no!"
```

Now we reload:

```idris
*Tutorial> :r
Type checking ./Tutorial.idr
Tutorial.idr:2:8:When elaborating right hand side of addOne:
Can't unify
		String
with
		Integer

Specifically:
		Can't unify
				String
		with
				Integer
Metavariables: Main.addOne
*Tutorial>
```

This error tells us that in our program, we put in a `String` where we were
required to put in an `Integer`, in this case because of the type signature
of `addOne`. Unfortunately, these errors can get really hard to read really
fast. It's in your best interest to keep your code type checking as much of
the time as possible.

## Data types

Now, instead of just toying around with integers, let's make some types of
our own. At this point it's going to be beneficial to restart Idris with the
command line option `--noprelude` (so `idris --total --noprelude`) in order to
not automatically import a bunch of things with the same names as things we are
about to write. Now we'll delete our silly `addOne` and start fresh by defining
natural numbers.

```idris
data N : Type where
  Z : N
  S : N -> N
```

In case you aren't familiar, the natural numbers are the numbers 0, 1, 2, 3,
etc. We can define these _inductively_ by saying every natural number is either
zero or the _successor_ of a natural number. The syntax here says that zero, `Z`
is a natural number, `N`, and successor, `S` is a function taking in a `N` and
returning a new `N`. When we define a type with a `data` declaration like this,
the cases (like `Z` and `S`) are called _constructors_ because they tell us how
to create each possible value of our type.

So now we can represent, for example, `3`, as `S (S (S Z))`. Now let's write a
function to add numbers:

```idris
add : N -> N -> N
add Z     y = y
add (S x) y = S (add x y)
```

When you see a type with a chain of arrows like `N -> N -> N` you can think of
it as a multi-variable function, with all but the last element being arguments
and the final element being the return type. (For those of you familiar with
functional programming languages like Haskell or OCaml, this is function
currying. Technically `add` is a function taking an `N` and returning a
function taking another `N` and returning the final `N`.)

This is our first recursive function. Notice that we define the function for
each type of natural number on the left hand side, and accept any number on
the right side in both cases. This is arbitrary; we could have done it the
other way around. In general, you can split up cases however you want, as long
as there is exactly one case that matches each possible combination of input
values. (We'll worry about this more later.) This is where the `--total` flag
will help you, otherwise Idris won't complain if you don't cover all the cases.

Here, we said that zero plus `y` is just `y`, and adding the successor of `x`
to `y` gives us the successor of `x` plus `y`. Now, let's test our function:

```idris
*Tutorial> add (S (S Z)) (S (S (S Z)))
S (S (S (S (S Z)))) : N
```

**Exercise 1:** Write multiplication. (Hint: do recursion on the left
argument just like with `add`.) Then verify at the REPL:

```idris
*Tutorial> mul (S (S Z)) (S (S (S Z)))
S (S (S (S (S (S Z))))) : N
```

The most readable way to show `2 + 3 = 5` and `2 * 3 = 6` ever, right!

**Exercise 2:** Can we write subtraction
(with function signature `sub : N -> N -> N`)? What happens if we try?
(Answer this in a comment.)

Instead of abstract math number systems, let's make an obviously useful type now:

```idris
data List : Type -> Type where
  Nil : List a
  (::) : a -> List a -> List a

infixr 5 ::
```

Whoa! That looks weird. First, look at the first line. Before, we said
`N : Type`. Now, we have `List : Type -> Type`. This is because `List` is
really a _function_ that takes in a type and gives us a new type. `List` isn't
a type, but `List Integer`, or `List N`, or `List (List N)` are.

Now let's look at `Nil`. `Nil` has type `List a`, but what is `a`? Here Idris
is being sneaky. When you put a name starting with a lowercase letter in a type
signature, it can stand for anything of the correct type. When we use `Nil` in
the right context, `a` will get filled in with the right type. You can see the
importance of context here if you put `Nil` in the REPL:

```idris
*Tutorial> Nil
(input):0:0:Incomplete term []
```

`Incomplete term` means that there isn't enough information for Idris to know
what type our term `Nil` is supposed to have - and as we've seen, every term
(which is the same thing as expression) in Idris must have a type.

`(::)` looks even weirder than `Nil`. First of all, how is that a name? When
you name things with punctuation inside parenthesis, Idris will create an infix
operator. This lets you write some things a bit more naturally. But just
remember, `a :: b` is the same thing as `(::) a b`.

That last line, `infixr 5 ::` says that `::` is infix and right associative,
which means that `a :: b :: c` is `(a :: (b :: c))` not `(a :: b) :: c`.

**Exercise 3**: Think about why we want right associativity, not left, then give
your answer in a comment.

The type of `(::)` tells us how to make a non-empty list. It says we can take
a value of any type `a` and add it onto the beginning of a list of `a`s, to get
a new list of `a`s. `1 :: (2 :: (3 :: Nil))` would be the list `[1, 2, 3]`.
Thankfully, Idris isn't entirely sadistic and some built-in syntax lets us
write exactly that, `[1, 2, 3]`. And of course, `[]` is shorthand for `Nil`,
the empty list.

Let's combine our two types we've written:

```idris
length : List a -> N
length Nil = Z
length (x :: xs) = S (length xs)
```

And test it:

```idris
*Tutorial> length [0, 2, 8]
S (S (S Z)) : N
```

We can also write a function to append two lists:

```idris
append : List a -> List a -> List a
append Nil         y = y
append (x :: xs) y = x :: append xs y
```

Notice how this mirrors the structure of our definition of `add` for natural
numbers.

## Proofs

So far everything we haven't done anything we couldn't do in any other
statically typed language. The real power of Idris comes from what we call
_dependent types_. A dependent type is a type which depends on the value of
some regular expression. We'll get to different kinds of dependent types in a
bit, but for now we'll just use the most basic and most important one:
_equality_.

Rather than try to understand equality types abstractly, first we'll consider
an example type, which we will later try to provide a defintion for.

```idris
appendSumsLengths : (x : List a)
                 -> (y : List a)
                 -> length (append x y) = add (length x) (length y)
```

This is a type declaration for a function like we've seen before, except a few
things are new. First, we gave names to the parameters, `x` and `y`. Then,
look at the return type `length (append x y) = add (length x) (length y)`.

You can read this as, the type that contains _proofs_ of the fact that the length
of `x` and `y` appended is equal to the sum of their individual lengths. And
since our function can take in any two lists, the type of the whole function
can be thought of as a proof that this property holds for any two lists. What
does it mean for a type to be a proof of something? This gets to a rather
complex idea called the
[Curry-Howard correspondence](http://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence),
but the basic idea is that our types can be read as logical propositions, and
values of those types can be read as proofs of those propositions. So suppose
we wrote a type signature like this:

```idris
allNaturalNumbersEqual : (x : N) -> (y : N) -> x = y
```

This is a false proposition (because not all natural numbers are
equal). Therefore, no matter how hard we try, we will not be able to write
this function. But if our type represents a proposition that is actually
true, then (hopefullly), we should be able to write a function of that
type, thus _proving_ the proposition.

Now you might ask, how do we create a value whose type is an equality type?
Just like any other type, we create values using the constructors. For any
value `x`, the type `x = x` has exactly one constructor, `Refl : x = x`,
standing for reflexivity. The way we create proofs of equality that are not
simple reflexivity is by using recursion and theorems that we will prove to
essentially narrow down the cases of our values until they really do have
to be equal just by reflexivity.

Probably the most important theorem we will need is that you can apply any
function to both sides of an equality and still get an equality:

```idris
apply : (f : a -> b) -> x = y -> f x = f y
apply f Refl = Refl
```

Notice that since `Refl` is the only constructor of an equality type, we use it
to match the proof argument. This convinces the type checker that `x` and `y`
are really the same thing, so `Refl` is sufficient proof on the right side to
show that `f x` and `f y` are the same thing. (If that doesn't make sense, don't
worry about it, because there's actually a bit of "magic" going on here that
allows this to work.)

Now we'll take a stab at proving our proposition about the lengths of lists.
As with addition and appending, we'll recur on the left argument. The first
case is easy:

```idris
appendSumsLengths Nil y = Refl
```

Since the left argument is `Nil`, `length (append Nil y)` evaluates to
`length y`. Likewise, `add (length Nil) (length y)` evaluates to
`add Z (length y)` then to `length y`. Thus, `Refl` is allowed, since
the left and right side of the equality that we are trying to prove
evaluate to the same thing.

Now we'll try the recursive case:

```idris
appendSumsLengths (x :: xs) y = ?recursiveCase
```

That doesn't look like a proof, right? This is a trick to help you write
proofs (and in fact any kind of function in general!) without having to
juggle a bunch of types around in your head. If in place of a value, you
put a question mark and then some name, Idris will temporarily trust you
and put an imaginary value in that spot. Then, when you reload the file,
the REPL will tell you information to help you fill in the "hole".

```idris
*Tutorial> :r
Type checking ./Tutorial.idr
Metavariables: Main.recursiveCase
*Tutorial> :t recursiveCase
  a : Type
  x : a
  xs : List a
  y : List a
--------------------------------------
recursiveCase : S (length (append xs y)) =
				S (add (length xs) (length y))
Metavariables: Main.recursiveCase
```

Notice, at the bottom, it tells us the fully evaluated version of the type
we are trying to prove. The first thing that will help us, is that we can
see that we have `S` applied to both sides of the equality. Thus, we can
refine our proof a bit to get a bit closer:

```idris
appendSumsLengths (x :: xs) y = apply S ?recursiveCase
```

Now when we look at our new goal in the REPL:

```idris
*Tutorial> :t recursiveCase
a : Type
x : a
xs : List a
y : List a
--------------------------------------
recursiveCase : length (append xs y) =
			  add (length xs) (length y)
Metavariables: Main.recursiveCase
```

we have something a bit easier. In fact, notice that we can recursively use
our function `appendSumsLengths` itself on `xs` and `y` to get exactly what
we want. With that, we get our full proof:

```idris
appendSumsLengths : (x : List a)
				 -> (y : List a)
				 -> length (append x y) = add (length x) (length y)
appendSumsLengths Nil y = Refl
appendSumsLengths (x :: xs) y = apply S (appendSumsLengths xs y)
```

And we're done! This is in fact a complete proof, so the only way that our
`append` and `length` functions could not work as we have just shown is if
there is some rather major bug in the compiler/type checker.

## Dependent types

Equality was our first example of a dependent type, but as we will see now,
we can create our own dependent data types to make our programs safer and
more precise.

As a motivating example, consider the functions `first` and `rest`, which
return the first element of a list, and all the elements after the first.
Our first instinct for the types of these functions might be:

```idris
first : List a -> a
rest : List a -> List a
```

Is there anything wrong with these types? Let's try to define `first`:

```idris
first Nil = ?whatToDo
first (x :: xs) = x
```

As we can see when we ask the REPL, there is nothing available to help us fill
this hole:

```idris
*Tutorial> :t whatToDo
a : Type
--------------------------------------
whatToDo : a
Metavariables: Main.whatToDo
```

We have that `a` is a type, but no `a`s themselves. This makes sense, we are
trying to pull a value out of nothing (the empty list). In most languages, you
would probably just throw an exception, return null, or do something like that.
In Idris, we can't really do anything like that, without cheating, since it
would break our ability to have correct proofs.

The second answer to our original question, what the types should be, is that
maybe we should have the return value be some kind of "optional" type that lets
us simply provide some "extra" value on an empty list. That's not quite
satisfying though. What if we know that our list is definitely non-empty? Then
we essentially pushed the burden of handling the "exception" to the caller of
our function. Now you have to have a way to bubble up errors all the way to the
UI of your program, for errors that aren't even supposed to happen!

The third answer is that we could make a type for non-empty lists. This would
solve our problem here, but what if we wanted to get the second element of a
list? Also, we would have to have special versions of all of the usual list
functions just for our new type.

The answer we want is to have a type that lets us constrain the length of a
list directly. In Idris, we can write exactly that:

```idris
namespace vect
  data Vector : N -> Type -> Type where
	Nil : Vector Z a
	(::) : a -> Vector size a -> Vector (S size) a
```

The first thing to note is that, in order to not clash names with our list
constructors, we'll have to put all our vector-related code in a namespace.
The following functions should all be indented and put in this namespace.
(Alternatively, you can just put this code in a separate file.
**NOTE**: Don't forget to include the line `infixr 5 ::`)

Unlike our `List` type before, our `Vector` type has an extra parameter which
is it's length. So `Vector (S (S Z)) Integer` is the type of list of two
integers. Look at the constructors carefully and convince yourself that they
do in fact allow you to only produce lists of the right length.

Now we can write our `first` and `rest` functions with good types:

```idris
first : Vector (S size) a -> a
first (x :: xs) = x

rest : Vector (S size) a -> Vector size a
rest (x :: xs) = xs
```

Now let's try to write append for vectors. Unlike with lists, we have to think
about what will happen to the lengths "ahead of time." Intuitively, this type
makes sense:

```idris
append : Vector x a -> Vector y a -> Vector (add x y) a
```

**Exercise 4:** Write `append` for vectors. (Hint: look at the definition for
lists.)

Now let's think about our `appendSumsLengths` theorem in the context of
vectors. Since the type of a vector specifies its length, the type of
`append` itself already proves this theorem!

## Correctness by contruction

Our final observation about the difference between vectors and lists brings us
to one of the most fundamental design decisions you will be faced with when
using a language like Idris. In general, there will be two ways to write
provably correct code. The first way, which we did with lists, was to write our
code more or less like we would in any other language, with moderately
imprecise types, and then to "externally" write some proofs about the
properties of our code. The second way, which we did with vectors, was to make
our types so precise, that our function has to be correct just by
type-checking. This is often called *correctness by construction*.

Both methods have benefits. The first method lets us write useful code without
too much overhead, and allows us to prove properties more incrementally. On the
other hand, the second method will often give us more hints about not only how
to prove what we want, but also even how to write our algorithms themselves.
The downside is it's technically less flexible. Sometimes your types will turn
out to be more rigid than you want them to be, and you'll have to restructure a
lot of code.

## Some harder proofs

Now we'll try to prove a nontrivial mathematical fact: the commutativity of
addition. This should give you a bit of an idea of the general workflow you
should attempt when trying to prove difficult propositions.

First (and not in our `vect` namespace anymore), let's write the type we're
trying to prove:

```idris
comm : (x : N) -> (y : N) -> add x y = add y x
```

Now, we have to decide how we're going to divide up the cases of our defintion.
Unfortunately, this can often be the most difficult part of a proof.
Thankfully, we can use a bit of intuition to here to make it easier. Remember
that all of our previous binary functions on natural numbers (and lists and
vectors) all recurred on the left argument. Therefore, although not immediately
obvious, it would make sense that if we also recur on the left argument in our
proof, we won't really "get anywhere." So we'll recur on the right:

```idris
comm : (x : N) -> (y : N) -> add x y = add y x
comm x Z = ?zeroCase
comm x (S y) = ?succCase
```

Now we will ask Idris what we need for `?zeroCase`:

```idris
*Tutorial> :t zeroCase
x : N
--------------------------------------
zeroCase : add x Z = x
Metavariables: Main.succCase, Main.zeroCase
```

Notice that the right side, which abstractly was `add y x` got simplified to
`x` by the definition of `add`. Here, we can see that we don't really have
anything available to help us, so we'll have to make a lemma to prove this
hole:

```idris
addZ : (x : N) -> add x Z = x
addZ Z = ?addZeroZ
addZ (S x) = ?addZeroS
```

Now we'll look at our goals:

```idris
*Tutorial> :t addZeroZ
--------------------------------------
addZeroZ : Z = Z
Metavariables: Main.succCase, Main.zeroCase, Main.addZeroS, Main.addZeroZ
*Tutorial> :t addZeroS
  x : N
--------------------------------------
addZeroS : S (add x Z) = S x
Metavariables: Main.succCase, Main.zeroCase, Main.addZeroS, Main.addZeroZ
```

`Refl` is what we want for the zero case. For the sucessor case, we
can see that we have `S` applied to both sides, so we can use `apply`:

```idris
addZ : (x : N) -> add x Z = x
addZ Z = Refl
addZ (S x) = apply S ?addZeroS
```

And then when we look at our goal again,

```idris
*Tutorial> :t addZeroS
x : N
--------------------------------------
addZeroS : add x Z = x
```

we can then use a recursive call to complete the proof:

```idris
addZ : (x : N) -> add x Z = x
addZ Z = Refl
addZ (S x) = apply S (addZ x)
```

Now we can fill in our first case of `comm`:

```idris
comm : (x : N) -> (y : N) -> add x y = add y x
comm x Z = addZ x
comm x (S y) = ?succCase
```

The successor case looks a lot harder:

```idris
*Tutorial> :t succCase
x : N
y : N
--------------------------------------
succCase : add x (S y) = S (add y x)
```

Nothing looks like it's obviously going to help. Here, we're going to need to
use a bit of general intuition. First, since we don't know what `x` and `y`
are, it seems likely that we will have to make a recursive call.
`comm x y` has type `add x y = add y x`. Notice that the right hand side of
that equation is close to the right hand side of what we want. So we use
`apply` again. Then `apply S (comm x y)` has type `S (add x y) = S (add y x)`.
This gets us what we want on the right side, but not the left. Thankfully,
Idris has a handy builtin function called `trans`:

```idris
*Tutorial> :t trans
trans : (a = b) -> (b = c) -> a = c
*Tutorial> :t sym
sym : (l = r) -> r = l
```

`trans` represents the property of transitivity, which we expect
equality to obey. `sym`, which we won't actually need for now, represents
symmetry. With `trans`, we now can make use of our almost helpful term we
created:

```idris
comm : (x : N) -> (y : N) -> add x y = add y x
comm x Z = addZ x
comm x (S y) = trans ?succCase (apply S (comm x y))
```

And now we're a bit closer with our goal:

```idris
*Tutorial> :t succCase
x : N
y : N
y1 : Type
b : N
--------------------------------------
succCase : add x (S y) = S (add x y)
```

Unfortunately, this one is also looking impossible as is, so we'll need another
lemma:

```idris
addS : (x : N) -> (y : N) -> add x (S y) = S (add x y)
addS Z y = Refl
addS (S x) y = ?addSS
```

Now, we look at the type we want:

```idris
*Tutorial> :t addSS
x : N
y : N
--------------------------------------
addSS : S (add x (S y)) = S (S (add x y))
```

Once again, `apply S` is our friend:

```idris
addS : (x : N) -> (y : N) -> add x (S y) = S (add x y)
addS Z y = Refl
addS (S x) y = apply S ?addSS -- (addS x y)
```

```idris
*Tutorial> :t addSS
x : N
y : N
--------------------------------------
addSS : add x (S y) = S (add x y)
```

Thankfully, a recursive call is all we need:

```idris
addS : (x : N) -> (y : N) -> add x (S y) = S (add x y)
addS Z y = Refl
addS (S x) y = apply S (addS x y)
```

With that, we can fill in our original hole:

```idris
comm : (x : N) -> (y : N) -> add x y = add y x
comm x Z = addZ x
comm x (S y) = trans (addS x y) (apply S (comm x y))
```

And we're done! (Note that we could have filled in the hole here as soon as
we wrote down the type for our lemma. In fact, that approach will often help
you keep track of _why_ you need the lemmas you're working on in the first
place.)

Now that you've got the general idea down, time to try writing some proofs of
your own!

**Exercise 5:** Can you write associativity for addition? Here's the type and case
split structure to help:

```idris
assoc : (x : N) -> (y : N) -> (z : N) -> add x (add y z) = add (add x y) z
assoc Z y z = ?assocZ
assoc (S x) y z = ?assocS
```

Thankfully this one is a bit easier than commutativity - you won't need any
lemmas or bizarre transitivity tricks.

**Exercise 6:** Once you've written associativity for addition, can you write it
for appending lists?

## Handing In
 To hand in these exercises, run __cs195y_handin idris1__ from a directory
 containing your Idris (.idr) source file(s).
