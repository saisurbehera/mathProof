/-
Copyright (c) 2019 Jean Lo. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jean Lo, YaÃ«l Dillies, Moritz Doll
-/
import analysis.locally_convex.basic
import data.real.pointwise
import data.real.sqrt
import topology.algebra.filter_basis
import topology.algebra.module.locally_convex

/-!
# Seminorms

This file defines seminorms.

A seminorm is a function to the reals which is positive-semidefinite, absolutely homogeneous, and
subadditive. They are closely related to convex sets and a topological vector space is locally
convex if and only if its topology is induced by a family of seminorms.

## Main declarations

For a module over a normed ring:
* `seminorm`: A function to the reals that is positive-semidefinite, absolutely homogeneous, and
  subadditive.
* `norm_seminorm ð E`: The norm on `E` as a seminorm.

## References

* [H. H. Schaefer, *Topological Vector Spaces*][schaefer1966]

## Tags

seminorm, locally convex, LCTVS
-/

open normed_field set
open_locale big_operators nnreal pointwise topological_space

variables {R R' ð E F G Î¹ : Type*}

/-- A seminorm on a module over a normed ring is a function to the reals that is positive
semidefinite, positive homogeneous, and subadditive. -/
structure seminorm (ð : Type*) (E : Type*) [semi_normed_ring ð] [add_monoid E] [has_scalar ð E] :=
(to_fun    : E â â)
(smul'     : â (a : ð) (x : E), to_fun (a â¢ x) = â¥aâ¥ * to_fun x)
(triangle' : â x y : E, to_fun (x + y) â¤ to_fun x + to_fun y)

namespace seminorm

section semi_normed_ring
variables [semi_normed_ring ð]

section add_monoid
variables [add_monoid E]

section has_scalar
variables [has_scalar ð E]

instance fun_like : fun_like (seminorm ð E) E (Î» _, â) :=
{ coe := seminorm.to_fun, coe_injective' := Î» f g h, by cases f; cases g; congr' }

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`. -/
instance : has_coe_to_fun (seminorm ð E) (Î» _, E â â) := â¨Î» p, p.to_funâ©

@[ext] lemma ext {p q : seminorm ð E} (h : â x, (p : E â â) x = q x) : p = q := fun_like.ext p q h

instance : has_zero (seminorm ð E) :=
â¨{ to_fun    := 0,
  smul'     := Î» _ _, (mul_zero _).symm,
  triangle' := Î» _ _, eq.ge (zero_add _) }â©

@[simp] lemma coe_zero : â(0 : seminorm ð E) = 0 := rfl

@[simp] lemma zero_apply (x : E) : (0 : seminorm ð E) x = 0 := rfl

instance : inhabited (seminorm ð E) := â¨0â©

variables (p : seminorm ð E) (c : ð) (x y : E) (r : â)

protected lemma smul : p (c â¢ x) = â¥câ¥ * p x := p.smul' _ _
protected lemma triangle : p (x + y) â¤ p x + p y := p.triangle' _ _

/-- Any action on `â` which factors through `ââ¥0` applies to a seminorm. -/
instance [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â] :
  has_scalar R (seminorm ð E) :=
{ smul := Î» r p,
  { to_fun := Î» x, r â¢ p x,
    smul' := Î» _ _, begin
      simp only [âsmul_one_smul ââ¥0 r (_ : â), nnreal.smul_def, smul_eq_mul],
      rw [p.smul, mul_left_comm],
    end,
    triangle' := Î» _ _, begin
      simp only [âsmul_one_smul ââ¥0 r (_ : â), nnreal.smul_def, smul_eq_mul],
      exact (mul_le_mul_of_nonneg_left (p.triangle _ _) (nnreal.coe_nonneg _)).trans_eq
        (mul_add _ _ _),
    end } }

instance [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â]
  [has_scalar R' â] [has_scalar R' ââ¥0] [is_scalar_tower R' ââ¥0 â]
  [has_scalar R R'] [is_scalar_tower R R' â] :
  is_scalar_tower R R' (seminorm ð E) :=
{ smul_assoc := Î» r a p, ext $ Î» x, smul_assoc r a (p x) }

lemma coe_smul [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â]
  (r : R) (p : seminorm ð E) : â(r â¢ p) = r â¢ p := rfl

@[simp] lemma smul_apply [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â]
  (r : R) (p : seminorm ð E) (x : E) : (r â¢ p) x = r â¢ p x := rfl

instance : has_add (seminorm ð E) :=
{ add := Î» p q,
  { to_fun := Î» x, p x + q x,
    smul' := Î» a x, by rw [p.smul, q.smul, mul_add],
    triangle' := Î» _ _, has_le.le.trans_eq (add_le_add (p.triangle _ _) (q.triangle _ _))
      (add_add_add_comm _ _ _ _) } }

lemma coe_add (p q : seminorm ð E) : â(p + q) = p + q := rfl

@[simp] lemma add_apply (p q : seminorm ð E) (x : E) : (p + q) x = p x + q x := rfl

instance : add_monoid (seminorm ð E) :=
fun_like.coe_injective.add_monoid _ rfl coe_add (Î» p n, coe_smul n p)

instance : ordered_cancel_add_comm_monoid (seminorm ð E) :=
fun_like.coe_injective.ordered_cancel_add_comm_monoid _ rfl coe_add (Î» p n, coe_smul n p)

instance [monoid R] [mul_action R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â] :
  mul_action R (seminorm ð E) :=
fun_like.coe_injective.mul_action _ coe_smul

variables (ð E)

/-- `coe_fn` as an `add_monoid_hom`. Helper definition for showing that `seminorm ð E` is
a module. -/
@[simps]
def coe_fn_add_monoid_hom : add_monoid_hom (seminorm ð E) (E â â) := â¨coe_fn, coe_zero, coe_addâ©

lemma coe_fn_add_monoid_hom_injective : function.injective (coe_fn_add_monoid_hom ð E) :=
show @function.injective (seminorm ð E) (E â â) coe_fn, from fun_like.coe_injective

variables {ð E}

instance [monoid R] [distrib_mul_action R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â] :
  distrib_mul_action R (seminorm ð E) :=
(coe_fn_add_monoid_hom_injective ð E).distrib_mul_action _ coe_smul

instance [semiring R] [module R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â] :
  module R (seminorm ð E) :=
(coe_fn_add_monoid_hom_injective ð E).module R _ coe_smul

-- TODO: define `has_Sup` too, from the skeleton at
-- https://github.com/leanprover-community/mathlib/pull/11329#issuecomment-1008915345
noncomputable instance : has_sup (seminorm ð E) :=
{ sup := Î» p q,
  { to_fun := p â q,
    triangle' := Î» x y, sup_le
      ((p.triangle x y).trans $ add_le_add le_sup_left le_sup_left)
      ((q.triangle x y).trans $ add_le_add le_sup_right le_sup_right),
    smul' := Î» x v, (congr_arg2 max (p.smul x v) (q.smul x v)).trans $
      (mul_max_of_nonneg _ _ $ norm_nonneg x).symm } }

@[simp] lemma coe_sup (p q : seminorm ð E) : â(p â q) = p â q := rfl
lemma sup_apply (p q : seminorm ð E) (x : E) : (p â q) x = p x â q x := rfl

lemma smul_sup [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â]
  (r : R) (p q : seminorm ð E) :
  r â¢ (p â q) = r â¢ p â r â¢ q :=
have real.smul_max : â x y : â, r â¢ max x y = max (r â¢ x) (r â¢ y),
from Î» x y, by simpa only [âsmul_eq_mul, ânnreal.smul_def, smul_one_smul ââ¥0 r (_ : â)]
                     using mul_max_of_nonneg x y (r â¢ 1 : ââ¥0).prop,
ext $ Î» x, real.smul_max _ _

instance : partial_order (seminorm ð E) :=
  partial_order.lift _ fun_like.coe_injective

lemma le_def (p q : seminorm ð E) : p â¤ q â (p : E â â) â¤ q := iff.rfl
lemma lt_def (p q : seminorm ð E) : p < q â (p : E â â) < q := iff.rfl

noncomputable instance : semilattice_sup (seminorm ð E) :=
function.injective.semilattice_sup _ fun_like.coe_injective coe_sup

end has_scalar

section smul_with_zero
variables [smul_with_zero ð E] (p : seminorm ð E)

@[simp]
protected lemma zero : p 0 = 0 :=
calc p 0 = p ((0 : ð) â¢ 0) : by rw zero_smul
...      = 0 : by rw [p.smul, norm_zero, zero_mul]

end smul_with_zero
end add_monoid

section module
variables [add_comm_group E] [add_comm_group F] [add_comm_group G]
variables [module ð E] [module ð F] [module ð G]
variables [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â]

/-- Composition of a seminorm with a linear map is a seminorm. -/
def comp (p : seminorm ð F) (f : E ââ[ð] F) : seminorm ð E :=
{ to_fun := Î» x, p(f x),
  smul' := Î» _ _, (congr_arg p (f.map_smul _ _)).trans (p.smul _ _),
  triangle' := Î» _ _, eq.trans_le (congr_arg p (f.map_add _ _)) (p.triangle _ _) }

lemma coe_comp (p : seminorm ð F) (f : E ââ[ð] F) : â(p.comp f) = p â f := rfl

@[simp] lemma comp_apply (p : seminorm ð F) (f : E ââ[ð] F) (x : E) : (p.comp f) x = p (f x) := rfl

@[simp] lemma comp_id (p : seminorm ð E) : p.comp linear_map.id = p :=
ext $ Î» _, rfl

@[simp] lemma comp_zero (p : seminorm ð F) : p.comp (0 : E ââ[ð] F) = 0 :=
ext $ Î» _, seminorm.zero _

@[simp] lemma zero_comp (f : E ââ[ð] F) : (0 : seminorm ð F).comp f = 0 :=
ext $ Î» _, rfl

lemma comp_comp (p : seminorm ð G) (g : F ââ[ð] G) (f : E ââ[ð] F) :
  p.comp (g.comp f) = (p.comp g).comp f :=
ext $ Î» _, rfl

lemma add_comp (p q : seminorm ð F) (f : E ââ[ð] F) : (p + q).comp f = p.comp f + q.comp f :=
ext $ Î» _, rfl

lemma comp_triangle (p : seminorm ð F) (f g : E ââ[ð] F) : p.comp (f + g) â¤ p.comp f + p.comp g :=
Î» _, p.triangle _ _

lemma smul_comp (p : seminorm ð F) (f : E ââ[ð] F) (c : R) : (c â¢ p).comp f = c â¢ (p.comp f) :=
ext $ Î» _, rfl

lemma comp_mono {p : seminorm ð F} {q : seminorm ð F} (f : E ââ[ð] F) (hp : p â¤ q) :
  p.comp f â¤ q.comp f := Î» _, hp _

/-- The composition as an `add_monoid_hom`. -/
@[simps] def pullback (f : E ââ[ð] F) : add_monoid_hom (seminorm ð F) (seminorm ð E) :=
â¨Î» p, p.comp f, zero_comp f, Î» p q, add_comp p q fâ©

section norm_one_class
variables [norm_one_class ð] (p : seminorm ð E) (x y : E) (r : â)

@[simp]
protected lemma neg : p (-x) = p x :=
calc p (-x) = p ((-1 : ð) â¢ x) : by rw neg_one_smul
...         = p x : by rw [p.smul, norm_neg, norm_one, one_mul]

protected lemma sub_le : p (x - y) â¤ p x + p y :=
calc
  p (x - y)
      = p (x + -y) : by rw sub_eq_add_neg
  ... â¤ p x + p (-y) : p.triangle x (-y)
  ... = p x + p y : by rw p.neg

lemma nonneg : 0 â¤ p x :=
have h: 0 â¤ 2 * p x, from
calc 0 = p (x + (- x)) : by rw [add_neg_self, p.zero]
...    â¤ p x + p (-x)  : p.triangle _ _
...    = 2 * p x : by rw [p.neg, two_mul],
nonneg_of_mul_nonneg_left h zero_lt_two

lemma sub_rev : p (x - y) = p (y - x) := by rw [âneg_sub, p.neg]

/-- The direct path from 0 to y is shorter than the path with x "inserted" in between. -/
lemma le_insert : p y â¤ p x + p (x - y) :=
calc p y = p (x - (x - y)) : by rw sub_sub_cancel
... â¤ p x + p (x - y) : p.sub_le _ _

/-- The direct path from 0 to x is shorter than the path with y "inserted" in between. -/
lemma le_insert' : p x â¤ p y + p (x - y) := by { rw sub_rev, exact le_insert _ _ _ }

instance : order_bot (seminorm ð E) := â¨0, nonnegâ©

@[simp] lemma coe_bot : â(â¥ : seminorm ð E) = 0 := rfl

lemma bot_eq_zero : (â¥ : seminorm ð E) = 0 := rfl

lemma smul_le_smul {p q : seminorm ð E} {a b : ââ¥0} (hpq : p â¤ q) (hab : a â¤ b) :
  a â¢ p â¤ b â¢ q :=
begin
  simp_rw [le_def, pi.le_def, coe_smul],
  intros x,
  simp_rw [pi.smul_apply, nnreal.smul_def, smul_eq_mul],
  exact mul_le_mul hab (hpq x) (nonneg p x) (nnreal.coe_nonneg b),
end

lemma finset_sup_apply (p : Î¹ â seminorm ð E) (s : finset Î¹) (x : E) :
  s.sup p x = â(s.sup (Î» i, â¨p i x, nonneg (p i) xâ©) : ââ¥0) :=
begin
  induction s using finset.cons_induction_on with a s ha ih,
  { rw [finset.sup_empty, finset.sup_empty, coe_bot, _root_.bot_eq_zero, pi.zero_apply,
        nonneg.coe_zero] },
  { rw [finset.sup_cons, finset.sup_cons, coe_sup, sup_eq_max, pi.sup_apply, sup_eq_max,
        nnreal.coe_max, subtype.coe_mk, ih] }
end

lemma finset_sup_le_sum (p : Î¹ â seminorm ð E) (s : finset Î¹) : s.sup p â¤ â i in s, p i :=
begin
  classical,
  refine finset.sup_le_iff.mpr _,
  intros i hi,
  rw [finset.sum_eq_sum_diff_singleton_add hi, le_add_iff_nonneg_left],
  exact bot_le,
end

lemma finset_sup_apply_le {p : Î¹ â seminorm ð E} {s : finset Î¹} {x : E} {a : â} (ha : 0 â¤ a)
  (h : â i, i â s â p i x â¤ a) : s.sup p x â¤ a :=
begin
  lift a to ââ¥0 using ha,
  rw [finset_sup_apply, nnreal.coe_le_coe],
  exact finset.sup_le h,
end

lemma finset_sup_apply_lt {p : Î¹ â seminorm ð E} {s : finset Î¹} {x : E} {a : â} (ha : 0 < a)
  (h : â i, i â s â p i x < a) : s.sup p x < a :=
begin
  lift a to ââ¥0 using ha.le,
  rw [finset_sup_apply, nnreal.coe_lt_coe, finset.sup_lt_iff],
  { exact h },
  { exact nnreal.coe_pos.mpr ha },
end

end norm_one_class
end module
end semi_normed_ring

section semi_normed_comm_ring
variables [semi_normed_comm_ring ð] [add_comm_group E] [add_comm_group F] [module ð E] [module ð F]

lemma comp_smul (p : seminorm ð F) (f : E ââ[ð] F) (c : ð) :
  p.comp (c â¢ f) = â¥câ¥â â¢ p.comp f :=
ext $ Î» _, by rw [comp_apply, smul_apply, linear_map.smul_apply, p.smul, nnreal.smul_def,
  coe_nnnorm, smul_eq_mul, comp_apply]

lemma comp_smul_apply (p : seminorm ð F) (f : E ââ[ð] F) (c : ð) (x : E) :
  p.comp (c â¢ f) x = â¥câ¥ * p (f x) := p.smul _ _

end semi_normed_comm_ring

section normed_field
variables [normed_field ð] [add_comm_group E] [module ð E]

private lemma bdd_below_range_add (x : E) (p q : seminorm ð E) :
  bdd_below (range (Î» (u : E), p u + q (x - u))) :=
by { use 0, rintro _ â¨x, rflâ©, exact add_nonneg (p.nonneg _) (q.nonneg _) }

noncomputable instance : has_inf (seminorm ð E) :=
{ inf := Î» p q,
  { to_fun := Î» x, â¨ u : E, p u + q (x-u),
    triangle' := Î» x y, begin
      refine le_cinfi_add_cinfi (Î» u v, _),
      apply cinfi_le_of_le (bdd_below_range_add _ _ _) (v+u), dsimp only,
      convert add_le_add (p.triangle v u) (q.triangle (y-v) (x-u)) using 1,
      { rw show x + y - (v + u) = y - v + (x - u), by abel },
      { abel },
    end,
    smul' := Î» a x, begin
      obtain rfl | ha := eq_or_ne a 0,
      { simp_rw [norm_zero, zero_mul, zero_smul, zero_sub, seminorm.neg],
        refine cinfi_eq_of_forall_ge_of_forall_gt_exists_lt
          (Î» i, add_nonneg (p.nonneg _) (q.nonneg _))
          (Î» x hx, â¨0, by rwa [p.zero, q.zero, add_zero]â©) },
      simp_rw [real.mul_infi_of_nonneg (norm_nonneg a), mul_add, âp.smul, âq.smul, smul_sub],
      refine function.surjective.infi_congr ((â¢) aâ»Â¹ : E â E) (Î» u, â¨a â¢ u, inv_smul_smulâ ha uâ©)
        (Î» u, _),
      rw smul_inv_smulâ ha,
    end } }

@[simp] lemma inf_apply (p q : seminorm ð E) (x : E) : (p â q) x = â¨ u : E, p u + q (x-u) := rfl

noncomputable instance : lattice (seminorm ð E) :=
{ inf := (â),
  inf_le_left := Î» p q x, begin
    apply cinfi_le_of_le (bdd_below_range_add _ _ _) x,
    simp only [sub_self, seminorm.zero, add_zero],
  end,
  inf_le_right := Î» p q x, begin
    apply cinfi_le_of_le (bdd_below_range_add _ _ _) (0:E),
    simp only [sub_self, seminorm.zero, zero_add, sub_zero],
  end,
  le_inf := Î» a b c hab hac x,
    le_cinfi $ Î» u, le_trans (a.le_insert' _ _) (add_le_add (hab _) (hac _)),
  ..seminorm.semilattice_sup }

lemma smul_inf [has_scalar R â] [has_scalar R ââ¥0] [is_scalar_tower R ââ¥0 â]
  (r : R) (p q : seminorm ð E) :
  r â¢ (p â q) = r â¢ p â r â¢ q :=
begin
  ext,
  simp_rw [smul_apply, inf_apply, smul_apply, âsmul_one_smul ââ¥0 r (_ : â), nnreal.smul_def,
    smul_eq_mul, real.mul_infi_of_nonneg (subtype.prop _), mul_add],
end

end normed_field

/-! ### Seminorm ball -/

section semi_normed_ring
variables [semi_normed_ring ð]

section add_comm_group
variables [add_comm_group E]

section has_scalar
variables [has_scalar ð E] (p : seminorm ð E)

/-- The ball of radius `r` at `x` with respect to seminorm `p` is the set of elements `y` with
`p (y - x) < `r`. -/
def ball (x : E) (r : â) := { y : E | p (y - x) < r }

variables {x y : E} {r : â}

@[simp] lemma mem_ball : y â ball p x r â p (y - x) < r := iff.rfl

lemma mem_ball_zero : y â ball p 0 r â p y < r := by rw [mem_ball, sub_zero]

lemma ball_zero_eq : ball p 0 r = { y : E | p y < r } := set.ext $ Î» x, p.mem_ball_zero

@[simp] lemma ball_zero' (x : E) (hr : 0 < r) : ball (0 : seminorm ð E) x r = set.univ :=
begin
  rw [set.eq_univ_iff_forall, ball],
  simp [hr],
end

lemma ball_smul (p : seminorm ð E) {c : nnreal} (hc : 0 < c) (r : â) (x : E) :
  (c â¢ p).ball x r = p.ball x (r / c) :=
by { ext, rw [mem_ball, mem_ball, smul_apply, nnreal.smul_def, smul_eq_mul, mul_comm,
  lt_div_iff (nnreal.coe_pos.mpr hc)] }

lemma ball_sup (p : seminorm ð E) (q : seminorm ð E) (e : E) (r : â) :
  ball (p â q) e r = ball p e r â© ball q e r :=
by simp_rw [ball, âset.set_of_and, coe_sup, pi.sup_apply, sup_lt_iff]

lemma ball_finset_sup' (p : Î¹ â seminorm ð E) (s : finset Î¹) (H : s.nonempty) (e : E) (r : â) :
  ball (s.sup' H p) e r = s.inf' H (Î» i, ball (p i) e r) :=
begin
  induction H using finset.nonempty.cons_induction with a a s ha hs ih,
  { classical, simp },
  { rw [finset.sup'_cons hs, finset.inf'_cons hs, ball_sup, inf_eq_inter, ih] },
end

lemma ball_mono {p : seminorm ð E} {râ râ : â} (h : râ â¤ râ) : p.ball x râ â p.ball x râ :=
Î» _ (hx : _ < _), hx.trans_le h

lemma ball_antitone {p q : seminorm ð E} (h : q â¤ p) : p.ball x r â q.ball x r :=
Î» _, (h _).trans_lt

lemma ball_add_ball_subset (p : seminorm ð E) (râ râ : â) (xâ xâ : E):
  p.ball (xâ : E) râ + p.ball (xâ : E) râ â p.ball (xâ + xâ) (râ + râ) :=
begin
  rintros x â¨yâ, yâ, hyâ, hyâ, rflâ©,
  rw [mem_ball, add_sub_comm],
  exact (p.triangle _ _).trans_lt (add_lt_add hyâ hyâ),
end

end has_scalar

section module

variables [module ð E]
variables [add_comm_group F] [module ð F]

lemma ball_comp (p : seminorm ð F) (f : E ââ[ð] F) (x : E) (r : â) :
  (p.comp f).ball x r = f â»Â¹' (p.ball (f x) r) :=
begin
  ext,
  simp_rw [ball, mem_preimage, comp_apply, set.mem_set_of_eq, map_sub],
end

section norm_one_class
variables [norm_one_class ð] (p : seminorm ð E)

@[simp] lemma ball_bot {r : â} (x : E) (hr : 0 < r) : ball (â¥ : seminorm ð E) x r = set.univ :=
ball_zero' x hr

/-- Seminorm-balls at the origin are balanced. -/
lemma balanced_ball_zero (r : â) : balanced ð (ball p 0 r) :=
begin
  rintro a ha x â¨y, hy, hxâ©,
  rw [mem_ball_zero, âhx, p.smul],
  calc _ â¤ p y : mul_le_of_le_one_left (p.nonneg _) ha
  ...    < r   : by rwa mem_ball_zero at hy,
end

lemma ball_finset_sup_eq_Inter (p : Î¹ â seminorm ð E) (s : finset Î¹) (x : E) {r : â} (hr : 0 < r) :
  ball (s.sup p) x r = â (i â s), ball (p i) x r :=
begin
  lift r to nnreal using hr.le,
  simp_rw [ball, Inter_set_of, finset_sup_apply, nnreal.coe_lt_coe,
    finset.sup_lt_iff (show â¥ < r, from hr), ânnreal.coe_lt_coe, subtype.coe_mk],
end

lemma ball_finset_sup (p : Î¹ â seminorm ð E) (s : finset Î¹) (x : E) {r : â}
  (hr : 0 < r) : ball (s.sup p) x r = s.inf (Î» i, ball (p i) x r) :=
begin
  rw finset.inf_eq_infi,
  exact ball_finset_sup_eq_Inter _ _ _ hr,
end

lemma ball_smul_ball (p : seminorm ð E) (râ râ : â) :
  metric.ball (0 : ð) râ â¢ p.ball 0 râ â p.ball 0 (râ * râ) :=
begin
  rw set.subset_def,
  intros x hx,
  rw set.mem_smul at hx,
  rcases hx with â¨a, y, ha, hy, hxâ©,
  rw [âhx, mem_ball_zero, seminorm.smul],
  exact mul_lt_mul'' (mem_ball_zero_iff.mp ha) (p.mem_ball_zero.mp hy) (norm_nonneg a) (p.nonneg y),
end

@[simp] lemma ball_eq_emptyset (p : seminorm ð E) {x : E} {r : â} (hr : r â¤ 0) : p.ball x r = â :=
begin
  ext,
  rw [seminorm.mem_ball, set.mem_empty_eq, iff_false, not_lt],
  exact hr.trans (p.nonneg _),
end

end norm_one_class
end module
end add_comm_group
end semi_normed_ring

section normed_field
variables [normed_field ð] [add_comm_group E] [module ð E] (p : seminorm ð E) {A B : set E}
  {a : ð} {r : â} {x : E}

lemma smul_ball_zero {p : seminorm ð E} {k : ð} {r : â} (hk : 0 < â¥kâ¥) :
  k â¢ p.ball 0 r = p.ball 0 (â¥kâ¥ * r) :=
begin
  ext,
  rw [set.mem_smul_set, seminorm.mem_ball_zero],
  split; intro h,
  { rcases h with â¨y, hy, hâ©,
    rw [âh, seminorm.smul],
    rw seminorm.mem_ball_zero at hy,
    exact (mul_lt_mul_left hk).mpr hy },
  refine â¨kâ»Â¹ â¢ x, _, _â©,
  { rw [seminorm.mem_ball_zero, seminorm.smul, norm_inv, â(mul_lt_mul_left hk),
      âmul_assoc, â(div_eq_mul_inv â¥kâ¥ â¥kâ¥), div_self (ne_of_gt hk), one_mul],
    exact h},
  rw [âsmul_assoc, smul_eq_mul, âdiv_eq_mul_inv, div_self (norm_pos_iff.mp hk), one_smul],
end

lemma ball_zero_absorbs_ball_zero (p : seminorm ð E) {râ râ : â} (hrâ : 0 < râ) :
  absorbs ð (p.ball 0 râ) (p.ball 0 râ) :=
begin
  by_cases hrâ : râ â¤ 0,
  { rw ball_eq_emptyset p hrâ, exact absorbs_empty },
  rw [not_le] at hrâ,
  rcases exists_between hrâ with â¨r, hr, hr'â©,
  refine â¨râ/r, div_pos hrâ hr, _â©,
  simp_rw set.subset_def,
  intros a ha x hx,
  have ha' : 0 < â¥aâ¥ := lt_of_lt_of_le (div_pos hrâ hr) ha,
  rw [smul_ball_zero ha', p.mem_ball_zero],
  rw p.mem_ball_zero at hx,
  rw div_le_iff hr at ha,
  exact hx.trans (lt_of_le_of_lt ha ((mul_lt_mul_left ha').mpr hr')),
end

/-- Seminorm-balls at the origin are absorbent. -/
protected lemma absorbent_ball_zero (hr : 0 < r) : absorbent ð (ball p (0 : E) r) :=
begin
  rw absorbent_iff_nonneg_lt,
  rintro x,
  have hxr : 0 â¤ p x/r := div_nonneg (p.nonneg _) hr.le,
  refine â¨p x/r, hxr, Î» a ha, _â©,
  have haâ : 0 < â¥aâ¥ := hxr.trans_lt ha,
  refine â¨aâ»Â¹ â¢ x, _, smul_inv_smulâ (norm_pos_iff.1 haâ) xâ©,
  rwa [mem_ball_zero, p.smul, norm_inv, inv_mul_lt_iff haâ, âdiv_lt_iff hr],
end

/-- Seminorm-balls containing the origin are absorbent. -/
protected lemma absorbent_ball (hpr : p x < r) : absorbent ð (ball p x r) :=
begin
  refine (p.absorbent_ball_zero $ sub_pos.2 hpr).subset (Î» y hy, _),
  rw p.mem_ball_zero at hy,
  exact p.mem_ball.2 ((p.sub_le _ _).trans_lt $ add_lt_of_lt_sub_right hy),
end

lemma symmetric_ball_zero (r : â) (hx : x â ball p 0 r) : -x â ball p 0 r :=
balanced_ball_zero p r (-1) (by rw [norm_neg, norm_one]) â¨x, hx, by rw [neg_smul, one_smul]â©

@[simp]
lemma neg_ball (p : seminorm ð E) (r : â) (x : E) :
  -ball p x r = ball p (-x) r :=
by { ext, rw [mem_neg, mem_ball, mem_ball, âneg_add', sub_neg_eq_add, p.neg], }

@[simp]
lemma smul_ball_preimage (p : seminorm ð E) (y : E) (r : â) (a : ð) (ha : a â  0) :
  ((â¢) a) â»Â¹' p.ball y r = p.ball (aâ»Â¹ â¢ y) (r / â¥aâ¥) :=
set.ext $ Î» _, by rw [mem_preimage, mem_ball, mem_ball,
  lt_div_iff (norm_pos_iff.mpr ha), mul_comm, âp.smul, smul_sub, smul_inv_smulâ ha]

end normed_field

section convex
variables [normed_field ð] [add_comm_group E] [normed_space â ð] [module ð E]

section has_scalar
variables [has_scalar â E] [is_scalar_tower â ð E] (p : seminorm ð E)

/-- A seminorm is convex. Also see `convex_on_norm`. -/
protected lemma convex_on : convex_on â univ p :=
begin
  refine â¨convex_univ, Î» x y _ _ a b ha hb hab, _â©,
  calc p (a â¢ x + b â¢ y) â¤ p (a â¢ x) + p (b â¢ y) : p.triangle _ _
    ... = â¥a â¢ (1 : ð)â¥ * p x + â¥b â¢ (1 : ð)â¥ * p y
        : by rw [âp.smul, âp.smul, smul_one_smul, smul_one_smul]
    ... = a * p x + b * p y
        : by rw [norm_smul, norm_smul, norm_one, mul_one, mul_one, real.norm_of_nonneg ha,
            real.norm_of_nonneg hb],
end

end has_scalar

section module
variables [module â E] [is_scalar_tower â ð E] (p : seminorm ð E) (x : E) (r : â)

/-- Seminorm-balls are convex. -/
lemma convex_ball : convex â (ball p x r) :=
begin
  convert (p.convex_on.translate_left (-x)).convex_lt r,
  ext y,
  rw [preimage_univ, sep_univ, p.mem_ball, sub_eq_add_neg],
  refl,
end

end module
end convex
end seminorm

/-! ### The norm as a seminorm -/

section norm_seminorm
variables (ð E) [normed_field ð] [semi_normed_group E] [normed_space ð E] {r : â}

/-- The norm of a seminormed group as a seminorm. -/
def norm_seminorm : seminorm ð E := â¨norm, norm_smul, norm_add_leâ©

@[simp] lemma coe_norm_seminorm : â(norm_seminorm ð E) = norm := rfl

@[simp] lemma ball_norm_seminorm : (norm_seminorm ð E).ball = metric.ball :=
by { ext x r y, simp only [seminorm.mem_ball, metric.mem_ball, coe_norm_seminorm, dist_eq_norm] }

variables {ð E} {x : E}

/-- Balls at the origin are absorbent. -/
lemma absorbent_ball_zero (hr : 0 < r) : absorbent ð (metric.ball (0 : E) r) :=
by { rw âball_norm_seminorm ð, exact (norm_seminorm _ _).absorbent_ball_zero hr }

/-- Balls containing the origin are absorbent. -/
lemma absorbent_ball (hx : â¥xâ¥ < r) : absorbent ð (metric.ball x r) :=
by { rw âball_norm_seminorm ð, exact (norm_seminorm _ _).absorbent_ball hx }

/-- Balls at the origin are balanced. -/
lemma balanced_ball_zero [norm_one_class ð] : balanced ð (metric.ball (0 : E) r) :=
by { rw âball_norm_seminorm ð, exact (norm_seminorm _ _).balanced_ball_zero r }

end norm_seminorm
