import BreakfastTime.Perm
import Mathlib.Data.List.Monad

/-!
# Monadic Search DSL

Provides non-deterministic search combinators using the `List` monad. These
combinators allow pipelined state exploration and early branch pruning for logic
puzzle solvers.
-/

namespace BreakfastTime.Search

open BreakfastTime.Perm (permutations)

/-- Non-deterministically choose an element from a list. -/
@[inline]
def choose (xs : List α) : List α :=
  xs

/-- Non-deterministically choose a permutation of a list. -/
@[inline]
def choosePerm (xs : List α) : List (List α) :=
  permutations xs

/--
Inline constraint checkpoint. Returns `[x]` if `p x` is true, otherwise `[]`.
-/
@[inline]
def checkpoint (p : α → Bool) (x : α) : List α :=
  if p x then [x] else []

end BreakfastTime.Search
