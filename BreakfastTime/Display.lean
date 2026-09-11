import BreakfastTime.Solve

/-!
# Breakfast Time Display Utilities

Provides formatting and IO routines for presenting puzzle solutions, keeping the
core solver purely functional.
-/

namespace BreakfastTime.Display

open BreakfastTime.Solve (Assignment answers)

/-- Pad a string on the right to a given width. -/
def padRight (s : String) (len : Nat) : String :=
  if s.length >= len then s else s.pushn ' ' (len - s.length)

/-- Format an assignment as a Markdown-style table row. -/
def formatAssignment (a : Assignment) : String :=
  let ns := padRight (toString a.name) 8
  let ds := padRight (toString a.drink) 8
  let ms := padRight (toString a.meal) 8
  let ts := padRight (toString a.toGo) 8
  s!"| {ns} | {ds} | {ms} | {ts} |"

/-- Print the unique solution as a text table. -/
def printSolution : IO Unit := do
  match answers with
  | [sol] =>
    IO.println "| Name     | Drink    | Meal     | To Go    |"
    IO.println "|----------|----------|----------|----------|"
    for a in sol do
      IO.println (formatAssignment a)
  | [] =>
    IO.println "No valid solution found."
  | _ :: _ =>
    IO.println "More than one valid solution found."

end BreakfastTime.Display
