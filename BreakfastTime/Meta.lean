import Lean

/-!
# Metaprogramming Utilities

Provides custom macros to automate boilerplate, such as enumerating all
constructors of an inductive type.
-/

namespace BreakfastTime.Meta

open Lean Elab Term Meta

/--
A macro to automatically generate a list of all constructors for a given
inductive type.

Usage: `allConstructors% MyInductiveType`
-/
elab "allConstructors% " t:ident : term => do
  let name ← resolveGlobalConstNoOverload t
  let env ← getEnv
  match env.find? name with
  | some (.inductInfo info) =>
    let ctors := info.ctors
    let stxs := ctors.toArray.map mkIdent
    let listStx ← `([$stxs,*])
    elabTerm listStx none
  | _ => throwError "not an inductive type"

end BreakfastTime.Meta
