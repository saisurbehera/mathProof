/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux
-/
import analysis.normed_space.star.basic
import analysis.normed_space.spectrum
import algebra.star.module
import analysis.normed_space.star.exponential

/-! # Spectral properties in Câ-algebras
In this file, we establish various propreties related to the spectrum of elements in Câ-algebras.
-/

local postfix `â`:std.prec.max_plus := star

open_locale topological_space ennreal
open filter ennreal spectrum cstar_ring

section unitary_spectrum

variables
{ð : Type*} [normed_field ð]
{E : Type*} [normed_ring E] [star_ring E] [cstar_ring E]
[normed_algebra ð E] [complete_space E] [nontrivial E]

lemma unitary.spectrum_subset_circle (u : unitary E) :
  spectrum ð (u : E) â metric.sphere 0 1 :=
begin
  refine Î» k hk, mem_sphere_zero_iff_norm.mpr (le_antisymm _ _),
  { simpa only [cstar_ring.norm_coe_unitary u] using norm_le_norm_of_mem hk },
  { rw âunitary.coe_to_units_apply u at hk,
    have hnk := ne_zero_of_mem_of_unit hk,
    rw [âinv_inv (unitary.to_units u), âspectrum.map_inv, set.mem_inv] at hk,
    have : â¥kâ¥â»Â¹ â¤ â¥â((unitary.to_units u)â»Â¹)â¥, simpa only [norm_inv] using norm_le_norm_of_mem hk,
    simpa using inv_le_of_inv_le (norm_pos_iff.mpr hnk) this }
end

lemma spectrum.subset_circle_of_unitary {u : E} (h : u â unitary E) :
  spectrum ð u â metric.sphere 0 1 :=
unitary.spectrum_subset_circle â¨u, hâ©

end unitary_spectrum

section complex_scalars

open complex

variables {A : Type*}
[normed_ring A] [normed_algebra â A] [complete_space A] [star_ring A] [cstar_ring A]

local notation `ââ` := algebra_map â A

lemma spectral_radius_eq_nnnorm_of_self_adjoint {a : A} (ha : a â self_adjoint A) :
  spectral_radius â a = â¥aâ¥â :=
begin
  have hconst : tendsto (Î» n : â, (â¥aâ¥â : ââ¥0â)) at_top _ := tendsto_const_nhds,
  refine tendsto_nhds_unique _ hconst,
  convert (spectrum.pow_nnnorm_pow_one_div_tendsto_nhds_spectral_radius (a : A)).comp
      (nat.tendsto_pow_at_top_at_top_of_one_lt (by linarith : 1 < 2)),
  refine funext (Î» n, _),
  rw [function.comp_app, nnnorm_pow_two_pow_of_self_adjoint ha, ennreal.coe_pow, ârpow_nat_cast,
    ârpow_mul],
  simp,
end

lemma spectral_radius_eq_nnnorm_of_star_normal (a : A) [is_star_normal a] :
  spectral_radius â a = â¥aâ¥â :=
begin
  refine (ennreal.pow_strict_mono (by linarith : 2 â  0)).injective _,
  have ha : aâ * a â self_adjoint A,
    from self_adjoint.mem_iff.mpr (by simpa only [star_star] using (star_mul aâ a)),
  have heq : (Î» n : â, ((â¥(aâ * a) ^ nâ¥â ^ (1 / n : â)) : ââ¥0â))
    = (Î» x, x ^ 2) â (Î» n : â, ((â¥a ^ nâ¥â ^ (1 / n : â)) : ââ¥0â)),
  { funext,
    rw [function.comp_apply, ârpow_nat_cast, ârpow_mul, mul_comm, rpow_mul, rpow_nat_cast,
      âcoe_pow, sq, ânnnorm_star_mul_self, commute.mul_pow (star_comm_self' a), star_pow], },
  have hâ := ((ennreal.continuous_pow 2).tendsto (spectral_radius â a)).comp
    (spectrum.pow_nnnorm_pow_one_div_tendsto_nhds_spectral_radius a),
  rw âheq at hâ,
  convert tendsto_nhds_unique hâ (pow_nnnorm_pow_one_div_tendsto_nhds_spectral_radius (aâ * a)),
  rw [spectral_radius_eq_nnnorm_of_self_adjoint ha, sq, nnnorm_star_mul_self, coe_mul],
end

/-- Any element of the spectrum of a selfadjoint is real. -/
theorem self_adjoint.mem_spectrum_eq_re [star_module â A] [nontrivial A] {a : A}
  (ha : a â self_adjoint A) {z : â} (hz : z â spectrum â a) : z = z.re :=
begin
  let Iu := units.mk0 I I_ne_zero,
  have : exp â â (I â¢ z) â spectrum â (exp â A (I â¢ a)),
    by simpa only [units.smul_def, units.coe_mk0]
      using spectrum.exp_mem_exp (Iu â¢ a) (smul_mem_smul_iff.mpr hz),
  exact complex.ext (of_real_re _)
    (by simpa only [âcomplex.exp_eq_exp_â_â, mem_sphere_zero_iff_norm, norm_eq_abs, abs_exp,
      real.exp_eq_one_iff, smul_eq_mul, I_mul, neg_eq_zero]
      using spectrum.subset_circle_of_unitary (self_adjoint.exp_i_smul_unitary ha) this),
end

/-- Any element of the spectrum of a selfadjoint is real. -/
theorem self_adjoint.mem_spectrum_eq_re' [star_module â A] [nontrivial A]
  (a : self_adjoint A) {z : â} (hz : z â spectrum â (a : A)) : z = z.re :=
self_adjoint.mem_spectrum_eq_re a.property hz

/-- The spectrum of a selfadjoint is real -/
theorem self_adjoint.coe_re_map_spectrum [star_module â A] [nontrivial A] {a : A}
  (ha : a â self_adjoint A) : spectrum â a = (coe â re '' (spectrum â a) : set â) :=
le_antisymm (Î» z hz, â¨z, hz, (self_adjoint.mem_spectrum_eq_re ha hz).symmâ©) (Î» z, by
  { rintros â¨z, hz, rflâ©,
    simpa only [(self_adjoint.mem_spectrum_eq_re ha hz).symm, function.comp_app] using hz })

/-- The spectrum of a selfadjoint is real -/
theorem self_adjoint.coe_re_map_spectrum' [star_module â A] [nontrivial A] (a : self_adjoint A) :
  spectrum â (a : A) = (coe â re '' (spectrum â (a : A)) : set â) :=
self_adjoint.coe_re_map_spectrum a.property

end complex_scalars
