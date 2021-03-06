/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel, Scott Morrison
-/
import algebra.group.ext
import category_theory.simple
import category_theory.linear
import category_theory.endomorphism
import algebra.algebra.spectrum

/-!
# Schur's lemma
We first prove the part of Schur's Lemma that holds in any preadditive category with kernels,
that any nonzero morphism between simple objects
is an isomorphism.

Second, we prove Schur's lemma for `π`-linear categories with finite dimensional hom spaces,
over an algebraically closed field `π`:
the hom space `X βΆ Y` between simple objects `X` and `Y` is at most one dimensional,
and is 1-dimensional iff `X` and `Y` are isomorphic.

## Future work
It might be nice to provide a `division_ring` instance on `End X` when `X` is simple.
This is an easy consequence of the results here,
but may take some care setting up usable instances.
-/

namespace category_theory

open category_theory.limits

universes v u
variables {C : Type u} [category.{v} C]
variables [preadditive C]

/--
The part of **Schur's lemma** that holds in any preadditive category with kernels:
that a nonzero morphism between simple objects is an isomorphism.
-/
lemma is_iso_of_hom_simple [has_kernels C] {X Y : C} [simple X] [simple Y] {f : X βΆ Y} (w : f β  0) :
  is_iso f :=
begin
  haveI : mono f := preadditive.mono_of_kernel_zero (kernel_zero_of_nonzero_from_simple w),
  exact is_iso_of_mono_of_nonzero w
end

/--
As a corollary of Schur's lemma for preadditive categories,
any morphism between simple objects is (exclusively) either an isomorphism or zero.
-/
lemma is_iso_iff_nonzero [has_kernels C] {X Y : C} [simple.{v} X] [simple.{v} Y] (f : X βΆ Y) :
  is_iso.{v} f β f β  0 :=
β¨Ξ» I,
  begin
    introI h,
    apply id_nonzero X,
    simp only [βis_iso.hom_inv_id f, h, zero_comp],
  end,
  Ξ» w, is_iso_of_hom_simple wβ©

open finite_dimensional

variables (π : Type*) [field π]

/--
Part of **Schur's lemma** for `π`-linear categories:
the hom space between two non-isomorphic simple objects is 0-dimensional.
-/
lemma finrank_hom_simple_simple_eq_zero_of_not_iso
  [has_kernels C] [linear π C] {X Y : C} [simple.{v} X] [simple.{v} Y]
  (h : (X β Y) β false):
  finrank π (X βΆ Y) = 0 :=
begin
  haveI := subsingleton_of_forall_eq (0 : X βΆ Y) (Ξ» f, begin
    have p := not_congr (is_iso_iff_nonzero f),
    simp only [not_not, ne.def] at p,
    refine p.mp (Ξ» _, by exactI h (as_iso f)),
  end),
  exact finrank_zero_of_subsingleton,
end

variables [is_alg_closed π] [linear π C]

-- In the proof below we have some difficulty using `I : finite_dimensional π (X βΆ X)`
-- where we need a `finite_dimensional π (End X)`.
-- These are definitionally equal, but without eta reduction Lean can't see this.
-- To get around this, we use `convert I`,
-- then check the various instances agree field-by-field,

/--
An auxiliary lemma for Schur's lemma.

If `X βΆ X` is finite dimensional, and every nonzero endomorphism is invertible,
then `X βΆ X` is 1-dimensional.
-/
-- We prove this with the explicit `is_iso_iff_nonzero` assumption,
-- rather than just `[simple X]`, as this form is useful for
-- MΓΌger's formulation of semisimplicity.
lemma finrank_endomorphism_eq_one
  {X : C} (is_iso_iff_nonzero : β f : X βΆ X, is_iso f β f β  0)
  [I : finite_dimensional π (X βΆ X)] :
  finrank π (X βΆ X) = 1 :=
begin
  have id_nonzero := (is_iso_iff_nonzero (π X)).mp (by apply_instance),
  apply finrank_eq_one (π X),
  { exact id_nonzero, },
  { intro f,
    haveI : nontrivial (End X) := nontrivial_of_ne _ _ id_nonzero,
    obtain β¨c, nuβ© := @spectrum.nonempty_of_is_alg_closed_of_finite_dimensional π (End X) _ _ _ _ _
      (by { convert I, ext, refl, ext, refl, }) (End.of f),
    use c,
    rw [spectrum.mem_iff, is_unit.sub_iff, is_unit_iff_is_iso, is_iso_iff_nonzero, ne.def,
      not_not, sub_eq_zero, algebra.algebra_map_eq_smul_one] at nu,
    exact nu.symm, },
end

variables [has_kernels C]

/--
**Schur's lemma** for endomorphisms in `π`-linear categories.
-/
lemma finrank_endomorphism_simple_eq_one
  (X : C) [simple.{v} X] [I : finite_dimensional π (X βΆ X)] :
  finrank π (X βΆ X) = 1 :=
finrank_endomorphism_eq_one π is_iso_iff_nonzero

lemma endomorphism_simple_eq_smul_id
  {X : C} [simple.{v} X] [I : finite_dimensional π (X βΆ X)] (f : X βΆ X) :
  β c : π, c β’ π X = f :=
(finrank_eq_one_iff_of_nonzero' (π X) (id_nonzero X)).mp (finrank_endomorphism_simple_eq_one π X) f

/--
**Schur's lemma** for `π`-linear categories:
if hom spaces are finite dimensional, then the hom space between simples is at most 1-dimensional.

See `finrank_hom_simple_simple_eq_one_iff` and `finrank_hom_simple_simple_eq_zero_iff` below
for the refinements when we know whether or not the simples are isomorphic.
-/
-- We don't really need `[β X Y : C, finite_dimensional π (X βΆ Y)]` here,
-- just at least one of `[finite_dimensional π (X βΆ X)]` or `[finite_dimensional π (Y βΆ Y)]`.
lemma finrank_hom_simple_simple_le_one
  (X Y : C) [β X Y : C, finite_dimensional π (X βΆ Y)] [simple.{v} X] [simple.{v} Y] :
  finrank π (X βΆ Y) β€ 1 :=
begin
  cases subsingleton_or_nontrivial (X βΆ Y) with h,
  { resetI,
    convert zero_le_one,
    exact finrank_zero_of_subsingleton, },
  { obtain β¨f, nzβ© := (nontrivial_iff_exists_ne 0).mp h,
    haveI fi := (is_iso_iff_nonzero f).mpr nz,
    apply finrank_le_one f,
    intro g,
    obtain β¨c, wβ© := endomorphism_simple_eq_smul_id π (g β« inv f),
    exact β¨c, by simpa using w =β« fβ©, },
end

lemma finrank_hom_simple_simple_eq_one_iff
  (X Y : C) [β X Y : C, finite_dimensional π (X βΆ Y)] [simple.{v} X] [simple.{v} Y] :
  finrank π (X βΆ Y) = 1 β nonempty (X β Y) :=
begin
  fsplit,
  { intro h,
    rw finrank_eq_one_iff' at h,
    obtain β¨f, nz, -β© := h,
    rw βis_iso_iff_nonzero at nz,
    exactI β¨as_iso fβ©, },
  { rintro β¨fβ©,
    have le_one := finrank_hom_simple_simple_le_one π X Y,
    have zero_lt : 0 < finrank π (X βΆ Y) :=
      finrank_pos_iff_exists_ne_zero.mpr β¨f.hom, (is_iso_iff_nonzero f.hom).mp infer_instanceβ©,
    linarith, }
end

lemma finrank_hom_simple_simple_eq_zero_iff
  (X Y : C) [β X Y : C, finite_dimensional π (X βΆ Y)] [simple.{v} X] [simple.{v} Y] :
  finrank π (X βΆ Y) = 0 β is_empty (X β Y) :=
begin
  rw [β not_nonempty_iff, β not_congr (finrank_hom_simple_simple_eq_one_iff π X Y)],
  refine β¨Ξ» h, by { rw h, simp, }, Ξ» h, _β©,
  have := finrank_hom_simple_simple_le_one π X Y,
  interval_cases finrank π (X βΆ Y) with h',
  { exact h', },
  { exact false.elim (h h'), },
end

end category_theory
