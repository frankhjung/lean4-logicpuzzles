# Logic Puzzles

A Lean 4 library of logic puzzle solvers.

## Dependencies

- [Lean 4](https://lean-lang.org/) (see `lean-toolchain`)
- [batteries](https://github.com/leanprover-community/batteries)
  — community standard library extensions (linting)
- [Mathlib](https://github.com/leanprover-community/mathlib4)
  — mathematics and data structures library for Lean 4

## Project Layout

Each puzzle is implemented as a separate module with its own directory:

- `BreakfastTime/` — the Breakfast Time puzzle module:
  - `Solve.lean` — puzzle domain encoding, clues, and solver.
  - `Search.lean` — reusable monadic search combinators (`choose`,
    `choosePerm`, `checkpoint`) with early branch pruning.
  - `Perm.lean` — permutation and `zipWith4` combinators.
  - `Meta.lean` — compile-time constructor enumeration macro
    (`allConstructors%`).
  - `Display.lean` — solution table formatting and IO.
  - `Main.lean` — executable entry point.
  - `Test.lean` — module-local unit and solver tests.

Shared infrastructure lives at the project root:

- `Test/Util.lean` — shared mutable test-state helpers (`assertEqual`,
  `summary`).
- `Test.lean` — test harness entry point that runs every module's test suite.

## Build and Test

All targets are available via `make help`.

```bash
make              # build, lint, test, and run all
make build        # build a single module (MODULE=…)
make build-all    # build every puzzle module
make lint         # run the batteries linter
make test         # test a single module (MODULE=…)
make test-all     # test every puzzle module
make run          # run a single module exe (MODULE=…)
make run-all      # run every puzzle executable
make clean        # remove build artefacts
make update       # update Lake dependencies
make help         # show all targets with descriptions
```

The `MODULE` variable defaults to `BreakfastTime`. Override it to target a
specific puzzle, e.g.:

```bash
make test MODULE=BreakfastTime
```

## Breakfast Time

The initial puzzle is the Breakfast Time puzzle, based on the classic
[Breakfast Time][breakfast-time] logic grid.

See [BreakfastTime.Solve][Solve.lean]

This module encodes the breakfast scenario, generates candidate assignments
monadically, filters them with early clue pruning, and exposes the unique
solution.

### Solver Design

The puzzle model is defined as a finite constraint problem over four people,
four breakfast drinks, four meals, and four to-go drinks:

- [`Name`][Name] — Jenny, Jackie, Samantha, Judy.
- [`Drink`][Drink] — Orange, Apple, Tea, Milk.
- [`Meal`][Meal] — Toast, Omelet, Pancakes, Cereal.
- [`ToGo`][ToGo] — Lemonade, Water, Coffee, Latte.

Each person is represented by an [`Assignment`][Assignment] record: `name`,
`drink`, `meal`, and `toGo`. The solver fixes an ordering for the names and then
builds candidate assignments using the monadic search DSL from
[BreakfastTime/Search.lean][Search.lean], generating permutations of drink,
meal, and to-go choices with [`choosePerm`][choosePerm] paired via
[`zipWith4`][zipWith4].

The operation [`candidates`][candidates] enumerates the full unconstrained
search space for exploration and testing.

The clue set is encoded as a list of predicates:

- [`clue1`][clue1] — Samantha eats cereal and does not have a latte to go.
- [`clue2`][clue2] — the pancakes eater also takes coffee to go and does not
  drink tea.
- [`clue3`][clue3] — the omelet eater has apple juice and is not Jenny.
- [`clue4`][clue4] — orange juice and tea are assigned to two different people,
  one of whom is Jackie and the other is the toast eater.
- [`clue5`][clue5] — the person with water to go does not have orange juice.
- [`clue6`][clue6] — Judy has lemonade to go.

Each clue is expressed as a function from an assignment list to `Bool`. The
helper functions [`findByName`][findByName], [`findByMeal`][findByMeal],
[`findByDrink`][findByDrink], and [`findByToGo`][findByToGo] look up the
assignment matching a given person, meal, drink, or to-go order.

The six predicates are collected in the [`clues`][clues] list, and
[`isValid`][isValid] checks that every entry is satisfied.

To avoid evaluating the full Cartesian product ($4! \times 4! \times 4! =
13,824$ states), [`answers`][answers] leverages the monadic search pipeline
with early branch pruning via
[`validPartialDrinksMeals`][validPartialDrinksMeals]. Evaluating Clues 3 and 4
as soon as drinks and meals are selected prunes invalid branches by **~98.6%**
(reducing 576 intermediate pairs to just 8) before permuting to-go drinks.

The executable entry point in [BreakfastTime/Main.lean][Main.lean] calls
[`printSolution`][printSolution] from
[BreakfastTime/Display.lean][Display.lean], which pattern-matches on
[`answers`][answers]: a unique solution is printed as a Markdown-style table
(one row per person, formatted by [`formatAssignment`][formatAssignment] and
padded by [`padRight`][padRight]), while empty and multiple-solution cases emit
diagnostic messages.

<!-- reflinks -->

[breakfast-time]: https://www.ahapuzzles.com/logic/logic-puzzles/breakfast-time/
[simp]: https://leanprover-community.github.io/extras/simp.html

[Solve.lean]: BreakfastTime/Solve.lean
[Search.lean]: BreakfastTime/Search.lean
[Display.lean]: BreakfastTime/Display.lean
[Perm.lean]: BreakfastTime/Perm.lean
[Main.lean]: BreakfastTime/Main.lean

[Name]: BreakfastTime/Solve.lean#L60
[Drink]: BreakfastTime/Solve.lean#L64
[Meal]: BreakfastTime/Solve.lean#L68
[ToGo]: BreakfastTime/Solve.lean#L72
[Assignment]: BreakfastTime/Solve.lean#L76
[findByName]: BreakfastTime/Solve.lean#L100
[findByMeal]: BreakfastTime/Solve.lean#L104
[findByDrink]: BreakfastTime/Solve.lean#L108
[findByToGo]: BreakfastTime/Solve.lean#L112
[candidates]: BreakfastTime/Solve.lean#L116
[clue1]: BreakfastTime/Solve.lean#L123
[clue2]: BreakfastTime/Solve.lean#L132
[clue3]: BreakfastTime/Solve.lean#L141
[clue4]: BreakfastTime/Solve.lean#L150
[clue5]: BreakfastTime/Solve.lean#L162
[clue6]: BreakfastTime/Solve.lean#L168
[clues]: BreakfastTime/Solve.lean#L174
[isValid]: BreakfastTime/Solve.lean#L178
[validPartialDrinksMeals]: BreakfastTime/Solve.lean#L182
[answers]: BreakfastTime/Solve.lean#L199
[choosePerm]: BreakfastTime/Search.lean#L23
[printSolution]: BreakfastTime/Display.lean#L31
[formatAssignment]: BreakfastTime/Display.lean#L23
[padRight]: BreakfastTime/Display.lean#L19
[permutations]: BreakfastTime/Perm.lean#L26
[zipWith4]: BreakfastTime/Perm.lean#L35
[length_insertions]: BreakfastTime/Perm.lean#L17
