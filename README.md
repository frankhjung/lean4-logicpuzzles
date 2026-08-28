# Logic Puzzles

A Lean 4 library of logic puzzle solvers.

## Dependencies

- [Lean 4](https://lean-lang.org/) (see `lean-toolchain`)
- [batteries](https://github.com/leanprover-community/batteries)
  — community standard library extensions (linting)

## Project layout

Each puzzle is implemented as a separate module with its own directory:

- `BreakfastTime/` — the Breakfast Time puzzle solver, executable, and
  module-local tests.
- `BreakfastTime/Perm.lean` — reusable list permutation and `zipWith4`
  combinators shared across puzzle solvers.

Shared infrastructure lives at the project root:

- `Test/Util.lean` — shared mutable test-state helpers (`assertEqual`,
  `summary`).
- `Test.lean` — test harness entry point that runs every module's test suite.

## Build and test

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

See [BreakfastTime.BreakfastTime][BreakfastTime.lean]

This module encodes the breakfast scenario, generates all candidate assignments,
filters them by the clue set, and exposes the unique solution.

### Solver design

The puzzle model is defined as a finite constraint problem over four people,
four breakfast drinks, four meals, and four to-go drinks:

- [`Name`][Name] — Jenny, Jackie, Samantha, Judy.
- [`Drink`][Drink] — Orange, Apple, Tea, Milk.
- [`Meal`][Meal] — Toast, Omelet, Pancakes, Cereal.
- [`ToGo`][ToGo] — Lemonade, Water, Coffee, Latte.

Each person is represented by an [`Assignment`][Assignment] record: `name`,
`drink`, `meal`, and `toGo`. The solver fixes an ordering for the names and then
builds every possible assignment by generating permutations of the four drink
choices, the four meal choices, and the four to-go choices, and pairing them
together with [`zipWith4`][zipWith4].

The key operation is [`candidates`][candidates], which enumerates the entire
search space of valid permutations. It does not assume the answer; it simply
constructs every possible way the puzzle could be configured. This produces a
complete candidate list from which the real solution is selected by logic.

The clue set is encoded as a list of predicates:

- [`clue1`][clue1] — Samantha eats cereal and does not have a latte to go.
- [`clue2`][clue2] — the pancakes eater also takes coffee to go and does not
  drink tea.
- [`clue3`][clue3] — the omelet eater has apple juice and is not Jenny.
- [`clue4`][clue4] — Orange juice and tea are assigned to two different people,
  one of whom is Jackie and the other is the toast eater.
- [`clue5`][clue5] — the person with water to go does not have orange juice.
- [`clue6`][clue6] — Judy has lemonade to go.

Each clue is expressed as a function from a candidate board
([`Assignment`][Assignment] list) to `Bool`. The helper functions
[`findByName`][findByName], [`findByMeal`][findByMeal],
[`findByDrink`][findByDrink], and [`findByToGo`][findByToGo] look up the
assignment matching a given person, meal, drink, or to-go order and make the
clue logic easy to read and verify. The six predicates are collected in the
[`clues`][clues] list; [`isValid`][isValid] checks that every entry in this list
is satisfied, and [`answers`][answers] keeps only those candidate assignments
that survive all six constraints.

The implementation is intentionally explicit: it models all possibilities,
encodes each rule in Lean, and filters until the solution set is reduced to a
single valid assignment. The [`permutations`][permutations] generator and
[`zipWith4`][zipWith4] combinator live in [BreakfastTime/Perm.lean][Perm.lean],
which also provides a [simp][simp] lemma
([`length_insertions`][length_insertions]) for reasoning about permutation
length.

The executable entry point in [BreakfastTime/Main.lean][Main.lean] calls
[`printSolution`][printSolution], which pattern-matches on
[`answers`][answers]: a unique solution is printed as a Markdown-style table
(one row per person, formatted by [`formatAssignment`][formatAssignment] and
padded by [`padRight`][padRight]), while the no-solution and multiple-solution
cases each emit a diagnostic message.

<!-- reflinks -->

[breakfast-time]: https://www.ahapuzzles.com/logic/logic-puzzles/breakfast-time/
[simp]: https://leanprover-community.github.io/extras/simp.html

[BreakfastTime.lean]: BreakfastTime/BreakfastTime.lean
[Perm.lean]: BreakfastTime/Perm.lean
[Main.lean]: BreakfastTime/Main.lean

[Name]: BreakfastTime/BreakfastTime.lean#L56
[Drink]: BreakfastTime/BreakfastTime.lean#L60
[Meal]: BreakfastTime/BreakfastTime.lean#L64
[ToGo]: BreakfastTime/BreakfastTime.lean#L68
[Assignment]: BreakfastTime/BreakfastTime.lean#L108
[candidates]: BreakfastTime/BreakfastTime.lean#L148
[clue1]: BreakfastTime/BreakfastTime.lean#L155
[clue2]: BreakfastTime/BreakfastTime.lean#L164
[clue3]: BreakfastTime/BreakfastTime.lean#L173
[clue4]: BreakfastTime/BreakfastTime.lean#L182
[clue5]: BreakfastTime/BreakfastTime.lean#L194
[clue6]: BreakfastTime/BreakfastTime.lean#L200
[findByName]: BreakfastTime/BreakfastTime.lean#L132
[findByMeal]: BreakfastTime/BreakfastTime.lean#L136
[findByDrink]: BreakfastTime/BreakfastTime.lean#L140
[findByToGo]: BreakfastTime/BreakfastTime.lean#L144
[clues]: BreakfastTime/BreakfastTime.lean#L206
[isValid]: BreakfastTime/BreakfastTime.lean#L210
[answers]: BreakfastTime/BreakfastTime.lean#L214
[printSolution]: BreakfastTime/BreakfastTime.lean#L230
[formatAssignment]: BreakfastTime/BreakfastTime.lean#L222
[padRight]: BreakfastTime/BreakfastTime.lean#L218
[permutations]: BreakfastTime/Perm.lean#L26
[zipWith4]: BreakfastTime/Perm.lean#L35
[length_insertions]: BreakfastTime/Perm.lean#L17
