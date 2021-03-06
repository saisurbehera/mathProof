/-
Copyright (c) 2021 YaÃ«l Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: YaÃ«l Dillies
-/
import analysis.convex.basic

/-!
# Star-convex sets

This files defines star-convex sets (aka star domains, star-shaped set, radially convex set).

A set is star-convex at `x` if every segment from `x` to a point in the set is contained in the set.

This is the prototypical example of a contractible set in homotopy theory (by scaling every point
towards `x`), but has wider uses.

Note that this has nothing to do with star rings, `has_star` and co.

## Main declarations

* `star_convex ð x s`: `s` is star-convex at `x` with scalars `ð`.

## Implementation notes

Instead of saying that a set is star-convex, we say a set is star-convex *at a point*. This has the
advantage of allowing us to talk about convexity as being "everywhere star-convexity" and of making
the union of star-convex sets be star-convex.

Incidentally, this choice means we don't need to assume a set is nonempty for it to be star-convex.
Concretely, the empty set is star-convex at every point.

## TODO

Balanced sets are star-convex.

The closure of a star-convex set is star-convex.

Star-convex sets are contractible.

A nonempty open star-convex set in `â^n` is diffeomorphic to the entire space.
-/

open set
open_locale convex pointwise

variables {ð E F Î² : Type*}

section ordered_semiring
variables [ordered_semiring ð]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F]

section has_scalar
variables (ð) [has_scalar ð E] [has_scalar ð F] (x : E) (s : set E)

/-- Star-convexity of sets. `s` is star-convex at `x` if every segment from `x` to a point in `s` is
contained in `s`. -/
def star_convex : Prop :=
â â¦y : Eâ¦, y â s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â a â¢ x + b â¢ y â s

variables {ð x s} {t : set E}

lemma convex_iff_forall_star_convex : convex ð s â â x â s, star_convex ð x s :=
forall_congr $ Î» x, forall_swap

lemma convex.star_convex (h : convex ð s) (hx : x â s) : star_convex ð x s :=
convex_iff_forall_star_convex.1 h _ hx

lemma star_convex_iff_segment_subset : star_convex ð x s â â â¦yâ¦, y â s â [x -[ð] y] â s :=
begin
  split,
  { rintro h y hy z â¨a, b, ha, hb, hab, rflâ©,
    exact h hy ha hb hab },
  { rintro h y hy a b ha hb hab,
    exact h hy â¨a, b, ha, hb, hab, rflâ© }
end

lemma star_convex.segment_subset (h : star_convex ð x s) {y : E} (hy : y â s) : [x -[ð] y] â s :=
star_convex_iff_segment_subset.1 h hy

lemma star_convex.open_segment_subset (h : star_convex ð x s) {y : E} (hy : y â s) :
  open_segment ð x y â s :=
(open_segment_subset_segment ð x y).trans (h.segment_subset hy)

/-- Alternative definition of star-convexity, in terms of pointwise set operations. -/
lemma star_convex_iff_pointwise_add_subset :
  star_convex ð x s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â a â¢ {x} + b â¢ s â s :=
begin
  refine â¨_, Î» h y hy a b ha hb hab,
    h ha hb hab (add_mem_add (smul_mem_smul_set $ mem_singleton _) â¨_, hy, rflâ©)â©,
  rintro hA a b ha hb hab w â¨au, bv, â¨u, (rfl : u = x), rflâ©, â¨v, hv, rflâ©, rflâ©,
  exact hA hv ha hb hab,
end

lemma star_convex_empty (x : E) : star_convex ð x â := Î» y hy, hy.elim

lemma star_convex_univ (x : E) : star_convex ð x univ := Î» _ _ _ _ _ _ _, trivial

lemma star_convex.inter (hs : star_convex ð x s) (ht : star_convex ð x t) :
  star_convex ð x (s â© t) :=
Î» y hy a b ha hb hab, â¨hs hy.left ha hb hab, ht hy.right ha hb habâ©

lemma star_convex_sInter {S : set (set E)} (h : â s â S, star_convex ð x s) :
  star_convex ð x (ââ S) :=
Î» y hy a b ha hb hab s hs, h s hs (hy s hs) ha hb hab

lemma star_convex_Inter {Î¹ : Sort*} {s : Î¹ â set E} (h : â i, star_convex ð x (s i)) :
  star_convex ð x (â i, s i) :=
(sInter_range s) â¸ star_convex_sInter $ forall_range_iff.2 h

lemma star_convex.union (hs : star_convex ð x s) (ht : star_convex ð x t) :
  star_convex ð x (s âª t) :=
begin
  rintro y (hy | hy) a b ha hb hab,
  { exact or.inl (hs hy ha hb hab) },
  { exact or.inr (ht hy ha hb hab) }
end

lemma star_convex_Union {Î¹ : Sort*} {s : Î¹ â set E} (hs : â i, star_convex ð x (s i)) :
  star_convex ð x (â i, s i) :=
begin
  rintro y hy a b ha hb hab,
  rw mem_Union at â¢ hy,
  obtain â¨i, hyâ© := hy,
  exact â¨i, hs i hy ha hb habâ©,
end

lemma star_convex_sUnion {S : set (set E)} (hS : â s â S, star_convex ð x s) :
  star_convex ð x (ââ S) :=
begin
  rw sUnion_eq_Union,
  exact star_convex_Union (Î» s, hS _ s.2),
end

lemma star_convex.prod {y : F} {s : set E} {t : set F} (hs : star_convex ð x s)
  (ht : star_convex ð y t) :
  star_convex ð (x, y) (s ÃË¢ t) :=
Î» y hy a b ha hb hab, â¨hs hy.1 ha hb hab, ht hy.2 ha hb habâ©

lemma star_convex_pi {Î¹ : Type*} {E : Î¹ â Type*} [Î  i, add_comm_monoid (E i)]
  [Î  i, has_scalar ð (E i)] {x : Î  i, E i} {s : set Î¹} {t : Î  i, set (E i)}
  (ht : â i, star_convex ð (x i) (t i)) :
  star_convex ð x (s.pi t) :=
Î» y hy a b ha hb hab i hi, ht i (hy i hi) ha hb hab

end has_scalar

section module
variables [module ð E] [module ð F] {x y z : E} {s : set E}

lemma star_convex.mem (hs : star_convex ð x s) (h : s.nonempty) : x â s :=
begin
  obtain â¨y, hyâ© := h,
  convert hs hy zero_le_one le_rfl (add_zero 1),
  rw [one_smul, zero_smul, add_zero],
end

lemma convex.star_convex_iff (hs : convex ð s) (h : s.nonempty) : star_convex ð x s â x â s :=
â¨Î» hxs, hxs.mem h, hs.star_convexâ©

lemma star_convex_iff_forall_pos (hx : x â s) :
  star_convex ð x s â â â¦yâ¦, y â s â â â¦a b : ðâ¦, 0 < a â 0 < b â a + b = 1 â a â¢ x + b â¢ y â s :=
begin
  refine â¨Î» h y hy a b ha hb hab, h hy ha.le hb.le hab, _â©,
  intros h y hy a b ha hb hab,
  obtain rfl | ha := ha.eq_or_lt,
  { rw zero_add at hab,
    rwa [hab, one_smul, zero_smul, zero_add] },
  obtain rfl | hb := hb.eq_or_lt,
  { rw add_zero at hab,
    rwa [hab, one_smul, zero_smul, add_zero] },
  exact h hy ha hb hab,
end

lemma star_convex_iff_forall_ne_pos (hx : x â s) :
  star_convex ð x s â â â¦yâ¦, y â s â x â  y â â â¦a b : ðâ¦, 0 < a â 0 < b â a + b = 1 â
    a â¢ x + b â¢ y â s :=
begin
  refine â¨Î» h y hy _ a b ha hb hab, h hy ha.le hb.le hab, _â©,
  intros h y hy a b ha hb hab,
  obtain rfl | ha' := ha.eq_or_lt,
  { rw [zero_add] at hab, rwa [hab, zero_smul, one_smul, zero_add] },
  obtain rfl | hb' := hb.eq_or_lt,
  { rw [add_zero] at hab, rwa [hab, zero_smul, one_smul, add_zero] },
  obtain rfl | hxy := eq_or_ne x y,
  { rwa convex.combo_self hab },
  exact h hy hxy ha' hb' hab,
end

lemma star_convex_iff_open_segment_subset (hx : x â s) :
  star_convex ð x s â â â¦yâ¦, y â s â open_segment ð x y â s :=
star_convex_iff_segment_subset.trans $ forallâ_congr $ Î» y hy,
  (open_segment_subset_iff_segment_subset hx hy).symm

lemma star_convex_singleton (x : E) : star_convex ð x {x} :=
begin
  rintro y (rfl : y = x) a b ha hb hab,
  exact convex.combo_self hab _,
end

lemma star_convex.linear_image (hs : star_convex ð x s) (f : E ââ[ð] F) :
  star_convex ð (f x) (s.image f) :=
begin
  intros y hy a b ha hb hab,
  obtain â¨y', hy', rflâ© := hy,
  exact â¨a â¢ x + b â¢ y', hs hy' ha hb hab, by rw [f.map_add, f.map_smul, f.map_smul]â©,
end

lemma star_convex.is_linear_image (hs : star_convex ð x s) {f : E â F} (hf : is_linear_map ð f) :
  star_convex ð (f x) (f '' s) :=
hs.linear_image $ hf.mk' f

lemma star_convex.linear_preimage {s : set F} (f : E ââ[ð] F) (hs : star_convex ð (f x) s) :
  star_convex ð x (s.preimage f) :=
begin
  intros y hy a b ha hb hab,
  rw [mem_preimage, f.map_add, f.map_smul, f.map_smul],
  exact hs hy ha hb hab,
end

lemma star_convex.is_linear_preimage {s : set F} {f : E â F} (hs : star_convex ð (f x) s)
  (hf : is_linear_map ð f) :
  star_convex ð x (preimage f s) :=
hs.linear_preimage $ hf.mk' f

lemma star_convex.add {t : set E} (hs : star_convex ð x s) (ht : star_convex ð y t) :
  star_convex ð (x + y) (s + t) :=
by { rw âadd_image_prod, exact (hs.prod ht).is_linear_image is_linear_map.is_linear_map_add }

lemma star_convex.add_left (hs : star_convex ð x s) (z : E) :
  star_convex ð (z + x) ((Î» x, z + x) '' s) :=
begin
  intros y hy a b ha hb hab,
  obtain â¨y', hy', rflâ© := hy,
  refine â¨a â¢ x + b â¢ y', hs hy' ha hb hab, _â©,
  rw [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul],
end

lemma star_convex.add_right (hs : star_convex ð x s) (z : E) :
  star_convex ð (x + z) ((Î» x, x + z) '' s) :=
begin
  intros y hy a b ha hb hab,
  obtain â¨y', hy', rflâ© := hy,
  refine â¨a â¢ x + b â¢ y', hs hy' ha hb hab, _â©,
  rw [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul],
end

/-- The translation of a star-convex set is also star-convex. -/
lemma star_convex.preimage_add_right (hs : star_convex ð (z + x) s) :
  star_convex ð x ((Î» x, z + x) â»Â¹' s) :=
begin
  intros y hy a b ha hb hab,
  have h := hs hy ha hb hab,
  rwa [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul] at h,
end

/-- The translation of a star-convex set is also star-convex. -/
lemma star_convex.preimage_add_left (hs : star_convex ð (x + z) s) :
  star_convex ð x ((Î» x, x + z) â»Â¹' s) :=
begin
  rw add_comm at hs,
  simpa only [add_comm] using hs.preimage_add_right,
end

end module
end add_comm_monoid

section add_comm_group
variables [add_comm_group E] [module ð E] {x y : E}

lemma star_convex.sub {s : set (E Ã E)} (hs : star_convex ð (x, y) s) :
  star_convex ð (x - y) ((Î» x : E Ã E, x.1 - x.2) '' s) :=
hs.is_linear_image is_linear_map.is_linear_map_sub

end add_comm_group
end ordered_semiring

section ordered_comm_semiring
variables [ordered_comm_semiring ð]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F] [module ð E] [module ð F] {x : E} {s : set E}

lemma star_convex.smul (hs : star_convex ð x s) (c : ð) : star_convex ð (c â¢ x) (c â¢ s) :=
hs.linear_image $ linear_map.lsmul _ _ c

lemma star_convex.preimage_smul {c : ð} (hs : star_convex ð (c â¢ x) s) :
  star_convex ð x ((Î» z, c â¢ z) â»Â¹' s) :=
hs.linear_preimage (linear_map.lsmul _ _ c)

lemma star_convex.affinity (hs : star_convex ð x s) (z : E) (c : ð) :
  star_convex ð (z + c â¢ x) ((Î» x, z + c â¢ x) '' s) :=
begin
  have h := (hs.smul c).add_left z,
  rwa [âimage_smul, image_image] at h,
end

end add_comm_monoid
end ordered_comm_semiring

section ordered_ring
variables [ordered_ring ð]

section add_comm_monoid
variables [add_comm_monoid E] [smul_with_zero ð E]{s : set E}

lemma star_convex_zero_iff :
  star_convex ð 0 s â â â¦x : Eâ¦, x â s â â â¦a : ðâ¦, 0 â¤ a â a â¤ 1 â a â¢ x â s :=
begin
  refine forall_congr (Î» x, forall_congr $ Î» hx, â¨Î» h a haâ haâ, _, Î» h a b ha hb hab, _â©),
  { simpa only [sub_add_cancel, eq_self_iff_true, forall_true_left, zero_add, smul_zero'] using
      h (sub_nonneg_of_le haâ) haâ },
  { rw [smul_zero', zero_add],
    exact h hb (by { rw âhab, exact le_add_of_nonneg_left ha }) }
end

end add_comm_monoid

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F] {x y : E} {s : set E}

lemma star_convex.add_smul_mem (hs : star_convex ð x s) (hy : x + y â s) {t : ð} (htâ : 0 â¤ t)
  (htâ : t â¤ 1) :
  x + t â¢ y â s :=
begin
  have h : x + t â¢ y = (1 - t) â¢ x + t â¢ (x + y),
  { rw [smul_add, âadd_assoc, âadd_smul, sub_add_cancel, one_smul] },
  rw h,
  exact hs hy (sub_nonneg_of_le htâ) htâ (sub_add_cancel _ _),
end

lemma star_convex.smul_mem (hs : star_convex ð 0 s) (hx : x â s) {t : ð} (htâ : 0 â¤ t)
  (htâ : t â¤ 1) :
  t â¢ x â s :=
by simpa using hs.add_smul_mem (by simpa using hx) htâ htâ

lemma star_convex.add_smul_sub_mem (hs : star_convex ð x s) (hy : y â s) {t : ð} (htâ : 0 â¤ t)
  (htâ : t â¤ 1) :
  x + t â¢ (y - x) â s :=
begin
  apply hs.segment_subset hy,
  rw segment_eq_image',
  exact mem_image_of_mem _ â¨htâ, htââ©,
end

/-- The preimage of a star-convex set under an affine map is star-convex. -/
lemma star_convex.affine_preimage (f : E âáµ[ð] F) {s : set F} (hs : star_convex ð (f x) s) :
  star_convex ð x (f â»Â¹' s) :=
begin
  intros y hy a b ha hb hab,
  rw [mem_preimage, convex.combo_affine_apply hab],
  exact hs hy ha hb hab,
end

/-- The image of a star-convex set under an affine map is star-convex. -/
lemma star_convex.affine_image (f : E âáµ[ð] F) {s : set E} (hs : star_convex ð x s) :
  star_convex ð (f x) (f '' s) :=
begin
  rintro y â¨y', â¨hy', hy'fâ©â© a b ha hb hab,
  refine â¨a â¢ x + b â¢ y', â¨hs hy' ha hb hab, _â©â©,
  rw [convex.combo_affine_apply hab, hy'f],
end

lemma star_convex.neg (hs : star_convex ð x s) : star_convex ð (-x) ((Î» z, -z) '' s) :=
hs.is_linear_image is_linear_map.is_linear_map_neg

lemma star_convex.neg_preimage (hs : star_convex ð (-x) s) : star_convex ð x ((Î» z, -z) â»Â¹' s) :=
hs.is_linear_preimage is_linear_map.is_linear_map_neg

end add_comm_group
end ordered_ring

section linear_ordered_field
variables [linear_ordered_field ð]

section add_comm_group
variables [add_comm_group E] [module ð E] {x : E} {s : set E}

/-- Alternative definition of star-convexity, using division. -/
lemma star_convex_iff_div :
  star_convex ð x s â â â¦yâ¦, y â s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â 0 < a + b â
    (a / (a + b)) â¢ x + (b / (a + b)) â¢ y â s :=
â¨Î» h y hy a b ha hb hab, begin
  apply h hy,
  { have ha', from mul_le_mul_of_nonneg_left ha (inv_pos.2 hab).le,
    rwa [mul_zero, âdiv_eq_inv_mul] at ha' },
  { have hb', from mul_le_mul_of_nonneg_left hb (inv_pos.2 hab).le,
    rwa [mul_zero, âdiv_eq_inv_mul] at hb' },
  { rw âadd_div,
    exact div_self hab.ne' }
end, Î» h y hy a b ha hb hab,
begin
  have h', from h hy ha hb,
  rw [hab, div_one, div_one] at h',
  exact h' zero_lt_one
endâ©

lemma star_convex.mem_smul (hs : star_convex ð 0 s) (hx : x â s) {t : ð} (ht : 1 â¤ t) :
  x â t â¢ s :=
begin
  rw mem_smul_set_iff_inv_smul_memâ (zero_lt_one.trans_le ht).ne',
  exact hs.smul_mem hx (inv_nonneg.2 $ zero_le_one.trans ht) (inv_le_one ht),
end

end add_comm_group
end linear_ordered_field

/-!
#### Star-convex sets in an ordered space

Relates `star_convex` and `set.ord_connected`.
-/

section ord_connected

lemma set.ord_connected.star_convex [ordered_semiring ð] [ordered_add_comm_monoid E]
  [module ð E] [ordered_smul ð E] {x : E} {s : set E} (hs : s.ord_connected) (hx : x â s)
  (h : â y â s, x â¤ y â¨ y â¤ x) :
  star_convex ð x s :=
begin
  intros y hy a b ha hb hab,
  obtain hxy | hyx := h _ hy,
  { refine hs.out hx hy (mem_Icc.2 â¨_, _â©),
    calc
      x   = a â¢ x + b â¢ x : (convex.combo_self hab _).symm
      ... â¤ a â¢ x + b â¢ y : add_le_add_left (smul_le_smul_of_nonneg hxy hb) _,
    calc
      a â¢ x + b â¢ y
          â¤ a â¢ y + b â¢ y : add_le_add_right (smul_le_smul_of_nonneg hxy ha) _
      ... = y             : convex.combo_self hab _ },
  { refine hs.out hy hx (mem_Icc.2 â¨_, _â©),
    calc
      y   = a â¢ y + b â¢ y : (convex.combo_self hab _).symm
      ... â¤ a â¢ x + b â¢ y : add_le_add_right (smul_le_smul_of_nonneg hyx ha) _,
    calc
      a â¢ x + b â¢ y
          â¤ a â¢ x + b â¢ x : add_le_add_left (smul_le_smul_of_nonneg hyx hb) _
      ... = x             : convex.combo_self hab _ }
end

lemma star_convex_iff_ord_connected [linear_ordered_field ð] {x : ð} {s : set ð} (hx : x â s) :
  star_convex ð x s â s.ord_connected :=
by simp_rw [ord_connected_iff_interval_subset_left hx, star_convex_iff_segment_subset,
  segment_eq_interval]

alias star_convex_iff_ord_connected â star_convex.ord_connected _

end ord_connected

/-! #### Star-convexity of submodules/subspaces -/

section submodule
open submodule

lemma submodule.star_convex [ordered_semiring ð] [add_comm_monoid E] [module ð E]
  (K : submodule ð E) :
  star_convex ð (0 : E) K :=
K.convex.star_convex K.zero_mem

lemma subspace.star_convex [linear_ordered_field ð] [add_comm_group E] [module ð E]
  (K : subspace ð E) :
  star_convex ð (0 : E) K :=
K.convex.star_convex K.zero_mem

end submodule
