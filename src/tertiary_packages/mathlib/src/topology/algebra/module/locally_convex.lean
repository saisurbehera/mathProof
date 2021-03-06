/-
Copyright (c) 2022 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker
-/
import analysis.convex.topology
/-!
# Locally convex topological modules

A `locally_convex_space` is a topological semimodule over an ordered semiring in which any point
admits a neighborhood basis made of convex sets, or equivalently, in which convex neighborhoods of
a point form a neighborhood basis at that point.

In a module, this is equivalent to `0` satisfying such properties.

## Main results

- `locally_convex_space_iff_zero` : in a module, local convexity at zero gives
  local convexity everywhere
- `seminorm.locally_convex_space` : a topology generated by a family of seminorms is locally convex
- `normed_space.locally_convex_space` : a normed space is locally convex

## TODO

- define a structure `locally_convex_filter_basis`, extending `module_filter_basis`, for filter
  bases generating a locally convex topology
- show that any locally convex topology is generated by a family of seminorms

-/

open topological_space filter

open_locale topological_space

section semimodule

/-- A `locally_convex_space` is a topological semimodule over an ordered semiring in which convex
neighborhoods of a point form a neighborhood basis at that point. -/
class locally_convex_space (ğ E : Type*) [ordered_semiring ğ] [add_comm_monoid E] [module ğ E]
  [topological_space E] : Prop :=
(convex_basis : â x : E, (ğ x).has_basis (Î» (s : set E), s â ğ x â§ convex ğ s) id)

variables (ğ E : Type*) [ordered_semiring ğ] [add_comm_monoid E] [module ğ E] [topological_space E]

lemma locally_convex_space_iff :
  locally_convex_space ğ E â
  â x : E, (ğ x).has_basis (Î» (s : set E), s â ğ x â§ convex ğ s) id :=
â¨@locally_convex_space.convex_basis _ _ _ _ _ _, locally_convex_space.mkâ©

lemma locally_convex_space.of_bases {Î¹ : Type*} (b : E â Î¹ â set E) (p : Î¹ â Prop)
  (hbasis : â x : E, (ğ x).has_basis p (b x)) (hconvex : â x i, p i â convex ğ (b x i)) :
  locally_convex_space ğ E :=
â¨Î» x, (hbasis x).to_has_basis
  (Î» i hi, â¨b x i, â¨â¨(hbasis x).mem_of_mem hi, hconvex x i hiâ©, le_refl (b x i)â©â©)
  (Î» s hs, â¨(hbasis x).index s hs.1,
    â¨(hbasis x).property_index hs.1, (hbasis x).set_index_subset hs.1â©â©)â©

lemma locally_convex_space.convex_basis_zero [locally_convex_space ğ E] :
  (ğ 0 : filter E).has_basis (Î» s, s â (ğ 0 : filter E) â§ convex ğ s) id :=
locally_convex_space.convex_basis 0

lemma locally_convex_space_iff_exists_convex_subset :
  locally_convex_space ğ E â â x : E, â U â ğ x, â S â ğ x, convex ğ S â§ S â U :=
(locally_convex_space_iff ğ E).trans (forall_congr $ Î» x, has_basis_self)

end semimodule

section module

variables (ğ E : Type*) [ordered_semiring ğ] [add_comm_group E] [module ğ E] [topological_space E]
  [topological_add_group E]

lemma locally_convex_space.of_basis_zero {Î¹ : Type*} (b : Î¹ â set E) (p : Î¹ â Prop)
  (hbasis : (ğ 0).has_basis p b) (hconvex : â i, p i â convex ğ (b i)) :
  locally_convex_space ğ E :=
begin
  refine locally_convex_space.of_bases ğ E (Î» (x : E) (i : Î¹), ((+) x) '' b i) p (Î» x, _)
    (Î» x i hi, (hconvex i hi).translate x),
  rw â map_add_left_nhds_zero,
  exact hbasis.map _
end

lemma locally_convex_space_iff_zero :
  locally_convex_space ğ E â
  (ğ 0 : filter E).has_basis (Î» (s : set E), s â (ğ 0 : filter E) â§ convex ğ s) id :=
â¨Î» h, @locally_convex_space.convex_basis _ _ _ _ _ _ h 0,
 Î» h, locally_convex_space.of_basis_zero ğ E _ _ h (Î» s, and.right)â©

lemma locally_convex_space_iff_exists_convex_subset_zero :
  locally_convex_space ğ E â
  â U â (ğ 0 : filter E), â S â (ğ 0 : filter E), convex ğ S â§ S â U :=
(locally_convex_space_iff_zero ğ E).trans has_basis_self

end module
