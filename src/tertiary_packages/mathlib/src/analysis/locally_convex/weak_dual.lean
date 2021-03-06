/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll
-/
import topology.algebra.module.weak_dual
import analysis.normed.normed_field
import analysis.locally_convex.with_seminorms

/-!
# Weak Dual in Topological Vector Spaces

We prove that the weak topology induced by a bilinear form `B : E ââ[ð] F ââ[ð] ð` is locally
convex and we explicit give a neighborhood basis in terms of the family of seminorms `Î» x, â¥B x yâ¥`
for `y : F`.

## Main definitions

* `linear_map.to_seminorm`: turn a linear form `f : E ââ[ð] ð` into a seminorm `Î» x, â¥f xâ¥`.
* `linear_map.to_seminorm_family`: turn a bilinear form `B : E ââ[ð] F ââ[ð] ð` into a map
`F â seminorm ð E`.

## Main statements

* `linear_map.has_basis_weak_bilin`: the seminorm balls of `B.to_seminorm_family` form a
neighborhood basis of `0` in the weak topology.
* `linear_map.to_seminorm_family.with_seminorms`: the topology of a weak space is induced by the
family of seminorm `B.to_seminorm_family`.
* `weak_bilin.locally_convex_space`: a spaced endowed with a weak topology is locally convex.

## References

* [Bourbaki, *Topological Vector Spaces*][bourbaki1987]

## Tags

weak dual, seminorm
-/

variables {ð E F Î¹ : Type*}

open_locale topological_space

section bilin_form

namespace linear_map

variables [normed_field ð] [add_comm_group E] [module ð E] [add_comm_group F] [module ð F]

/-- Construct a seminorm from a linear form `f : E ââ[ð] ð` over a normed field `ð` by
`Î» x, â¥f xâ¥` -/
def to_seminorm (f : E ââ[ð] ð) : seminorm ð E :=
{ to_fun := Î» x, â¥f xâ¥,
  smul' := Î» a x, by simp only [map_smulââ, ring_hom.id_apply, smul_eq_mul, norm_mul],
  triangle' := Î» x x', by { simp only [map_add, add_apply], exact norm_add_le _ _ } }

lemma coe_to_seminorm {f : E ââ[ð] ð} :
  âf.to_seminorm = Î» x, â¥f xâ¥ := rfl

@[simp] lemma to_seminorm_apply {f : E ââ[ð] ð} {x : E} :
  f.to_seminorm x = â¥f xâ¥ := rfl

lemma to_seminorm_ball_zero {f : E ââ[ð] ð} {r : â} :
  seminorm.ball f.to_seminorm 0 r = { x : E | â¥f xâ¥ < r} :=
by simp only [seminorm.ball_zero_eq, to_seminorm_apply]

lemma to_seminorm_comp (f : F ââ[ð] ð) (g : E ââ[ð] F) :
  f.to_seminorm.comp g = (f.comp g).to_seminorm :=
by { ext, simp only [seminorm.comp_apply, to_seminorm_apply, coe_comp] }

/-- Construct a family of seminorms from a bilinear form. -/
def to_seminorm_family (B : E ââ[ð] F ââ[ð] ð) : seminorm_family ð E F :=
Î» y, (B.flip y).to_seminorm

@[simp] lemma to_seminorm_family_apply {B : E ââ[ð] F ââ[ð] ð} {x y} :
  (B.to_seminorm_family y) x = â¥B x yâ¥ := rfl

end linear_map

end bilin_form

section topology

variables [normed_field ð] [add_comm_group E] [module ð E] [add_comm_group F] [module ð F]
variables [nonempty Î¹]
variables {B : E ââ[ð] F ââ[ð] ð}

lemma linear_map.has_basis_weak_bilin (B : E ââ[ð] F ââ[ð] ð) :
  (ð (0 : weak_bilin B)).has_basis B.to_seminorm_family.basis_sets id :=
begin
  let p := B.to_seminorm_family,
  rw [nhds_induced, nhds_pi],
  simp only [map_zero, linear_map.zero_apply],
  have h := @metric.nhds_basis_ball ð _ 0,
  have h' := filter.has_basis_pi (Î» (i : F), h),
  have h'' := filter.has_basis.comap (Î» x y, B x y) h',
  refine h''.to_has_basis _ _,
  { rintros (U : set F Ã (F â â)) hU,
    cases hU with hUâ hUâ,
    simp only [id.def],
    let U' := hUâ.to_finset,
    by_cases hUâ : U.fst.nonempty,
    { have hUâ' : U'.nonempty := (set.finite.to_finset.nonempty hUâ).mpr hUâ,
      let r := U'.inf' hUâ' U.snd,
      have hr : 0 < r :=
      (finset.lt_inf'_iff hUâ' _).mpr (Î» y hy, hUâ y ((set.finite.mem_to_finset hUâ).mp hy)),
      use [seminorm.ball (U'.sup p) (0 : E) r],
      refine â¨p.basis_sets_mem _ hr, Î» x hx y hy, _â©,
      simp only [set.mem_preimage, set.mem_pi, mem_ball_zero_iff],
      rw seminorm.mem_ball_zero at hx,
      rw âlinear_map.to_seminorm_family_apply,
      have hyU' : y â U' := (set.finite.mem_to_finset hUâ).mpr hy,
      have hp : p y â¤ U'.sup p := finset.le_sup hyU',
      refine lt_of_le_of_lt (hp x) (lt_of_lt_of_le hx _),
      exact finset.inf'_le _ hyU' },
    rw set.not_nonempty_iff_eq_empty.mp hUâ,
    simp only [set.empty_pi, set.preimage_univ, set.subset_univ, and_true],
    exact Exists.intro ((p 0).ball 0 1) (p.basis_sets_singleton_mem 0 one_pos) },
  rintros U (hU : U â p.basis_sets),
  rw seminorm_family.basis_sets_iff at hU,
  rcases hU with â¨s, r, hr, hUâ©,
  rw hU,
  refine â¨(s, Î» _, r), â¨by simp only [s.finite_to_set], Î» y hy, hrâ©, Î» x hx, _â©,
  simp only [set.mem_preimage, set.mem_pi, finset.mem_coe, mem_ball_zero_iff] at hx,
  simp only [id.def, seminorm.mem_ball, sub_zero],
  refine seminorm.finset_sup_apply_lt hr (Î» y hy, _),
  rw linear_map.to_seminorm_family_apply,
  exact hx y hy,
end

instance : with_seminorms
  (linear_map.to_seminorm_family B : F â seminorm ð (weak_bilin B)) :=
seminorm_family.with_seminorms_of_has_basis _ B.has_basis_weak_bilin

end topology

section locally_convex

variables [normed_field ð] [add_comm_group E] [module ð E] [add_comm_group F] [module ð F]
variables [nonempty Î¹] [normed_space â ð] [module â E] [is_scalar_tower â ð E]

instance {B : E ââ[ð] F ââ[ð] ð} : locally_convex_space â (weak_bilin B) :=
seminorm_family.to_locally_convex_space B.to_seminorm_family

end locally_convex
