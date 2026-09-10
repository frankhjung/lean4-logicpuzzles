import Test.Util
import BreakfastTime.Test

open Test.Util (Suite mkState summary)

/-- Registered test suites for all puzzle modules. -/
def allSuites : List Suite := [
  { name := "BreakfastTime", run := BreakfastTime.Test.runTests }
]

/-- Run registered puzzle test suites, optionally filtered by module name. -/
def main (args : List String) : IO UInt32 := do
  let suitesToRun ← match args with
    | [] | ["all"] => pure allSuites
    | targets =>
      let matched := allSuites.filter (fun s => targets.any (· == s.name))
      let missing := targets.filter (fun t => !allSuites.any (·.name == t))
      for m in missing do
        IO.eprintln s!"[TEST] Unknown puzzle test suite: '{m}'"
        let available := allSuites.map (·.name)
        IO.eprintln s!"[TEST] Available suites: {available}"
      if !missing.isEmpty then
        return 1
      pure matched

  let suiteNames := suitesToRun.map (·.name)
  IO.println s!"Running tests for: {suiteNames}..."
  let st ← mkState
  for suite in suitesToRun do
    suite.run st

  summary st
  let s ← st.get
  if s.fails > 0 then
    IO.println "[TEST] Some tests failed."
    return 1
  else
    IO.println "[TEST] All tests passed!"
    return 0
