-- This is the finished code from the lecture on insertion sort. It uses
-- types from the prelude, so don't load with --noprelude. (--total is good
-- though.)


-- First we'll define a type synonym just to avoid typing List Nat a lot:
L : Type
L = List Nat

-- This dependent type represents the proposition that a list is sorted.
-- We use the builtin prelude type `LTE : Nat -> Nat -> Type` which represents
-- the proposition that one natural number is less than or equal to another.
data Sorted : L -> Type where
  SEmpty : Sorted []
  SOne : Sorted [v]
  SCons : LTE x1 x2 -> Sorted (x2 :: r) -> Sorted (x1 :: x2 :: r)

-- Now we make a type for permutations of lists:
data Perm : L -> L -> Type where
  PEmpty : Perm [] []
  PFirst : Perm r1 r2 -> Perm (x :: r1) (x :: r2)
  PSwap : Perm (x1 :: x2 :: r) (x2 :: x1 :: r)
  PTrans : Perm a b -> Perm b c -> Perm a c

-- This type just lets us package together a list, a proof that it is sorted,
-- and a proof that it is a permutation of some original list:
data SortFor : L -> Type where
  SortBy : (s : L) -> Sorted s -> Perm l s -> SortFor l

-- When we're inserting an element into a sorted list, we'll need to know
-- whether the inserted element went on the front or if it got inserted
-- somewhere inside:
data InsertFor : Nat -> Nat -> L -> Type where
  InsertHead : Sorted (v :: x :: r) -> InsertFor v x r
  InsertInside : (s : L) -> Sorted (x :: s) -> Perm (v :: x :: r) (x :: s) -> InsertFor v x r

-- This function just lets us make an identity permutation for any list:
pId : (x : L) -> Perm x x
pId [] = PEmpty
pId (x :: xs) = PFirst (pId xs)

-- Sometimes we want to get a proof that the rest of a list is sorted:
sRest : Sorted (x :: r) -> Sorted r
sRest SOne = SEmpty
sRest (SCons p s) = s

-- This lets us make a permutation where we swap the first two elements of the
-- list on the left from some original permutation:
pSwapLeft : Perm (x :: y :: r) l -> Perm (y :: x :: r) l
pSwapLeft p = PTrans PSwap p

-- Given a sorted list, we want to get a proof that the first element is less
-- than or equal to the second:
getFirstCompare : Sorted (x :: y :: r) -> (LTE x y)
getFirstCompare (SCons p _) = p

-- This is a decision function which gives us either a proof that x <= y
-- or y <= x:
compareLTE : (x : Nat) -> (y : Nat) -> Either (LTE x y) (LTE y x)
compareLTE Z y = Left LTEZero
compareLTE x Z = Right LTEZero
compareLTE (S x) (S y) with (compareLTE x y)
  | Left  xy = Left  (LTESucc xy)
  | Right yx = Right (LTESucc yx)

-- When performing an insertion, it's helpful to separate all the cases where
-- the list being inserted into is non-empty:
insertNonEmpty : (v : Nat) -> (x : Nat) -> (r : L) -> Sorted (x :: r)
              -> InsertFor v x r

-- Here we have the case where the list has length one. Depending on the
-- comparison of the element being inserted and the element in the list, we
-- will either insert at the front or after the first element:
insertNonEmpty v x [] SOne with (compareLTE v x)
  | Left  vx = InsertHead (SCons vx SOne)
  | Right xv = InsertInside [v] (SCons xv SOne) PSwap

-- Now with a non-empty rest we still need to compare the inserted element and
-- the first element:
insertNonEmpty v x (y :: r) s with (compareLTE v x)

  -- If v <= x, we can just insert v at the front:
  | Left  vx = InsertHead (SCons vx s)

  -- If x <= v, now we need to insert v into the rest of the list:
  | Right xv with (insertNonEmpty v y r (sRest s))

    -- If v got inserted right at the beginning of the rest, then we add x at
    -- the front:
    | InsertHead vyrSorted =
      InsertInside (v :: y :: r)
                   (SCons xv vyrSorted)
                   (pSwapLeft (pId (x :: v :: y :: r)))

    -- Otherwise v got inserted somewhere else inside, and we have to put x at
    -- the beginning of the result of our insertion into the rest:
    | InsertInside ins xInsSorted perm =
      InsertInside (y :: ins)
                   (SCons (getFirstCompare s) xInsSorted)
                   (PTrans (pSwapLeft (pId (x :: v ::y :: r))) (PFirst perm))


-- Now we can write a more general insert function that handles the empty case:
insert : (v : Nat) -> (r : L) -> Sorted r -> SortFor (v :: r)

insert v [] SEmpty = SortBy [v] SOne (PFirst PEmpty)

-- In the non-empty case, we have to pattern match depending on what kind of
-- insertion `insertNonEmpty` returned:
insert v (x :: r) s with (insertNonEmpty v x r s)
  | InsertHead sorted = SortBy (v :: x :: r) sorted (pId (v :: x :: r))
  | InsertInside rest sorted perm = SortBy (x :: rest) sorted perm

-- Now we can sort recursively by insertion:
insertionSort : (l : L) -> SortFor l
insertionSort [] = SortBy [] SEmpty PEmpty
insertionSort (v :: r) with (insertionSort r)
  | (SortBy sr srSorted srPerm) with (insert v sr srSorted)
    | (SortBy s sSorted sPerm) = SortBy s sSorted (PTrans (PFirst srPerm) sPerm)

-- And we have a proven correct sorting function!
