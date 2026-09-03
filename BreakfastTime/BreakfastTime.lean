import BreakfastTime.Perm
import BreakfastTime.Meta

/-!
# Breakfast Time logic puzzle

A Lean 4 implementation of the Breakfast Time logic puzzle.

== Solve Breakfast at Tiffanys logic puzzle (medium)

Four close friends decided to get together one morning for breakfast and
conversation. Jenny, whose turn it was to pick the location, decided on a
fancy hotel in downtown NYC. Each of the women had a small meal served with
a drink (one of the drinks was an Orange Juice) and they talked about their
busy week. Their conversation continued longer than expected and each of
the women had to rush out of the hotel. Before leaving, they each got
another drink to go (one of which was a latte). Can you figure out which
woman ordered which drink for breakfast, what they ate, and which drink
they took to go?

=== Clues

1. Samantha had a bowl of cereal but not a Latte.
2. The friend who ordered the potato pancakes also ordered a coffee to
   go but didn't have an ice tea.
3. The woman who ordered the omelet had apple juice to drink but she
   wasn't Jenny.
4. Of the two friends who ordered the orange juice and the ice tea,
   one was Jackie and the other was the friend who ordered the french
   toast.
5. The friend who ordered a bottle of water to go didn't order
   orange juice.
6. Judy ordered a lemonade to go.

=== Answer

|----------+---------+----------+----------|
| Name     | Drinks  | Meal     | To Go    |
|==========+=========+==========+==========|
| Jenny    | Tea     | Toast    | Latte    |
| Jackie   | Orange  | Pancakes | Coffee   |
| Samantha | Milk    | Cereal   | Water    |
| Judy     | Apple   | Omelet   | Lemonade |
|----------+---------+----------+----------|

=== References

- <https://www.ahapuzzles.com/logic/logic-puzzles/breakfast-time/>

-/

namespace BreakfastTime.BreakfastTime

open BreakfastTime.Perm (permutations zipWith4)
open BreakfastTime.Meta

/-- Friend names. -/
inductive Name | Jenny | Jackie | Samantha | Judy
  deriving BEq, DecidableEq, Repr, Inhabited

/-- Breakfast drinks. -/
inductive Drink | Orange | Apple | Tea | Milk
  deriving BEq, DecidableEq, Repr, Inhabited

/-- Breakfast meals. -/
inductive Meal | Toast | Omelet | Pancakes | Cereal
  deriving BEq, DecidableEq, Repr, Inhabited

/-- To-go drinks. -/
inductive ToGo | Lemonade | Water | Coffee | Latte
  deriving BEq, DecidableEq, Repr, Inhabited

/-- A single person's assignment: Name, Drink, Meal, ToGo. -/
structure Assignment where
  /-- The person's name. -/
  name : Name
  /-- The person's drink choice. -/
  drink : Drink
  /-- The person's meal choice. -/
  meal : Meal
  /-- The person's drink-to-go choice. -/
  toGo : ToGo
  deriving BEq, DecidableEq, Repr, Inhabited

/-- All possible names in fixed order. -/
def names : List Name := allConstructors% Name

/-- All possible drinks. -/
def drinks : List Drink := allConstructors% Drink

/-- All possible meals. -/
def meals : List Meal := allConstructors% Meal

/-- All possible to-go drinks. -/
def togos : List ToGo := allConstructors% ToGo

/-- Find the assignment for a given name. -/
def findByName (sol : List Assignment) (name : Name) : Option Assignment :=
  sol.find? (fun a => a.name == name)

/-- Find the assignment for a given meal. -/
def findByMeal (sol : List Assignment) (meal : Meal) : Option Assignment :=
  sol.find? (fun a => a.meal == meal)

/-- Find the assignment for a given drink. -/
def findByDrink (sol : List Assignment) (drink : Drink) : Option Assignment :=
  sol.find? (fun a => a.drink == drink)

/-- Find the assignment for a given to-go drink. -/
def findByToGo (sol : List Assignment) (toGo : ToGo) : Option Assignment :=
  sol.find? (fun a => a.toGo == toGo)

/-- All candidate assignments for the puzzle. -/
def candidates : List (List Assignment) :=
  (permutations drinks).flatMap fun ds =>
  (permutations meals).flatMap fun ms =>
  (permutations togos).map fun ts =>
  zipWith4 Assignment.mk names ds ms ts

/-- 1. Samantha had cereal but not a Latte. -/
def clue1 (sol : List Assignment) : Bool :=
  match findByName sol Name.Samantha with
  | some a => a.meal == Meal.Cereal && a.toGo != ToGo.Latte
  | none => false

/--
2. The friend who ordered pancakes also ordered coffee to go and did
not have tea.
-/
def clue2 (sol : List Assignment) : Bool :=
  match findByMeal sol Meal.Pancakes with
  | some a => a.toGo == ToGo.Coffee && a.drink != Drink.Tea
  | none => false

/--
3. The woman who ordered the omelet had apple juice to drink but she
wasn't Jenny.
-/
def clue3 (sol : List Assignment) : Bool :=
  match findByMeal sol Meal.Omelet with
  | some a => a.drink == Drink.Apple && a.name != Name.Jenny
  | none => false

/--
4. The orange juice and tea drink were ordered by two friends, one of
whom was Jackie and the other was the friend who ordered toast.
-/
def clue4 (sol : List Assignment) : Bool :=
  let jackieData := findByName sol Name.Jackie
  let toastData := findByMeal sol Meal.Toast
  match jackieData, toastData with
  | some a1, some a2 =>
      (a1.drink == Drink.Orange && a2.drink == Drink.Tea) ||
      (a1.drink == Drink.Tea && a2.drink == Drink.Orange)
  | _, _ => false

/--
5. The friend who ordered water to go did not order orange juice.
-/
def clue5 (sol : List Assignment) : Bool :=
  match findByToGo sol ToGo.Water with
  | some a => a.drink != Drink.Orange
  | none => false

/-- 6. Judy ordered lemonade to go. -/
def clue6 (sol : List Assignment) : Bool :=
  match findByName sol Name.Judy with
  | some a => a.toGo == ToGo.Lemonade
  | none => false

/-- All six clue predicates. -/
def clues : List (List Assignment → Bool) :=
  [clue1, clue2, clue3, clue4, clue5, clue6]

/-- True when all clues are satisfied. -/
def isValid (sol : List Assignment) : Bool :=
  clues.all fun clue => clue sol

/-- All valid solutions for the puzzle. -/
def answers : List (List Assignment) :=
  candidates.filter isValid

end BreakfastTime.BreakfastTime
