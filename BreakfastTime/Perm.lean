import BreakfastTime.Combinators

/-!
# Permutation combinators (Legacy Shim)

Re-exports combinators from `BreakfastTime.Combinators` for backward
compatibility.
-/

namespace BreakfastTime.Perm

open BreakfastTime.Combinators

/-- All possible ways to insert an element into a list. -/
@[inline]
def insertions : α → List α → List (List α) :=
  BreakfastTime.Combinators.insertions

/-- All permutations of a list. -/
@[inline]
def permutations : List α → List (List α) :=
  BreakfastTime.Combinators.permutations

/--
Zip four lists together with a function `f`.
Delegates to the applicative `<⊛>` implementation.
-/
@[inline]
def zipWith4 (f : α → β → γ → δ → ε)
    (as : List α) (bs : List β) (cs : List γ) (ds : List δ) : List ε :=
  BreakfastTime.Combinators.zipWith4 f as bs cs ds

end BreakfastTime.Perm
