import LSpec
import BreakfastTime.Test

open LSpec

/-- Run all puzzle test suites unconditionally. -/
def main (_ : List String) : IO UInt32 :=
  lspecIO (.ofList [("BreakfastTime", [BreakfastTime.Test.tests])]) []
