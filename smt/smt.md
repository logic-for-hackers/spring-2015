###Z3: Pythagorean Triples

A Pythagorean Triple is three positive integers (a,b,c) such that a^2 + b^2 = c^2. 
Euclid's formula is a way to produce Pythagorean triples. Given integers m and n (m>n>0):
(m^2 - n^2, 2mn, m^2+n^2) always produces a Pythagorean triple.

    (1) Use Z3 to check this assertion. Note that although this problem involves non-linear 
     integer arithmetic, Z3 is still able to make headway and prove Euclid's formula correct.
     Unlike Alloy, which would be limited by bounds, Z3's "unsat" result holds over all mathematical integers.

    (2) A primitive triple is one in which a, b, and c share no common factors. Check whether Euclid's
     formula can ever produce non-primitive triples. 

    Hint: to do this, you can use the "exists" primitive in Z3 to seek a common factor.

It will help to use this datatype-definition, which lets you build functions
that take and return Triple.  Access fields of a triple using the first,
second, and third functions. Construct triples using the mk-triple function,
which takes three integer arguments.

    (declare-datatypes () 
        ((Triple (mk-triple (first Int) (second Int) (third Int)))))

Hint: The SMT2 format provides a define-fun function; we suggest defining a
function for Euclid's formula,  plus functions that recognize whether or not a
triple is (a) Pythagorean and (b) primitive. Examples:

"This integer is even."
    
    ; This function takes a single Int and returns a Bool
    (define-fun is-even ((x Int)) Bool  
        (= (mod x 2) 0))

"There is some index on which these two arrays agree, and the value at that index is nonzero."
    
    ; Take two arrays that map ints to ints, return bool
    (define-fun arrays-equal-nonzero-somewhere ((arr1 (Array Int Int)) 
                                                (arr2 (Array Int Int))) Bool  
        (exists ((idx Int)) 
            (and (not (= (select arr1 idx) 0)) 
                 (= (select arr1 idx) (select arr2 idx)))))

You may download and install Z3 if you wish, but you'll find it easiest to
just use the web interface, which can be found at:

http://rise4fun.com/z3

Here's a tutorial if you're having trouble with Z3:

http://rise4fun.com/Z3/tutorial/guide

The Z3 examples from class can be found on the course webpage:

http://cs.brown.edu/courses/cs195y/2015/files.html

### Handin:
To hand in your the project run __cs195y_handin smt__ from a directory containing 
your Z3 source file(s). (Make sure that what you submit runs from Z3's web interface.)
