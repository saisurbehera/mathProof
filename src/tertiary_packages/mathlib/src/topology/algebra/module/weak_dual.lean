/-
Copyright (c) 2021 Kalle KytΓΆlΓ€. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kalle KytΓΆlΓ€, Moritz Doll
-/
import topology.algebra.module.basic

/-!
# Weak dual topology

This file defines the weak topology given two vector spaces `E` and `F` over a commutative semiring
`π` and a bilinear form `B : E ββ[π] F ββ[π] π`. The weak topology on `E` is the coarest topology
such that for all `y : F` every map `Ξ» x, B x y` is continuous.

In the case that `F = E βL[π] π` and `B` being the canonical pairing, we obtain the weak-* topology,
`weak_dual π E := (E βL[π] π)`. Interchanging the arguments in the bilinear form yields the
weak topology `weak_space π E := E`.

## Main definitions

The main definitions are the types `weak_bilin B` for the general case and the two special cases
`weak_dual π E` and `weak_space π E` with the respective topology instances on it.

* Given `B : E ββ[π] F ββ[π] π`, the type `weak_bilin B` is a type synonym for `E`.
* The instance `weak_bilin.topological_space` is the weak topology induced by the bilinear form `B`.
* `weak_dual π E` is a type synonym for `dual π E` (when the latter is defined): both are equal to
  the type `E βL[π] π` of continuous linear maps from a module `E` over `π` to the ring `π`.
* The instance `weak_dual.topological_space` is the weak-* topology on `weak_dual π E`, i.e., the
  coarsest topology making the evaluation maps at all `z : E` continuous.
* `weak_space π E` is a type synonym for `E` (when the latter is defined).
* The instance `weak_dual.topological_space` is the weak topology on `E`, i.e., the
  coarsest topology such that all `v : dual π E` remain continuous.

## Main results

We establish that `weak_bilin B` has the following structure:
* `weak_bilin.has_continuous_add`: The addition in `weak_bilin B` is continuous.
* `weak_bilin.has_continuous_smul`: The scalar multiplication in `weak_bilin B` is continuous.

We prove the following results characterizing the weak topology:
* `eval_continuous`: For any `y : F`, the evaluation mapping `Ξ» x, B x y` is continuous.
* `continuous_of_continuous_eval`: For a mapping to `weak_bilin B` to be continuous,
  it suffices that its compositions with pairing with `B` at all points `y : F` is continuous.
* `tendsto_iff_forall_eval_tendsto`: Convergence in `weak_bilin B` can be characterized
  in terms of convergence of the evaluations at all points `y : F`.

## Notations

No new notation is introduced.

## References

* [H. H. Schaefer, *Topological Vector Spaces*][schaefer1966]

## Tags

weak-star, weak dual, duality

-/

noncomputable theory
open filter
open_locale topological_space

variables {Ξ± π π R E F M : Type*}

section weak_topology

/-- The space `E` equipped with the weak topology induced by the bilinear form `B`. -/
@[derive [add_comm_monoid, module π],
nolint has_inhabited_instance unused_arguments]
def weak_bilin [comm_semiring π] [add_comm_monoid E] [module π E] [add_comm_monoid F]
  [module π F] (B : E ββ[π] F ββ[π] π) := E

instance [comm_semiring π] [a : add_comm_group E] [module π E] [add_comm_monoid F]
  [module π F] (B : E ββ[π] F ββ[π] π) : add_comm_group (weak_bilin B) := a

@[priority 100]
instance module_weak_bilin [comm_semiring π] [comm_semiring π] [add_comm_group E] [module π E]
  [add_comm_group F] [module π F] [m : module π E] (B : E ββ[π] F ββ[π] π) :
  module π (weak_bilin B) := m

instance scalar_tower_weak_bilin [comm_semiring π] [comm_semiring π] [add_comm_group E] [module π E]
  [add_comm_group F] [module π F] [has_scalar π π] [module π E] [s : is_scalar_tower π π E]
  (B : E ββ[π] F ββ[π] π) : is_scalar_tower π π (weak_bilin B) := s

section semiring

variables [topological_space π] [comm_semiring π]
variables [add_comm_monoid E] [module π E]
variables [add_comm_monoid F] [module π F]
variables (B : E ββ[π] F ββ[π] π)

instance : topological_space (weak_bilin B) :=
topological_space.induced (Ξ» x y, B x y) Pi.topological_space

lemma coe_fn_continuous : continuous (Ξ» (x : weak_bilin B) y, B x y) :=
continuous_induced_dom

lemma eval_continuous (y : F) : continuous (Ξ» x : weak_bilin B, B x y) :=
( continuous_pi_iff.mp (coe_fn_continuous B)) y

lemma continuous_of_continuous_eval [topological_space Ξ±] {g : Ξ± β weak_bilin B}
  (h : β y, continuous (Ξ» a, B (g a) y)) : continuous g :=
continuous_induced_rng (continuous_pi_iff.mpr h)

/-- The coercion `(Ξ» x y, B x y) : E β (F β π)` is an embedding. -/
lemma bilin_embedding {B : E ββ[π] F ββ[π] π} (hB : function.injective B) :
  embedding (Ξ» (x : weak_bilin B)  y, B x y) :=
function.injective.embedding_induced $ linear_map.coe_injective.comp hB

theorem tendsto_iff_forall_eval_tendsto {l : filter Ξ±} {f : Ξ± β (weak_bilin B)} {x : weak_bilin B}
  (hB : function.injective B) : tendsto f l (π x) β β y, tendsto (Ξ» i, B (f i) y) l (π (B x y)) :=
by rw [β tendsto_pi_nhds, embedding.tendsto_nhds_iff (bilin_embedding hB)]

/-- Addition in `weak_space B` is continuous. -/
instance [has_continuous_add π] : has_continuous_add (weak_bilin B) :=
begin
  refine β¨continuous_induced_rng _β©,
  refine cast (congr_arg _ _) (((coe_fn_continuous B).comp continuous_fst).add
    ((coe_fn_continuous B).comp continuous_snd)),
  ext,
  simp only [function.comp_app, pi.add_apply, map_add, linear_map.add_apply],
end

/-- Scalar multiplication by `π` on `weak_bilin B` is continuous. -/
instance [has_continuous_smul π π] : has_continuous_smul π (weak_bilin B) :=
begin
  refine β¨continuous_induced_rng _β©,
  refine cast (congr_arg _ _) (continuous_fst.smul ((coe_fn_continuous B).comp continuous_snd)),
  ext,
  simp only [function.comp_app, pi.smul_apply, linear_map.map_smulββ, ring_hom.id_apply,
    linear_map.smul_apply],
end

end semiring

section ring

variables [topological_space π] [comm_ring π]
variables [add_comm_group E] [module π E]
variables [add_comm_group F] [module π F]
variables (B : E ββ[π] F ββ[π] π)

/-- `weak_space B` is a `topological_add_group`, meaning that addition and negation are
continuous. -/
instance [has_continuous_add π] : topological_add_group (weak_bilin B) :=
{ to_has_continuous_add := by apply_instance,
  continuous_neg := begin
    refine continuous_induced_rng (continuous_pi_iff.mpr (Ξ» y, _)),
    refine cast (congr_arg _ _) (eval_continuous B (-y)),
    ext,
    simp only [map_neg, function.comp_app, linear_map.neg_apply],
  end }

end ring

end weak_topology

section weak_star_topology

/-- The canonical pairing of a vector space and its topological dual. -/
def top_dual_pairing (π E) [comm_semiring π] [topological_space π] [has_continuous_add π]
  [add_comm_monoid E] [module π E] [topological_space E]
  [has_continuous_const_smul π π] :
  (E βL[π] π) ββ[π] E ββ[π] π := continuous_linear_map.coe_lm π

variables [comm_semiring π] [topological_space π] [has_continuous_add π]
variables [has_continuous_const_smul π π]
variables [add_comm_monoid E] [module π E] [topological_space E]

lemma dual_pairing_apply (v : (E βL[π] π)) (x : E) : top_dual_pairing π E v x = v x := rfl

/-- The weak star topology is the topology coarsest topology on `E βL[π] π` such that all
functionals `Ξ» v, top_dual_pairing π E v x` are continuous. -/
@[derive [add_comm_monoid, module π, topological_space, has_continuous_add]]
def weak_dual (π E) [comm_semiring π] [topological_space π] [has_continuous_add π]
  [has_continuous_const_smul π π] [add_comm_monoid E] [module π E] [topological_space E] :=
weak_bilin (top_dual_pairing π E)

instance : inhabited (weak_dual π E) := continuous_linear_map.inhabited

instance fun_like_weak_dual : fun_like (weak_dual π E) E (Ξ» _, π) :=
by {dunfold weak_dual, dunfold weak_bilin, apply_instance}

/-- If a monoid `M` distributively continuously acts on `π` and this action commutes with
multiplication on `π`, then it acts on `weak_dual π E`. -/
instance (M) [monoid M] [distrib_mul_action M π] [smul_comm_class π M π]
  [has_continuous_const_smul M π] :
  mul_action M (weak_dual π E) :=
continuous_linear_map.mul_action

/-- If a monoid `M` distributively continuously acts on `π` and this action commutes with
multiplication on `π`, then it acts distributively on `weak_dual π E`. -/
instance (M) [monoid M] [distrib_mul_action M π] [smul_comm_class π M π]
  [has_continuous_const_smul M π] :
  distrib_mul_action M (weak_dual π E) :=
continuous_linear_map.distrib_mul_action

/-- If `π` is a topological module over a semiring `R` and scalar multiplication commutes with the
multiplication on `π`, then `weak_dual π E` is a module over `R`. -/
instance weak_dual_module (R) [semiring R] [module R π] [smul_comm_class π R π]
  [has_continuous_const_smul R π] :
  module R (weak_dual π E) :=
continuous_linear_map.module

instance (M) [monoid M] [distrib_mul_action M π] [smul_comm_class π M π]
  [has_continuous_const_smul M π] : has_continuous_const_smul M (weak_dual π E) :=
β¨Ξ» m, continuous_induced_rng $ (coe_fn_continuous (top_dual_pairing π E)).const_smul mβ©

/-- If a monoid `M` distributively continuously acts on `π` and this action commutes with
multiplication on `π`, then it continuously acts on `weak_dual π E`. -/
instance (M) [monoid M] [distrib_mul_action M π] [smul_comm_class π M π]
  [topological_space M] [has_continuous_smul M π] :
  has_continuous_smul M (weak_dual π E) :=
β¨continuous_induced_rng $ continuous_fst.smul ((coe_fn_continuous (top_dual_pairing π E)).comp
  continuous_snd)β©

/-- The weak topology is the topology coarsest topology on `E` such that all
functionals `Ξ» x, top_dual_pairing π E v x` are continuous. -/
@[derive [add_comm_monoid, module π, topological_space, has_continuous_add],
nolint has_inhabited_instance]
def weak_space (π E) [comm_semiring π] [topological_space π] [has_continuous_add π]
  [has_continuous_const_smul π π] [add_comm_monoid E] [module π E] [topological_space E] :=
weak_bilin (top_dual_pairing π E).flip

end weak_star_topology
