import Test.Util
import BreakfastTime.Test

open Test.Util (mkState summary)

/-- Run the test suite. -/
def main : IO Unit := do
  IO.println "Running tests..."

  let st ← mkState
  BreakfastTime.Test.runTests st

  summary st
  let s ← st.get
  if s.fails > 0 then
    IO.println "[TEST] Some tests failed."
    IO.Process.exit 1
  else
    IO.println "[TEST] All tests passed!"
