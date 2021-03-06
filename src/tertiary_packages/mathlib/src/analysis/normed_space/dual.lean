/-
Copyright (c) 2020 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth
-/
import analysis.normed_space.hahn_banach
import analysis.normed_space.is_R_or_C
import analysis.locally_convex.polar

/-!
# The topological dual of a normed space

In this file we define the topological dual `normed_space.dual` of a normed space, and the
continuous linear map `normed_space.inclusion_in_double_dual` from a normed space into its double
dual.

For base field `๐ = โ` or `๐ = โ`, this map is actually an isometric embedding; we provide a
version `normed_space.inclusion_in_double_dual_li` of the map which is of type a bundled linear
isometric embedding, `E โโแตข[๐] (dual ๐ (dual ๐ E))`.

Since a lot of elementary properties don't require `eq_of_dist_eq_zero` we start setting up the
theory for `semi_normed_group` and we specialize to `normed_group` when needed.

## Main definitions

* `inclusion_in_double_dual` and `inclusion_in_double_dual_li` are the inclusion of a normed space
  in its double dual, considered as a bounded linear map and as a linear isometry, respectively.
* `polar ๐ s` is the subset of `dual ๐ E` consisting of those functionals `x'` for which
  `โฅx' zโฅ โค 1` for every `z โ s`.

## Tags

dual
-/

noncomputable theory
open_locale classical topological_space
universes u v

namespace normed_space

section general
variables (๐ : Type*) [nondiscrete_normed_field ๐]
variables (E : Type*) [semi_normed_group E] [normed_space ๐ E]
variables (F : Type*) [normed_group F] [normed_space ๐ F]

/-- The topological dual of a seminormed space `E`. -/
@[derive [inhabited, semi_normed_group, normed_space ๐]] def dual := E โL[๐] ๐

instance : add_monoid_hom_class (dual ๐ E) E ๐ := continuous_linear_map.add_monoid_hom_class

instance : has_coe_to_fun (dual ๐ E) (ฮป _, E โ ๐) := continuous_linear_map.to_fun

instance : normed_group (dual ๐ F) := continuous_linear_map.to_normed_group

instance [finite_dimensional ๐ E] : finite_dimensional ๐ (dual ๐ E) :=
continuous_linear_map.finite_dimensional

/-- The inclusion of a normed space in its double (topological) dual, considered
   as a bounded linear map. -/
def inclusion_in_double_dual : E โL[๐] (dual ๐ (dual ๐ E)) :=
continuous_linear_map.apply ๐ ๐

@[simp] lemma dual_def (x : E) (f : dual ๐ E) : inclusion_in_double_dual ๐ E x f = f x := rfl

lemma inclusion_in_double_dual_norm_eq :
  โฅinclusion_in_double_dual ๐ Eโฅ = โฅ(continuous_linear_map.id ๐ (dual ๐ E))โฅ :=
continuous_linear_map.op_norm_flip _

lemma inclusion_in_double_dual_norm_le : โฅinclusion_in_double_dual ๐ Eโฅ โค 1 :=
by { rw inclusion_in_double_dual_norm_eq, exact continuous_linear_map.norm_id_le }

lemma double_dual_bound (x : E) : โฅ(inclusion_in_double_dual ๐ E) xโฅ โค โฅxโฅ :=
by simpa using continuous_linear_map.le_of_op_norm_le _ (inclusion_in_double_dual_norm_le ๐ E) x

/-- The dual pairing as a bilinear form. -/
def dual_pairing : (dual ๐ E) โโ[๐] E โโ[๐] ๐ := continuous_linear_map.coe_lm ๐

@[simp] lemma dual_pairing_apply {v : dual ๐ E} {x : E} : dual_pairing ๐ E v x = v x := rfl

lemma dual_pairing_separating_left : (dual_pairing ๐ E).separating_left :=
begin
  rw [linear_map.separating_left_iff_ker_eq_bot, linear_map.ker_eq_bot],
  exact continuous_linear_map.coe_injective,
end

end general

section bidual_isometry

variables (๐ : Type v) [is_R_or_C ๐]
  {E : Type u} [normed_group E] [normed_space ๐ E]

/-- If one controls the norm of every `f x`, then one controls the norm of `x`.
    Compare `continuous_linear_map.op_norm_le_bound`. -/
lemma norm_le_dual_bound (x : E) {M : โ} (hMp: 0 โค M) (hM : โ (f : dual ๐ E), โฅf xโฅ โค M * โฅfโฅ) :
  โฅxโฅ โค M :=
begin
  classical,
  by_cases h : x = 0,
  { simp only [h, hMp, norm_zero] },
  { obtain โจf, hfโ, hfxโฉ : โ f : E โL[๐] ๐, โฅfโฅ = 1 โง f x = โฅxโฅ := exists_dual_vector ๐ x h,
    calc โฅxโฅ = โฅ(โฅxโฅ : ๐)โฅ : is_R_or_C.norm_coe_norm.symm
    ... = โฅf xโฅ : by rw hfx
    ... โค M * โฅfโฅ : hM f
    ... = M : by rw [hfโ, mul_one] }
end

lemma eq_zero_of_forall_dual_eq_zero {x : E} (h : โ f : dual ๐ E, f x = (0 : ๐)) : x = 0 :=
norm_le_zero_iff.mp (norm_le_dual_bound ๐ x le_rfl (ฮป f, by simp [h f]))

lemma eq_zero_iff_forall_dual_eq_zero (x : E) : x = 0 โ โ g : dual ๐ E, g x = 0 :=
โจฮป hx, by simp [hx], ฮป h, eq_zero_of_forall_dual_eq_zero ๐ hโฉ

lemma eq_iff_forall_dual_eq {x y : E} :
  x = y โ โ g : dual ๐ E, g x = g y :=
begin
  rw [โ sub_eq_zero, eq_zero_iff_forall_dual_eq_zero ๐ (x - y)],
  simp [sub_eq_zero],
end

/-- The inclusion of a normed space in its double dual is an isometry onto its image.-/
def inclusion_in_double_dual_li : E โโแตข[๐] (dual ๐ (dual ๐ E)) :=
{ norm_map' := begin
    intros x,
    apply le_antisymm,
    { exact double_dual_bound ๐ E x },
    rw continuous_linear_map.norm_def,
    refine le_cInf continuous_linear_map.bounds_nonempty _,
    rintros c โจhc1, hc2โฉ,
    exact norm_le_dual_bound ๐ x hc1 hc2
  end,
  .. inclusion_in_double_dual ๐ E }

end bidual_isometry

section polar_sets

open metric set normed_space

/-- Given a subset `s` in a normed space `E` (over a field `๐`), the polar
`polar ๐ s` is the subset of `dual ๐ E` consisting of those functionals which
evaluate to something of norm at most one at all points `z โ s`. -/
def polar (๐ : Type*) [nondiscrete_normed_field ๐]
  {E : Type*} [normed_group E] [normed_space ๐ E] : set E โ set (dual ๐ E) :=
(dual_pairing ๐ E).flip.polar

variables (๐ : Type*) [nondiscrete_normed_field ๐]
variables {E : Type*} [normed_group E] [normed_space ๐ E]

lemma mem_polar_iff {x' : dual ๐ E} (s : set E) : x' โ polar ๐ s โ โ z โ s, โฅx' zโฅ โค 1 := iff.rfl

@[simp] lemma polar_univ : polar ๐ (univ : set E) = {(0 : dual ๐ E)} :=
(dual_pairing ๐ E).flip.polar_univ
  (linear_map.flip_separating_right.mpr (dual_pairing_separating_left ๐ E))

lemma is_closed_polar (s : set E) : is_closed (polar ๐ s) :=
begin
  dunfold normed_space.polar,
  simp only [linear_map.polar_eq_Inter, linear_map.flip_apply],
  refine is_closed_bInter (ฮป z hz, _),
  exact is_closed_Iic.preimage (continuous_linear_map.apply ๐ ๐ z).continuous.norm
end

@[simp] lemma polar_closure (s : set E) : polar ๐ (closure s) = polar ๐ s :=
((dual_pairing ๐ E).flip.polar_antitone subset_closure).antisymm $
  (dual_pairing ๐ E).flip.polar_gc.l_le $
  closure_minimal ((dual_pairing ๐ E).flip.polar_gc.le_u_l s) $
  (is_closed_polar _ _).preimage (inclusion_in_double_dual ๐ E).continuous

variables {๐}

/-- If `x'` is a dual element such that the norms `โฅx' zโฅ` are bounded for `z โ s`, then a
small scalar multiple of `x'` is in `polar ๐ s`. -/
lemma smul_mem_polar {s : set E} {x' : dual ๐ E} {c : ๐}
  (hc : โ z, z โ s โ โฅ x' z โฅ โค โฅcโฅ) : cโปยน โข x' โ polar ๐ s :=
begin
  by_cases c_zero : c = 0, { simp only [c_zero, inv_zero, zero_smul],
    exact (dual_pairing ๐ E).flip.zero_mem_polar _ },
  have eq : โ z, โฅ cโปยน โข (x' z) โฅ = โฅ cโปยน โฅ * โฅ x' z โฅ := ฮป z, norm_smul cโปยน _,
  have le : โ z, z โ s โ โฅ cโปยน โข (x' z) โฅ โค โฅ cโปยน โฅ * โฅ c โฅ,
  { intros z hzs,
    rw eq z,
    apply mul_le_mul (le_of_eq rfl) (hc z hzs) (norm_nonneg _) (norm_nonneg _), },
  have cancel : โฅ cโปยน โฅ * โฅ c โฅ = 1,
  by simp only [c_zero, norm_eq_zero, ne.def, not_false_iff,
                inv_mul_cancel, norm_inv],
  rwa cancel at le,
end

lemma polar_ball_subset_closed_ball_div {c : ๐} (hc : 1 < โฅcโฅ) {r : โ} (hr : 0 < r) :
  polar ๐ (ball (0 : E) r) โ closed_ball (0 : dual ๐ E) (โฅcโฅ / r) :=
begin
  intros x' hx',
  rw mem_polar_iff at hx',
  simp only [polar, mem_set_of_eq, mem_closed_ball_zero_iff, mem_ball_zero_iff] at *,
  have hcr : 0 < โฅcโฅ / r, from div_pos (zero_lt_one.trans hc) hr,
  refine continuous_linear_map.op_norm_le_of_shell hr hcr.le hc (ฮป x hโ hโ, _),
  calc โฅx' xโฅ โค 1 : hx' _ hโ
  ... โค (โฅcโฅ / r) * โฅxโฅ : (inv_pos_le_iff_one_le_mul' hcr).1 (by rwa inv_div)
end

variables (๐)

lemma closed_ball_inv_subset_polar_closed_ball {r : โ} :
  closed_ball (0 : dual ๐ E) rโปยน โ polar ๐ (closed_ball (0 : E) r) :=
ฮป x' hx' x hx,
calc โฅx' xโฅ โค โฅx'โฅ * โฅxโฅ : x'.le_op_norm x
... โค rโปยน * r :
  mul_le_mul (mem_closed_ball_zero_iff.1 hx') (mem_closed_ball_zero_iff.1 hx)
    (norm_nonneg _) (dist_nonneg.trans hx')
... = r / r : div_eq_inv_mul.symm
... โค 1 : div_self_le_one r

/-- The `polar` of closed ball in a normed space `E` is the closed ball of the dual with
inverse radius. -/
lemma polar_closed_ball
  {๐ : Type*} [is_R_or_C ๐] {E : Type*} [normed_group E] [normed_space ๐ E] {r : โ} (hr : 0 < r) :
  polar ๐ (closed_ball (0 : E) r) = closed_ball (0 : dual ๐ E) rโปยน :=
begin
  refine subset.antisymm _ (closed_ball_inv_subset_polar_closed_ball _),
  intros x' h,
  simp only [mem_closed_ball_zero_iff],
  refine continuous_linear_map.op_norm_le_of_ball hr (inv_nonneg.mpr hr.le) (ฮป z hz, _),
  simpa only [one_div] using linear_map.bound_of_ball_bound' hr 1 x'.to_linear_map h z
end

/-- Given a neighborhood `s` of the origin in a normed space `E`, the dual norms
of all elements of the polar `polar ๐ s` are bounded by a constant. -/
lemma bounded_polar_of_mem_nhds_zero {s : set E} (s_nhd : s โ ๐ (0 : E)) :
  bounded (polar ๐ s) :=
begin
  obtain โจa, haโฉ : โ a : ๐, 1 < โฅaโฅ := normed_field.exists_one_lt_norm ๐,
  obtain โจr, r_pos, r_ballโฉ : โ (r : โ) (hr : 0 < r), ball 0 r โ s :=
    metric.mem_nhds_iff.1 s_nhd,
  exact bounded_closed_ball.mono (((dual_pairing ๐ E).flip.polar_antitone r_ball).trans $
    polar_ball_subset_closed_ball_div ha r_pos)
end

end polar_sets

end normed_space
