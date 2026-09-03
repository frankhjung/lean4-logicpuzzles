import Test.Util
import BreakfastTime.Perm
import BreakfastTime.Search
import BreakfastTime.Solve

namespace BreakfastTime.Test

open Test.Util
open BreakfastTime.Perm
open BreakfastTime.Search
open BreakfastTime.Solve

/-- Run BreakfastTime puzzle tests. -/
def runTests (st : IO.Ref State) : IO Unit := do
  IO.println "\n[TEST] Testing BreakfastTime.Solve"

  let perms123 := permutations [1, 2, 3]
  assertEqual st perms123.length 6 "permutations [1,2,3] length"

  let allPresent := perms123.all (fun p => p.contains 1 && p.contains 2 && p.contains 3)
  assertEqual st allPresent true "permutations completeness"

  let z4 := zipWith4 (fun a b c d => a + b + c + d) [1,2] [10,20] [100,200] [1000,2000,3000]
  assertEqual st z4 [1111, 2222] "zipWith4 basic behaviour"

  let chosen := choose [10, 20, 30]
  assertEqual st chosen [10, 20, 30] "choose preserves list"

  let perm2 := choosePerm [1, 2]
  assertEqual st perm2.length 2 "choosePerm [1, 2] length"

  let guardTrue := (guard true : List Unit).length
  assertEqual st guardTrue 1 "guard true yields unit"

  let guardFalse := (guard false : List Unit).length
  assertEqual st guardFalse 0 "guard false yields empty"

  let cpPass := checkpoint (· > 10) 15
  assertEqual st cpPass [15] "checkpoint pass"

  let cpFail := checkpoint (· > 10) 5
  assertEqual st cpFail [] "checkpoint fail"

  let monadicSearch : List Nat := do
    let x ← choose [1, 2, 3, 4]
    guard (x % 2 == 0)
    pure (x * 10)
  assertEqual st monadicSearch [20, 40] "monadic search pipeline"

  assertEqual st answers.length 1 "puzzle has exactly 1 solution"

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

    assertEqual st (jenny == jennyExpected) true "Jenny's assignment"
    assertEqual st (jackie == jackieExpected) true "Jackie's assignment"
    assertEqual st (samantha == samanthaExpected) true "Samantha's assignment"
    assertEqual st (judy == judyExpected) true "Judy's assignment"
  | _ =>
    IO.println "[FAIL] Expected exactly one solution"

end BreakfastTime.Test
