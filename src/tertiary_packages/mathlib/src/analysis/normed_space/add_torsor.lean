/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers, Yury Kudryashov
-/
import analysis.normed_space.basic
import analysis.normed.group.add_torsor
import linear_algebra.affine_space.midpoint
import topology.instances.real_vector_space

/-!
# Torsors of normed space actions.

This file contains lemmas about normed additive torsors over normed spaces.
-/

noncomputable theory
open_locale nnreal topological_space
open filter

variables {Ī± V P : Type*} [semi_normed_group V] [pseudo_metric_space P] [normed_add_torsor V P]
variables {W Q : Type*} [normed_group W] [metric_space Q] [normed_add_torsor W Q]

include V

section normed_space

variables {š : Type*} [normed_field š] [normed_space š V]

open affine_map

@[simp] lemma dist_center_homothety (pā pā : P) (c : š) :
  dist pā (homothety pā c pā) = ā„cā„ * dist pā pā :=
by simp [homothety_def, norm_smul, ā dist_eq_norm_vsub, dist_comm]

@[simp] lemma dist_homothety_center (pā pā : P) (c : š) :
  dist (homothety pā c pā) pā = ā„cā„ * dist pā pā :=
by rw [dist_comm, dist_center_homothety]

@[simp] lemma dist_line_map_line_map (pā pā : P) (cā cā : š) :
  dist (line_map pā pā cā) (line_map pā pā cā) = dist cā cā * dist pā pā :=
begin
  rw dist_comm pā pā,
  simp only [line_map_apply, dist_eq_norm_vsub, vadd_vsub_vadd_cancel_right, ā sub_smul, norm_smul,
    vsub_eq_sub],
end

lemma lipschitz_with_line_map (pā pā : P) :
  lipschitz_with (nndist pā pā) (line_map pā pā : š ā P) :=
lipschitz_with.of_dist_le_mul $ Ī» cā cā,
  ((dist_line_map_line_map pā pā cā cā).trans (mul_comm _ _)).le

@[simp] lemma dist_line_map_left (pā pā : P) (c : š) :
  dist (line_map pā pā c) pā = ā„cā„ * dist pā pā :=
by simpa only [line_map_apply_zero, dist_zero_right] using dist_line_map_line_map pā pā c 0

@[simp] lemma dist_left_line_map (pā pā : P) (c : š) :
  dist pā (line_map pā pā c) = ā„cā„ * dist pā pā :=
(dist_comm _ _).trans (dist_line_map_left _ _ _)

@[simp] lemma dist_line_map_right (pā pā : P) (c : š) :
  dist (line_map pā pā c) pā = ā„1 - cā„ * dist pā pā :=
by simpa only [line_map_apply_one, dist_eq_norm'] using dist_line_map_line_map pā pā c 1

@[simp] lemma dist_right_line_map (pā pā : P) (c : š) :
  dist pā (line_map pā pā c) = ā„1 - cā„ * dist pā pā :=
(dist_comm _ _).trans (dist_line_map_right _ _ _)

@[simp] lemma dist_homothety_self (pā pā : P) (c : š) :
  dist (homothety pā c pā) pā = ā„1 - cā„ * dist pā pā :=
by rw [homothety_eq_line_map, dist_line_map_right]

@[simp] lemma dist_self_homothety (pā pā : P) (c : š) :
  dist pā (homothety pā c pā) = ā„1 - cā„ * dist pā pā :=
by rw [dist_comm, dist_homothety_self]

variables [invertible (2:š)]

@[simp] lemma dist_left_midpoint (pā pā : P) :
  dist pā (midpoint š pā pā) = ā„(2:š)ā„ā»Ā¹ * dist pā pā :=
by rw [midpoint, dist_comm, dist_line_map_left, inv_of_eq_inv, ā norm_inv]

@[simp] lemma dist_midpoint_left (pā pā : P) :
  dist (midpoint š pā pā) pā = ā„(2:š)ā„ā»Ā¹ * dist pā pā :=
by rw [dist_comm, dist_left_midpoint]

@[simp] lemma dist_midpoint_right (pā pā : P) :
  dist (midpoint š pā pā) pā = ā„(2:š)ā„ā»Ā¹ * dist pā pā :=
by rw [midpoint_comm, dist_midpoint_left, dist_comm]

@[simp] lemma dist_right_midpoint (pā pā : P) :
  dist pā (midpoint š pā pā) = ā„(2:š)ā„ā»Ā¹ * dist pā pā :=
by rw [dist_comm, dist_midpoint_right]

lemma dist_midpoint_midpoint_le' (pā pā pā pā : P) :
  dist (midpoint š pā pā) (midpoint š pā pā) ā¤ (dist pā pā + dist pā pā) / ā„(2 : š)ā„ :=
begin
  rw [dist_eq_norm_vsub V, dist_eq_norm_vsub V, dist_eq_norm_vsub V, midpoint_vsub_midpoint];
    try { apply_instance },
  rw [midpoint_eq_smul_add, norm_smul, inv_of_eq_inv, norm_inv, ā div_eq_inv_mul],
  exact div_le_div_of_le_of_nonneg (norm_add_le _ _) (norm_nonneg _),
end

end normed_space

variables [normed_space ā V] [normed_space ā W]

lemma dist_midpoint_midpoint_le (pā pā pā pā : V) :
  dist (midpoint ā pā pā) (midpoint ā pā pā) ā¤ (dist pā pā + dist pā pā) / 2 :=
by simpa using dist_midpoint_midpoint_le' pā pā pā pā

include W

/-- A continuous map between two normed affine spaces is an affine map provided that
it sends midpoints to midpoints. -/
def affine_map.of_map_midpoint (f : P ā Q)
  (h : ā x y, f (midpoint ā x y) = midpoint ā (f x) (f y))
  (hfc : continuous f) :
  P āįµ[ā] Q :=
affine_map.mk' f
  ā((add_monoid_hom.of_map_midpoint ā ā
    ((affine_equiv.vadd_const ā (f $ classical.arbitrary P)).symm ā f ā
      (affine_equiv.vadd_const ā (classical.arbitrary P))) (by simp)
      (Ī» x y, by simp [h])).to_real_linear_map $ by apply_rules [continuous.vadd, continuous.vsub,
        continuous_const, hfc.comp, continuous_id])
  (classical.arbitrary P)
  (Ī» p, by simp)
