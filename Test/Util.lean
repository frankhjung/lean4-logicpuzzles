namespace Test.Util

/-- Mutable state for test results. -/
structure State where
  /-- Number of failed assertions. -/
  fails : Nat
  /-- Number of executed assertions. -/
  total : Nat

/-- Record success and failure counts. -/
def mkState : IO (IO.Ref State) :=
  IO.mkRef { fails := 0, total := 0 }

/-- Assert equality between two values and record the result. -/
def assertEqual {α : Type} [BEq α] [ToString α]
    (st : IO.Ref State)
    (actual : α) (expected : α) (msg : String)
    : IO Unit := do
  let s ← st.get
  let total := s.total + 1
  if actual == expected then
    st.set { s with total := total }
    IO.println s!"[PASS] {msg}"
  else
    st.set { s with total := total, fails := s.fails + 1 }
    IO.println s!"[FAIL] {msg}: expected {expected}, got {actual}"

/-- Print summary of test results. -/
def summary (st : IO.Ref State) : IO Unit := do
  let s ← st.get
  IO.println ""
  IO.println s!"[TEST] Summary: {s.total} tests, {s.fails} failures"

end Test.Util
