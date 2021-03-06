/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll
-/
import analysis.locally_convex.basic
import topology.bornology.basic

/-!
# Von Neumann Boundedness

This file defines natural or von Neumann bounded sets and proves elementary properties.

## Main declarations

* `bornology.is_vonN_bounded`: A set `s` is von Neumann-bounded if every neighborhood of zero
absorbs `s`.
* `bornology.vonN_bornology`: The bornology made of the von Neumann-bounded sets.

## Main results

* `bornology.is_vonN_bounded_of_topological_space_le`: A coarser topology admits more
von Neumann-bounded sets.

## References

* [Bourbaki, *Topological Vector Spaces*][bourbaki1987]

-/

variables {ð E Î¹ : Type*}

open_locale topological_space pointwise

namespace bornology

section semi_normed_ring

section has_zero

variables (ð)
variables [semi_normed_ring ð] [has_scalar ð E] [has_zero E]
variables [topological_space E]

/-- A set `s` is von Neumann bounded if every neighborhood of 0 absorbs `s`. -/
def is_vonN_bounded (s : set E) : Prop := â â¦Vâ¦, V â ð (0 : E) â absorbs ð V s

variables (E)

@[simp] lemma is_vonN_bounded_empty : is_vonN_bounded ð (â : set E) :=
Î» _ _, absorbs_empty

variables {ð E}

lemma is_vonN_bounded_iff (s : set E) : is_vonN_bounded ð s â â V â ð (0 : E), absorbs ð V s :=
iff.rfl

lemma _root_.filter.has_basis.is_vonN_bounded_basis_iff {q : Î¹ â Prop} {s : Î¹ â set E} {A : set E}
  (h : (ð (0 : E)).has_basis q s) :
  is_vonN_bounded ð A â â i (hi : q i), absorbs ð (s i) A :=
begin
  refine â¨Î» hA i hi, hA (h.mem_of_mem hi), Î» hA V hV, _â©,
  rcases h.mem_iff.mp hV with â¨i, hi, hVâ©,
  exact (hA i hi).mono_left hV,
end

/-- Subsets of bounded sets are bounded. -/
lemma is_vonN_bounded.subset {sâ sâ : set E} (h : sâ â sâ) (hsâ : is_vonN_bounded ð sâ) :
  is_vonN_bounded ð sâ :=
Î» V hV, (hsâ hV).mono_right h

/-- The union of two bounded sets is bounded. -/
lemma is_vonN_bounded.union {sâ sâ : set E} (hsâ : is_vonN_bounded ð sâ)
  (hsâ : is_vonN_bounded ð sâ) :
  is_vonN_bounded ð (sâ âª sâ) :=
Î» V hV, (hsâ hV).union (hsâ hV)

end has_zero

end semi_normed_ring

section multiple_topologies

variables [semi_normed_ring ð] [add_comm_group E] [module ð E]

/-- If a topology `t'` is coarser than `t`, then any set `s` that is bounded with respect to
`t` is bounded with respect to `t'`. -/
lemma is_vonN_bounded.of_topological_space_le {t t' : topological_space E} (h : t â¤ t') {s : set E}
  (hs : @is_vonN_bounded ð E _ _ _ t s) : @is_vonN_bounded ð E _ _ _ t' s :=
Î» V hV, hs $ (le_iff_nhds t t').mp h 0 hV

end multiple_topologies

section normed_field

variables [normed_field ð] [add_comm_group E] [module ð E]
variables [topological_space E] [has_continuous_smul ð E]

/-- Singletons are bounded. -/
lemma is_vonN_bounded_singleton (x : E) : is_vonN_bounded ð ({x} : set E) :=
Î» V hV, (absorbent_nhds_zero hV).absorbs

/-- The union of all bounded set is the whole space. -/
lemma is_vonN_bounded_covers : ââ (set_of (is_vonN_bounded ð)) = (set.univ : set E) :=
set.eq_univ_iff_forall.mpr (Î» x, set.mem_sUnion.mpr
  â¨{x}, is_vonN_bounded_singleton _, set.mem_singleton _â©)

variables (ð E)

/-- The von Neumann bornology defined by the von Neumann bounded sets.

Note that this is not registered as an instance, in order to avoid diamonds with the
metric bornology.-/
@[reducible] -- See note [reducible non-instances]
def vonN_bornology : bornology E :=
bornology.of_bounded (set_of (is_vonN_bounded ð)) (is_vonN_bounded_empty ð E)
  (Î» _ hs _ ht, hs.subset ht) (Î» _ hs _, hs.union) is_vonN_bounded_singleton

variables {E}

@[simp] lemma is_bounded_iff_is_vonN_bounded {s : set E} :
  @is_bounded _ (vonN_bornology ð E) s â is_vonN_bounded ð s :=
is_bounded_of_bounded_iff _

end normed_field

end bornology
