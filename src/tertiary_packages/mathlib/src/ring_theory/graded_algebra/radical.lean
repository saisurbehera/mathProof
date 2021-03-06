/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang, Eric Wieser
-/

import ring_theory.graded_algebra.homogeneous_ideal

/-!

This file contains a proof that the radical of any homogeneous ideal is a homogeneous ideal

## Main statements

* `ideal.is_homogeneous.is_prime_iff`: for any `I : ideal A`, if `I` is homogeneous, then
  `I` is prime if and only if `I` is homogeneously prime, i.e. `I â  âĪ` and if `x, y` are
  homogeneous elements such that `x * y â I`, then at least one of `x,y` is in `I`.
* `ideal.is_prime.homogeneous_core`: for any `I : ideal A`, if `I` is prime, then
  `I.homogeneous_core ð` (i.e. the largest homogeneous ideal contained in `I`) is also prime.
* `ideal.is_homogeneous.radical`: for any `I : ideal A`, if `I` is homogeneous, then the
  radical of `I` is homogeneous as well.
* `homogeneous_ideal.radical`: for any `I : homogeneous_ideal ð`, `I.radical` is the the
  radical of `I` as a `homogeneous_ideal ð`

## Implementation details

Throughout this file, the indexing type `Îđ` of grading is assumed to be a
`linear_ordered_cancel_add_comm_monoid`. This might be stronger than necessary but cancelling
property is strictly necessary; for a counterexample of how `ideal.is_homogeneous.is_prime_iff`
fails for a non-cancellative set see `counterexample/homogeneous_prime_not_prime.lean`.

## Tags

homogeneous, radical
-/

open graded_algebra set_like finset
open_locale big_operators

variables {Îđ R A : Type*}
variables [comm_semiring R] [comm_ring A] [algebra R A]
variables [linear_ordered_cancel_add_comm_monoid Îđ]
variables {ð : Îđ â submodule R A} [graded_algebra ð]

lemma ideal.is_homogeneous.is_prime_of_homogeneous_mem_or_mem
  {I : ideal A} (hI : I.is_homogeneous ð) (I_ne_top : I â  âĪ)
  (homogeneous_mem_or_mem : â {x y : A},
    is_homogeneous ð x â is_homogeneous ð y â (x * y â I â x â I âĻ y â I)) :
  ideal.is_prime I :=
âĻI_ne_top, begin
  intros x y hxy,
  by_contradiction rid,
  obtain âĻridâ, ridââĐ := not_or_distrib.mp rid,
  /-
  The idea of the proof is the following :
  since `x * y â I` and `I` homogeneous, then `proj i (x * y) â I` for any `i : Îđ`.
  Then consider two sets `{i â x.support | xáĩĒ â I}` and `{j â y.support | yâąž â J}`;
  let `maxâ, maxâ` be the maximum of the two sets, then `proj (maxâ + maxâ) (x * y) â I`.
  Then, `proj maxâ x â I` and `proj maxâ j â I`
  but `proj i x â I` for all `maxâ < i` and `proj j y â I` for all `maxâ < j`.
  `  proj (maxâ + maxâ) (x * y)`
  `= â {(i, j) â supports | i + j = maxâ + maxâ}, xáĩĒ * yâąž`
  `= proj maxâ x * proj maxâ y`
  `  + â {(i, j) â supports \ {(maxâ, maxâ)} | i + j = maxâ + maxâ}, xáĩĒ * yâąž`.
  This is a contradiction, because both `proj (maxâ + maxâ) (x * y) â I` and the sum on the
  right hand side is in `I` however `proj maxâ x * proj maxâ y` is not in `I`.
  -/
  letI : Î  (x : A),
    decidable_pred (Îŧ (i : Îđ), proj ð i x â I) := Îŧ x, classical.dec_pred _,
  letI : Î  i (x : ð i), decidable (x â  0) := Îŧ i x, classical.dec _,
  set setâ := (support ð x).filter (Îŧ i, proj ð i x â I) with setâ_eq,
  set setâ := (support ð y).filter (Îŧ i, proj ð i y â I) with setâ_eq,
  have nonempty : â (x : A), (x â I) â ((support ð x).filter (Îŧ i, proj ð i x â I)).nonempty,
  { intros x hx,
    rw filter_nonempty_iff,
    contrapose! hx,
    rw â sum_support_decompose ð x,
    apply ideal.sum_mem _ hx, },
  set maxâ := setâ.max' (nonempty x ridâ) with maxâ_eq,
  set maxâ := setâ.max' (nonempty y ridâ) with maxâ_eq,
  have mem_maxâ : maxâ â setâ := max'_mem setâ (nonempty x ridâ),
  have mem_maxâ : maxâ â setâ := max'_mem setâ (nonempty y ridâ),
  replace hxy : proj ð (maxâ + maxâ) (x * y) â I := hI _ hxy,

  have mem_I : proj ð maxâ x * proj ð maxâ y â I,
  { set antidiag :=
      ((support ð x).product (support ð y)).filter (Îŧ z : Îđ Ã Îđ, z.1 + z.2 = maxâ + maxâ) with ha,
    have mem_antidiag : (maxâ, maxâ) â antidiag,
    { simp only [add_sum_erase, mem_filter, mem_product],
      exact âĻâĻmem_of_mem_filter _ mem_maxâ, mem_of_mem_filter _ mem_maxââĐ, rflâĐ },
    have eq_add_sum :=
      calc  proj ð (maxâ + maxâ) (x * y)
          = â ij in antidiag, proj ð ij.1 x * proj ð ij.2 y
          : by simp_rw [ha, proj_apply, map_mul, support, direct_sum.coe_mul_apply_submodule]
      ... = proj ð maxâ x * proj ð maxâ y + â ij in antidiag.erase (maxâ, maxâ),
                                              proj ð ij.1 x * proj ð ij.2 y
          : (add_sum_erase _ _ mem_antidiag).symm,
    rw eq_sub_of_add_eq eq_add_sum.symm,
    refine ideal.sub_mem _ hxy (ideal.sum_mem _ (Îŧ z H, _)),
    rcases z with âĻi, jâĐ,
    simp only [mem_erase, prod.mk.inj_iff, ne.def, mem_filter, mem_product] at H,
    rcases H with âĻHâ, âĻHâ, HââĐ, HââĐ,
    have max_lt : maxâ < i âĻ maxâ < j,
    { rcases lt_trichotomy maxâ i with h | rfl | h,
      { exact or.inl h },
      { refine false.elim (Hâ âĻrfl, add_left_cancel HââĐ), },
      { apply or.inr,
        have := add_lt_add_right h j,
        rw Hâ at this,
        exact lt_of_add_lt_add_left this, }, },
    cases max_lt,
    { -- in this case `maxâ < i`, then `xáĩĒ â I`; for otherwise `i â setâ` then `i âĪ maxâ`.
      have not_mem : i â setâ := Îŧ h, lt_irrefl _
        ((max'_lt_iff setâ (nonempty x ridâ)).mp max_lt i h),
      rw setâ_eq at not_mem,
      simp only [not_and, not_not, ne.def, dfinsupp.mem_support_to_fun, mem_filter] at not_mem,
      exact ideal.mul_mem_right _ I (not_mem Hâ), },
    { -- in this case  `maxâ < j`, then `yâąž â I`; for otherwise `j â setâ`, then `j âĪ maxâ`.
      have not_mem : j â setâ := Îŧ h, lt_irrefl _
        ((max'_lt_iff setâ (nonempty y ridâ)).mp max_lt j h),
      rw setâ_eq at not_mem,
      simp only [not_and, not_not, ne.def, dfinsupp.mem_support_to_fun, mem_filter] at not_mem,
      exact ideal.mul_mem_left I _ (not_mem Hâ), }, },

  have not_mem_I : proj ð maxâ x * proj ð maxâ y â I,
  { have neither_mem : proj ð maxâ x â I â§ proj ð maxâ y â I,
    { rw mem_filter at mem_maxâ mem_maxâ,
      exact âĻmem_maxâ.2, mem_maxâ.2âĐ, },
    intro rid,
    cases homogeneous_mem_or_mem âĻmaxâ, submodule.coe_mem _âĐ âĻmaxâ, submodule.coe_mem _âĐ mem_I,
    { apply neither_mem.1 h },
    { apply neither_mem.2 h }, },

  exact not_mem_I mem_I,
endâĐ

lemma ideal.is_homogeneous.is_prime_iff {I : ideal A} (h : I.is_homogeneous ð) :
  I.is_prime â
  (I â  âĪ) â§
    â {x y : A}, set_like.is_homogeneous ð x â set_like.is_homogeneous ð y
      â (x * y â I â x â I âĻ y â I) :=
âĻÎŧ HI,
  âĻne_of_apply_ne _ HI.ne_top, Îŧ x y hx hy hxy, ideal.is_prime.mem_or_mem HI hxyâĐ,
  Îŧ âĻI_ne_top, homogeneous_mem_or_memâĐ,
    h.is_prime_of_homogeneous_mem_or_mem I_ne_top @homogeneous_mem_or_memâĐ

lemma ideal.is_prime.homogeneous_core {I : ideal A} (h : I.is_prime) :
  (I.homogeneous_core ð).to_ideal.is_prime :=
begin
  apply (ideal.homogeneous_core ð I).is_homogeneous.is_prime_of_homogeneous_mem_or_mem,
  { exact ne_top_of_le_ne_top h.ne_top (ideal.to_ideal_homogeneous_core_le ð I) },
  rintros x y hx hy hxy,
  have H := h.mem_or_mem (ideal.to_ideal_homogeneous_core_le ð I hxy),
  refine H.imp _ _,
  { exact ideal.mem_homogeneous_core_of_is_homogeneous_of_mem hx, },
  { exact ideal.mem_homogeneous_core_of_is_homogeneous_of_mem hy, },
end

lemma ideal.is_homogeneous.radical_eq {I : ideal A} (hI : I.is_homogeneous ð) :
  I.radical = Inf { J | J.is_homogeneous ð â§ I âĪ J â§ J.is_prime } :=
begin
  rw ideal.radical_eq_Inf,
  apply le_antisymm,
  { exact Inf_le_Inf (Îŧ J, and.right), },
  { refine Inf_le_Inf_of_forall_exists_le _,
    rintros J âĻHJâ, HJââĐ,
    refine âĻ(J.homogeneous_core ð).to_ideal, _, J.to_ideal_homogeneous_core_le _âĐ,
    refine âĻhomogeneous_ideal.is_homogeneous _, _, HJâ.homogeneous_coreâĐ,
    refine hI.to_ideal_homogeneous_core_eq_self.symm.trans_le (ideal.homogeneous_core_mono _ HJâ), }
end

lemma ideal.is_homogeneous.radical {I : ideal A} (h : I.is_homogeneous ð)  :
  I.radical.is_homogeneous ð :=
by { rw h.radical_eq, exact ideal.is_homogeneous.Inf (Îŧ _, and.left) }

/-- The radical of a homogenous ideal, as another homogenous ideal. -/
def homogeneous_ideal.radical (I : homogeneous_ideal ð) : homogeneous_ideal ð :=
âĻI.to_ideal.radical, I.is_homogeneous.radicalâĐ

@[simp]
lemma homogeneous_ideal.coe_radical (I : homogeneous_ideal ð) :
  I.radical.to_ideal = I.to_ideal.radical := rfl
