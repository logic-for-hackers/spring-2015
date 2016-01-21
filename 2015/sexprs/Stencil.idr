data List : Type -> Type where
  Nil : List a
  (::) : a -> List a -> List a

infixr 5 ::

data Token : Type where
  A : String -> Token -- an atomic element
  L : Token           -- a left  parenthesis '('
  R : Token           -- a right parenthesis ')'

-- Just for convenience we define a type synonym
Tokens : Type
Tokens = List Token

data Expr : Type where
  Atom : String -> Expr
  Node : List Expr -> Expr

mutual
  -- Match one expression at the beginning of a stream of tokens
  data MatchExpr : Expr -> Tokens -> Tokens -> Type where
    MAtom : MatchExpr (Atom a) ((A a) :: rest) rest
    MNode : MatchExprs exprs afterRight afterLeft
         -> MatchExpr (Node exprs) (L :: afterRight) afterLeft

  -- Match a series of expressions terminated by `R`
  data MatchExprs : List Expr -> Tokens -> Tokens -> Type where
    MNone : MatchExprs [] (R :: rest) rest
    MFirstRest : MatchExpr e s afterFirst -> MatchExprs exprs afterFirst rest
              -> MatchExprs (e :: exprs) s rest

-- Contains an expression and matching rest
data MatchExprFor : Tokens -> Type where
  ExprWith : (e : Expr) -> (rest : Tokens) -> MatchExpr e tokens rest
           -> MatchExprFor tokens

data MatchExprsFor : Tokens -> Type where
  ExprsWith : (exprs : List Expr) -> (rest : Tokens) -> MatchExprs exprs tokens rest
           -> MatchExprsFor tokens

-- Represents a proof that a proposition p is false, proven by a function that
-- would take in a hypothetical element of p of return an element of the empty
-- type Void
Not : Type -> Type
Not p = p -> Void

-- Contains either a proof of the proposition p or a proof that p is false
data Decision : Type -> Type where
  True : p -> Decision p
  False : Not p -> Decision p

-- The following are various impossibility lemmas that you will want to use when
-- a string of tokens doesn't match:

noEmptyExpr : MatchExprFor [] -> Void
noEmptyExpr (ExprWith (Atom a) [] MAtom) impossible
noEmptyExpr (ExprWith (Node exprs) [] (MNode mexprs)) impossible

noEmptyExprs : MatchExprsFor [] -> Void
noEmptyExprs (ExprsWith [] [] MNone) impossible
noEmptyExprs (ExprsWith (e :: exprs) rest (MFirstRest {afterFirst} me mexprs)) =
  noEmptyExpr (ExprWith e afterFirst me)

noRExpr : MatchExprFor (R :: s) -> Void
noRExpr (ExprWith (Atom a) rest MAtom) impossible
noRExpr (ExprWith (Node exprs) rest (MNode mexprs)) impossible

noBadExprs : (MatchExprFor (L :: s) -> Void) -> MatchExprsFor (L :: s) -> Void
noBadExprs noMatch (ExprsWith [] rest MNone) impossible
noBadExprs noMatch (ExprsWith (e :: exprs) rest (MFirstRest {afterFirst} me mexprs)) =
  noMatch (ExprWith e afterFirst me)

noBadRest : MatchExpr e s rest -> (MatchExprsFor rest -> Void) -> Not (MatchExprsFor s)
noBadRest me noMatch (ExprsWith (e :: exprs) rest (MFirstRest me mexprs)) = ?noBadRestP

noBadInner : (MatchExprsFor s -> Void) -> MatchExprFor (L :: s) -> Void
noBadInner noMatch (ExprWith (Atom a) rest MAtom) impossible
noBadInner noMatch (ExprWith (Node exprs) rest (MNode mexprs)) = ?noBadInnerP

noLAtom : MatchExpr (Atom a) (L :: token) rest -> (MatchExprsFor (L :: tokens) -> Void)
noLAtom MAtom m impossible

mutual
  matchExpr : (s : Tokens) -> Decision (MatchExprFor s)
  matchExpr [] = ?matchExprEmpty
  matchExpr (R :: tokens) = ?matchExprR
  matchExpr (L :: tokens) = ?matchExprL
  matchExpr (A a :: tokens) = ?matchExprA

  matchExprs : (s : Tokens) -> Decision (MatchExprsFor s)
  matchExprs [] = ?matchExprsEmpty
  matchExprs (R :: tokens) = ?matchExprsR
  matchExprs (L :: tokens) = ?matchExprsL
  matchExprs (A a :: tokens) = ?matchExprsA

  matchExprsL : Decision (MatchExprFor (L :: s)) -> Decision (MatchExprsFor (L :: s))
  matchExprsL (False noMatch) = ?matchExprsLFalse
  matchExprsL (True (ExprWith (Atom a) rest matom)) = ?matchExprsLAtom
  matchExprsL (True (ExprWith (Node exprs) rest (MNode mexprs))) = ?matchExprsLNode

  matchExprsAfterNode : (exprs : List Expr) -> (mexprs : MatchExprs exprs s rest)
                     -> Decision (MatchExprsFor rest) -> Decision (MatchExprsFor (L :: s))
  matchExprsAfterNode exprs mexprs (False noMatch) = ?matchExprsNodeFalse
  matchExprsAfterNode exprs mexprs (True (ExprsWith restExprs rest mrestExprs)) = ?matchExprsNodeTrue

  matchExprL : Decision (MatchExprsFor s) -> Decision (MatchExprFor (L :: s))

  matchExprsA : (a : String) -> Decision (MatchExprsFor s) -> Decision (MatchExprsFor (A a :: s))
