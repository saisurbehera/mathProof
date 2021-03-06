/-
Copyright (c) 2019 Alexander Bentkamp. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp, FranΓ§ois Dupuis
-/
import analysis.convex.basic
import order.order_dual
import tactic.field_simp
import tactic.linarith
import tactic.ring

/-!
# Convex and concave functions

This file defines convex and concave functions in vector spaces and proves the finite Jensen
inequality. The integral version can be found in `analysis.convex.integral`.

A function `f : E β Ξ²` is `convex_on` a set `s` if `s` is itself a convex set, and for any two
points `x y β s`, the segment joining `(x, f x)` to `(y, f y)` is above the graph of `f`.
Equivalently, `convex_on π f s` means that the epigraph `{p : E Γ Ξ² | p.1 β s β§ f p.1 β€ p.2}` is
a convex set.

## Main declarations

* `convex_on π s f`: The function `f` is convex on `s` with scalars `π`.
* `concave_on π s f`: The function `f` is concave on `s` with scalars `π`.
* `strict_convex_on π s f`: The function `f` is strictly convex on `s` with scalars `π`.
* `strict_concave_on π s f`: The function `f` is strictly concave on `s` with scalars `π`.
-/

open finset linear_map set
open_locale big_operators classical convex pointwise

variables {π E F Ξ² ΞΉ : Type*}

section ordered_semiring
variables [ordered_semiring π]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F]

section ordered_add_comm_monoid
variables [ordered_add_comm_monoid Ξ²]

section has_scalar
variables (π) [has_scalar π E] [has_scalar π Ξ²] (s : set E) (f : E β Ξ²)

/-- Convexity of functions -/
def convex_on : Prop :=
convex π s β§
  β β¦x y : Eβ¦, x β s β y β s β β β¦a b : πβ¦, 0 β€ a β 0 β€ b β a + b = 1 β
    f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y

/-- Concavity of functions -/
def concave_on : Prop :=
convex π s β§
  β β¦x y : Eβ¦, x β s β y β s β β β¦a b : πβ¦, 0 β€ a β 0 β€ b β a + b = 1 β
    a β’ f x + b β’ f y β€ f (a β’ x + b β’ y)

/-- Strict convexity of functions -/
def strict_convex_on : Prop :=
convex π s β§
  β β¦x y : Eβ¦, x β s β y β s β x β  y β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β
    f (a β’ x + b β’ y) < a β’ f x + b β’ f y

/-- Strict concavity of functions -/
def strict_concave_on : Prop :=
convex π s β§
  β β¦x y : Eβ¦, x β s β y β s β x β  y β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β
    a β’ f x + b β’ f y < f (a β’ x + b β’ y)

variables {π s f}

open order_dual (to_dual of_dual)

lemma convex_on.dual (hf : convex_on π s f) : concave_on π s (to_dual β f) := hf

lemma concave_on.dual (hf : concave_on π s f) : convex_on π s (to_dual β f) := hf

lemma strict_convex_on.dual (hf : strict_convex_on π s f) : strict_concave_on π s (to_dual β f) :=
hf

lemma strict_concave_on.dual (hf : strict_concave_on π s f) : strict_convex_on π s (to_dual β f) :=
hf

lemma convex_on_id {s : set Ξ²} (hs : convex π s) : convex_on π s id := β¨hs, by { intros, refl }β©

lemma concave_on_id {s : set Ξ²} (hs : convex π s) : concave_on π s id := β¨hs, by { intros, refl }β©

lemma convex_on.subset {t : set E} (hf : convex_on π t f) (hst : s β t) (hs : convex π s) :
  convex_on π s f :=
β¨hs, Ξ» x y hx hy, hf.2 (hst hx) (hst hy)β©

lemma concave_on.subset {t : set E} (hf : concave_on π t f) (hst : s β t) (hs : convex π s) :
  concave_on π s f :=
β¨hs, Ξ» x y hx hy, hf.2 (hst hx) (hst hy)β©

lemma strict_convex_on.subset {t : set E} (hf : strict_convex_on π t f) (hst : s β t)
  (hs : convex π s) :
  strict_convex_on π s f :=
β¨hs, Ξ» x y hx hy, hf.2 (hst hx) (hst hy)β©

lemma strict_concave_on.subset {t : set E} (hf : strict_concave_on π t f) (hst : s β t)
  (hs : convex π s) :
  strict_concave_on π s f :=
β¨hs, Ξ» x y hx hy, hf.2 (hst hx) (hst hy)β©

end has_scalar

section distrib_mul_action
variables [has_scalar π E] [distrib_mul_action π Ξ²] {s : set E} {f g : E β Ξ²}

lemma convex_on.add (hf : convex_on π s f) (hg : convex_on π s g) :
  convex_on π s (f + g) :=
β¨hf.1, Ξ» x y hx hy a b ha hb hab,
  calc
    f (a β’ x + b β’ y) + g (a β’ x + b β’ y) β€ (a β’ f x + b β’ f y) + (a β’ g x + b β’ g y)
      : add_le_add (hf.2 hx hy ha hb hab) (hg.2 hx hy ha hb hab)
    ... = a β’ (f x + g x) + b β’ (f y + g y) : by rw [smul_add, smul_add, add_add_add_comm]β©

lemma concave_on.add (hf : concave_on π s f) (hg : concave_on π s g) :
  concave_on π s (f + g) :=
hf.dual.add hg

end distrib_mul_action

section module
variables [has_scalar π E] [module π Ξ²] {s : set E} {f : E β Ξ²}

lemma convex_on_const (c : Ξ²) (hs : convex π s) : convex_on π s (Ξ» x:E, c) :=
β¨hs, Ξ» x y _ _ a b _ _ hab, (convex.combo_self hab c).geβ©

lemma concave_on_const (c : Ξ²) (hs : convex π s) : concave_on π s (Ξ» x:E, c) :=
@convex_on_const _ _ (order_dual Ξ²) _ _ _ _ _ _ c hs

lemma convex_on_of_convex_epigraph (h : convex π {p : E Γ Ξ² | p.1 β s β§ f p.1 β€ p.2}) :
  convex_on π s f :=
β¨Ξ» x y hx hy a b ha hb hab, (@h (x, f x) (y, f y) β¨hx, le_rflβ© β¨hy, le_rflβ© a b ha hb hab).1,
  Ξ» x y hx hy a b ha hb hab, (@h (x, f x) (y, f y) β¨hx, le_rflβ© β¨hy, le_rflβ© a b ha hb hab).2β©

lemma concave_on_of_convex_hypograph (h : convex π {p : E Γ Ξ² | p.1 β s β§ p.2 β€ f p.1}) :
  concave_on π s f :=
@convex_on_of_convex_epigraph π  E (order_dual Ξ²) _ _ _ _ _ _ _ h

end module

section ordered_smul
variables [has_scalar π E] [module π Ξ²] [ordered_smul π Ξ²] {s : set E} {f : E β Ξ²}

lemma convex_on.convex_le (hf : convex_on π s f) (r : Ξ²) :
  convex π {x β s | f x β€ r} :=
Ξ» x y hx hy a b ha hb hab, β¨hf.1 hx.1 hy.1 ha hb hab,
  calc
    f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y : hf.2 hx.1 hy.1 ha hb hab
                  ... β€ a β’ r + b β’ r     : add_le_add (smul_le_smul_of_nonneg hx.2 ha)
                                              (smul_le_smul_of_nonneg hy.2 hb)
                  ... = r                 : convex.combo_self hab rβ©

lemma concave_on.convex_ge (hf : concave_on π s f) (r : Ξ²) :
  convex π {x β s | r β€ f x} :=
hf.dual.convex_le r

lemma convex_on.convex_epigraph (hf : convex_on π s f) :
  convex π {p : E Γ Ξ² | p.1 β s β§ f p.1 β€ p.2} :=
begin
  rintro β¨x, rβ© β¨y, tβ© β¨hx, hrβ© β¨hy, htβ© a b ha hb hab,
  refine β¨hf.1 hx hy ha hb hab, _β©,
  calc f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y : hf.2 hx hy ha hb hab
  ... β€ a β’ r + b β’ t : add_le_add (smul_le_smul_of_nonneg hr ha)
                            (smul_le_smul_of_nonneg ht hb)
end

lemma concave_on.convex_hypograph (hf : concave_on π s f) :
  convex π {p : E Γ Ξ² | p.1 β s β§ p.2 β€ f p.1} :=
hf.dual.convex_epigraph

lemma convex_on_iff_convex_epigraph :
  convex_on π s f β convex π {p : E Γ Ξ² | p.1 β s β§ f p.1 β€ p.2} :=
β¨convex_on.convex_epigraph, convex_on_of_convex_epigraphβ©

lemma concave_on_iff_convex_hypograph :
  concave_on π s f β convex π {p : E Γ Ξ² | p.1 β s β§ p.2 β€ f p.1} :=
@convex_on_iff_convex_epigraph π E (order_dual Ξ²) _ _ _ _ _ _ _ f

end ordered_smul

section module
variables [module π E] [has_scalar π Ξ²] {s : set E} {f : E β Ξ²}

/-- Right translation preserves convexity. -/
lemma convex_on.translate_right (hf : convex_on π s f) (c : E) :
  convex_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, c + z)) :=
β¨hf.1.translate_preimage_right _, Ξ» x y hx hy a b ha hb hab,
  calc
    f (c + (a β’ x + b β’ y)) = f (a β’ (c + x) + b β’ (c + y))
        : by rw [smul_add, smul_add, add_add_add_comm, convex.combo_self hab]
    ... β€ a β’ f (c + x) + b β’ f (c + y) : hf.2 hx hy ha hb habβ©

/-- Right translation preserves concavity. -/
lemma concave_on.translate_right (hf : concave_on π s f) (c : E) :
  concave_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, c + z)) :=
hf.dual.translate_right _

/-- Left translation preserves convexity. -/
lemma convex_on.translate_left (hf : convex_on π s f) (c : E) :
  convex_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, z + c)) :=
by simpa only [add_comm] using hf.translate_right _

/-- Left translation preserves concavity. -/
lemma concave_on.translate_left (hf : concave_on π s f) (c : E) :
  concave_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, z + c)) :=
hf.dual.translate_left _

end module

section module
variables [module π E] [module π Ξ²]

lemma convex_on_iff_forall_pos {s : set E} {f : E β Ξ²} :
  convex_on π s f β convex π s β§
    β β¦x y : Eβ¦, x β s β y β s β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1
    β f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y :=
begin
  refine and_congr_right' β¨Ξ» h x y hx hy a b ha hb hab, h hx hy ha.le hb.le hab,
    Ξ» h x y hx hy a b ha hb hab, _β©,
  obtain rfl | ha' := ha.eq_or_lt,
  { rw [zero_add] at hab, subst b, simp_rw [zero_smul, zero_add, one_smul] },
  obtain rfl | hb' := hb.eq_or_lt,
  { rw [add_zero] at hab, subst a, simp_rw [zero_smul, add_zero, one_smul] },
  exact h hx hy ha' hb' hab,
end

lemma concave_on_iff_forall_pos {s : set E} {f : E β Ξ²} :
  concave_on π s f β convex π s β§
    β β¦x y : Eβ¦, x β s β y β s β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1
    β a β’ f x + b β’ f y β€ f (a β’ x + b β’ y) :=
@convex_on_iff_forall_pos π E (order_dual Ξ²) _ _ _ _ _ _ _

lemma convex_on_iff_pairwise_pos {s : set E} {f : E β Ξ²} :
  convex_on π s f β convex π s β§
    s.pairwise (Ξ» x y, β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1
    β f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y) :=
begin
  rw convex_on_iff_forall_pos,
  refine and_congr_right' β¨Ξ» h x hx y hy _ a b ha hb hab, h hx hy ha hb hab,
    Ξ» h x y hx hy a b ha hb hab, _β©,
  obtain rfl | hxy := eq_or_ne x y,
  { rw [convex.combo_self hab, convex.combo_self hab] },
  exact h hx hy hxy ha hb hab,
end

lemma concave_on_iff_pairwise_pos {s : set E} {f : E β Ξ²} :
  concave_on π s f β convex π s β§
   s.pairwise (Ξ» x y, β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1
    β a β’ f x + b β’ f y β€ f (a β’ x + b β’ y)) :=
@convex_on_iff_pairwise_pos π E (order_dual Ξ²) _ _ _ _ _ _ _

/-- A linear map is convex. -/
lemma linear_map.convex_on (f : E ββ[π] Ξ²) {s : set E} (hs : convex π s) : convex_on π s f :=
β¨hs, Ξ» _ _ _ _ _ _ _ _ _, by rw [f.map_add, f.map_smul, f.map_smul]β©

/-- A linear map is concave. -/
lemma linear_map.concave_on (f : E ββ[π] Ξ²) {s : set E} (hs : convex π s) : concave_on π s f :=
β¨hs, Ξ» _ _ _ _ _ _ _ _ _, by rw [f.map_add, f.map_smul, f.map_smul]β©

lemma strict_convex_on.convex_on {s : set E} {f : E β Ξ²} (hf : strict_convex_on π s f) :
  convex_on π s f :=
convex_on_iff_pairwise_pos.mpr β¨hf.1, Ξ» x hx y hy hxy a b ha hb hab, (hf.2 hx hy hxy ha hb hab).leβ©

lemma strict_concave_on.concave_on {s : set E} {f : E β Ξ²} (hf : strict_concave_on π s f) :
  concave_on π s f :=
hf.dual.convex_on

section ordered_smul
variables [ordered_smul π Ξ²] {s : set E} {f : E β Ξ²}

lemma strict_convex_on.convex_lt (hf : strict_convex_on π s f) (r : Ξ²) :
  convex π {x β s | f x < r} :=
convex_iff_pairwise_pos.2 $ Ξ» x hx y hy hxy a b ha hb hab, β¨hf.1 hx.1 hy.1 ha.le hb.le hab,
  calc
    f (a β’ x + b β’ y) < a β’ f x + b β’ f y : hf.2 hx.1 hy.1 hxy ha hb hab
                  ... β€ a β’ r + b β’ r     : add_le_add (smul_lt_smul_of_pos hx.2 ha).le
                                              (smul_lt_smul_of_pos hy.2 hb).le
                  ... = r                 : convex.combo_self hab rβ©

lemma strict_concave_on.convex_gt (hf : strict_concave_on π s f) (r : Ξ²) :
  convex π {x β s | r < f x} :=
hf.dual.convex_lt r

end ordered_smul

section linear_order
variables [linear_order E] {s : set E} {f : E β Ξ²}

/-- For a function on a convex set in a linearly ordered space (where the order and the algebraic
structures aren't necessarily compatible), in order to prove that it is convex, it suffices to
verify the inequality `f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y` only for `x < y` and positive `a`,
`b`. The main use case is `E = π` however one can apply it, e.g., to `π^n` with lexicographic order.
-/
lemma linear_order.convex_on_of_lt (hs : convex π s)
  (hf : β β¦x y : Eβ¦, x β s β y β s β x < y β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β
    f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y) : convex_on π s f :=
begin
  refine convex_on_iff_pairwise_pos.2 β¨hs, Ξ» x hx y hy hxy a b ha hb hab, _β©,
  wlog h : x β€ y using [x y a b, y x b a],
  { exact le_total _ _ },
  exact hf hx hy (h.lt_of_ne hxy) ha hb hab,
end

/-- For a function on a convex set in a linearly ordered space (where the order and the algebraic
structures aren't necessarily compatible), in order to prove that it is concave it suffices to
verify the inequality `a β’ f x + b β’ f y β€ f (a β’ x + b β’ y)` for `x < y` and positive `a`, `b`. The
main use case is `E = β` however one can apply it, e.g., to `β^n` with lexicographic order. -/
lemma linear_order.concave_on_of_lt (hs : convex π s)
  (hf : β β¦x y : Eβ¦, x β s β y β s β x < y β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β
     a β’ f x + b β’ f y β€ f (a β’ x + b β’ y)) : concave_on π s f :=
@linear_order.convex_on_of_lt _ _ (order_dual Ξ²) _ _ _ _ _ _ s f hs hf

/-- For a function on a convex set in a linearly ordered space (where the order and the algebraic
structures aren't necessarily compatible), in order to prove that it is convex, it suffices to
verify the inequality `f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y` for `x < y` and positive `a`, `b`. The
main use case is `E = π` however one can apply it, e.g., to `π^n` with lexicographic order. -/
lemma linear_order.strict_convex_on_of_lt (hs : convex π s)
  (hf : β β¦x y : Eβ¦, x β s β y β s β x < y β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β
    f (a β’ x + b β’ y) < a β’ f x + b β’ f y) : strict_convex_on π s f :=
begin
  refine β¨hs, Ξ» x y hx hy hxy a b ha hb hab, _β©,
  wlog h : x β€ y using [x y a b, y x b a],
  { exact le_total _ _ },
  exact hf hx hy (h.lt_of_ne hxy) ha hb hab,
end

/-- For a function on a convex set in a linearly ordered space (where the order and the algebraic
structures aren't necessarily compatible), in order to prove that it is concave it suffices to
verify the inequality `a β’ f x + b β’ f y β€ f (a β’ x + b β’ y)` for `x < y` and positive `a`, `b`. The
main use case is `E = π` however one can apply it, e.g., to `π^n` with lexicographic order. -/
lemma linear_order.strict_concave_on_of_lt (hs : convex π s)
  (hf : β β¦x y : Eβ¦, x β s β y β s β x < y β β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β
     a β’ f x + b β’ f y < f (a β’ x + b β’ y)) : strict_concave_on π s f :=
@linear_order.strict_convex_on_of_lt _ _ (order_dual Ξ²) _ _ _ _ _ _ _ _ hs hf

end linear_order
end module

section module
variables [module π E] [module π F] [has_scalar π Ξ²]

/-- If `g` is convex on `s`, so is `(f β g)` on `f β»ΒΉ' s` for a linear `f`. -/
lemma convex_on.comp_linear_map {f : F β Ξ²} {s : set F} (hf : convex_on π s f) (g : E ββ[π] F) :
  convex_on π (g β»ΒΉ' s) (f β g) :=
β¨hf.1.linear_preimage _, Ξ» x y hx hy a b ha hb hab,
  calc
    f (g (a β’ x + b β’ y)) = f (a β’ (g x) + b β’ (g y)) : by rw [g.map_add, g.map_smul, g.map_smul]
                      ... β€ a β’ f (g x) + b β’ f (g y) : hf.2 hx hy ha hb habβ©

/-- If `g` is concave on `s`, so is `(g β f)` on `f β»ΒΉ' s` for a linear `f`. -/
lemma concave_on.comp_linear_map {f : F β Ξ²} {s : set F} (hf : concave_on π s f) (g : E ββ[π] F) :
  concave_on π (g β»ΒΉ' s) (f β g) :=
hf.dual.comp_linear_map g

end module
end ordered_add_comm_monoid

section ordered_cancel_add_comm_monoid
variables [ordered_cancel_add_comm_monoid Ξ²]

section distrib_mul_action
variables [has_scalar π E] [distrib_mul_action π Ξ²] {s : set E} {f g : E β Ξ²}

lemma strict_convex_on.add (hf : strict_convex_on π s f) (hg : strict_convex_on π s g) :
  strict_convex_on π s (f + g) :=
β¨hf.1, Ξ» x y hx hy hxy a b ha hb hab,
  calc
    f (a β’ x + b β’ y) + g (a β’ x + b β’ y) < (a β’ f x + b β’ f y) + (a β’ g x + b β’ g y)
      : add_lt_add (hf.2 hx hy hxy ha hb hab) (hg.2 hx hy hxy ha hb hab)
    ... = a β’ (f x + g x) + b β’ (f y + g y) : by rw [smul_add, smul_add, add_add_add_comm]β©

lemma strict_concave_on.add (hf : strict_concave_on π s f) (hg : strict_concave_on π s g) :
  strict_concave_on π s (f + g) :=
hf.dual.add hg

end distrib_mul_action

section module
variables [module π E] [module π Ξ²] [ordered_smul π Ξ²] {s : set E} {f : E β Ξ²}

lemma convex_on.convex_lt (hf : convex_on π s f) (r : Ξ²) : convex π {x β s | f x < r} :=
convex_iff_forall_pos.2 $ Ξ» x y hx hy a b ha hb hab, β¨hf.1 hx.1 hy.1 ha.le hb.le hab,
  calc
    f (a β’ x + b β’ y)
        β€ a β’ f x + b β’ f y : hf.2 hx.1 hy.1 ha.le hb.le hab
    ... < a β’ r + b β’ r     : add_lt_add_of_lt_of_le (smul_lt_smul_of_pos hx.2 ha)
                                (smul_le_smul_of_nonneg hy.2.le hb.le)
    ... = r                 : convex.combo_self hab _β©

lemma concave_on.convex_gt (hf : concave_on π s f) (r : Ξ²) : convex π {x β s | r < f x} :=
hf.dual.convex_lt r

lemma convex_on.open_segment_subset_strict_epigraph (hf : convex_on π s f) (p q : E Γ Ξ²)
  (hp : p.1 β s β§ f p.1 < p.2) (hq : q.1 β s β§ f q.1 β€ q.2) :
  open_segment π p q β {p : E Γ Ξ² | p.1 β s β§ f p.1 < p.2} :=
begin
  rintro _ β¨a, b, ha, hb, hab, rflβ©,
  refine β¨hf.1 hp.1 hq.1 ha.le hb.le hab, _β©,
  calc f (a β’ p.1 + b β’ q.1) β€ a β’ f p.1 + b β’ f q.1 : hf.2 hp.1 hq.1 ha.le hb.le hab
  ... < a β’ p.2 + b β’ q.2 :
    add_lt_add_of_lt_of_le (smul_lt_smul_of_pos hp.2 ha) (smul_le_smul_of_nonneg hq.2 hb.le)
end

lemma concave_on.open_segment_subset_strict_hypograph (hf : concave_on π s f) (p q : E Γ Ξ²)
  (hp : p.1 β s β§ p.2 < f p.1) (hq : q.1 β s β§ q.2 β€ f q.1) :
  open_segment π p q β {p : E Γ Ξ² | p.1 β s β§ p.2 < f p.1} :=
hf.dual.open_segment_subset_strict_epigraph p q hp hq

lemma convex_on.convex_strict_epigraph (hf : convex_on π s f) :
  convex π {p : E Γ Ξ² | p.1 β s β§ f p.1 < p.2} :=
convex_iff_open_segment_subset.mpr $
  Ξ» p q hp hq, hf.open_segment_subset_strict_epigraph p q hp β¨hq.1, hq.2.leβ©

lemma concave_on.convex_strict_hypograph (hf : concave_on π s f) :
  convex π {p : E Γ Ξ² | p.1 β s β§ p.2 < f p.1} :=
hf.dual.convex_strict_epigraph

end module
end ordered_cancel_add_comm_monoid

section linear_ordered_add_comm_monoid
variables [linear_ordered_add_comm_monoid Ξ²] [has_scalar π E] [module π Ξ²] [ordered_smul π Ξ²]
  {s : set E} {f g : E β Ξ²}

/-- The pointwise maximum of convex functions is convex. -/
lemma convex_on.sup (hf : convex_on π s f) (hg : convex_on π s g) :
  convex_on π s (f β g) :=
begin
  refine β¨hf.left, Ξ» x y hx hy a b ha hb hab, sup_le _ _β©,
  { calc f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y : hf.right hx hy ha hb hab
     ...                   β€ a β’ (f x β g x) + b β’ (f y β g y) : add_le_add
     (smul_le_smul_of_nonneg le_sup_left ha)
     (smul_le_smul_of_nonneg le_sup_left hb) },
  { calc g (a β’ x + b β’ y) β€ a β’ g x + b β’ g y : hg.right hx hy ha hb hab
     ...                   β€ a β’ (f x β g x) + b β’ (f y β g y) : add_le_add
     (smul_le_smul_of_nonneg le_sup_right ha)
     (smul_le_smul_of_nonneg le_sup_right hb) }
end

/-- The pointwise minimum of concave functions is concave. -/
lemma concave_on.inf (hf : concave_on π s f) (hg : concave_on π s g) :
  concave_on π s (f β g) :=
hf.dual.sup hg

/-- The pointwise maximum of strictly convex functions is strictly convex. -/
lemma strict_convex_on.sup (hf : strict_convex_on π s f) (hg : strict_convex_on π s g) :
  strict_convex_on π s (f β g) :=
β¨hf.left, Ξ» x y hx hy hxy a b ha hb hab, max_lt
  (calc f (a β’ x + b β’ y) < a β’ f x + b β’ f y : hf.2 hx hy hxy ha hb hab
    ...                   β€ a β’ (f x β g x) + b β’ (f y β g y) : add_le_add
    (smul_le_smul_of_nonneg le_sup_left ha.le)
    (smul_le_smul_of_nonneg le_sup_left hb.le))
  (calc g (a β’ x + b β’ y) < a β’ g x + b β’ g y : hg.2 hx hy hxy ha hb hab
    ...                   β€ a β’ (f x β g x) + b β’ (f y β g y) : add_le_add
    (smul_le_smul_of_nonneg le_sup_right ha.le)
    (smul_le_smul_of_nonneg le_sup_right hb.le))β©

/-- The pointwise minimum of strictly concave functions is strictly concave. -/
lemma strict_concave_on.inf (hf : strict_concave_on π s f) (hg : strict_concave_on π s g) :
   strict_concave_on π s (f β g) :=
hf.dual.sup hg

/-- A convex function on a segment is upper-bounded by the max of its endpoints. -/
lemma convex_on.le_on_segment' (hf : convex_on π s f) {x y : E} (hx : x β s) (hy : y β s)
  {a b : π} (ha : 0 β€ a) (hb : 0 β€ b) (hab : a + b = 1) :
  f (a β’ x + b β’ y) β€ max (f x) (f y) :=
calc
  f (a β’ x + b β’ y) β€ a β’ f x + b β’ f y : hf.2 hx hy ha hb hab
  ... β€ a β’ max (f x) (f y) + b β’ max (f x) (f y) :
    add_le_add (smul_le_smul_of_nonneg (le_max_left _ _) ha)
      (smul_le_smul_of_nonneg (le_max_right _ _) hb)
  ... = max (f x) (f y) : convex.combo_self hab _

/-- A concave function on a segment is lower-bounded by the min of its endpoints. -/
lemma concave_on.ge_on_segment' (hf : concave_on π s f) {x y : E} (hx : x β s) (hy : y β s)
  {a b : π} (ha : 0 β€ a) (hb : 0 β€ b) (hab : a + b = 1) :
  min (f x) (f y) β€ f (a β’ x + b β’ y) :=
hf.dual.le_on_segment' hx hy ha hb hab

/-- A convex function on a segment is upper-bounded by the max of its endpoints. -/
lemma convex_on.le_on_segment (hf : convex_on π s f) {x y z : E} (hx : x β s) (hy : y β s)
  (hz : z β [x -[π] y]) :
  f z β€ max (f x) (f y) :=
let β¨a, b, ha, hb, hab, hzβ© := hz in hz βΈ hf.le_on_segment' hx hy ha hb hab

/-- A concave function on a segment is lower-bounded by the min of its endpoints. -/
lemma concave_on.ge_on_segment (hf : concave_on π s f) {x y z : E} (hx : x β s) (hy : y β s)
  (hz : z β [x -[π] y]) :
  min (f x) (f y) β€ f z :=
hf.dual.le_on_segment hx hy hz

/-- A strictly convex function on an open segment is strictly upper-bounded by the max of its
endpoints. -/
lemma strict_convex_on.lt_on_open_segment' (hf : strict_convex_on π s f) {x y : E} (hx : x β s)
  (hy : y β s) (hxy : x β  y) {a b : π} (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1) :
  f (a β’ x + b β’ y) < max (f x) (f y) :=
calc
  f (a β’ x + b β’ y) < a β’ f x + b β’ f y : hf.2 hx hy hxy ha hb hab
  ... β€ a β’ max (f x) (f y) + b β’ max (f x) (f y) :
    add_le_add (smul_le_smul_of_nonneg (le_max_left _ _) ha.le)
      (smul_le_smul_of_nonneg (le_max_right _ _) hb.le)
  ... = max (f x) (f y) : convex.combo_self hab _

/-- A strictly concave function on an open segment is strictly lower-bounded by the min of its
endpoints. -/
lemma strict_concave_on.lt_on_open_segment' (hf : strict_concave_on π s f) {x y : E} (hx : x β s)
  (hy : y β s) (hxy : x β  y) {a b : π} (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1) :
  min (f x) (f y) < f (a β’ x + b β’ y) :=
hf.dual.lt_on_open_segment' hx hy hxy ha hb hab

/-- A strictly convex function on an open segment is strictly upper-bounded by the max of its
endpoints. -/
lemma strict_convex_on.lt_on_open_segment (hf : strict_convex_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hxy : x β  y) (hz : z β open_segment π x y) :
  f z < max (f x) (f y) :=
let β¨a, b, ha, hb, hab, hzβ© := hz in hz βΈ hf.lt_on_open_segment' hx hy hxy ha hb hab

/-- A strictly concave function on an open segment is strictly lower-bounded by the min of its
endpoints. -/
lemma strict_concave_on.lt_on_open_segment (hf : strict_concave_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hxy : x β  y) (hz : z β open_segment π x y) :
  min (f x) (f y) < f z :=
hf.dual.lt_on_open_segment hx hy hxy hz

end linear_ordered_add_comm_monoid

section linear_ordered_cancel_add_comm_monoid
variables [linear_ordered_cancel_add_comm_monoid Ξ²]

section ordered_smul
variables [has_scalar π E] [module π Ξ²] [ordered_smul π Ξ²] {s : set E} {f g : E β Ξ²}

lemma convex_on.le_left_of_right_le' (hf : convex_on π s f) {x y : E} (hx : x β s) (hy : y β s)
  {a b : π} (ha : 0 < a) (hb : 0 β€ b) (hab : a + b = 1) (hfy : f y β€ f (a β’ x + b β’ y)) :
  f (a β’ x + b β’ y) β€ f x :=
le_of_not_lt $ Ξ» h, lt_irrefl (f (a β’ x + b β’ y)) $
  calc
    f (a β’ x + b β’ y)
        β€ a β’ f x + b β’ f y : hf.2 hx hy ha.le hb hab
    ... < a β’ f (a β’ x + b β’ y) + b β’ f (a β’ x + b β’ y)
        : add_lt_add_of_lt_of_le (smul_lt_smul_of_pos h ha) (smul_le_smul_of_nonneg hfy hb)
    ... = f (a β’ x + b β’ y) : convex.combo_self hab _

lemma concave_on.left_le_of_le_right' (hf : concave_on π s f) {x y : E} (hx : x β s) (hy : y β s)
  {a b : π} (ha : 0 < a) (hb : 0 β€ b) (hab : a + b = 1) (hfy : f (a β’ x + b β’ y) β€ f y) :
  f x β€ f (a β’ x + b β’ y) :=
hf.dual.le_left_of_right_le' hx hy ha hb hab hfy

lemma convex_on.le_right_of_left_le' (hf : convex_on π s f) {x y : E} {a b : π}
  (hx : x β s) (hy : y β s) (ha : 0 β€ a) (hb : 0 < b) (hab : a + b = 1)
  (hfx : f x β€ f (a β’ x + b β’ y)) :
  f (a β’ x + b β’ y) β€ f y :=
begin
  rw add_comm at β’ hab hfx,
  exact hf.le_left_of_right_le' hy hx hb ha hab hfx,
end

lemma concave_on.le_right_of_left_le' (hf : concave_on π s f) {x y : E} {a b : π}
  (hx : x β s) (hy : y β s) (ha : 0 β€ a) (hb : 0 < b) (hab : a + b = 1)
  (hfx : f (a β’ x + b β’ y) β€ f x) :
  f y β€ f (a β’ x + b β’ y) :=
hf.dual.le_right_of_left_le' hx hy ha hb hab hfx

lemma convex_on.le_left_of_right_le (hf : convex_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hyz : f y β€ f z) :
  f z β€ f x :=
begin
  obtain β¨a, b, ha, hb, hab, rflβ© := hz,
  exact hf.le_left_of_right_le' hx hy ha hb.le hab hyz,
end

lemma concave_on.left_le_of_le_right (hf : concave_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hyz : f z β€ f y) :
  f x β€ f z :=
hf.dual.le_left_of_right_le hx hy hz hyz

lemma convex_on.le_right_of_left_le (hf : convex_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hxz : f x β€ f z) :
  f z β€ f y :=
begin
  obtain β¨a, b, ha, hb, hab, rflβ© := hz,
  exact hf.le_right_of_left_le' hx hy ha.le hb hab hxz,
end

lemma concave_on.le_right_of_left_le (hf : concave_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hxz : f z β€ f x) :
  f y β€ f z :=
hf.dual.le_right_of_left_le hx hy hz hxz

end ordered_smul

section module
variables [module π E] [module π Ξ²] [ordered_smul π Ξ²] {s : set E} {f g : E β Ξ²}

/- The following lemmas don't require `module π E` if you add the hypothesis `x β  y`. At the time of
the writing, we decided the resulting lemmas wouldn't be useful. Feel free to reintroduce them. -/
lemma strict_convex_on.lt_left_of_right_lt' (hf : strict_convex_on π s f) {x y : E} (hx : x β s)
  (hy : y β s) {a b : π} (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1)
  (hfy : f y < f (a β’ x + b β’ y)) :
  f (a β’ x + b β’ y) < f x :=
not_le.1 $ Ξ» h, lt_irrefl (f (a β’ x + b β’ y)) $
  calc
    f (a β’ x + b β’ y)
        < a β’ f x + b β’ f y : hf.2 hx hy begin
            rintro rfl,
            rw convex.combo_self hab at hfy,
            exact lt_irrefl _ hfy,
          end ha hb hab
    ... < a β’ f (a β’ x + b β’ y) + b β’ f (a β’ x + b β’ y)
        : add_lt_add_of_le_of_lt (smul_le_smul_of_nonneg h ha.le) (smul_lt_smul_of_pos hfy hb)
    ... = f (a β’ x + b β’ y) : convex.combo_self hab _

lemma strict_concave_on.left_lt_of_lt_right' (hf : strict_concave_on π s f) {x y : E} (hx : x β s)
  (hy : y β s) {a b : π} (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1)
  (hfy : f (a β’ x + b β’ y) < f y) :
  f x < f (a β’ x + b β’ y) :=
hf.dual.lt_left_of_right_lt' hx hy ha hb hab hfy

lemma strict_convex_on.lt_right_of_left_lt' (hf : strict_convex_on π s f) {x y : E} {a b : π}
  (hx : x β s) (hy : y β s) (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1)
  (hfx : f x < f (a β’ x + b β’ y)) :
  f (a β’ x + b β’ y) < f y :=
begin
  rw add_comm at β’ hab hfx,
  exact hf.lt_left_of_right_lt' hy hx hb ha hab hfx,
end

lemma strict_concave_on.lt_right_of_left_lt' (hf : strict_concave_on π s f) {x y : E} {a b : π}
  (hx : x β s) (hy : y β s) (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1)
  (hfx : f (a β’ x + b β’ y) < f x) :
  f y < f (a β’ x + b β’ y) :=
hf.dual.lt_right_of_left_lt' hx hy ha hb hab hfx

lemma strict_convex_on.lt_left_of_right_lt (hf : strict_convex_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hyz : f y < f z) :
  f z < f x :=
begin
  obtain β¨a, b, ha, hb, hab, rflβ© := hz,
  exact hf.lt_left_of_right_lt' hx hy ha hb hab hyz,
end

lemma strict_concave_on.left_lt_of_lt_right (hf : strict_concave_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hyz : f z < f y) :
  f x < f z :=
hf.dual.lt_left_of_right_lt hx hy hz hyz

lemma strict_convex_on.lt_right_of_left_lt (hf : strict_convex_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hxz : f x < f z) :
  f z < f y :=
begin
  obtain β¨a, b, ha, hb, hab, rflβ© := hz,
  exact hf.lt_right_of_left_lt' hx hy ha hb hab hxz,
end

lemma strict_concave_on.lt_right_of_left_lt (hf : strict_concave_on π s f) {x y z : E} (hx : x β s)
  (hy : y β s) (hz : z β open_segment π x y) (hxz : f z < f x) :
  f y < f z :=
hf.dual.lt_right_of_left_lt hx hy hz hxz

end module
end linear_ordered_cancel_add_comm_monoid

section ordered_add_comm_group
variables [ordered_add_comm_group Ξ²] [has_scalar π E] [module π Ξ²] {s : set E} {f : E β Ξ²}

/-- A function `-f` is convex iff `f` is concave. -/
@[simp] lemma neg_convex_on_iff : convex_on π s (-f) β concave_on π s f :=
begin
  split,
  { rintro β¨hconv, hβ©,
    refine β¨hconv, Ξ» x y hx hy a b ha hb hab, _β©,
    simp [neg_apply, neg_le, add_comm] at h,
    exact h hx hy ha hb hab },
  { rintro β¨hconv, hβ©,
    refine β¨hconv, Ξ» x y hx hy a b ha hb hab, _β©,
    rw βneg_le_neg_iff,
    simp_rw [neg_add, pi.neg_apply, smul_neg, neg_neg],
    exact h hx hy ha hb hab }
end

/-- A function `-f` is concave iff `f` is convex. -/
@[simp] lemma neg_concave_on_iff : concave_on π s (-f) β convex_on π s f:=
by rw [β neg_convex_on_iff, neg_neg f]

/-- A function `-f` is strictly convex iff `f` is strictly concave. -/
@[simp] lemma neg_strict_convex_on_iff : strict_convex_on π s (-f) β strict_concave_on π s f :=
begin
  split,
  { rintro β¨hconv, hβ©,
    refine β¨hconv, Ξ» x y hx hy hxy a b ha hb hab, _β©,
    simp [neg_apply, neg_lt, add_comm] at h,
    exact h hx hy hxy ha hb hab },
  { rintro β¨hconv, hβ©,
    refine β¨hconv, Ξ» x y hx hy hxy a b ha hb hab, _β©,
    rw βneg_lt_neg_iff,
    simp_rw [neg_add, pi.neg_apply, smul_neg, neg_neg],
    exact h hx hy hxy ha hb hab }
end

/-- A function `-f` is strictly concave iff `f` is strictly convex. -/
@[simp] lemma neg_strict_concave_on_iff : strict_concave_on π s (-f) β strict_convex_on π s f :=
by rw [β neg_strict_convex_on_iff, neg_neg f]

alias neg_convex_on_iff β _ concave_on.neg
alias neg_concave_on_iff β _ convex_on.neg
alias neg_strict_convex_on_iff β _ strict_concave_on.neg
alias neg_strict_concave_on_iff β _ strict_convex_on.neg

end ordered_add_comm_group
end add_comm_monoid

section add_cancel_comm_monoid
variables [add_cancel_comm_monoid E] [ordered_add_comm_monoid Ξ²] [module π E] [has_scalar π Ξ²]
  {s : set E} {f : E β Ξ²}

/-- Right translation preserves strict convexity. -/
lemma strict_convex_on.translate_right (hf : strict_convex_on π s f) (c : E) :
  strict_convex_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, c + z)) :=
β¨hf.1.translate_preimage_right _, Ξ» x y hx hy hxy a b ha hb hab,
  calc
    f (c + (a β’ x + b β’ y)) = f (a β’ (c + x) + b β’ (c + y))
        : by rw [smul_add, smul_add, add_add_add_comm, convex.combo_self hab]
    ... < a β’ f (c + x) + b β’ f (c + y) : hf.2 hx hy ((add_right_injective c).ne hxy) ha hb habβ©

/-- Right translation preserves strict concavity. -/
lemma strict_concave_on.translate_right (hf : strict_concave_on π s f) (c : E) :
  strict_concave_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, c + z)) :=
hf.dual.translate_right _

/-- Left translation preserves strict convexity. -/
lemma strict_convex_on.translate_left (hf : strict_convex_on π s f) (c : E) :
  strict_convex_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, z + c)) :=
by simpa only [add_comm] using hf.translate_right _

/-- Left translation preserves strict concavity. -/
lemma strict_concave_on.translate_left (hf : strict_concave_on π s f) (c : E) :
  strict_concave_on π ((Ξ» z, c + z) β»ΒΉ' s) (f β (Ξ» z, z + c)) :=
by simpa only [add_comm] using hf.translate_right _

end add_cancel_comm_monoid
end ordered_semiring

section ordered_comm_semiring
variables [ordered_comm_semiring π] [add_comm_monoid E]

section ordered_add_comm_monoid
variables [ordered_add_comm_monoid Ξ²]

section module
variables [has_scalar π E] [module π Ξ²] [ordered_smul π Ξ²] {s : set E} {f : E β Ξ²}

lemma convex_on.smul {c : π} (hc : 0 β€ c) (hf : convex_on π s f) : convex_on π s (Ξ» x, c β’ f x) :=
β¨hf.1, Ξ» x y hx hy a b ha hb hab,
  calc
    c β’ f (a β’ x + b β’ y) β€ c β’ (a β’ f x + b β’ f y)
      : smul_le_smul_of_nonneg (hf.2 hx hy ha hb hab) hc
    ... = a β’ (c β’ f x) + b β’ (c β’ f y)
      : by rw [smul_add, smul_comm c, smul_comm c]; apply_instanceβ©

lemma concave_on.smul {c : π} (hc : 0 β€ c) (hf : concave_on π s f) :
  concave_on π s (Ξ» x, c β’ f x) :=
hf.dual.smul hc

end module
end ordered_add_comm_monoid
end ordered_comm_semiring

section ordered_ring
variables [linear_ordered_field π] [add_comm_group E] [add_comm_group F]

section ordered_add_comm_monoid
variables [ordered_add_comm_monoid Ξ²]

section module
variables [module π E] [module π F] [has_scalar π Ξ²]

/-- If a function is convex on `s`, it remains convex when precomposed by an affine map. -/
lemma convex_on.comp_affine_map {f : F β Ξ²} (g : E βα΅[π] F) {s : set F} (hf : convex_on π s f) :
  convex_on π (g β»ΒΉ' s) (f β g) :=
β¨hf.1.affine_preimage _, Ξ» x y hx hy a b ha hb hab,
  calc
    (f β g) (a β’ x + b β’ y) = f (g (a β’ x + b β’ y))         : rfl
                       ...  = f (a β’ (g x) + b β’ (g y))     : by rw [convex.combo_affine_apply hab]
                       ...  β€ a β’ f (g x) + b β’ f (g y)     : hf.2 hx hy ha hb habβ©

/-- If a function is concave on `s`, it remains concave when precomposed by an affine map. -/
lemma concave_on.comp_affine_map {f : F β Ξ²} (g : E βα΅[π] F) {s : set F} (hf : concave_on π s f) :
  concave_on π (g β»ΒΉ' s) (f β g) :=
hf.dual.comp_affine_map g

end module
end ordered_add_comm_monoid
end ordered_ring

section linear_ordered_field
variables [linear_ordered_field π] [add_comm_monoid E]

section ordered_add_comm_monoid
variables [ordered_add_comm_monoid Ξ²]

section has_scalar
variables [has_scalar π E] [has_scalar π Ξ²] {s : set E}

lemma convex_on_iff_div {f : E β Ξ²} :
  convex_on π s f β convex π s β§ β β¦x y : Eβ¦, x β s β y β s β β β¦a b : πβ¦, 0 β€ a β 0 β€ b β 0 < a + b
  β f ((a/(a+b)) β’ x + (b/(a+b)) β’ y) β€ (a/(a+b)) β’ f x + (b/(a+b)) β’ f y :=
and_congr iff.rfl
β¨begin
  intros h x y hx hy a b ha hb hab,
  apply h hx hy (div_nonneg ha hab.le) (div_nonneg hb hab.le),
  rw [βadd_div, div_self hab.ne'],
end,
begin
  intros h x y hx hy a b ha hb hab,
  simpa [hab, zero_lt_one] using h hx hy ha hb,
endβ©

lemma concave_on_iff_div {f : E β Ξ²} :
  concave_on π s f β convex π s β§ β β¦x y : Eβ¦, x β s β y β s β β β¦a b : πβ¦, 0 β€ a β 0 β€ b
  β 0 < a + b β (a/(a+b)) β’ f x + (b/(a+b)) β’ f y β€ f ((a/(a+b)) β’ x + (b/(a+b)) β’ y) :=
@convex_on_iff_div _ _ (order_dual Ξ²) _ _ _ _ _ _ _

lemma strict_convex_on_iff_div {f : E β Ξ²} :
  strict_convex_on π s f β convex π s β§ β β¦x y : Eβ¦, x β s β y β s β x β  y β β β¦a b : πβ¦, 0 < a
    β 0 < b β f ((a/(a+b)) β’ x + (b/(a+b)) β’ y) < (a/(a+b)) β’ f x + (b/(a+b)) β’ f y :=
and_congr iff.rfl
β¨begin
  intros h x y hx hy hxy a b ha hb,
  have hab := add_pos ha hb,
  apply h hx hy hxy (div_pos ha hab) (div_pos hb hab),
  rw [βadd_div, div_self hab.ne'],
end,
begin
  intros h x y hx hy hxy a b ha hb hab,
  simpa [hab, zero_lt_one] using h hx hy hxy ha hb,
endβ©

lemma strict_concave_on_iff_div {f : E β Ξ²} :
  strict_concave_on π s f β convex π s β§ β β¦x y : Eβ¦, x β s β y β s β x β  y β β β¦a b : πβ¦, 0 < a
    β 0 < b β (a/(a+b)) β’ f x + (b/(a+b)) β’ f y < f ((a/(a+b)) β’ x + (b/(a+b)) β’ y) :=
@strict_convex_on_iff_div _ _ (order_dual Ξ²) _ _ _ _ _ _ _

end has_scalar
end ordered_add_comm_monoid
end linear_ordered_field
