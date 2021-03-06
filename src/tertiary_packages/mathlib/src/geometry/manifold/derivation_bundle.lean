/-
Copyright ยฉ 2020 Nicolรฒ Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolรฒ Cavalleri
-/

import geometry.manifold.algebra.smooth_functions
import ring_theory.derivation

/-!

# Derivation bundle

In this file we define the derivations at a point of a manifold on the algebra of smooth fuctions.
Moreover, we define the differential of a function in terms of derivations.

The content of this file is not meant to be regarded as an alternative definition to the current
tangent bundle but rather as a purely algebraic theory that provides a purely algebraic definition
of the Lie algebra for a Lie group.

-/

variables (๐ : Type*) [nondiscrete_normed_field ๐]
{E : Type*} [normed_group E] [normed_space ๐ E]
{H : Type*} [topological_space H] (I : model_with_corners ๐ E H)
(M : Type*) [topological_space M] [charted_space H M] (n : with_top โ)

open_locale manifold

-- the following two instances prevent poorly understood type class inference timeout problems
instance smooth_functions_algebra : algebra ๐ C^โโฎI, M; ๐โฏ := by apply_instance
instance smooth_functions_tower : is_scalar_tower ๐ C^โโฎI, M; ๐โฏ C^โโฎI, M; ๐โฏ := by apply_instance

/-- Type synonym, introduced to put a different `has_scalar` action on `C^nโฎI, M; ๐โฏ`
which is defined as `f โข r = f(x) * r`. -/
@[nolint unused_arguments] def pointed_smooth_map (x : M) := C^nโฎI, M; ๐โฏ

localized "notation `C^` n `โฎ` I `,` M `;` ๐ `โฏโจ` x `โฉ` :=
  pointed_smooth_map ๐ I M n x" in derivation

variables {๐ M}

namespace pointed_smooth_map

instance {x : M} : has_coe_to_fun C^โโฎI, M; ๐โฏโจxโฉ (ฮป _, M โ ๐) :=
cont_mdiff_map.has_coe_to_fun
instance {x : M} : comm_ring C^โโฎI, M; ๐โฏโจxโฉ := smooth_map.comm_ring
instance {x : M} : algebra ๐ C^โโฎI, M; ๐โฏโจxโฉ := smooth_map.algebra
instance {x : M} : inhabited C^โโฎI, M; ๐โฏโจxโฉ := โจ0โฉ
instance {x : M} : algebra C^โโฎI, M; ๐โฏโจxโฉ C^โโฎI, M; ๐โฏ := algebra.id C^โโฎI, M; ๐โฏ
instance {x : M} : is_scalar_tower ๐ C^โโฎI, M; ๐โฏโจxโฉ C^โโฎI, M; ๐โฏ := is_scalar_tower.right

variable {I}

/-- `smooth_map.eval_ring_hom` gives rise to an algebra structure of `C^โโฎI, M; ๐โฏ` on `๐`. -/
instance eval_algebra {x : M} : algebra C^โโฎI, M; ๐โฏโจxโฉ ๐ :=
(smooth_map.eval_ring_hom x : C^โโฎI, M; ๐โฏโจxโฉ โ+* ๐).to_algebra

/-- With the `eval_algebra` algebra structure evaluation is actually an algebra morphism. -/
def eval (x : M) : C^โโฎI, M; ๐โฏ โโ[C^โโฎI, M; ๐โฏโจxโฉ] ๐ :=
algebra.of_id C^โโฎI, M; ๐โฏโจxโฉ ๐

lemma smul_def (x : M) (f : C^โโฎI, M; ๐โฏโจxโฉ) (k : ๐) : f โข k = f x * k := rfl

instance (x : M) : is_scalar_tower ๐ C^โโฎI, M; ๐โฏโจxโฉ ๐ :=
{ smul_assoc := ฮป k f h, by { simp only [smul_def, algebra.id.smul_eq_mul, smooth_map.coe_smul,
  pi.smul_apply, mul_assoc]} }

end pointed_smooth_map

open_locale derivation

/-- The derivations at a point of a manifold. Some regard this as a possible definition of the
tangent space -/
@[reducible] def point_derivation (x : M) := derivation ๐ (C^โโฎI, M; ๐โฏโจxโฉ) ๐

section

variables (I) {M} (X Y : derivation ๐ C^โโฎI, M; ๐โฏ C^โโฎI, M; ๐โฏ) (f g : C^โโฎI, M; ๐โฏ) (r : ๐)

/-- Evaluation at a point gives rise to a `C^โโฎI, M; ๐โฏ`-linear map between `C^โโฎI, M; ๐โฏ` and `๐`.
 -/
def smooth_function.eval_at (x : M) : C^โโฎI, M; ๐โฏ โโ[C^โโฎI, M; ๐โฏโจxโฉ] ๐ :=
(pointed_smooth_map.eval x).to_linear_map

namespace derivation

variable {I}

/-- The evaluation at a point as a linear map. -/
def eval_at (x : M) : (derivation ๐ C^โโฎI, M; ๐โฏ C^โโฎI, M; ๐โฏ) โโ[๐] point_derivation I x :=
(smooth_function.eval_at I x).comp_der

lemma eval_at_apply (x : M) : eval_at x X f = (X f) x := rfl

end derivation

variables {I} {E' : Type*} [normed_group E'] [normed_space ๐ E']
{H' : Type*} [topological_space H'] {I' : model_with_corners ๐ E' H'}
{M' : Type*} [topological_space M'] [charted_space H' M']

/-- The heterogeneous differential as a linear map. Instead of taking a function as an argument this
differential takes `h : f x = y`. It is particularly handy to deal with situations where the points
on where it has to be evaluated are equal but not definitionally equal. -/
def hfdifferential {f : C^โโฎI, M; I', M'โฏ} {x : M} {y : M'} (h : f x = y) :
  point_derivation I x โโ[๐] point_derivation I' y :=
{ to_fun := ฮป v, derivation.mk'
    { to_fun := ฮป g, v (g.comp f),
      map_add' := ฮป g g', by rw [smooth_map.add_comp, derivation.map_add],
      map_smul' := ฮป k g,
        by simp only [smooth_map.smul_comp, derivation.map_smul, ring_hom.id_apply], }
    (ฮป g g', by simp only [derivation.leibniz, smooth_map.mul_comp, linear_map.coe_mk,
      pointed_smooth_map.smul_def, cont_mdiff_map.comp_apply, h]),
  map_smul' := ฮป k v, rfl,
  map_add' := ฮป v w, rfl }

/-- The homogeneous differential as a linear map. -/
def fdifferential (f : C^โโฎI, M; I', M'โฏ) (x : M) :
  point_derivation I x โโ[๐] point_derivation I' (f x) :=
hfdifferential (rfl : f x = f x)

/- Standard notation for the differential. The abbreviation is `MId`. -/
localized "notation `๐` := fdifferential" in manifold

/- Standard notation for the differential. The abbreviation is `MId`. -/
localized "notation `๐โ` := hfdifferential" in manifold

@[simp] lemma apply_fdifferential (f : C^โโฎI, M; I', M'โฏ) {x : M} (v : point_derivation I x)
  (g : C^โโฎI', M'; ๐โฏ) : ๐f x v g = v (g.comp f) := rfl

@[simp] lemma apply_hfdifferential {f : C^โโฎI, M; I', M'โฏ} {x : M} {y : M'} (h : f x = y)
  (v : point_derivation I x) (g : C^โโฎI', M'; ๐โฏ) : ๐โh v g = ๐f x v g := rfl

variables {E'' : Type*} [normed_group E''] [normed_space ๐ E'']
{H'' : Type*} [topological_space H''] {I'' : model_with_corners ๐ E'' H''}
{M'' : Type*} [topological_space M''] [charted_space H'' M'']

@[simp] lemma fdifferential_comp (g : C^โโฎI', M'; I'', M''โฏ) (f : C^โโฎI, M; I', M'โฏ) (x : M) :
  ๐(g.comp f) x = (๐g (f x)).comp (๐f x) := rfl

end
