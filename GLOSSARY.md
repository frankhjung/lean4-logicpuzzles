# Glossary

## Assignment

A record mapping a single friend (`Name`) to their breakfast drink, meal, and
to-go beverage choices. A complete puzzle solution consists of exactly four
assignments, one for each friend.

_Avoid_: Row, Solution, Entry.

## Breakfast Drink

The beverage ordered by a friend to accompany their morning meal (`Orange`,
`Apple`, `Tea`, `Milk`). Distinct from the takeaway drink ordered prior to
departure.

_Avoid_: Drink, Beverage.

## Candidate

A potential solution comprising a full list of assignments generated through
permutations of attribute categories prior to validation against the puzzle's
clues.

_Avoid_: State, Guess.

## Clue

A boolean predicate expressing a problem constraint that any valid puzzle
solution must satisfy. Clues may relate individuals to choices or relate two
distinct choices to one another.

_Avoid_: Rule, Condition.

## Early Branch Pruning

A search optimisation technique that filters partial attribute combinations
(such as drinks and meals) before generating subsequent permutations (such as
to-go drinks), discarding invalid search branches early.

_Avoid_: Filtering, Short-circuiting.

## Logic Puzzle

A finite constraint satisfaction grid problem where a set of clues uniquely
identifies a single valid mapping across multiple disjoint categorical
domains.

_Avoid_: Riddle, Game.

## Partial Assignment

An intermediate tuple combining a subset of attributes (such as `Name`,
`Drink`, and `Meal`) evaluated during search before full candidate
instantiation.

_Avoid_: Incomplete record, Draft.

## Solution

The unique, complete list of assignments that satisfies every clue predicate
in the puzzle specification.

_Avoid_: Answer, Result.

## To-Go Drink

The takeaway beverage ordered by each friend upon leaving the venue
(`Lemonade`, `Water`, `Coffee`, `Latte`). Distinct from the breakfast drink.

_Avoid_: Takeaway, Departure drink.
