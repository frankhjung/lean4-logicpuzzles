import Mathlib.Data.List.Monad

/-!
# Combinators

Applicative zip and permutation combinators for logic puzzle solvers.
-/

namespace BreakfastTime.Combinators

/--
Return all possible ways to insert an element `x` into a list `xs`.
-/
@[inline]
def insertions (x : α) : List α → List (List α)
  | [] => [[x]]
  | y :: ys => (x :: y :: ys) :: (insertions x ys).map (y :: ·)

@[simp] theorem length_insertions (x : α) (xs : List α) :
    (insertions x xs).length = xs.length + 1 := by
  induction xs with
  | nil => rfl
  | cons y ys ih => simp [insertions, ih]

/--
Return all permutations of a list `xs`.
-/
def permutations : List α → List (List α)
  | [] => [[]]
  | x :: xs => (permutations xs).flatMap (insertions x)

/--
Element-wise applicative application over lists.
Truncates to the length of the shortest input list.
-/
@[inline]
def zipApply : List (α → β) → List α → List β
  | f :: fs, x :: xs => f x :: zipApply fs xs
  | _, _             => []

/-- Infix operator for element-wise list application. -/
infixl:60 " <⊛> " => zipApply

@[simp] theorem zipApply_nil_left (xs : List α) :
    ([] : List (α → β)) <⊛> xs = [] := by
  cases xs <;> rfl

@[simp] theorem zipApply_nil_right (fs : List (α → β)) :
    fs <⊛> ([] : List α) = [] := by
  cases fs <;> rfl

@[simp] theorem zipApply_cons (f : α → β) (fs : List (α → β)) (x : α) (xs : List α) :
    (f :: fs) <⊛> (x :: xs) = f x :: (fs <⊛> xs) := rfl

@[simp] theorem length_zipApply (fs : List (α → β)) (xs : List α) :
    (zipApply fs xs).length = min fs.length xs.length := by
  induction fs generalizing xs with
  | nil => simp
  | cons f fs ih =>
    cases xs with
    | nil => simp
    | cons x xs =>
      simp [ih]

/--
Zip four lists together with a function `f`.
Implemented via applicative zip `<⊛>`. Truncates to the shortest list.
-/
@[inline]
def zipWith4 (f : α → β → γ → δ → ε)
    (as : List α) (bs : List β) (cs : List γ) (ds : List δ) : List ε :=
  as.map f <⊛> bs <⊛> cs <⊛> ds

end BreakfastTime.Combinators
