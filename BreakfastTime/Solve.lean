import BreakfastTime.Combinators

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

namespace BreakfastTime.Solve

open BreakfastTime.Combinators

/-- Friend names. -/
inductive Name | Jenny | Jackie | Samantha | Judy
  deriving BEq, DecidableEq, Repr, Inhabited

instance : ToString Name where
  toString
    | .Jenny => "Jenny"
    | .Jackie => "Jackie"
    | .Samantha => "Samantha"
    | .Judy => "Judy"

/-- Breakfast drinks. -/
inductive Drink | Orange | Apple | Tea | Milk
  deriving BEq, DecidableEq, Repr, Inhabited

instance : ToString Drink where
  toString
    | .Orange => "Orange"
    | .Apple => "Apple"
    | .Tea => "Tea"
    | .Milk => "Milk"

/-- Breakfast meals. -/
inductive Meal | Toast | Omelet | Pancakes | Cereal
  deriving BEq, DecidableEq, Repr, Inhabited

instance : ToString Meal where
  toString
    | .Toast => "Toast"
    | .Omelet => "Omelet"
    | .Pancakes => "Pancakes"
    | .Cereal => "Cereal"

/-- To-go drinks. -/
inductive ToGo | Lemonade | Water | Coffee | Latte
  deriving BEq, DecidableEq, Repr, Inhabited

instance : ToString ToGo where
  toString
    | .Lemonade => "Lemonade"
    | .Water => "Water"
    | .Coffee => "Coffee"
    | .Latte => "Latte"

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
def names : List Name := [.Jenny, .Jackie, .Samantha, .Judy]

/-- All possible drinks. -/
def drinks : List Drink := [.Orange, .Apple, .Tea, .Milk]

/-- All possible meals. -/
def meals : List Meal := [.Toast, .Omelet, .Pancakes, .Cereal]

/-- All possible to-go drinks. -/
def togos : List ToGo := [.Lemonade, .Water, .Coffee, .Latte]

/-- 1. Samantha had cereal but not a Latte. -/
def clue1 (sol : List Assignment) : Bool :=
  sol.any fun a => a.name == .Samantha && a.meal == .Cereal && a.toGo != .Latte

/--
2. The friend who ordered pancakes also ordered coffee to go and did
not have tea.
-/
def clue2 (sol : List Assignment) : Bool :=
  sol.any fun a => a.meal == .Pancakes && a.toGo == .Coffee && a.drink != .Tea

/--
3. The woman who ordered the omelet had apple juice to drink but she
wasn't Jenny.
-/
def clue3 (sol : List Assignment) : Bool :=
  sol.any fun a => a.meal == .Omelet && a.drink == .Apple && a.name != .Jenny

/--
4. The orange juice and tea drink were ordered by two friends, one of
whom was Jackie and the other was the friend who ordered toast.
-/
def clue4 (sol : List Assignment) : Bool :=
  match sol.find? (·.name == .Jackie), sol.find? (·.meal == .Toast) with
  | some a1, some a2 =>
      (a1.drink == .Orange && a2.drink == .Tea) ||
      (a1.drink == .Tea && a2.drink == .Orange)
  | _, _ => false

/--
5. The friend who ordered water to go did not order orange juice.
-/
def clue5 (sol : List Assignment) : Bool :=
  sol.any fun a => a.toGo == .Water && a.drink != .Orange

/-- 6. Judy ordered lemonade to go. -/
def clue6 (sol : List Assignment) : Bool :=
  sol.any fun a => a.name == .Judy && a.toGo == .Lemonade

/-- All six clue predicates. -/
def clues : List (List Assignment → Bool) :=
  [clue1, clue2, clue3, clue4, clue5, clue6]

/-- True when all clues are satisfied. -/
def isValid (sol : List Assignment) : Bool :=
  clues.all fun clue => clue sol

/-- Check if partial (Name × Drink × Meal) assignment satisfies Clues 3 & 4. -/
def validPartialDrinksMeals (ds : List Drink) (ms : List Meal) : Bool :=
  let pairs := names.zip (ds.zip ms)
  let c3 := pairs.any fun (n, d, m) =>
    m == Meal.Omelet && d == Drink.Apple && n != Name.Jenny
  let jackieDrink := pairs.find? (·.1 == Name.Jackie) |>.map (·.2.1)
  let toastDrink := pairs.find? (·.2.2 == Meal.Toast) |>.map (·.2.1)
  let c4 := match jackieDrink, toastDrink with
    | some d1, some d2 =>
        (d1 == Drink.Orange && d2 == Drink.Tea) ||
        (d1 == Drink.Tea && d2 == Drink.Orange)
    | _, _ => false
  c3 && c4

/--
Find all valid solutions using the monadic search DSL with early branch
pruning on intermediate attribute combinations.
-/
def answers : List (List Assignment) := do
  let ds ← permutations drinks
  let ms ← permutations meals
  guard (validPartialDrinksMeals ds ms)
  let ts ← permutations togos
  let sol := zipWith4 Assignment.mk names ds ms ts
  guard (isValid sol)
  pure sol

end BreakfastTime.Solve
