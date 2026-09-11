import Mathlib.Data.List.Defs
import Batteries.Data.List.Basic
import Mathlib.Data.List.Monad

/-!
# Combinators

Standardised list combinators for logic puzzle solvers delegating to
Mathlib and Batteries.
-/

namespace BreakfastTime.Combinators

/--
Return all permutations of a list `xs`.
Delegates to `List.permutations'` from Mathlib.
-/
@[inline]
def permutations (xs : List α) : List (List α) :=
  List.permutations' xs

/--
Zip four lists together with a function `f`.
Delegates to `List.zipWith₄` from Batteries.
-/
@[inline]
def zipWith4 (f : α → β → γ → δ → ε)
    (as : List α) (bs : List β) (cs : List γ) (ds : List δ) : List ε :=
  List.zipWith₄ f as bs cs ds

end BreakfastTime.Combinators
