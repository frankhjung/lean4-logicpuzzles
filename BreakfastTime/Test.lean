import Test.Util
import BreakfastTime.Perm
import BreakfastTime.BreakfastTime

namespace BreakfastTime.Test

open Test.Util
open BreakfastTime.Perm
open BreakfastTime.BreakfastTime

/-- Run BreakfastTime puzzle tests. -/
def runTests (st : IO.Ref State) : IO Unit := do
  IO.println "\n[TEST] Testing BreakfastTime.BreakfastTime"

  let perms123 := permutations [1, 2, 3]
  assertEqual st perms123.length 6 "permutations [1,2,3] length"

  let allPresent := perms123.all (fun p => p.contains 1 && p.contains 2 && p.contains 3)
  assertEqual st allPresent true "permutations completeness"

  let z4 := zipWith4 (fun a b c d => a + b + c + d) [1,2] [10,20] [100,200] [1000,2000,3000]
  assertEqual st z4 [1111, 2222] "zipWith4 basic behaviour"

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
