/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll
-/
import analysis.seminorm
import order.closure

/-!
# Balanced Core and Balanced Hull

## Main definitions

* `balanced_core`: The largest balanced subset of a set `s`.
* `balanced_hull`: The smallest balanced superset of a set `s`.

## Main statements

* `balanced_core_eq_Inter`: Characterization of the balanced core as an intersection over subsets.
* `nhds_basis_closed_balanced`: The closed balanced sets form a basis of the neighborhood filter.

## Implementation details

The balanced core and hull are implemented differently: for the core we take the obvious definition
of the union over all balanced sets that are contained in `s`, whereas for the hull, we take the
union over `r â¢ s`, for `r` the scalars with `â¥râ¥ â¤ 1`. We show that `balanced_hull` has the
defining properties of a hull in `balanced.hull_minimal` and `subset_balanced_hull`.
For the core we need slightly stronger assumptions to obtain a characterization as an intersection,
this is `balanced_core_eq_Inter`.

## References

* [Bourbaki, *Topological Vector Spaces*][bourbaki1987]

## Tags

balanced
-/


open set
open_locale pointwise topological_space filter


variables {ð E Î¹ : Type*}

section balanced_hull

section semi_normed_ring
variables [semi_normed_ring ð]

section has_scalar
variables [has_scalar ð E]

variables (ð)

/-- The largest balanced subset of `s`.-/
def balanced_core (s : set E) := ââ {t : set E | balanced ð t â§ t â s}

/-- Helper definition to prove `balanced_core_eq_Inter`-/
def balanced_core_aux (s : set E) := â (r : ð) (hr : 1 â¤ â¥râ¥), r â¢ s

/-- The smallest balanced superset of `s`.-/
def balanced_hull (s : set E) := â (r : ð) (hr : â¥râ¥ â¤ 1), r â¢ s

variables {ð}

lemma balanced_core_subset (s : set E) : balanced_core ð s â s :=
begin
  refine sUnion_subset (Î» t ht, _),
  simp only [mem_set_of_eq] at ht,
  exact ht.2,
end

lemma balanced_core_emptyset : balanced_core ð (â : set E) = â :=
set.eq_empty_of_subset_empty (balanced_core_subset _)

lemma balanced_core_mem_iff {s : set E} {x : E} : x â balanced_core ð s â
  â t : set E, balanced ð t â§ t â s â§ x â t :=
by simp_rw [balanced_core, mem_sUnion, mem_set_of_eq, exists_prop, and_assoc]

lemma smul_balanced_core_subset (s : set E) {a : ð} (ha : â¥aâ¥ â¤ 1) :
  a â¢ balanced_core ð s â balanced_core ð s :=
begin
  rw subset_def,
  intros x hx,
  rw mem_smul_set at hx,
  rcases hx with â¨y, hy, hxâ©,
  rw balanced_core_mem_iff at hy,
  rcases hy with â¨t, ht1, ht2, hyâ©,
  rw âhx,
  refine â¨t, _, ht1 a ha (smul_mem_smul_set hy)â©,
  rw mem_set_of_eq,
  exact â¨ht1, ht2â©,
end

lemma balanced_core_balanced (s : set E) : balanced ð (balanced_core ð s) :=
Î» _, smul_balanced_core_subset s

/-- The balanced core of `t` is maximal in the sense that it contains any balanced subset
`s` of `t`.-/
lemma balanced.subset_core_of_subset {s t : set E} (hs : balanced ð s) (h : s â t):
  s â balanced_core ð t :=
begin
  refine subset_sUnion_of_mem _,
  rw [mem_set_of_eq],
  exact â¨hs, hâ©,
end

lemma balanced_core_aux_mem_iff (s : set E) (x : E) : x â balanced_core_aux ð s â
  â (r : ð) (hr : 1 â¤ â¥râ¥), x â r â¢ s :=
by rw [balanced_core_aux, set.mem_Interâ]

lemma balanced_hull_mem_iff (s : set E) (x : E) : x â balanced_hull ð s â
  â (r : ð) (hr : â¥râ¥ â¤ 1), x â r â¢ s :=
by rw [balanced_hull, set.mem_Unionâ]

/-- The balanced core of `s` is minimal in the sense that it is contained in any balanced superset
`t` of `s`. -/
lemma balanced.hull_subset_of_subset {s t : set E} (ht : balanced ð t) (h : s â t) :
  balanced_hull ð s â t :=
begin
  intros x hx,
  rcases (balanced_hull_mem_iff _ _).mp hx with â¨r, hr, hxâ©,
  rcases mem_smul_set.mp hx with â¨y, hy, hxâ©,
  rw âhx,
  exact balanced_mem ht (h hy) hr,
end

end has_scalar

section add_comm_monoid

variables [add_comm_monoid E] [module ð E]

lemma balanced_core_nonempty_iff {s : set E} : (balanced_core ð s).nonempty â (0 : E) â s :=
begin
  split; intro h,
  { cases h with x hx,
    have h' : balanced ð (balanced_core ð s) := balanced_core_balanced s,
    have h'' := h' 0 (has_le.le.trans norm_zero.le zero_le_one),
    refine mem_of_subset_of_mem (subset.trans h'' (balanced_core_subset s)) _,
    exact mem_smul_set.mpr â¨x, hx, zero_smul _ _â© },
  refine nonempty_of_mem (mem_of_subset_of_mem _ (mem_singleton 0)),
  exact balanced.subset_core_of_subset zero_singleton_balanced (singleton_subset_iff.mpr h),
end

lemma balanced_core_zero_mem {s : set E} (hs: (0 : E) â s) : (0 : E) â balanced_core ð s :=
balanced_core_mem_iff.mpr
  â¨{0}, zero_singleton_balanced, singleton_subset_iff.mpr hs, mem_singleton 0â©

variables (ð)

lemma subset_balanced_hull [norm_one_class ð] {s : set E} : s â balanced_hull ð s :=
Î» _ hx, (balanced_hull_mem_iff _ _).mpr â¨1, norm_one.le, mem_smul_set.mp â¨_, hx, one_smul _ _â©â©

variables {ð}

lemma balanced_hull.balanced (s : set E) : balanced ð (balanced_hull ð s) :=
begin
  intros a ha,
  simp_rw [balanced_hull, smul_set_Unionâ, subset_def, mem_Unionâ],
  intros x hx,
  rcases hx with â¨r, hr, hxâ©,
  use [a â¢ r],
  split,
  { rw smul_eq_mul,
    refine has_le.le.trans (semi_normed_ring.norm_mul _ _) _,
    refine mul_le_one ha (norm_nonneg r) hr },
  rw smul_assoc,
  exact hx,
end

end add_comm_monoid

end semi_normed_ring

section normed_field

variables [normed_field ð] [add_comm_group E] [module ð E]

@[simp] lemma balanced_core_aux_empty : balanced_core_aux ð (â : set E) = â :=
begin
  rw [balanced_core_aux, set.Interâ_eq_empty_iff],
  intros _,
  simp only [smul_set_empty, mem_empty_eq, not_false_iff, exists_prop, and_true],
  exact â¨1, norm_one.geâ©,
end

lemma balanced_core_aux_subset (s : set E) : balanced_core_aux ð s â s :=
begin
  rw subset_def,
  intros x hx,
  rw balanced_core_aux_mem_iff at hx,
  have h := hx 1 norm_one.ge,
  rw one_smul at h,
  exact h,
end

lemma balanced_core_aux_balanced {s : set E} (h0 : (0 : E) â balanced_core_aux ð s):
  balanced ð (balanced_core_aux ð s) :=
begin
  intros a ha x hx,
  rcases mem_smul_set.mp hx with â¨y, hy, hxâ©,
  by_cases (a = 0),
  { simp[h] at hx,
    rw âhx,
    exact h0 },
  rw [âhx, balanced_core_aux_mem_iff],
  rw balanced_core_aux_mem_iff at hy,
  intros r hr,
  have h'' : 1 â¤ â¥aâ»Â¹ â¢ râ¥ :=
  begin
    rw smul_eq_mul,
    simp only [norm_mul, norm_inv],
    exact one_le_mul_of_one_le_of_one_le (one_le_inv (norm_pos_iff.mpr h) ha) hr,
  end,
  have h' := hy (aâ»Â¹ â¢ r) h'',
  rw smul_assoc at h',
  exact (mem_inv_smul_set_iffâ h _ _).mp h',
end

lemma balanced_core_aux_maximal {s t : set E} (h : t â s) (ht : balanced ð t) :
  t â balanced_core_aux ð s :=
begin
  intros x hx,
  rw balanced_core_aux_mem_iff,
  intros r hr,
  rw mem_smul_set_iff_inv_smul_memâ (norm_pos_iff.mp (lt_of_lt_of_le zero_lt_one hr)),
  refine h (balanced_mem ht hx _),
  rw norm_inv,
  exact inv_le_one hr,
end

lemma balanced_core_subset_balanced_core_aux {s : set E} :
  balanced_core ð s â balanced_core_aux ð s :=
balanced_core_aux_maximal (balanced_core_subset s) (balanced_core_balanced s)

lemma balanced_core_eq_Inter {s : set E} (hs : (0 : E) â s) :
  balanced_core ð s = â (r : ð) (hr : 1 â¤ â¥râ¥), r â¢ s :=
begin
  rw âbalanced_core_aux,
  refine subset_antisymm balanced_core_subset_balanced_core_aux _,
  refine balanced.subset_core_of_subset (balanced_core_aux_balanced _) (balanced_core_aux_subset s),
  refine mem_of_subset_of_mem balanced_core_subset_balanced_core_aux (balanced_core_zero_mem hs),
end

lemma subset_balanced_core {U V : set E} (hV' : (0 : E) â V)
  (hUV : â (a : ð) (ha : â¥aâ¥ â¤ 1), a â¢ U â V) :
  U â balanced_core ð V :=
begin
  rw balanced_core_eq_Inter hV',
  refine set.subset_Interâ (Î» a ha, _),
  rw [âone_smul ð U, âmul_inv_cancel (norm_pos_iff.mp (lt_of_lt_of_le zero_lt_one ha)),
    âsmul_eq_mul, smul_assoc],
  refine set.smul_set_mono (hUV aâ»Â¹ _),
  rw [norm_inv],
  exact inv_le_one ha,
end

end normed_field

end balanced_hull

/-! ### Topological properties -/

section topology

variables [nondiscrete_normed_field ð] [add_comm_group E] [module ð E] [topological_space E]
  [has_continuous_smul ð E]

lemma balanced_core_is_closed {U : set E} (hU : is_closed U) : is_closed (balanced_core ð U) :=
begin
  by_cases h : (0 : E) â U,
  { rw balanced_core_eq_Inter h,
    refine is_closed_Inter (Î» a, _),
    refine is_closed_Inter (Î» ha, _),
    have ha' := lt_of_lt_of_le zero_lt_one ha,
    rw norm_pos_iff at ha',
    refine is_closed_map_smul_of_ne_zero ha' U hU },
  convert is_closed_empty,
  contrapose! h,
  exact balanced_core_nonempty_iff.mp (set.ne_empty_iff_nonempty.mp h),
end

lemma balanced_core_mem_nhds_zero {U : set E} (hU : U â ð (0 : E)) :
  balanced_core ð U â ð (0 : E) :=
begin
  -- Getting neighborhoods of the origin for `0 : ð` and `0 : E`
  have h : filter.tendsto (Î» (x : ð Ã E), x.fst â¢ x.snd) (ð (0,0)) (ð ((0 : ð) â¢ (0 : E))) :=
  continuous_iff_continuous_at.mp has_continuous_smul.continuous_smul (0, 0),
  rw [smul_zero] at h,
  have h' := filter.has_basis.prod (@metric.nhds_basis_ball ð _ 0) (filter.basis_sets (ð (0 : E))),
  simp_rw [ânhds_prod_eq, id.def] at h',
  have h'' := filter.tendsto.basis_left h h' U hU,
  rcases h'' with â¨x, hx, h''â©,
  cases normed_field.exists_norm_lt ð hx.left with y hy,
  have hy' : y â  0 := norm_pos_iff.mp hy.1,
  let W := y â¢ x.snd,
  rw âfilter.exists_mem_subset_iff,
  refine â¨W, (set_smul_mem_nhds_zero_iff hy').mpr hx.2, _â©,
  -- It remains to show that `W â balanced_core ð U`
  refine subset_balanced_core (mem_of_mem_nhds hU) (Î» a ha, _),
  refine set.subset.trans (Î» z hz, _) (set.maps_to'.mp h''),
  rw [set.image_prod, set.image2_smul],
  rw set.mem_smul_set at hz,
  rcases hz with â¨z', hz', hzâ©,
  rw [âhz, set.mem_smul],
  refine â¨a â¢ y, yâ»Â¹ â¢ z', _, _, _â©,
  { rw [algebra.id.smul_eq_mul, mem_ball_zero_iff, norm_mul, âone_mul x.fst],
    exact mul_lt_mul' ha hy.2 hy.1.le zero_lt_one },
  { convert set.smul_mem_smul_set hz',
    rw [âsmul_assoc yâ»Â¹ y x.snd, smul_eq_mul, inv_mul_cancel hy', one_smul] },
  rw [smul_assoc, âsmul_assoc y yâ»Â¹ z', smul_eq_mul, mul_inv_cancel hy', one_smul],
end

variables (ð)

lemma nhds_basis_closed_balanced [regular_space E] : (ð (0 : E)).has_basis
  (Î» (s : set E), s â ð (0 : E) â§ is_closed s â§ balanced ð s) id :=
begin
  refine (closed_nhds_basis 0).to_has_basis (Î» s hs, _) (Î» s hs, â¨s, â¨hs.1, hs.2.1â©, rfl.subsetâ©),
  refine â¨balanced_core ð s, â¨balanced_core_mem_nhds_zero hs.1, _â©, balanced_core_subset sâ©,
  refine â¨balanced_core_is_closed hs.2, balanced_core_balanced sâ©
end

end topology
