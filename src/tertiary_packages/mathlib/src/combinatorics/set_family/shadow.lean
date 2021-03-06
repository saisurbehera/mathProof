/-
Copyright (c) 2021 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Alena Gusakov, YaÃ«l Dillies
-/
import data.finset.slice
import logic.function.iterate

/-!
# Shadows

This file defines shadows of a set family. The shadow of a set family is the set family of sets we
get by removing any element from any set of the original family. If one pictures `finset Î±` as a big
hypercube (each dimension being membership of a given element), then taking the shadow corresponds
to projecting each finset down once in all available directions.

## Main definitions

* `finset.shadow`: The shadow of a set family. Everything we can get by removing a new element from
  some set.
* `finset.up_shadow`: The upper shadow of a set family. Everything we can get by adding an element
  to some set.

## Notation

We define notation in locale `finset_family`:
* `â ð`: Shadow of `ð`.
* `ââº ð`: Upper shadow of `ð`.

We also maintain the convention that `a, b : Î±` are elements of the ground type, `s, t : finset Î±`
are finsets, and `ð, â¬ : finset (finset Î±)` are finset families.

## References

* https://github.com/b-mehta/maths-notes/blob/master/iii/mich/combinatorics.pdf
* http://discretemath.imp.fu-berlin.de/DMII-2015-16/kruskal.pdf

## Tags

shadow, set family
-/

open finset nat

variables {Î± : Type*}

namespace finset
section shadow
variables [decidable_eq Î±] {ð : finset (finset Î±)} {s t : finset Î±} {a : Î±} {k r : â}

/-- The shadow of a set family `ð` is all sets we can get by removing one element from any set in
`ð`, and the (`k` times) iterated shadow (`shadow^[k]`) is all sets we can get by removing `k`
elements from any set in `ð`. -/
def shadow (ð : finset (finset Î±)) : finset (finset Î±) := ð.sup (Î» s, s.image (erase s))

localized "notation `â `:90 := finset.shadow" in finset_family

/-- The shadow of the empty set is empty. -/
@[simp] lemma shadow_empty : â (â : finset (finset Î±)) = â := rfl
@[simp] lemma shadow_singleton_empty : â ({â} : finset (finset Î±)) = â := rfl

--TODO: Prove `â {{a}} = {â}` quickly using `covers` and `grade_order`

/-- The shadow is monotone. -/
@[mono] lemma shadow_monotone : monotone (shadow : finset (finset Î±) â finset (finset Î±)) :=
Î» ð â¬, sup_mono

/-- `s` is in the shadow of `ð` iff there is an `t â ð` from which we can remove one element to
get `s`. -/
lemma mem_shadow_iff : s â â ð â â t â ð, â a â t, erase t a = s :=
by simp only [shadow, mem_sup, mem_image]

lemma erase_mem_shadow (hs : s â ð) (ha : a â s) : erase s a â â ð :=
mem_shadow_iff.2 â¨s, hs, a, ha, rflâ©

/-- `t` is in the shadow of `ð` iff we can add an element to it so that the resulting finset is in
`ð`. -/
lemma mem_shadow_iff_insert_mem : s â â ð â â a â s, insert a s â ð :=
begin
  refine mem_shadow_iff.trans â¨_, _â©,
  { rintro â¨s, hs, a, ha, rflâ©,
    refine â¨a, not_mem_erase a s, _â©,
    rwa insert_erase ha },
  { rintro â¨a, ha, hsâ©,
    exact â¨insert a s, hs, a, mem_insert_self _ _, erase_insert haâ© }
end

/-- The shadow of a family of `r`-sets is a family of `r - 1`-sets. -/
protected lemma _root_.set.sized.shadow (hð : (ð : set (finset Î±)).sized r) :
  (â ð : set (finset Î±)).sized (r - 1) :=
begin
  intros A h,
  obtain â¨A, hA, i, hi, rflâ© := mem_shadow_iff.1 h,
  rw [card_erase_of_mem hi, hð hA],
end

lemma sized_shadow_iff (h : â â ð) :
  (â ð : set (finset Î±)).sized r â (ð : set (finset Î±)).sized (r + 1) :=
begin
  refine â¨Î» hð s hs, _, set.sized.shadowâ©,
  obtain â¨a, haâ© := nonempty_iff_ne_empty.2 (ne_of_mem_of_not_mem hs h),
  rw [âhð (erase_mem_shadow hs ha), card_erase_add_one ha],
end

/-- `s â â ð` iff `s` is exactly one element less than something from `ð` -/
lemma mem_shadow_iff_exists_mem_card_add_one :
  s â â ð â â t â ð, s â t â§ t.card = s.card + 1 :=
begin
  refine mem_shadow_iff_insert_mem.trans â¨_, _â©,
  { rintro â¨a, ha, hsâ©,
    exact â¨insert a s, hs, subset_insert _ _, card_insert_of_not_mem haâ© },
  { rintro â¨t, ht, hst, hâ©,
    obtain â¨a, haâ© : â a, t \ s = {a} :=
      card_eq_one.1 (by rw [card_sdiff hst, h, add_tsub_cancel_left]),
    exact â¨a, Î» hat,
      not_mem_sdiff_of_mem_right hat ((ha.ge : _ â _) $ mem_singleton_self a),
      by rwa [insert_eq a s, âha, sdiff_union_of_subset hst]â© }
end

/-- Being in the shadow of `ð` means we have a superset in `ð`. -/
lemma exists_subset_of_mem_shadow (hs : s â â ð) : â t â ð, s â t :=
let â¨t, ht, hstâ© := mem_shadow_iff_exists_mem_card_add_one.1 hs in â¨t, ht, hst.1â©

/-- `t â â^k ð` iff `t` is exactly `k` elements less than something in `ð`. -/
lemma mem_shadow_iff_exists_mem_card_add :
  s â (â^[k]) ð â â t â ð, s â t â§ t.card = s.card + k :=
begin
  induction k with k ih generalizing ð s,
  { refine â¨Î» hs, â¨s, hs, subset.refl _, rflâ©, _â©,
    rintro â¨t, ht, hst, hcardâ©,
    rwa eq_of_subset_of_card_le hst hcard.le },
  simp only [exists_prop, function.comp_app, function.iterate_succ],
  refine ih.trans _,
  clear ih,
  split,
  { rintro â¨t, ht, hst, hcardstâ©,
    obtain â¨u, hu, htu, hcardtuâ© := mem_shadow_iff_exists_mem_card_add_one.1 ht,
    refine â¨u, hu, hst.trans htu, _â©,
    rw [hcardtu, hcardst],
    refl },
  { rintro â¨t, ht, hst, hcardâ©,
    obtain â¨u, hsu, hut, huâ© := finset.exists_intermediate_set k
      (by { rw [add_comm, hcard], exact le_succ _ }) hst,
    rw add_comm at hu,
    refine â¨u, mem_shadow_iff_exists_mem_card_add_one.2 â¨t, ht, hut, _â©, hsu, huâ©,
    rw [hcard, hu],
    refl }
end

end shadow

open_locale finset_family

section up_shadow
variables [decidable_eq Î±] [fintype Î±] {ð : finset (finset Î±)} {s t : finset Î±} {a : Î±} {k r : â}

/-- The upper shadow of a set family `ð` is all sets we can get by adding one element to any set in
`ð`, and the (`k` times) iterated upper shadow (`up_shadow^[k]`) is all sets we can get by adding
`k` elements from any set in `ð`. -/
def up_shadow (ð : finset (finset Î±)) : finset (finset Î±) :=
ð.sup $ Î» s, sá¶.image $ Î» a, insert a s

localized "notation `ââº `:90 := finset.up_shadow" in finset_family

/-- The upper shadow of the empty set is empty. -/
@[simp] lemma up_shadow_empty : ââº (â : finset (finset Î±)) = â := rfl

/-- The upper shadow is monotone. -/
@[mono] lemma up_shadow_monotone : monotone (up_shadow : finset (finset Î±) â finset (finset Î±)) :=
Î» ð â¬, sup_mono

/-- `s` is in the upper shadow of `ð` iff there is an `t â ð` from which we can remove one element
to get `s`. -/
lemma mem_up_shadow_iff : s â ââº ð â â t â ð, â a â t, insert a t = s :=
by simp_rw [up_shadow, mem_sup, mem_image, exists_prop, mem_compl]

lemma insert_mem_up_shadow (hs : s â ð) (ha : a â s) : insert a s â ââº ð :=
mem_up_shadow_iff.2 â¨s, hs, a, ha, rflâ©

/-- The upper shadow of a family of `r`-sets is a family of `r + 1`-sets. -/
protected lemma _root_.set.sized.up_shadow (hð : (ð : set (finset Î±)).sized r) :
  (ââº ð : set (finset Î±)).sized (r + 1) :=
begin
  intros A h,
  obtain â¨A, hA, i, hi, rflâ© := mem_up_shadow_iff.1 h,
  rw [card_insert_of_not_mem hi, hð hA],
end

/-- `t` is in the upper shadow of `ð` iff we can remove an element from it so that the resulting
finset is in `ð`. -/
lemma mem_up_shadow_iff_erase_mem : s â ââº ð â â a â s, s.erase a â ð :=
begin
  refine mem_up_shadow_iff.trans â¨_, _â©,
  { rintro â¨s, hs, a, ha, rflâ©,
    refine â¨a, mem_insert_self a s, _â©,
    rwa erase_insert ha },
  { rintro â¨a, ha, hsâ©,
    exact â¨s.erase a, hs, a, not_mem_erase _ _, insert_erase haâ© }
end

/-- `s â ââº ð` iff `s` is exactly one element less than something from `ð`. -/
lemma mem_up_shadow_iff_exists_mem_card_add_one :
  s â ââº ð â â t â ð, t â s â§ t.card + 1 = s.card :=
begin
  refine mem_up_shadow_iff_erase_mem.trans â¨_, _â©,
  { rintro â¨a, ha, hsâ©,
    exact â¨s.erase a, hs, erase_subset _ _, card_erase_add_one haâ© },
  { rintro â¨t, ht, hts, hâ©,
    obtain â¨a, haâ© : â a, s \ t = {a} :=
      card_eq_one.1 (by rw [card_sdiff hts, âh, add_tsub_cancel_left]),
    refine â¨a, sdiff_subset _ _ ((ha.ge : _ â _) $ mem_singleton_self a), _â©,
    rwa [âsdiff_singleton_eq_erase, âha, sdiff_sdiff_eq_self hts] }
end

/-- Being in the upper shadow of `ð` means we have a superset in `ð`. -/
lemma exists_subset_of_mem_up_shadow (hs : s â ââº ð) : â t â ð, t â s :=
let â¨t, ht, hts, _â© := mem_up_shadow_iff_exists_mem_card_add_one.1 hs in â¨t, ht, htsâ©

/-- `t â â^k ð` iff `t` is exactly `k` elements more than something in `ð`. -/
lemma mem_up_shadow_iff_exists_mem_card_add :
  s â (ââº^[k]) ð â â t â ð, t â s â§ t.card + k = s.card :=
begin
  induction k with k ih generalizing ð s,
  { refine â¨Î» hs, â¨s, hs, subset.refl _, rflâ©, _â©,
    rintro â¨t, ht, hst, hcardâ©,
    rwa âeq_of_subset_of_card_le hst hcard.ge },
  simp only [exists_prop, function.comp_app, function.iterate_succ],
  refine ih.trans _,
  clear ih,
  split,
  { rintro â¨t, ht, hts, hcardstâ©,
    obtain â¨u, hu, hut, hcardtuâ© := mem_up_shadow_iff_exists_mem_card_add_one.1 ht,
    refine â¨u, hu, hut.trans hts, _â©,
    rw [âhcardst, âhcardtu, add_right_comm],
    refl },
  { rintro â¨t, ht, hts, hcardâ©,
    obtain â¨u, htu, hus, huâ© := finset.exists_intermediate_set 1
      (by { rw [add_comm, âhcard], exact add_le_add_left (zero_lt_succ _) _ }) hts,
    rw add_comm at hu,
    refine â¨u, mem_up_shadow_iff_exists_mem_card_add_one.2 â¨t, ht, htu, hu.symmâ©, hus, _â©,
    rw [hu, âhcard, add_right_comm],
    refl }
end

@[simp] lemma shadow_image_compl : (â ð).image compl = ââº (ð.image compl) :=
begin
  ext s,
  simp only [mem_image, exists_prop, mem_shadow_iff, mem_up_shadow_iff],
  split,
  { rintro â¨_, â¨s, hs, a, ha, rflâ©, rflâ©,
    exact â¨sá¶, â¨s, hs, rflâ©, a, not_mem_compl.2 ha, compl_erase.symmâ© },
  { rintro â¨_, â¨s, hs, rflâ©, a, ha, rflâ©,
    exact â¨s.erase a, â¨s, hs, a, not_mem_compl.1 ha, rflâ©, compl_eraseâ© }
end

@[simp] lemma up_shadow_image_compl : (ââº ð).image compl = â (ð.image compl) :=
begin
  ext s,
  simp only [mem_image, exists_prop, mem_shadow_iff, mem_up_shadow_iff],
  split,
  { rintro â¨_, â¨s, hs, a, ha, rflâ©, rflâ©,
    exact â¨sá¶, â¨s, hs, rflâ©, a, mem_compl.2 ha, compl_insert.symmâ© },
  { rintro â¨_, â¨s, hs, rflâ©, a, ha, rflâ©,
    exact â¨insert a s, â¨s, hs, a, mem_compl.1 ha, rflâ©, compl_insertâ© }
end

end up_shadow
end finset
