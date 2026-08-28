/-!
# Permutation combinators

Reusable list permutation helpers used across logic puzzle solvers.
-/

namespace BreakfastTime.Perm

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
Zip four lists together with a function `f`.
Truncates to the length of the shortest input list.
-/
@[inline]
def zipWith4 (f : α → β → γ → δ → ε) :
    List α → List β → List γ → List δ → List ε
  | a :: as, b :: bs, c :: cs, d :: ds => f a b c d :: zipWith4 f as bs cs ds
  | _, _, _, _                         => []

end BreakfastTime.Perm
