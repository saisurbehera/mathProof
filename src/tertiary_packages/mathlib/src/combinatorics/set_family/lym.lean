/-
Copyright (c) 2022 Bhavik Mehta, YaÃ«l Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Alena Gusakov, YaÃ«l Dillies
-/
import algebra.big_operators.ring
import combinatorics.double_counting
import combinatorics.set_family.shadow
import data.rat.order
import tactic.linarith

/-!
# Lubell-Yamamoto-Meshalkin inequality and Sperner's theorem

This file proves the local LYM and LYM inequalities as well as Sperner's theorem.

## Main declarations

* `finset.card_div_choose_le_card_shadow_div_choose`: Local Lubell-Yamamoto-Meshalkin inequality.
  The shadow of a set `ð` in a layer takes a greater proportion of its layer than `ð` does.
* `finset.sum_card_slice_div_choose_le_one`: Lubell-Yamamoto-Meshalkin inequality. The sum of
  densities of `ð` in each layer is at most `1` for any antichain `ð`.
* `is_antichain.sperner`: Sperner's theorem. The size of any antichain in `finset Î±` is at most the
  size of the maximal layer of `finset Î±`. It is a corollary of `sum_card_slice_div_choose_le_one`.

## TODO

Prove upward local LYM.

Provide equality cases. Local LYM gives that the equality case of LYM and Sperner is precisely when
`ð` is a middle layer.

`falling` could be useful more generally in grade orders.

## References

* http://b-mehta.github.io/maths-notes/iii/mich/combinatorics.pdf
* http://discretemath.imp.fu-berlin.de/DMII-2015-16/kruskal.pdf

## Tags

shadow, lym, slice, sperner, antichain
-/

open finset nat
open_locale big_operators finset_family

variables {ð Î± : Type*} [linear_ordered_field ð]

namespace finset

/-! ### Local LYM inequality -/

section local_lym
variables [decidable_eq Î±] [fintype Î±] {ð : finset (finset Î±)} {r : â}

/-- The downward **local LYM inequality**, with cancelled denominators. `ð` takes up less of `Î±^(r)`
(the finsets of card `r`) than `âð` takes up of `Î±^(r - 1)`. -/
lemma card_mul_le_card_shadow_mul (hð : (ð : set (finset Î±)).sized r) :
  ð.card * r â¤ (âð).card * (fintype.card Î± - r + 1) :=
begin
  refine card_mul_le_card_mul' (â) (Î» s hs, _) (Î» s hs, _),
  { rw [âhð hs, âcard_image_of_inj_on s.erase_inj_on],
    refine card_le_of_subset _,
    simp_rw [image_subset_iff, mem_bipartite_below],
    exact Î» a ha, â¨erase_mem_shadow hs ha, erase_subset _ _â© },
  refine le_trans _ tsub_tsub_le_tsub_add,
  rw [âhð.shadow hs, âcard_compl, âcard_image_of_inj_on (insert_inj_on' _)],
  refine card_le_of_subset (Î» t ht, _),
  apply_instance,
  rw mem_bipartite_above at ht,
  have : â â ð,
  { rw [âmem_coe, hð.empty_mem_iff, coe_eq_singleton],
    rintro rfl,
    rwa shadow_singleton_empty at hs },
  obtain â¨a, ha, rflâ© :=
    exists_eq_insert_iff.2 â¨ht.2, by rw [(sized_shadow_iff this).1 hð.shadow ht.1, hð.shadow hs]â©,
  exact mem_image_of_mem _ (mem_compl.2 ha),
end

/-- The downward **local LYM inequality**. `ð` takes up less of `Î±^(r)` (the finsets of card `r`)
than `âð` takes up of `Î±^(r - 1)`. -/
lemma card_div_choose_le_card_shadow_div_choose (hr : r â  0) (hð : (ð : set (finset Î±)).sized r) :
  (ð.card : ð) / (fintype.card Î±).choose r â¤ (âð).card / (fintype.card Î±).choose (r - 1) :=
begin
  obtain hr' | hr' := lt_or_le (fintype.card Î±) r,
  { rw [choose_eq_zero_of_lt hr', cast_zero, div_zero],
    exact div_nonneg (cast_nonneg _) (cast_nonneg _) },
  replace hð := card_mul_le_card_shadow_mul hð,
  rw div_le_div_iff; norm_cast,
  { cases r,
    { exact (hr rfl).elim },
    rw nat.succ_eq_add_one at *,
    rw [tsub_add_eq_add_tsub hr', add_tsub_add_eq_tsub_right] at hð,
    apply le_of_mul_le_mul_right _ (pos_iff_ne_zero.2 hr),
    convert nat.mul_le_mul_right ((fintype.card Î±).choose r) hð using 1,
    { simp [mul_assoc, nat.choose_succ_right_eq],
      exact or.inl (mul_comm _ _) },
    { simp only [mul_assoc, choose_succ_right_eq, mul_eq_mul_left_iff],
      exact or.inl (mul_comm _ _) } },
  { exact nat.choose_pos hr' },
  { exact nat.choose_pos (r.pred_le.trans hr') }
end

end local_lym

/-! ### LYM inequality -/

section lym
section falling
variables [decidable_eq Î±] (k : â) (ð : finset (finset Î±))

/-- `falling k ð` is all the finsets of cardinality `k` which are a subset of something in `ð`. -/
def falling : finset (finset Î±) := ð.sup $ powerset_len k

variables {ð k} {s : finset Î±}

lemma mem_falling : s â falling k ð â (â t â ð, s â t) â§ s.card = k :=
by simp_rw [falling, mem_sup, mem_powerset_len, exists_and_distrib_right]

variables (ð k)

lemma sized_falling : (falling k ð : set (finset Î±)).sized k := Î» s hs, (mem_falling.1 hs).2

lemma slice_subset_falling : ð # k â falling k ð :=
Î» s hs, mem_falling.2 $ (mem_slice.1 hs).imp_left $ Î» h, â¨s, h, subset.refl _â©

lemma falling_zero_subset : falling 0 ð â {â} :=
subset_singleton_iff'.2 $ Î» t ht, card_eq_zero.1 $ sized_falling _ _ ht

lemma slice_union_shadow_falling_succ : ð # k âª â (falling (k + 1) ð) = falling k ð :=
begin
  ext s,
  simp_rw [mem_union, mem_slice, mem_shadow_iff, exists_prop, mem_falling],
  split,
  { rintro (h | â¨s, â¨â¨t, ht, hstâ©, hsâ©, a, ha, rflâ©),
    { exact â¨â¨s, h.1, subset.refl _â©, h.2â© },
    refine â¨â¨t, ht, (erase_subset _ _).trans hstâ©, _â©,
    rw [card_erase_of_mem ha, hs],
    refl },
  { rintro â¨â¨t, ht, hstâ©, hsâ©,
    by_cases s â ð,
    { exact or.inl â¨h, hsâ© },
    obtain â¨a, ha, hstâ© := ssubset_iff_exists_insert_subset.1
      (ssubset_of_subset_of_ne hst (ht.ne_of_not_mem h).symm),
    refine or.inr â¨insert a s, â¨â¨t, ht, hstâ©, _â©, a, mem_insert_self _ _, erase_insert haâ©,
    rw [card_insert_of_not_mem ha, hs] }
end

variables {ð k}

/-- The shadow of `falling m ð` is disjoint from the `n`-sized elements of `ð`, thanks to the
antichain property. -/
lemma _root_.is_antichain.disjoint_slice_shadow_falling {m n : â}
  (hð : is_antichain (â) (ð : set (finset Î±))) :
  disjoint (ð # m) (â (falling n ð)) :=
disjoint_right.2 $ Î» s hâ hâ,
begin
  simp_rw [mem_shadow_iff, exists_prop, mem_falling] at hâ,
  obtain â¨s, â¨â¨t, ht, hstâ©, hsâ©, a, ha, rflâ© := hâ,
  refine hð (slice_subset hâ) ht _ ((erase_subset _ _).trans hst),
  rintro rfl,
  exact not_mem_erase _ _ (hst ha),
end

/-- A bound on any top part of the sum in LYM in terms of the size of `falling k ð`. -/
lemma le_card_falling_div_choose [fintype Î±] (hk : k â¤ fintype.card Î±)
  (hð : is_antichain (â) (ð : set (finset Î±))) :
  â r in range (k + 1),
    ((ð # (fintype.card Î± - r)).card : ð) / (fintype.card Î±).choose (fintype.card Î± - r)
      â¤ (falling (fintype.card Î± - k) ð).card / (fintype.card Î±).choose (fintype.card Î± - k) :=
begin
  induction k with k ih,
  { simp only [tsub_zero, cast_one, cast_le, sum_singleton, div_one, choose_self, range_one],
    exact card_le_of_subset (slice_subset_falling _ _) },
  rw succ_eq_add_one at *,
  rw [sum_range_succ, âslice_union_shadow_falling_succ,
    card_disjoint_union hð.disjoint_slice_shadow_falling, cast_add, _root_.add_div, add_comm],
  rw [âtsub_tsub, tsub_add_cancel_of_le (le_tsub_of_add_le_left hk)],
  exact add_le_add_left ((ih $ le_of_succ_le hk).trans $ card_div_choose_le_card_shadow_div_choose
    (tsub_pos_iff_lt.2 $ nat.succ_le_iff.1 hk).ne' $ sized_falling _ _) _,
end

end falling

variables {ð : finset (finset Î±)} {s : finset Î±} {k : â}

/-- The **Lubell-Yamamoto-Meshalkin inequality**. If `ð` is an antichain, then the sum of the
proportion of elements it takes from each layer is less than `1`. -/
lemma sum_card_slice_div_choose_le_one [fintype Î±] (hð : is_antichain (â) (ð : set (finset Î±))) :
  â r in range (fintype.card Î± + 1), ((ð # r).card : ð) / (fintype.card Î±).choose r â¤ 1 :=
begin
  classical,
  rw âsum_flip,
  refine (le_card_falling_div_choose le_rfl hð).trans _,
  rw div_le_iff; norm_cast,
  { simpa only [nat.sub_self, one_mul, nat.choose_zero_right, falling]
      using (sized_falling 0 ð).card_le },
  { rw [tsub_self, choose_zero_right],
    exact zero_lt_one }
end

end lym

/-! ### Sperner's theorem -/

/-- **Sperner's theorem**. The size of an antichain in `finset Î±` is bounded by the size of the
maximal layer in `finset Î±`. This precisely means that `finset Î±` is a Sperner order. -/
lemma _root_.is_antichain.sperner [fintype Î±] {ð : finset (finset Î±)}
  (hð : is_antichain (â) (ð : set (finset Î±))) :
  ð.card â¤ (fintype.card Î±).choose (fintype.card Î± / 2) :=
begin
  classical,
  suffices : â r in Iic (fintype.card Î±),
    ((ð # r).card : â) / (fintype.card Î±).choose (fintype.card Î± / 2) â¤ 1,
  { rwa [âsum_div, ânat.cast_sum, div_le_one, cast_le, sum_card_slice] at this,
    norm_cast,
    exact choose_pos (nat.div_le_self _ _) },
  rw [Iic, âIco_succ_right, bot_eq_zero, Ico_zero_eq_range],
  refine (sum_le_sum $ Î» r hr, _).trans (sum_card_slice_div_choose_le_one hð),
  rw mem_range at hr,
  refine div_le_div_of_le_left _ _ _; norm_cast,
  { exact nat.zero_le _ },
  { exact choose_pos (lt_succ_iff.1 hr) },
  { exact choose_le_middle _ _ }
end

end finset
