/-
Copyright (c) 2021 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker
-/
import analysis.normed_space.exponential
import analysis.calculus.fderiv_analytic
import data.complex.exponential
import topology.metric_space.cau_seq_filter

/-!
# Calculus results on exponential in a Banach algebra

In this file, we prove basic properties about the derivative of the exponential map `exp π πΈ`
in a Banach algebra `πΈ` over a field `π`. We keep them separate from the main file
`analysis/normed_space/exponential` in order to minimize dependencies.

## Main results

We prove most result for an arbitrary field `π`, and then specialize to `π = β` or `π = β`.

### General case

- `has_strict_fderiv_at_exp_zero_of_radius_pos` : `exp π πΈ` has strict FrΓ©chet-derivative
  `1 : πΈ βL[π] πΈ` at zero, as long as it converges on a neighborhood of zero
  (see also `has_strict_deriv_at_exp_zero_of_radius_pos` for the case `πΈ = π`)
- `has_strict_fderiv_at_exp_of_lt_radius` : if `π` has characteristic zero and `πΈ` is commutative,
  then given a point `x` in the disk of convergence, `exp π πΈ` as strict FrΓ©chet-derivative
  `exp π πΈ x β’ 1 : πΈ βL[π] πΈ` at x (see also `has_strict_deriv_at_exp_of_lt_radius` for the case
  `πΈ = π`)

### `π = β` or `π = β`

- `has_strict_fderiv_at_exp_zero` : `exp π πΈ` has strict FrΓ©chet-derivative `1 : πΈ βL[π] πΈ` at zero
  (see also `has_strict_deriv_at_exp_zero` for the case `πΈ = π`)
- `has_strict_fderiv_at_exp` : if `πΈ` is commutative, then given any point `x`, `exp π πΈ` as strict
  FrΓ©chet-derivative `exp π πΈ x β’ 1 : πΈ βL[π] πΈ` at x (see also `has_strict_deriv_at_exp` for the
  case `πΈ = π`)

### Compatibilty with `real.exp` and `complex.exp`

- `complex.exp_eq_exp_β_β` : `complex.exp = exp β β`
- `real.exp_eq_exp_β_β` : `real.exp = exp β β`

-/

open filter is_R_or_C continuous_multilinear_map normed_field asymptotics
open_locale nat topological_space big_operators ennreal

section any_field_any_algebra

variables {π πΈ : Type*} [nondiscrete_normed_field π] [normed_ring πΈ] [normed_algebra π πΈ]
  [complete_space πΈ]

/-- The exponential in a Banach-algebra `πΈ` over a normed field `π` has strict FrΓ©chet-derivative
`1 : πΈ βL[π] πΈ` at zero, as long as it converges on a neighborhood of zero. -/
lemma has_strict_fderiv_at_exp_zero_of_radius_pos (h : 0 < (exp_series π πΈ).radius) :
  has_strict_fderiv_at (exp π πΈ) (1 : πΈ βL[π] πΈ) 0 :=
begin
  convert (has_fpower_series_at_exp_zero_of_radius_pos h).has_strict_fderiv_at,
  ext x,
  change x = exp_series π πΈ 1 (Ξ» _, x),
  simp [exp_series_apply_eq]
end

/-- The exponential in a Banach-algebra `πΈ` over a normed field `π` has FrΓ©chet-derivative
`1 : πΈ βL[π] πΈ` at zero, as long as it converges on a neighborhood of zero. -/
lemma has_fderiv_at_exp_zero_of_radius_pos (h : 0 < (exp_series π πΈ).radius) :
  has_fderiv_at (exp π πΈ) (1 : πΈ βL[π] πΈ) 0 :=
(has_strict_fderiv_at_exp_zero_of_radius_pos h).has_fderiv_at

end any_field_any_algebra

section any_field_comm_algebra

variables {π πΈ : Type*} [nondiscrete_normed_field π] [normed_comm_ring πΈ] [normed_algebra π πΈ]
  [complete_space πΈ]

/-- The exponential map in a commutative Banach-algebra `πΈ` over a normed field `π` of
characteristic zero has FrΓ©chet-derivative `exp π πΈ x β’ 1 : πΈ βL[π] πΈ` at any point `x` in the
disk of convergence. -/
lemma has_fderiv_at_exp_of_mem_ball [char_zero π] {x : πΈ}
  (hx : x β emetric.ball (0 : πΈ) (exp_series π πΈ).radius) :
  has_fderiv_at (exp π πΈ) (exp π πΈ x β’ 1 : πΈ βL[π] πΈ) x :=
begin
  have hpos : 0 < (exp_series π πΈ).radius := (zero_le _).trans_lt hx,
  rw has_fderiv_at_iff_is_o_nhds_zero,
  suffices : (Ξ» h, exp π πΈ x * (exp π πΈ (0 + h) - exp π πΈ 0 - continuous_linear_map.id π πΈ h))
    =αΆ [π 0] (Ξ» h, exp π πΈ (x + h) - exp π πΈ x - exp π πΈ x β’ continuous_linear_map.id π πΈ h),
  { refine (is_o.const_mul_left _ _).congr' this (eventually_eq.refl _ _),
    rw β has_fderiv_at_iff_is_o_nhds_zero,
    exact has_fderiv_at_exp_zero_of_radius_pos hpos },
  have : βαΆ  h in π (0 : πΈ), h β emetric.ball (0 : πΈ) (exp_series π πΈ).radius :=
    emetric.ball_mem_nhds _ hpos,
  filter_upwards [this] with _ hh,
  rw [exp_add_of_mem_ball hx hh, exp_zero, zero_add, continuous_linear_map.id_apply, smul_eq_mul],
  ring
end

/-- The exponential map in a commutative Banach-algebra `πΈ` over a normed field `π` of
characteristic zero has strict FrΓ©chet-derivative `exp π πΈ x β’ 1 : πΈ βL[π] πΈ` at any point `x` in
the disk of convergence. -/
lemma has_strict_fderiv_at_exp_of_mem_ball [char_zero π] {x : πΈ}
  (hx : x β emetric.ball (0 : πΈ) (exp_series π πΈ).radius) :
  has_strict_fderiv_at (exp π πΈ) (exp π πΈ x β’ 1 : πΈ βL[π] πΈ) x :=
let β¨p, hpβ© := analytic_at_exp_of_mem_ball x hx in
hp.has_fderiv_at.unique (has_fderiv_at_exp_of_mem_ball hx) βΈ hp.has_strict_fderiv_at

end any_field_comm_algebra

section deriv

variables {π : Type*} [nondiscrete_normed_field π] [complete_space π]

/-- The exponential map in a complete normed field `π` of characteristic zero has strict derivative
`exp π π x` at any point `x` in the disk of convergence. -/
lemma has_strict_deriv_at_exp_of_mem_ball [char_zero π] {x : π}
  (hx : x β emetric.ball (0 : π) (exp_series π π).radius) :
  has_strict_deriv_at (exp π π) (exp π π x) x :=
by simpa using (has_strict_fderiv_at_exp_of_mem_ball hx).has_strict_deriv_at

/-- The exponential map in a complete normed field `π` of characteristic zero has derivative
`exp π π x` at any point `x` in the disk of convergence. -/
lemma has_deriv_at_exp_of_mem_ball [char_zero π] {x : π}
  (hx : x β emetric.ball (0 : π) (exp_series π π).radius) :
  has_deriv_at (exp π π) (exp π π x) x :=
(has_strict_deriv_at_exp_of_mem_ball hx).has_deriv_at

/-- The exponential map in a complete normed field `π` of characteristic zero has strict derivative
`1` at zero, as long as it converges on a neighborhood of zero. -/
lemma has_strict_deriv_at_exp_zero_of_radius_pos (h : 0 < (exp_series π π).radius) :
  has_strict_deriv_at (exp π π) 1 0 :=
(has_strict_fderiv_at_exp_zero_of_radius_pos h).has_strict_deriv_at

/-- The exponential map in a complete normed field `π` of characteristic zero has derivative
`1` at zero, as long as it converges on a neighborhood of zero. -/
lemma has_deriv_at_exp_zero_of_radius_pos (h : 0 < (exp_series π π).radius) :
  has_deriv_at (exp π π) 1 0 :=
(has_strict_deriv_at_exp_zero_of_radius_pos h).has_deriv_at

end deriv

section is_R_or_C_any_algebra

variables {π πΈ : Type*} [is_R_or_C π] [normed_ring πΈ] [normed_algebra π πΈ]
  [complete_space πΈ]

/-- The exponential in a Banach-algebra `πΈ` over `π = β` or `π = β` has strict FrΓ©chet-derivative
`1 : πΈ βL[π] πΈ` at zero. -/
lemma has_strict_fderiv_at_exp_zero :
  has_strict_fderiv_at (exp π πΈ) (1 : πΈ βL[π] πΈ) 0 :=
has_strict_fderiv_at_exp_zero_of_radius_pos (exp_series_radius_pos π πΈ)

/-- The exponential in a Banach-algebra `πΈ` over `π = β` or `π = β` has FrΓ©chet-derivative
`1 : πΈ βL[π] πΈ` at zero. -/
lemma has_fderiv_at_exp_zero :
  has_fderiv_at (exp π πΈ) (1 : πΈ βL[π] πΈ) 0 :=
has_strict_fderiv_at_exp_zero.has_fderiv_at

end is_R_or_C_any_algebra

section is_R_or_C_comm_algebra

variables {π πΈ : Type*} [is_R_or_C π] [normed_comm_ring πΈ] [normed_algebra π πΈ]
  [complete_space πΈ]

/-- The exponential map in a commutative Banach-algebra `πΈ` over `π = β` or `π = β` has strict
FrΓ©chet-derivative `exp π πΈ x β’ 1 : πΈ βL[π] πΈ` at any point `x`. -/
lemma has_strict_fderiv_at_exp {x : πΈ} :
  has_strict_fderiv_at (exp π πΈ) (exp π πΈ x β’ 1 : πΈ βL[π] πΈ) x :=
has_strict_fderiv_at_exp_of_mem_ball ((exp_series_radius_eq_top π πΈ).symm βΈ edist_lt_top _ _)

/-- The exponential map in a commutative Banach-algebra `πΈ` over `π = β` or `π = β` has
FrΓ©chet-derivative `exp π πΈ x β’ 1 : πΈ βL[π] πΈ` at any point `x`. -/
lemma has_fderiv_at_exp {x : πΈ} :
  has_fderiv_at (exp π πΈ) (exp π πΈ x β’ 1 : πΈ βL[π] πΈ) x :=
has_strict_fderiv_at_exp.has_fderiv_at

end is_R_or_C_comm_algebra

section deriv_R_or_C

variables {π : Type*} [is_R_or_C π]

/-- The exponential map in `π = β` or `π = β` has strict derivative `exp π π x` at any point
`x`. -/
lemma has_strict_deriv_at_exp {x : π} : has_strict_deriv_at (exp π π) (exp π π x) x :=
has_strict_deriv_at_exp_of_mem_ball ((exp_series_radius_eq_top π π).symm βΈ edist_lt_top _ _)

/-- The exponential map in `π = β` or `π = β` has derivative `exp π π x` at any point `x`. -/
lemma has_deriv_at_exp {x : π} : has_deriv_at (exp π π) (exp π π x) x :=
has_strict_deriv_at_exp.has_deriv_at

/-- The exponential map in `π = β` or `π = β` has strict derivative `1` at zero. -/
lemma has_strict_deriv_at_exp_zero : has_strict_deriv_at (exp π π) 1 0 :=
has_strict_deriv_at_exp_zero_of_radius_pos (exp_series_radius_pos π π)

/-- The exponential map in `π = β` or `π = β` has derivative `1` at zero. -/
lemma has_deriv_at_exp_zero :
  has_deriv_at (exp π π) 1 0 :=
has_strict_deriv_at_exp_zero.has_deriv_at

end deriv_R_or_C

section complex

lemma complex.exp_eq_exp_β_β : complex.exp = exp β β :=
begin
  refine funext (Ξ» x, _),
  rw [complex.exp, exp_eq_tsum_field],
  exact tendsto_nhds_unique x.exp'.tendsto_limit
    (exp_series_field_summable x).has_sum.tendsto_sum_nat
end

end complex

section real

lemma real.exp_eq_exp_β_β : real.exp = exp β β :=
begin
  refine funext (Ξ» x, _),
  rw [real.exp, complex.exp_eq_exp_β_β, β exp_β_β_eq_exp_β_β, exp_eq_tsum, exp_eq_tsum_field,
      β re_to_complex, β re_clm_apply, re_clm.map_tsum (exp_series_summable' (x : β))],
  refine tsum_congr (Ξ» n, _),
  rw [re_clm.map_smul, β complex.of_real_pow, re_clm_apply, re_to_complex, complex.of_real_re,
      smul_eq_mul, one_div, mul_comm, div_eq_mul_inv]
end

end real
