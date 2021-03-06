/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll, Anatole Dedecker
-/

import analysis.seminorm
import analysis.locally_convex.bounded

/-!
# Topology induced by a family of seminorms

## Main definitions

* `seminorm_family.basis_sets`: The set of open seminorm balls for a family of seminorms.
* `seminorm_family.module_filter_basis`: A module filter basis formed by the open balls.
* `seminorm.is_bounded`: A linear map `f : E ââ[ð] F` is bounded iff every seminorm in `F` can be
bounded by a finite number of seminorms in `E`.

## Main statements

* `continuous_from_bounded`: A bounded linear map `f : E ââ[ð] F` is continuous.
* `seminorm_family.to_locally_convex_space`: A space equipped with a family of seminorms is locally
convex.

## TODO

Show that for any locally convex space there exist seminorms that induce the topology.

## Tags

seminorm, locally convex
-/

open normed_field set seminorm
open_locale big_operators nnreal pointwise topological_space

variables {ð E F G Î¹ Î¹' : Type*}

section filter_basis

variables [normed_field ð] [add_comm_group E] [module ð E]

variables (ð E Î¹)

/-- An abbreviation for indexed families of seminorms. This is mainly to allow for dot-notation. -/
abbreviation seminorm_family := Î¹ â seminorm ð E

variables {ð E Î¹}

namespace seminorm_family

/-- The sets of a filter basis for the neighborhood filter of 0. -/
def basis_sets (p : seminorm_family ð E Î¹) : set (set E) :=
â (s : finset Î¹) r (hr : 0 < r), singleton $ ball (s.sup p) (0 : E) r

variables (p : seminorm_family ð E Î¹)

lemma basis_sets_iff {U : set E} :
  U â p.basis_sets â â (i : finset Î¹) r (hr : 0 < r), U = ball (i.sup p) 0 r :=
by simp only [basis_sets, mem_Union, mem_singleton_iff]

lemma basis_sets_mem (i : finset Î¹) {r : â} (hr : 0 < r) :
  (i.sup p).ball 0 r â p.basis_sets :=
(basis_sets_iff _).mpr â¨i,_,hr,rflâ©

lemma basis_sets_singleton_mem (i : Î¹) {r : â} (hr : 0 < r) :
  (p i).ball 0 r â p.basis_sets :=
(basis_sets_iff _).mpr â¨{i},_,hr, by rw finset.sup_singletonâ©

lemma basis_sets_nonempty [nonempty Î¹] : p.basis_sets.nonempty :=
begin
  let i := classical.arbitrary Î¹,
  refine set.nonempty_def.mpr â¨(p i).ball 0 1, _â©,
  exact p.basis_sets_singleton_mem i zero_lt_one,
end

lemma basis_sets_intersect
  (U V : set E) (hU : U â p.basis_sets) (hV : V â p.basis_sets) :
  â (z : set E) (H : z â p.basis_sets), z â U â© V :=
begin
  classical,
  rcases p.basis_sets_iff.mp hU with â¨s, râ, hrâ, hUâ©,
  rcases p.basis_sets_iff.mp hV with â¨t, râ, hrâ, hVâ©,
  use ((s âª t).sup p).ball 0 (min râ râ),
  refine â¨p.basis_sets_mem (s âª t) (lt_min_iff.mpr â¨hrâ, hrââ©), _â©,
  rw [hU, hV, ball_finset_sup_eq_Inter _ _ _ (lt_min_iff.mpr â¨hrâ, hrââ©),
    ball_finset_sup_eq_Inter _ _ _ hrâ, ball_finset_sup_eq_Inter _ _ _ hrâ],
  exact set.subset_inter
    (set.Interâ_mono' $ Î» i hi, â¨i, finset.subset_union_left _ _ hi, ball_mono $ min_le_left _ _â©)
    (set.Interâ_mono' $ Î» i hi, â¨i, finset.subset_union_right _ _ hi, ball_mono $
    min_le_right _ _â©),
end

lemma basis_sets_zero (U) (hU : U â p.basis_sets) :
  (0 : E) â U :=
begin
  rcases p.basis_sets_iff.mp hU with â¨Î¹', r, hr, hUâ©,
  rw [hU, mem_ball_zero, (Î¹'.sup p).zero],
  exact hr,
end

lemma basis_sets_add (U) (hU : U â p.basis_sets) :
  â (V : set E) (H : V â p.basis_sets), V + V â U :=
begin
  rcases p.basis_sets_iff.mp hU with â¨s, r, hr, hUâ©,
  use (s.sup p).ball 0 (r/2),
  refine â¨p.basis_sets_mem s (div_pos hr zero_lt_two), _â©,
  refine set.subset.trans (ball_add_ball_subset (s.sup p) (r/2) (r/2) 0 0) _,
  rw [hU, add_zero, add_halves'],
end

lemma basis_sets_neg (U) (hU' : U â p.basis_sets) :
  â (V : set E) (H : V â p.basis_sets), V â (Î» (x : E), -x) â»Â¹' U :=
begin
  rcases p.basis_sets_iff.mp hU' with â¨s, r, hr, hUâ©,
  rw [hU, neg_preimage, neg_ball (s.sup p), neg_zero],
  exact â¨U, hU', eq.subset hUâ©,
end

/-- The `add_group_filter_basis` induced by the filter basis `seminorm_basis_zero`. -/
protected def add_group_filter_basis [nonempty Î¹] : add_group_filter_basis E :=
add_group_filter_basis_of_comm p.basis_sets p.basis_sets_nonempty
  p.basis_sets_intersect p.basis_sets_zero p.basis_sets_add p.basis_sets_neg

lemma basis_sets_smul_right (v : E) (U : set E)
  (hU : U â p.basis_sets) : âá¶  (x : ð) in ð 0, x â¢ v â U :=
begin
  rcases p.basis_sets_iff.mp hU with â¨s, r, hr, hUâ©,
  rw [hU, filter.eventually_iff],
  simp_rw [(s.sup p).mem_ball_zero, (s.sup p).smul],
  by_cases h : 0 < (s.sup p) v,
  { simp_rw (lt_div_iff h).symm,
    rw â_root_.ball_zero_eq,
    exact metric.ball_mem_nhds 0 (div_pos hr h) },
  simp_rw [le_antisymm (not_lt.mp h) ((s.sup p).nonneg v), mul_zero, hr],
  exact is_open.mem_nhds is_open_univ (mem_univ 0),
end

variables [nonempty Î¹]

lemma basis_sets_smul (U) (hU : U â p.basis_sets) :
  â (V : set ð) (H : V â ð (0 : ð)) (W : set E)
  (H : W â p.add_group_filter_basis.sets), V â¢ W â U :=
begin
  rcases p.basis_sets_iff.mp hU with â¨s, r, hr, hUâ©,
  refine â¨metric.ball 0 r.sqrt, metric.ball_mem_nhds 0 (real.sqrt_pos.mpr hr), _â©,
  refine â¨(s.sup p).ball 0 r.sqrt, p.basis_sets_mem s (real.sqrt_pos.mpr hr), _â©,
  refine set.subset.trans (ball_smul_ball (s.sup p) r.sqrt r.sqrt) _,
  rw [hU, real.mul_self_sqrt (le_of_lt hr)],
end

lemma basis_sets_smul_left (x : ð) (U : set E)
  (hU : U â p.basis_sets) : â (V : set E)
  (H : V â p.add_group_filter_basis.sets), V â (Î» (y : E), x â¢ y) â»Â¹' U :=
begin
  rcases p.basis_sets_iff.mp hU with â¨s, r, hr, hUâ©,
  rw hU,
  by_cases h : x â  0,
  { rw [(s.sup p).smul_ball_preimage 0 r x h, smul_zero],
    use (s.sup p).ball 0 (r / â¥xâ¥),
    exact â¨p.basis_sets_mem s (div_pos hr (norm_pos_iff.mpr h)), subset.rflâ© },
  refine â¨(s.sup p).ball 0 r, p.basis_sets_mem s hr, _â©,
  simp only [not_ne_iff.mp h, subset_def, mem_ball_zero, hr, mem_univ, seminorm.zero,
    implies_true_iff, preimage_const_of_mem, zero_smul],
end

/-- The `module_filter_basis` induced by the filter basis `seminorm_basis_zero`. -/
protected def module_filter_basis : module_filter_basis ð E :=
{ to_add_group_filter_basis := p.add_group_filter_basis,
  smul' := p.basis_sets_smul,
  smul_left' := p.basis_sets_smul_left,
  smul_right' := p.basis_sets_smul_right }

end seminorm_family

end filter_basis

section bounded

namespace seminorm

variables [normed_field ð] [add_comm_group E] [module ð E] [add_comm_group F] [module ð F]

-- Todo: This should be phrased entirely in terms of the von Neumann bornology.

/-- The proposition that a linear map is bounded between spaces with families of seminorms. -/
def is_bounded (p : Î¹ â seminorm ð E) (q : Î¹' â seminorm ð F) (f : E ââ[ð] F) : Prop :=
  â i, â s : finset Î¹, â C : ââ¥0, C â  0 â§ (q i).comp f â¤ C â¢ s.sup p

lemma is_bounded_const (Î¹' : Type*) [nonempty Î¹']
  {p : Î¹ â seminorm ð E} {q : seminorm ð F} (f : E ââ[ð] F) :
  is_bounded p (Î» _ : Î¹', q) f â â (s : finset Î¹) C : ââ¥0, C â  0 â§ q.comp f â¤ C â¢ s.sup p :=
by simp only [is_bounded, forall_const]

lemma const_is_bounded (Î¹ : Type*) [nonempty Î¹]
  {p : seminorm ð E} {q : Î¹' â seminorm ð F} (f : E ââ[ð] F) :
  is_bounded (Î» _ : Î¹, p) q f â â i, â C : ââ¥0, C â  0 â§ (q i).comp f â¤ C â¢ p :=
begin
  split; intros h i,
  { rcases h i with â¨s, C, hC, hâ©,
    exact â¨C, hC, le_trans h (smul_le_smul (finset.sup_le (Î» _ _, le_rfl)) le_rfl)â© },
  use [{classical.arbitrary Î¹}],
  simp only [h, finset.sup_singleton],
end

lemma is_bounded_sup {p : Î¹ â seminorm ð E} {q : Î¹' â seminorm ð F}
  {f : E ââ[ð] F} (hf : is_bounded p q f) (s' : finset Î¹') :
  â (C : ââ¥0) (s : finset Î¹), 0 < C â§ (s'.sup q).comp f â¤ C â¢ (s.sup p) :=
begin
  classical,
  by_cases hs' : Â¬s'.nonempty,
  { refine â¨1, â, zero_lt_one, _â©,
    rw [finset.not_nonempty_iff_eq_empty.mp hs', finset.sup_empty, seminorm.bot_eq_zero, zero_comp],
    exact seminorm.nonneg _ },
  rw not_not at hs',
  choose fâ fC hf using hf,
  use [s'.card â¢ s'.sup fC, finset.bUnion s' fâ],
  split,
  { refine nsmul_pos _ (ne_of_gt (finset.nonempty.card_pos hs')),
    cases finset.nonempty.bex hs' with j hj,
    exact lt_of_lt_of_le (zero_lt_iff.mpr (and.elim_left (hf j))) (finset.le_sup hj) },
  have hs : â i : Î¹', i â s' â (q i).comp f â¤ s'.sup fC â¢ ((finset.bUnion s' fâ).sup p) :=
  begin
    intros i hi,
    refine le_trans (and.elim_right (hf i)) (smul_le_smul _ (finset.le_sup hi)),
    exact finset.sup_mono (finset.subset_bUnion_of_mem fâ hi),
  end,
  refine le_trans (comp_mono f (finset_sup_le_sum q s')) _,
  simp_rw [âpullback_apply, add_monoid_hom.map_sum, pullback_apply],
  refine le_trans (finset.sum_le_sum hs) _,
  rw [finset.sum_const, smul_assoc],
  exact le_rfl,
end

end seminorm

end bounded

section topology

variables [normed_field ð] [add_comm_group E] [module ð E] [nonempty Î¹]

/-- The proposition that the topology of `E` is induced by a family of seminorms `p`. -/
class with_seminorms (p : seminorm_family ð E Î¹) [t : topological_space E] : Prop :=
(topology_eq_with_seminorms : t = p.module_filter_basis.topology)

lemma seminorm_family.with_seminorms_eq (p : seminorm_family ð E Î¹) [t : topological_space E]
  [with_seminorms p] : t = p.module_filter_basis.topology :=
with_seminorms.topology_eq_with_seminorms

variables [topological_space E]
variables (p : seminorm_family ð E Î¹) [with_seminorms p]

lemma seminorm_family.has_basis : (ð (0 : E)).has_basis
  (Î» (s : set E), s â p.basis_sets) id :=
begin
  rw (congr_fun (congr_arg (@nhds E) p.with_seminorms_eq) 0),
  exact add_group_filter_basis.nhds_zero_has_basis _,
end
end topology

section topological_add_group

variables [normed_field ð] [add_comm_group E] [module ð E]
variables [topological_space E] [topological_add_group E]
variables [nonempty Î¹]

lemma seminorm_family.with_seminorms_of_nhds (p : seminorm_family ð E Î¹)
  (h : ð (0 : E) = p.module_filter_basis.to_filter_basis.filter) :
  with_seminorms p :=
begin
  refine â¨topological_add_group.ext (by apply_instance)
    (p.add_group_filter_basis.is_topological_add_group) _â©,
  rw add_group_filter_basis.nhds_zero_eq,
  exact h,
end

lemma seminorm_family.with_seminorms_of_has_basis (p : seminorm_family ð E Î¹)
  (h : (ð (0 : E)).has_basis (Î» (s : set E), s â p.basis_sets) id) :
  with_seminorms p :=
p.with_seminorms_of_nhds $ filter.has_basis.eq_of_same_basis h
  p.add_group_filter_basis.to_filter_basis.has_basis


end topological_add_group

section normed_space

/-- The topology of a `normed_space ð E` is induced by the seminorm `norm_seminorm ð E`. -/
instance norm_with_seminorms (ð E) [normed_field ð] [semi_normed_group E] [normed_space ð E] :
  with_seminorms (Î» (_ : fin 1), norm_seminorm ð E) :=
begin
  let p : seminorm_family ð E (fin 1) := Î» _, norm_seminorm ð E,
  refine â¨topological_add_group.ext normed_top_group
    (p.add_group_filter_basis.is_topological_add_group) _â©,
  refine filter.has_basis.eq_of_same_basis metric.nhds_basis_ball _,
  rw âball_norm_seminorm ð E,
  refine filter.has_basis.to_has_basis p.add_group_filter_basis.nhds_zero_has_basis _
    (Î» r hr, â¨(norm_seminorm ð E).ball 0 r, p.basis_sets_singleton_mem 0 hr, rfl.subsetâ©),
  rintros U (hU : U â p.basis_sets),
  rcases p.basis_sets_iff.mp hU with â¨s, r, hr, hUâ©,
  use [r, hr],
  rw [hU, id.def],
  by_cases h : s.nonempty,
  { rw finset.sup_const h },
  rw [finset.not_nonempty_iff_eq_empty.mp h, finset.sup_empty, ball_bot _ hr],
  exact set.subset_univ _,
end

end normed_space

section nondiscrete_normed_field

variables [nondiscrete_normed_field ð] [add_comm_group E] [module ð E] [nonempty Î¹]
variables (p : seminorm_family ð E Î¹)
variables [topological_space E] [with_seminorms p]

lemma bornology.is_vonN_bounded_iff_finset_seminorm_bounded {s : set E} :
  bornology.is_vonN_bounded ð s â â I : finset Î¹, â r (hr : 0 < r), â (x â s), I.sup p x < r :=
begin
  rw (p.has_basis).is_vonN_bounded_basis_iff,
  split,
  { intros h I,
    simp only [id.def] at h,
    specialize h ((I.sup p).ball 0 1) (p.basis_sets_mem I zero_lt_one),
    rcases h with â¨r, hr, hâ©,
    cases normed_field.exists_lt_norm ð r with a ha,
    specialize h a (le_of_lt ha),
    rw [seminorm.smul_ball_zero (lt_trans hr ha), mul_one] at h,
    refine â¨â¥aâ¥, lt_trans hr ha, _â©,
    intros x hx,
    specialize h hx,
    exact (finset.sup I p).mem_ball_zero.mp h },
  intros h s' hs',
  rcases p.basis_sets_iff.mp hs' with â¨I, r, hr, hs'â©,
  rw [id.def, hs'],
  rcases h I with â¨r', hr', h'â©,
  simp_rw â(I.sup p).mem_ball_zero at h',
  refine absorbs.mono_right _ h',
  exact (finset.sup I p).ball_zero_absorbs_ball_zero hr,
end

lemma bornology.is_vonN_bounded_iff_seminorm_bounded {s : set E} :
  bornology.is_vonN_bounded ð s â â i : Î¹, â r (hr : 0 < r), â (x â s), p i x < r :=
begin
  rw bornology.is_vonN_bounded_iff_finset_seminorm_bounded p,
  split,
  { intros hI i,
    convert hI {i},
    rw [finset.sup_singleton] },
  intros hi I,
  by_cases hI : I.nonempty,
  { choose r hr h using hi,
    have h' : 0 < I.sup' hI r :=
    by { rcases hI.bex with â¨i, hiâ©, exact lt_of_lt_of_le (hr i) (finset.le_sup' r hi) },
    refine â¨I.sup' hI r, h', Î» x hx, finset_sup_apply_lt h' (Î» i hi, _)â©,
    refine lt_of_lt_of_le (h i x hx) _,
    simp only [finset.le_sup'_iff, exists_prop],
    exact â¨i, hi, (eq.refl _).leâ© },
  simp only [finset.not_nonempty_iff_eq_empty.mp hI, finset.sup_empty, coe_bot, pi.zero_apply,
    exists_prop],
  exact â¨1, zero_lt_one, Î» _ _, zero_lt_oneâ©,
end

end nondiscrete_normed_field
section continuous_bounded

namespace seminorm

variables [normed_field ð] [add_comm_group E] [module ð E] [add_comm_group F] [module ð F]
variables [nonempty Î¹] [nonempty Î¹']

lemma continuous_from_bounded (p : seminorm_family ð E Î¹) (q : seminorm_family ð F Î¹')
  [uniform_space E] [uniform_add_group E] [with_seminorms p]
  [uniform_space F] [uniform_add_group F] [with_seminorms q]
  (f : E ââ[ð] F) (hf : seminorm.is_bounded p q f) : continuous f :=
begin
  refine uniform_continuous.continuous _,
  refine add_monoid_hom.uniform_continuous_of_continuous_at_zero f.to_add_monoid_hom _,
  rw [f.to_add_monoid_hom_coe, continuous_at_def, f.map_zero, p.with_seminorms_eq],
  intros U hU,
  rw [q.with_seminorms_eq, add_group_filter_basis.nhds_zero_eq, filter_basis.mem_filter_iff] at hU,
  rcases hU with â¨V, hV : V â q.basis_sets, hUâ©,
  rcases q.basis_sets_iff.mp hV with â¨sâ, r, hr, hVâ©,
  rw hV at hU,
  rw [p.add_group_filter_basis.nhds_zero_eq, filter_basis.mem_filter_iff],
  rcases (seminorm.is_bounded_sup hf sâ) with â¨C, sâ, hC, hfâ©,
  refine â¨(sâ.sup p).ball 0 (r/C), p.basis_sets_mem _ (div_pos hr (nnreal.coe_pos.mpr hC)), _â©,
  refine subset.trans _ (preimage_mono hU),
  simp_rw [âlinear_map.map_zero f, âball_comp],
  refine subset.trans _ (ball_antitone hf),
  rw ball_smul (sâ.sup p) hC,
end

lemma cont_with_seminorms_normed_space (F) [semi_normed_group F] [normed_space ð F]
  [uniform_space E] [uniform_add_group E]
  (p : Î¹ â seminorm ð E) [with_seminorms p] (f : E ââ[ð] F)
  (hf : â (s : finset Î¹) C : ââ¥0, C â  0 â§ (norm_seminorm ð F).comp f â¤ C â¢ s.sup p) :
  continuous f :=
begin
  rw âseminorm.is_bounded_const (fin 1) at hf,
  exact continuous_from_bounded p (Î» _ : fin 1, norm_seminorm ð F) f hf,
end

lemma cont_normed_space_to_with_seminorms (E) [semi_normed_group E] [normed_space ð E]
  [uniform_space F] [uniform_add_group F]
  (q : Î¹ â seminorm ð F) [with_seminorms q] (f : E ââ[ð] F)
  (hf : â i : Î¹, â C : ââ¥0, C â  0 â§ (q i).comp f â¤ C â¢ (norm_seminorm ð E)) : continuous f :=
begin
  rw âseminorm.const_is_bounded (fin 1) at hf,
  exact continuous_from_bounded (Î» _ : fin 1, norm_seminorm ð E) q f hf,
end

end seminorm

end continuous_bounded

section locally_convex_space

open locally_convex_space

variables [nonempty Î¹] [normed_field ð] [normed_space â ð]
  [add_comm_group E] [module ð E] [module â E] [is_scalar_tower â ð E] [topological_space E]
  [topological_add_group E]

lemma seminorm_family.to_locally_convex_space (p : seminorm_family ð E Î¹) [with_seminorms p] :
  locally_convex_space â E :=
begin
  apply of_basis_zero â E id (Î» s, s â p.basis_sets),
  { rw [p.with_seminorms_eq, add_group_filter_basis.nhds_eq _, add_group_filter_basis.N_zero],
    exact filter_basis.has_basis _ },
  { intros s hs,
    change s â set.Union _ at hs,
    simp_rw [set.mem_Union, set.mem_singleton_iff] at hs,
    rcases hs with â¨I, r, hr, rflâ©,
    exact convex_ball _ _ _ }
end

end locally_convex_space

section normed_space

variables (ð) [normed_field ð] [normed_space â ð] [semi_normed_group E]

/-- Not an instance since `ð` can't be inferred. See `normed_space.to_locally_convex_space` for a
slightly weaker instance version. -/
lemma normed_space.to_locally_convex_space' [normed_space ð E] [module â E]
  [is_scalar_tower â ð E] : locally_convex_space â E :=
seminorm_family.to_locally_convex_space (Î» _ : fin 1, norm_seminorm ð E)

/-- See `normed_space.to_locally_convex_space'` for a slightly stronger version which is not an
instance. -/
instance normed_space.to_locally_convex_space [normed_space â E] :
  locally_convex_space â E :=
normed_space.to_locally_convex_space' â

end normed_space
