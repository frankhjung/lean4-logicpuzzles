import LSpec
import BreakfastTime.Combinators
import BreakfastTime.Solve

namespace BreakfastTime.Test

open LSpec
open BreakfastTime.Combinators
open BreakfastTime.Solve

/-- Test `permutations` behaviour. -/
def testPermutations : TestSeq :=
  let perms123 := permutations [1, 2, 3]
  let allPresent := perms123.all
    (fun p => p.contains 1 && p.contains 2 && p.contains 3)
  test "permutations [1,2,3] length" (perms123.length == 6) $
  test "permutations completeness" (allPresent == true)

/-- Test `zipWith4` behaviour. -/
def testZipWith4 : TestSeq :=
  let z4 := zipWith4 (fun a b c d => a + b + c + d)
    [1, 2] [10, 20] [100, 200] [1000, 2000, 3000]
  test "zipWith4 basic behaviour" (z4 == [1111, 2222])

/-- Test `guard` behaviour with the `List` monad. -/
def testGuard : TestSeq :=
  let guardTrue := (guard true : List Unit).length
  let guardFalse := (guard false : List Unit).length
  test "guard true yields unit" (guardTrue == 1) $
  test "guard false yields empty" (guardFalse == 0)

/-- Test monadic search pipeline using the `List` monad directly. -/
def testMonadicSearch : TestSeq :=
  let monadicSearch : List Nat := do
    let x ← [1, 2, 3, 4]
    guard (x % 2 == 0)
    pure (x * 10)
  test "monadic search pipeline" (monadicSearch == [20, 40])

/-- Test `ToString` instance behaviour. -/
def testToString : TestSeq :=
  test "Name toString" (toString Name.Jenny == "Jenny") $
  test "Drink toString" (toString Drink.Apple == "Apple") $
  test "Meal toString" (toString Meal.Toast == "Toast") $
  test "ToGo toString" (toString ToGo.Latte == "Latte")

/-- Test the BreakfastTime puzzle solver. -/
def testSolve : TestSeq :=
  match answers with
  | [sol] =>
    let jenny := sol.find? (·.name == Name.Jenny)
    let jackie := sol.find? (·.name == Name.Jackie)
    let samantha := sol.find? (·.name == Name.Samantha)
    let judy := sol.find? (·.name == Name.Judy)

    let jennyExpected :=
      some ⟨Name.Jenny, Drink.Tea, Meal.Toast, ToGo.Latte⟩
    let jackieExpected :=
      some ⟨Name.Jackie, Drink.Orange, Meal.Pancakes, ToGo.Coffee⟩
    let samanthaExpected :=
      some ⟨Name.Samantha, Drink.Milk, Meal.Cereal, ToGo.Water⟩
    let judyExpected :=
      some ⟨Name.Judy, Drink.Apple, Meal.Omelet, ToGo.Lemonade⟩

    test "puzzle has exactly 1 solution" (answers.length == 1) $
    test "Jenny's assignment" (jenny == jennyExpected) $
    test "Jackie's assignment" (jackie == jackieExpected) $
    test "Samantha's assignment" (samantha == samanthaExpected) $
    test "Judy's assignment" (judy == judyExpected)
  | _ =>
    test "puzzle has exactly 1 solution" false

/-- All BreakfastTime puzzle tests. -/
def tests : TestSeq :=
  testPermutations ++ testZipWith4 ++ testGuard ++
  testMonadicSearch ++ testToString ++ testSolve

end BreakfastTime.Test
