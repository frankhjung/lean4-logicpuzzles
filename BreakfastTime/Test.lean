import LSpec
import BreakfastTime.Combinators
import BreakfastTime.Perm
import BreakfastTime.Search
import BreakfastTime.Solve

namespace BreakfastTime.Test

open LSpec
open BreakfastTime.Combinators
open BreakfastTime.Search
open BreakfastTime.Solve

/-- Test `permutations` behaviour. -/
def testPermutations : TestSeq :=
  let perms123 := permutations [1, 2, 3]
  let allPresent := perms123.all (fun p => p.contains 1 && p.contains 2 && p.contains 3)
  test "permutations [1,2,3] length" (perms123.length == 6) $
  test "permutations completeness" (allPresent == true)

/-- Test applicative `<⊛>` zip behaviour across varying arities and lengths. -/
def testZipApply : TestSeq :=
  let z2 := [Nat.add 1, Nat.add 2] <⊛> [10, 20]
  let z3 := [1, 2].map (fun a b c => a + b + c) <⊛> [10, 20] <⊛> [100, 200]
  let z5 := [1, 2].map (fun a b c d e => a + b + c + d + e)
    <⊛> [10, 20] <⊛> [100, 200] <⊛> [1000, 2000] <⊛> [10000, 20000]
  let zTruncLeft := [1, 2, 3].map (· + ·) <⊛> [10, 20]
  let zTruncRight := [1, 2].map (· + ·) <⊛> [10, 20, 30]
  test "zipApply binary application" (z2 == [11, 22]) $
  test "zipApply ternary application" (z3 == [111, 222]) $
  test "zipApply 5-ary application" (z5 == [11111, 22222]) $
  test "zipApply truncates when left is longer" (zTruncLeft == [11, 22]) $
  test "zipApply truncates when right is longer" (zTruncRight == [11, 22])

/-- Test `zipWith4` behaviour. -/
def testZipWith4 : TestSeq :=
  let z4 := zipWith4 (fun a b c d => a + b + c + d) [1,2] [10,20] [100,200] [1000,2000,3000]
  test "zipWith4 basic behaviour" (z4 == [1111, 2222])

/-- Test `choose` behaviour. -/
def testChoose : TestSeq :=
  let chosen := choose [10, 20, 30]
  test "choose preserves list" (chosen == [10, 20, 30])

/-- Test `choosePerm` behaviour. -/
def testChoosePerm : TestSeq :=
  let perm2 := choosePerm [1, 2]
  test "choosePerm [1, 2] length" (perm2.length == 2)

/-- Test `guard` behaviour. -/
def testGuard : TestSeq :=
  let guardTrue := (guard true : List Unit).length
  let guardFalse := (guard false : List Unit).length
  test "guard true yields unit" (guardTrue == 1) $
  test "guard false yields empty" (guardFalse == 0)

/-- Test `checkpoint` behaviour. -/
def testCheckpoint : TestSeq :=
  let cpPass := checkpoint (· > 10) 15
  let cpFail := checkpoint (· > 10) 5
  test "checkpoint pass" (cpPass == [15]) $
  test "checkpoint fail" (cpFail == ([] : List Nat))

/-- Test monadic search pipeline. -/
def testMonadicSearch : TestSeq :=
  let monadicSearch : List Nat := do
    let x ← choose [1, 2, 3, 4]
    guard (x % 2 == 0)
    pure (x * 10)
  test "monadic search pipeline" (monadicSearch == [20, 40])

/-- Test the BreakfastTime puzzle solver. -/
def testSolve : TestSeq :=
  match answers with
  | [sol] =>
    let jenny := sol.find? (·.name == Name.Jenny)
    let jackie := sol.find? (·.name == Name.Jackie)
    let samantha := sol.find? (·.name == Name.Samantha)
    let judy := sol.find? (·.name == Name.Judy)

    let jennyExpected := some ⟨Name.Jenny, Drink.Tea, Meal.Toast, ToGo.Latte⟩
    let jackieExpected := some ⟨Name.Jackie, Drink.Orange, Meal.Pancakes, ToGo.Coffee⟩
    let samanthaExpected := some ⟨Name.Samantha, Drink.Milk, Meal.Cereal, ToGo.Water⟩
    let judyExpected := some ⟨Name.Judy, Drink.Apple, Meal.Omelet, ToGo.Lemonade⟩

    test "puzzle has exactly 1 solution" (answers.length == 1) $
    test "Jenny's assignment" (jenny == jennyExpected) $
    test "Jackie's assignment" (jackie == jackieExpected) $
    test "Samantha's assignment" (samantha == samanthaExpected) $
    test "Judy's assignment" (judy == judyExpected)
  | _ =>
    test "puzzle has exactly 1 solution" false

/-- All BreakfastTime puzzle tests. -/
def tests : TestSeq :=
  testPermutations ++ testZipApply ++ testZipWith4 ++ testChoose ++
  testChoosePerm ++ testGuard ++ testCheckpoint ++ testMonadicSearch ++
  testSolve

end BreakfastTime.Test

