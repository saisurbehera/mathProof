/-
Copyright (c) 2019 Alexander Bentkamp. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp, Yury Kudriashov, YaÃ«l Dillies
-/
import algebra.order.invertible
import algebra.order.module
import linear_algebra.affine_space.midpoint
import linear_algebra.affine_space.affine_subspace
import linear_algebra.ray

/-!
# Convex sets and functions in vector spaces

In a ð-vector space, we define the following objects and properties.
* `segment ð x y`: Closed segment joining `x` and `y`.
* `open_segment ð x y`: Open segment joining `x` and `y`.
* `convex ð s`: A set `s` is convex if for any two points `x y â s` it includes `segment ð x y`.
* `std_simplex ð Î¹`: The standard simplex in `Î¹ â ð` (currently requires `fintype Î¹`). It is the
  intersection of the positive quadrant with the hyperplane `s.sum = 1`.

We also provide various equivalent versions of the definitions above, prove that some specific sets
are convex.

## Notations

We provide the following notation:
* `[x -[ð] y] = segment ð x y` in locale `convex`

## TODO

Generalize all this file to affine spaces.

Should we rename `segment` and `open_segment` to `convex.Icc` and `convex.Ioo`? Should we also
define `clopen_segment`/`convex.Ico`/`convex.Ioc`?
-/

variables {ð E F Î² : Type*}

open linear_map set
open_locale big_operators classical pointwise

/-! ### Segment -/

section ordered_semiring
variables [ordered_semiring ð] [add_comm_monoid E]

section has_scalar
variables (ð) [has_scalar ð E]

/-- Segments in a vector space. -/
def segment (x y : E) : set E :=
{z : E | â (a b : ð) (ha : 0 â¤ a) (hb : 0 â¤ b) (hab : a + b = 1), a â¢ x + b â¢ y = z}

/-- Open segment in a vector space. Note that `open_segment ð x x = {x}` instead of being `â` when
the base semiring has some element between `0` and `1`. -/
def open_segment (x y : E) : set E :=
{z : E | â (a b : ð) (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1), a â¢ x + b â¢ y = z}

localized "notation `[` x ` -[` ð `] ` y `]` := segment ð x y" in convex

lemma segment_eq_imageâ (x y : E) :
  [x -[ð] y] = (Î» p : ð Ã ð, p.1 â¢ x + p.2 â¢ y) '' {p | 0 â¤ p.1 â§ 0 â¤ p.2 â§ p.1 + p.2 = 1} :=
by simp only [segment, image, prod.exists, mem_set_of_eq, exists_prop, and_assoc]

lemma open_segment_eq_imageâ (x y : E) :
  open_segment ð x y =
    (Î» p : ð Ã ð, p.1 â¢ x + p.2 â¢ y) '' {p | 0 < p.1 â§ 0 < p.2 â§ p.1 + p.2 = 1} :=
by simp only [open_segment, image, prod.exists, mem_set_of_eq, exists_prop, and_assoc]

lemma segment_symm (x y : E) : [x -[ð] y] = [y -[ð] x] :=
set.ext $ Î» z,
â¨Î» â¨a, b, ha, hb, hab, Hâ©, â¨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans Hâ©,
  Î» â¨a, b, ha, hb, hab, Hâ©, â¨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans Hâ©â©

lemma open_segment_symm (x y : E) :
  open_segment ð x y = open_segment ð y x :=
set.ext $ Î» z,
â¨Î» â¨a, b, ha, hb, hab, Hâ©, â¨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans Hâ©,
  Î» â¨a, b, ha, hb, hab, Hâ©, â¨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans Hâ©â©

lemma open_segment_subset_segment (x y : E) :
  open_segment ð x y â [x -[ð] y] :=
Î» z â¨a, b, ha, hb, hab, hzâ©, â¨a, b, ha.le, hb.le, hab, hzâ©

lemma segment_subset_iff {x y : E} {s : set E} :
  [x -[ð] y] â s â â a b : ð, 0 â¤ a â 0 â¤ b â a + b = 1 â a â¢ x + b â¢ y â s :=
â¨Î» H a b ha hb hab, H â¨a, b, ha, hb, hab, rflâ©,
  Î» H z â¨a, b, ha, hb, hab, hzâ©, hz â¸ H a b ha hb habâ©

lemma open_segment_subset_iff {x y : E} {s : set E} :
  open_segment ð x y â s â â a b : ð, 0 < a â 0 < b â a + b = 1 â a â¢ x + b â¢ y â s :=
â¨Î» H a b ha hb hab, H â¨a, b, ha, hb, hab, rflâ©,
  Î» H z â¨a, b, ha, hb, hab, hzâ©, hz â¸ H a b ha hb habâ©

end has_scalar

open_locale convex

section mul_action_with_zero
variables (ð) [mul_action_with_zero ð E]

lemma left_mem_segment (x y : E) : x â [x -[ð] y] :=
â¨1, 0, zero_le_one, le_refl 0, add_zero 1, by rw [zero_smul, one_smul, add_zero]â©

lemma right_mem_segment (x y : E) : y â [x -[ð] y] :=
segment_symm ð y x â¸ left_mem_segment ð y x

end mul_action_with_zero

section module
variables (ð) [module ð E]

@[simp] lemma segment_same (x : E) : [x -[ð] x] = {x} :=
set.ext $ Î» z, â¨Î» â¨a, b, ha, hb, hab, hzâ©,
  by simpa only [(add_smul _ _ _).symm, mem_singleton_iff, hab, one_smul, eq_comm] using hz,
  Î» h, mem_singleton_iff.1 h â¸ left_mem_segment ð z zâ©

lemma mem_open_segment_of_ne_left_right {x y z : E} (hx : x â  z) (hy : y â  z)
  (hz : z â [x -[ð] y]) :
  z â open_segment ð x y :=
begin
  obtain â¨a, b, ha, hb, hab, hzâ© := hz,
  by_cases ha' : a = 0,
  { rw [ha', zero_add] at hab,
    rw [ha', hab, zero_smul, one_smul, zero_add] at hz,
    exact (hy hz).elim },
  by_cases hb' : b = 0,
  { rw [hb', add_zero] at hab,
    rw [hb', hab, zero_smul, one_smul, add_zero] at hz,
    exact (hx hz).elim },
  exact â¨a, b, ha.lt_of_ne (ne.symm ha'), hb.lt_of_ne (ne.symm hb'), hab, hzâ©,
end

variables {ð}

lemma open_segment_subset_iff_segment_subset {x y : E} {s : set E} (hx : x â s) (hy : y â s) :
  open_segment ð x y â s â [x -[ð] y] â s :=
begin
  refine â¨Î» h z hz, _, (open_segment_subset_segment ð x y).transâ©,
  obtain rfl | hxz := eq_or_ne x z,
  { exact hx },
  obtain rfl | hyz := eq_or_ne y z,
  { exact hy },
  exact h (mem_open_segment_of_ne_left_right ð hxz hyz hz),
end

lemma convex.combo_self {a b : ð} (h : a + b = 1) (x : E) : a â¢ x + b â¢ x = x :=
by rw [âadd_smul, h, one_smul]

end module
end ordered_semiring

open_locale convex

section ordered_ring
variables [ordered_ring ð]

section add_comm_group
variables (ð) [add_comm_group E] [add_comm_group F] [module ð E] [module ð F]

section densely_ordered
variables [nontrivial ð] [densely_ordered ð]

@[simp] lemma open_segment_same (x : E) :
  open_segment ð x x = {x} :=
set.ext $ Î» z, â¨Î» â¨a, b, ha, hb, hab, hzâ©,
  by simpa only [â add_smul, mem_singleton_iff, hab, one_smul, eq_comm] using hz,
  Î» (h : z = x), begin
    obtain â¨a, haâ, haââ© := densely_ordered.dense (0 : ð) 1 zero_lt_one,
    refine â¨a, 1 - a, haâ, sub_pos_of_lt haâ, add_sub_cancel'_right _ _, _â©,
    rw [âadd_smul, add_sub_cancel'_right, one_smul, h],
  endâ©

end densely_ordered

lemma segment_eq_image (x y : E) : [x -[ð] y] = (Î» Î¸ : ð, (1 - Î¸) â¢ x + Î¸ â¢ y) '' Icc (0 : ð) 1 :=
set.ext $ Î» z,
  â¨Î» â¨a, b, ha, hb, hab, hzâ©,
    â¨b, â¨hb, hab â¸ le_add_of_nonneg_left haâ©, hab â¸ hz â¸ by simp only [add_sub_cancel]â©,
    Î» â¨Î¸, â¨hÎ¸â, hÎ¸ââ©, hzâ©, â¨1-Î¸, Î¸, sub_nonneg.2 hÎ¸â, hÎ¸â, sub_add_cancel _ _, hzâ©â©

lemma open_segment_eq_image (x y : E) :
  open_segment ð x y = (Î» (Î¸ : ð), (1 - Î¸) â¢ x + Î¸ â¢ y) '' Ioo (0 : ð) 1 :=
set.ext $ Î» z,
  â¨Î» â¨a, b, ha, hb, hab, hzâ©,
    â¨b, â¨hb, hab â¸ lt_add_of_pos_left _ haâ©, hab â¸ hz â¸ by simp only [add_sub_cancel]â©,
    Î» â¨Î¸, â¨hÎ¸â, hÎ¸ââ©, hzâ©, â¨1 - Î¸, Î¸, sub_pos.2 hÎ¸â, hÎ¸â, sub_add_cancel _ _, hzâ©â©

lemma segment_eq_image' (x y : E) :
  [x -[ð] y] = (Î» (Î¸ : ð), x + Î¸ â¢ (y - x)) '' Icc (0 : ð) 1 :=
by { convert segment_eq_image ð x y, ext Î¸, simp only [smul_sub, sub_smul, one_smul], abel }

lemma open_segment_eq_image' (x y : E) :
  open_segment ð x y = (Î» (Î¸ : ð), x + Î¸ â¢ (y - x)) '' Ioo (0 : ð) 1 :=
by { convert open_segment_eq_image ð x y, ext Î¸, simp only [smul_sub, sub_smul, one_smul], abel }

lemma segment_eq_image_line_map (x y : E) :
  [x -[ð] y] = affine_map.line_map x y '' Icc (0 : ð) 1 :=
by { convert segment_eq_image ð x y, ext, exact affine_map.line_map_apply_module _ _ _ }

lemma open_segment_eq_image_line_map (x y : E) :
  open_segment ð x y = affine_map.line_map x y '' Ioo (0 : ð) 1 :=
by { convert open_segment_eq_image ð x y, ext, exact affine_map.line_map_apply_module _ _ _ }

lemma segment_image (f : E ââ[ð] F) (a b : E) : f '' [a -[ð] b] = [f a -[ð] f b] :=
set.ext (Î» x, by simp_rw [segment_eq_image, mem_image, exists_exists_and_eq_and, map_add, map_smul])

@[simp] lemma open_segment_image (f : E ââ[ð] F) (a b : E) :
  f '' open_segment ð a b = open_segment ð (f a) (f b) :=
set.ext (Î» x, by simp_rw [open_segment_eq_image, mem_image, exists_exists_and_eq_and, map_add,
  map_smul])

lemma mem_segment_translate (a : E) {x b c} : a + x â [a + b -[ð] a + c] â x â [b -[ð] c] :=
begin
  rw [segment_eq_image', segment_eq_image'],
  refine exists_congr (Î» Î¸, and_congr iff.rfl _),
  simp only [add_sub_add_left_eq_sub, add_assoc, add_right_inj],
end

@[simp] lemma mem_open_segment_translate (a : E) {x b c : E} :
  a + x â open_segment ð (a + b) (a + c) â x â open_segment ð b c :=
begin
  rw [open_segment_eq_image', open_segment_eq_image'],
  refine exists_congr (Î» Î¸, and_congr iff.rfl _),
  simp only [add_sub_add_left_eq_sub, add_assoc, add_right_inj],
end

lemma segment_translate_preimage (a b c : E) : (Î» x, a + x) â»Â¹' [a + b -[ð] a + c] = [b -[ð] c] :=
set.ext $ Î» x, mem_segment_translate ð a

lemma open_segment_translate_preimage (a b c : E) :
  (Î» x, a + x) â»Â¹' open_segment ð (a + b) (a + c) = open_segment ð b c :=
set.ext $ Î» x, mem_open_segment_translate ð a

lemma segment_translate_image (a b c : E) : (Î» x, a + x) '' [b -[ð] c] = [a + b -[ð] a + c] :=
segment_translate_preimage ð a b c â¸ image_preimage_eq _ $ add_left_surjective a

lemma open_segment_translate_image (a b c : E) :
  (Î» x, a + x) '' open_segment ð b c = open_segment ð (a + b) (a + c) :=
open_segment_translate_preimage ð a b c â¸ image_preimage_eq _ $ add_left_surjective a

end add_comm_group
end ordered_ring

lemma same_ray_of_mem_segment [ordered_comm_ring ð] [add_comm_group E] [module ð E]
  {x y z : E} (h : x â [y -[ð] z]) : same_ray ð (x - y) (z - x) :=
begin
  rw segment_eq_image' at h,
  rcases h with â¨Î¸, â¨hÎ¸â, hÎ¸ââ©, rflâ©,
  simpa only [add_sub_cancel', â sub_sub, sub_smul, one_smul]
    using (same_ray_nonneg_smul_left (z - y) hÎ¸â).nonneg_smul_right (sub_nonneg.2 hÎ¸â)
end

section linear_ordered_ring
variables [linear_ordered_ring ð]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F]

lemma midpoint_mem_segment [invertible (2 : ð)] (x y : E) :
  midpoint ð x y â [x -[ð] y] :=
begin
  rw segment_eq_image_line_map,
  exact â¨â2, â¨inv_of_nonneg.mpr zero_le_two, inv_of_le_one one_le_twoâ©, rflâ©,
end

lemma mem_segment_sub_add [invertible (2 : ð)] (x y : E) :
  x â [x-y -[ð] x+y] :=
begin
  convert @midpoint_mem_segment ð _ _ _ _ _ _ _,
  rw midpoint_sub_add
end

lemma mem_segment_add_sub [invertible (2 : ð)] (x y : E) :
  x â [x+y -[ð] x-y] :=
begin
  convert @midpoint_mem_segment ð _ _ _ _ _ _ _,
  rw midpoint_add_sub
end

end add_comm_group
end linear_ordered_ring

section linear_ordered_field
variables [linear_ordered_field ð]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F]

lemma mem_segment_iff_same_ray {x y z : E} :
  x â [y -[ð] z] â same_ray ð (x - y) (z - x) :=
begin
  refine â¨same_ray_of_mem_segment, Î» h, _â©,
  rcases h.exists_eq_smul_add with â¨a, b, ha, hb, hab, hxy, hzxâ©,
  rw [add_comm, sub_add_sub_cancel] at hxy hzx,
  rw [â mem_segment_translate _ (-x), neg_add_self],
  refine â¨b, a, hb, ha, add_comm a b â¸ hab, _â©,
  rw [â sub_eq_neg_add, â neg_sub, hxy, â sub_eq_neg_add, hzx, smul_neg, smul_comm, neg_add_self]
end

lemma mem_segment_iff_div {x y z : E} : x â [y -[ð] z] â
  â a b : ð, 0 â¤ a â§ 0 â¤ b â§ 0 < a + b â§ (a / (a + b)) â¢ y + (b / (a + b)) â¢ z = x :=
begin
  split,
  { rintro â¨a, b, ha, hb, hab, rflâ©,
    use [a, b, ha, hb],
    simp * },
  { rintro â¨a, b, ha, hb, hab, rflâ©,
    refine â¨a / (a + b), b / (a + b), div_nonneg ha hab.le, div_nonneg hb hab.le, _, rflâ©,
    rw [â add_div, div_self hab.ne'] }
end

lemma mem_open_segment_iff_div {x y z : E} : x â open_segment ð y z â
  â a b : ð, 0 < a â§ 0 < b â§ (a / (a + b)) â¢ y + (b / (a + b)) â¢ z = x :=
begin
  split,
  { rintro â¨a, b, ha, hb, hab, rflâ©,
    use [a, b, ha, hb],
    rw [hab, div_one, div_one] },
  { rintro â¨a, b, ha, hb, rflâ©,
    have hab : 0 < a + b, from add_pos ha hb,
    refine â¨a / (a + b), b / (a + b), div_pos ha hab, div_pos hb hab, _, rflâ©,
    rw [â add_div, div_self hab.ne'] }
end

@[simp] lemma left_mem_open_segment_iff [no_zero_smul_divisors ð E] {x y : E} :
  x â open_segment ð x y â x = y :=
begin
  split,
  { rintro â¨a, b, ha, hb, hab, hxâ©,
    refine smul_right_injective _ hb.ne' ((add_right_inj (a â¢ x)).1 _),
    rw [hx, âadd_smul, hab, one_smul] },
  { rintro rfl,
    rw open_segment_same,
    exact mem_singleton _ }
end

@[simp] lemma right_mem_open_segment_iff {x y : E} :
  y â open_segment ð x y â x = y :=
by rw [open_segment_symm, left_mem_open_segment_iff, eq_comm]

end add_comm_group
end linear_ordered_field

/-!
#### Segments in an ordered space
Relates `segment`, `open_segment` and `set.Icc`, `set.Ico`, `set.Ioc`, `set.Ioo`
-/
section ordered_semiring
variables [ordered_semiring ð]

section ordered_add_comm_monoid
variables [ordered_add_comm_monoid E] [module ð E] [ordered_smul ð E]

lemma segment_subset_Icc {x y : E} (h : x â¤ y) : [x -[ð] y] â Icc x y :=
begin
  rintro z â¨a, b, ha, hb, hab, rflâ©,
  split,
  calc
    x   = a â¢ x + b â¢ x :(convex.combo_self hab _).symm
    ... â¤ a â¢ x + b â¢ y : add_le_add_left (smul_le_smul_of_nonneg h hb) _,
  calc
    a â¢ x + b â¢ y
        â¤ a â¢ y + b â¢ y : add_le_add_right (smul_le_smul_of_nonneg h ha) _
    ... = y : convex.combo_self hab _,
end

end ordered_add_comm_monoid

section ordered_cancel_add_comm_monoid
variables [ordered_cancel_add_comm_monoid E] [module ð E] [ordered_smul ð E]

lemma open_segment_subset_Ioo {x y : E} (h : x < y) : open_segment ð x y â Ioo x y :=
begin
  rintro z â¨a, b, ha, hb, hab, rflâ©,
  split,
  calc
    x   = a â¢ x + b â¢ x : (convex.combo_self hab _).symm
    ... < a â¢ x + b â¢ y : add_lt_add_left (smul_lt_smul_of_pos h hb) _,
  calc
    a â¢ x + b â¢ y
        < a â¢ y + b â¢ y : add_lt_add_right (smul_lt_smul_of_pos h ha) _
    ... = y : convex.combo_self hab _,
end

end ordered_cancel_add_comm_monoid

section linear_ordered_add_comm_monoid
variables [linear_ordered_add_comm_monoid E] [module ð E] [ordered_smul ð E] {ð}

lemma segment_subset_interval (x y : E) : [x -[ð] y] â interval x y :=
begin
  cases le_total x y,
  { rw interval_of_le h,
    exact segment_subset_Icc h },
  { rw [interval_of_ge h, segment_symm],
    exact segment_subset_Icc h }
end

lemma convex.min_le_combo (x y : E) {a b : ð} (ha : 0 â¤ a) (hb : 0 â¤ b) (hab : a + b = 1) :
  min x y â¤ a â¢ x + b â¢ y :=
(segment_subset_interval x y â¨_, _, ha, hb, hab, rflâ©).1

lemma convex.combo_le_max (x y : E) {a b : ð} (ha : 0 â¤ a) (hb : 0 â¤ b) (hab : a + b = 1) :
  a â¢ x + b â¢ y â¤ max x y :=
(segment_subset_interval x y â¨_, _, ha, hb, hab, rflâ©).2

end linear_ordered_add_comm_monoid
end ordered_semiring

section linear_ordered_field
variables [linear_ordered_field ð]

lemma Icc_subset_segment {x y : ð} : Icc x y â [x -[ð] y] :=
begin
  rintro z â¨hxz, hyzâ©,
  obtain rfl | h := (hxz.trans hyz).eq_or_lt,
  { rw segment_same,
    exact hyz.antisymm hxz },
  rw âsub_nonneg at hxz hyz,
  rw âsub_pos at h,
  refine â¨(y - z) / (y - x), (z - x) / (y - x), div_nonneg hyz h.le, div_nonneg hxz h.le, _, _â©,
  { rw [âadd_div, sub_add_sub_cancel, div_self h.ne'] },
  { rw [smul_eq_mul, smul_eq_mul, âmul_div_right_comm, âmul_div_right_comm, âadd_div,
      div_eq_iff h.ne', add_comm, sub_mul, sub_mul, mul_comm x, sub_add_sub_cancel, mul_sub] }
end

@[simp] lemma segment_eq_Icc {x y : ð} (h : x â¤ y) : [x -[ð] y] = Icc x y :=
(segment_subset_Icc h).antisymm Icc_subset_segment

lemma Ioo_subset_open_segment {x y : ð} : Ioo x y â open_segment ð x y :=
Î» z hz, mem_open_segment_of_ne_left_right _ hz.1.ne hz.2.ne'
    (Icc_subset_segment $ Ioo_subset_Icc_self hz)

@[simp] lemma open_segment_eq_Ioo {x y : ð} (h : x < y) : open_segment ð x y = Ioo x y :=
(open_segment_subset_Ioo h).antisymm Ioo_subset_open_segment

lemma segment_eq_Icc' (x y : ð) : [x -[ð] y] = Icc (min x y) (max x y) :=
begin
  cases le_total x y,
  { rw [segment_eq_Icc h, max_eq_right h, min_eq_left h] },
  { rw [segment_symm, segment_eq_Icc h, max_eq_left h, min_eq_right h] }
end

lemma open_segment_eq_Ioo' {x y : ð} (hxy : x â  y) :
  open_segment ð x y = Ioo (min x y) (max x y) :=
begin
  cases hxy.lt_or_lt,
  { rw [open_segment_eq_Ioo h, max_eq_right h.le, min_eq_left h.le] },
  { rw [open_segment_symm, open_segment_eq_Ioo h, max_eq_left h.le, min_eq_right h.le] }
end

lemma segment_eq_interval (x y : ð) : [x -[ð] y] = interval x y :=
segment_eq_Icc' _ _

/-- A point is in an `Icc` iff it can be expressed as a convex combination of the endpoints. -/
lemma convex.mem_Icc {x y : ð} (h : x â¤ y) {z : ð} :
  z â Icc x y â â (a b : ð), 0 â¤ a â§ 0 â¤ b â§ a + b = 1 â§ a * x + b * y = z :=
begin
  rw âsegment_eq_Icc h,
  simp_rw [âexists_prop],
  refl,
end

/-- A point is in an `Ioo` iff it can be expressed as a strict convex combination of the endpoints.
-/
lemma convex.mem_Ioo {x y : ð} (h : x < y) {z : ð} :
  z â Ioo x y â â (a b : ð), 0 < a â§ 0 < b â§ a + b = 1 â§ a * x + b * y = z :=
begin
  rw âopen_segment_eq_Ioo h,
  simp_rw [âexists_prop],
  refl,
end

/-- A point is in an `Ioc` iff it can be expressed as a semistrict convex combination of the
endpoints. -/
lemma convex.mem_Ioc {x y : ð} (h : x < y) {z : ð} :
  z â Ioc x y â â (a b : ð), 0 â¤ a â§ 0 < b â§ a + b = 1 â§ a * x + b * y = z :=
begin
  split,
  { rintro hz,
    obtain â¨a, b, ha, hb, hab, rflâ© := (convex.mem_Icc h.le).1 (Ioc_subset_Icc_self hz),
    obtain rfl | hb' := hb.eq_or_lt,
    { rw add_zero at hab,
      rw [hab, one_mul, zero_mul, add_zero] at hz,
      exact (hz.1.ne rfl).elim },
    { exact â¨a, b, ha, hb', hab, rflâ© } },
  { rintro â¨a, b, ha, hb, hab, rflâ©,
    obtain rfl | ha' := ha.eq_or_lt,
    { rw zero_add at hab,
      rwa [hab, one_mul, zero_mul, zero_add, right_mem_Ioc] },
    { exact Ioo_subset_Ioc_self ((convex.mem_Ioo h).2 â¨a, b, ha', hb, hab, rflâ©) } }
end

/-- A point is in an `Ico` iff it can be expressed as a semistrict convex combination of the
endpoints. -/
lemma convex.mem_Ico {x y : ð} (h : x < y) {z : ð} :
  z â Ico x y â â (a b : ð), 0 < a â§ 0 â¤ b â§ a + b = 1 â§ a * x + b * y = z :=
begin
  split,
  { rintro hz,
    obtain â¨a, b, ha, hb, hab, rflâ© := (convex.mem_Icc h.le).1 (Ico_subset_Icc_self hz),
    obtain rfl | ha' := ha.eq_or_lt,
    { rw zero_add at hab,
      rw [hab, one_mul, zero_mul, zero_add] at hz,
      exact (hz.2.ne rfl).elim },
    { exact â¨a, b, ha', hb, hab, rflâ© } },
  { rintro â¨a, b, ha, hb, hab, rflâ©,
    obtain rfl | hb' := hb.eq_or_lt,
    { rw add_zero at hab,
      rwa [hab, one_mul, zero_mul, add_zero, left_mem_Ico] },
    { exact Ioo_subset_Ico_self ((convex.mem_Ioo h).2 â¨a, b, ha, hb', hab, rflâ©) } }
end

end linear_ordered_field

/-! ### Convexity of sets -/

section ordered_semiring
variables [ordered_semiring ð]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F]

section has_scalar
variables (ð) [has_scalar ð E] [has_scalar ð F] (s : set E)

/-- Convexity of sets. -/
def convex : Prop :=
â â¦x y : Eâ¦, x â s â y â s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â
  a â¢ x + b â¢ y â s

variables {ð s}

lemma convex_iff_segment_subset :
  convex ð s â â â¦x yâ¦, x â s â y â s â [x -[ð] y] â s :=
forallâ_congr $ Î» x y hx hy, (segment_subset_iff _).symm

lemma convex.segment_subset (h : convex ð s) {x y : E} (hx : x â s) (hy : y â s) :
  [x -[ð] y] â s :=
convex_iff_segment_subset.1 h hx hy

lemma convex.open_segment_subset (h : convex ð s) {x y : E} (hx : x â s) (hy : y â s) :
  open_segment ð x y â s :=
(open_segment_subset_segment ð x y).trans (h.segment_subset hx hy)

/-- Alternative definition of set convexity, in terms of pointwise set operations. -/
lemma convex_iff_pointwise_add_subset :
  convex ð s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â a â¢ s + b â¢ s â s :=
iff.intro
  begin
    rintro hA a b ha hb hab w â¨au, bv, â¨u, hu, rflâ©, â¨v, hv, rflâ©, rflâ©,
    exact hA hu hv ha hb hab
  end
  (Î» h x y hx hy a b ha hb hab,
    (h ha hb hab) (set.add_mem_add â¨_, hx, rflâ© â¨_, hy, rflâ©))

alias convex_iff_pointwise_add_subset â convex.set_combo_subset _

lemma convex_empty : convex ð (â : set E) :=
Î» x y, false.elim

lemma convex_univ : convex ð (set.univ : set E) := Î» _ _ _ _ _ _ _ _ _, trivial

lemma convex.inter {t : set E} (hs : convex ð s) (ht : convex ð t) : convex ð (s â© t) :=
Î» x y (hx : x â s â© t) (hy : y â s â© t) a b (ha : 0 â¤ a) (hb : 0 â¤ b) (hab : a + b = 1),
  â¨hs hx.left hy.left ha hb hab, ht hx.right hy.right ha hb habâ©

lemma convex_sInter {S : set (set E)} (h : â s â S, convex ð s) : convex ð (ââ S) :=
assume x y hx hy a b ha hb hab s hs,
h s hs (hx s hs) (hy s hs) ha hb hab

lemma convex_Inter {Î¹ : Sort*} {s : Î¹ â set E} (h : â i : Î¹, convex ð (s i)) :
  convex ð (â i, s i) :=
(sInter_range s) â¸ convex_sInter $ forall_range_iff.2 h

lemma convex.prod {s : set E} {t : set F} (hs : convex ð s) (ht : convex ð t) :
  convex ð (s ÃË¢ t) :=
begin
  intros x y hx hy a b ha hb hab,
  apply mem_prod.2,
  exact â¨hs (mem_prod.1 hx).1 (mem_prod.1 hy).1 ha hb hab,
        ht (mem_prod.1 hx).2 (mem_prod.1 hy).2 ha hb habâ©
end

lemma convex_pi {Î¹ : Type*} {E : Î¹ â Type*} [Î  i, add_comm_monoid (E i)]
  [Î  i, has_scalar ð (E i)] {s : set Î¹} {t : Î  i, set (E i)} (ht : â i, convex ð (t i)) :
  convex ð (s.pi t) :=
Î» x y hx hy a b ha hb hab i hi, ht i (hx i hi) (hy i hi) ha hb hab

lemma directed.convex_Union {Î¹ : Sort*} {s : Î¹ â set E} (hdir : directed (â) s)
  (hc : â â¦i : Î¹â¦, convex ð (s i)) :
  convex ð (â i, s i) :=
begin
  rintro x y hx hy a b ha hb hab,
  rw mem_Union at â¢ hx hy,
  obtain â¨i, hxâ© := hx,
  obtain â¨j, hyâ© := hy,
  obtain â¨k, hik, hjkâ© := hdir i j,
  exact â¨k, hc (hik hx) (hjk hy) ha hb habâ©,
end

lemma directed_on.convex_sUnion {c : set (set E)} (hdir : directed_on (â) c)
  (hc : â â¦A : set Eâ¦, A â c â convex ð A) :
  convex ð (ââc) :=
begin
  rw sUnion_eq_Union,
  exact (directed_on_iff_directed.1 hdir).convex_Union (Î» A, hc A.2),
end

end has_scalar

section module
variables [module ð E] [module ð F] {s : set E}

lemma convex_iff_open_segment_subset :
  convex ð s â â â¦x yâ¦, x â s â y â s â open_segment ð x y â s :=
convex_iff_segment_subset.trans $ forallâ_congr $ Î» x y hx hy,
  (open_segment_subset_iff_segment_subset hx hy).symm

lemma convex_iff_forall_pos :
  convex ð s â â â¦x yâ¦, x â s â y â s â â â¦a b : ðâ¦, 0 < a â 0 < b â a + b = 1
  â a â¢ x + b â¢ y â s :=
convex_iff_open_segment_subset.trans $ forallâ_congr $ Î» x y hx hy,
  open_segment_subset_iff ð

lemma convex_iff_pairwise_pos :
  convex ð s â s.pairwise (Î» x y, â â¦a b : ðâ¦, 0 < a â 0 < b â a + b = 1 â a â¢ x + b â¢ y â s) :=
begin
  refine convex_iff_forall_pos.trans â¨Î» h x hx y hy _, h hx hy, _â©,
  intros h x y hx hy a b ha hb hab,
  obtain rfl | hxy := eq_or_ne x y,
  { rwa convex.combo_self hab },
  { exact h hx hy hxy ha hb hab },
end

protected lemma set.subsingleton.convex {s : set E} (h : s.subsingleton) : convex ð s :=
convex_iff_pairwise_pos.mpr (h.pairwise _)

lemma convex_singleton (c : E) : convex ð ({c} : set E) :=
subsingleton_singleton.convex

lemma convex.linear_image (hs : convex ð s) (f : E ââ[ð] F) : convex ð (f '' s) :=
begin
  intros x y hx hy a b ha hb hab,
  obtain â¨x', hx', rflâ© := mem_image_iff_bex.1 hx,
  obtain â¨y', hy', rflâ© := mem_image_iff_bex.1 hy,
  exact â¨a â¢ x' + b â¢ y', hs hx' hy' ha hb hab, by rw [f.map_add, f.map_smul, f.map_smul]â©,
end

lemma convex.is_linear_image (hs : convex ð s) {f : E â F} (hf : is_linear_map ð f) :
  convex ð (f '' s) :=
hs.linear_image $ hf.mk' f

lemma convex.linear_preimage {s : set F} (hs : convex ð s) (f : E ââ[ð] F) :
  convex ð (f â»Â¹' s) :=
begin
  intros x y hx hy a b ha hb hab,
  rw [mem_preimage, f.map_add, f.map_smul, f.map_smul],
  exact hs hx hy ha hb hab,
end

lemma convex.is_linear_preimage {s : set F} (hs : convex ð s) {f : E â F} (hf : is_linear_map ð f) :
  convex ð (f â»Â¹' s) :=
hs.linear_preimage $ hf.mk' f

lemma convex.add {t : set E} (hs : convex ð s) (ht : convex ð t) : convex ð (s + t) :=
by { rw â add_image_prod, exact (hs.prod ht).is_linear_image is_linear_map.is_linear_map_add }

lemma convex.translate (hs : convex ð s) (z : E) : convex ð ((Î» x, z + x) '' s) :=
begin
  intros x y hx hy a b ha hb hab,
  obtain â¨x', hx', rflâ© := mem_image_iff_bex.1 hx,
  obtain â¨y', hy', rflâ© := mem_image_iff_bex.1 hy,
  refine â¨a â¢ x' + b â¢ y', hs hx' hy' ha hb hab, _â©,
  rw [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul],
end

/-- The translation of a convex set is also convex. -/
lemma convex.translate_preimage_right (hs : convex ð s) (z : E) : convex ð ((Î» x, z + x) â»Â¹' s) :=
begin
  intros x y hx hy a b ha hb hab,
  have h := hs hx hy ha hb hab,
  rwa [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul] at h,
end

/-- The translation of a convex set is also convex. -/
lemma convex.translate_preimage_left (hs : convex ð s) (z : E) : convex ð ((Î» x, x + z) â»Â¹' s) :=
by simpa only [add_comm] using hs.translate_preimage_right z

section ordered_add_comm_monoid
variables [ordered_add_comm_monoid Î²] [module ð Î²] [ordered_smul ð Î²]

lemma convex_Iic (r : Î²) : convex ð (Iic r) :=
Î» x y hx hy a b ha hb hab,
calc
  a â¢ x + b â¢ y
      â¤ a â¢ r + b â¢ r
      : add_le_add (smul_le_smul_of_nonneg hx ha) (smul_le_smul_of_nonneg hy hb)
  ... = r : convex.combo_self hab _

lemma convex_Ici (r : Î²) : convex ð (Ici r) :=
@convex_Iic ð (order_dual Î²) _ _ _ _ r

lemma convex_Icc (r s : Î²) : convex ð (Icc r s) :=
Ici_inter_Iic.subst ((convex_Ici r).inter $ convex_Iic s)

lemma convex_halfspace_le {f : E â Î²} (h : is_linear_map ð f) (r : Î²) :
  convex ð {w | f w â¤ r} :=
(convex_Iic r).is_linear_preimage h

lemma convex_halfspace_ge {f : E â Î²} (h : is_linear_map ð f) (r : Î²) :
  convex ð {w | r â¤ f w} :=
(convex_Ici r).is_linear_preimage h

lemma convex_hyperplane {f : E â Î²} (h : is_linear_map ð f) (r : Î²) :
  convex ð {w | f w = r} :=
begin
  simp_rw le_antisymm_iff,
  exact (convex_halfspace_le h r).inter (convex_halfspace_ge h r),
end

end ordered_add_comm_monoid

section ordered_cancel_add_comm_monoid
variables [ordered_cancel_add_comm_monoid Î²] [module ð Î²] [ordered_smul ð Î²]

lemma convex_Iio (r : Î²) : convex ð (Iio r) :=
begin
  intros x y hx hy a b ha hb hab,
  obtain rfl | ha' := ha.eq_or_lt,
  { rw zero_add at hab,
    rwa [zero_smul, zero_add, hab, one_smul] },
  rw mem_Iio at hx hy,
  calc
    a â¢ x + b â¢ y
        < a â¢ r + b â¢ r
        : add_lt_add_of_lt_of_le (smul_lt_smul_of_pos hx ha') (smul_le_smul_of_nonneg hy.le hb)
    ... = r : convex.combo_self hab _
end

lemma convex_Ioi (r : Î²) : convex ð (Ioi r) :=
@convex_Iio ð (order_dual Î²) _ _ _ _ r

lemma convex_Ioo (r s : Î²) : convex ð (Ioo r s) :=
Ioi_inter_Iio.subst ((convex_Ioi r).inter $ convex_Iio s)

lemma convex_Ico (r s : Î²) : convex ð (Ico r s) :=
Ici_inter_Iio.subst ((convex_Ici r).inter $ convex_Iio s)

lemma convex_Ioc (r s : Î²) : convex ð (Ioc r s) :=
Ioi_inter_Iic.subst ((convex_Ioi r).inter $ convex_Iic s)

lemma convex_halfspace_lt {f : E â Î²} (h : is_linear_map ð f) (r : Î²) :
  convex ð {w | f w < r} :=
(convex_Iio r).is_linear_preimage h

lemma convex_halfspace_gt {f : E â Î²} (h : is_linear_map ð f) (r : Î²) :
  convex ð {w | r < f w} :=
(convex_Ioi r).is_linear_preimage h

end ordered_cancel_add_comm_monoid

section linear_ordered_add_comm_monoid
variables [linear_ordered_add_comm_monoid Î²] [module ð Î²] [ordered_smul ð Î²]

lemma convex_interval (r s : Î²) : convex ð (interval r s) :=
convex_Icc _ _

end linear_ordered_add_comm_monoid
end module
end add_comm_monoid

section linear_ordered_add_comm_monoid
variables [linear_ordered_add_comm_monoid E] [ordered_add_comm_monoid Î²] [module ð E]
  [ordered_smul ð E] {s : set E} {f : E â Î²}

lemma monotone_on.convex_le (hf : monotone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | f x â¤ r} :=
Î» x y hx hy a b ha hb hab, â¨hs hx.1 hy.1 ha hb hab,
  (hf (hs hx.1 hy.1 ha hb hab) (max_rec' s hx.1 hy.1) (convex.combo_le_max x y ha hb hab)).trans
    (max_rec' _ hx.2 hy.2)â©

lemma monotone_on.convex_lt (hf : monotone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | f x < r} :=
Î» x y hx hy a b ha hb hab, â¨hs hx.1 hy.1 ha hb hab,
  (hf (hs hx.1 hy.1 ha hb hab) (max_rec' s hx.1 hy.1) (convex.combo_le_max x y ha hb hab)).trans_lt
    (max_rec' _ hx.2 hy.2)â©

lemma monotone_on.convex_ge (hf : monotone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | r â¤ f x} :=
@monotone_on.convex_le ð (order_dual E) (order_dual Î²) _ _ _ _ _ _ _ hf.dual hs r

lemma monotone_on.convex_gt (hf : monotone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | r < f x} :=
@monotone_on.convex_lt ð (order_dual E) (order_dual Î²) _ _ _ _ _ _ _ hf.dual hs r

lemma antitone_on.convex_le (hf : antitone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | f x â¤ r} :=
@monotone_on.convex_ge ð E (order_dual Î²) _ _ _ _ _ _ _ hf hs r

lemma antitone_on.convex_lt (hf : antitone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | f x < r} :=
@monotone_on.convex_gt ð E (order_dual Î²) _ _ _ _ _ _ _ hf hs r

lemma antitone_on.convex_ge (hf : antitone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | r â¤ f x} :=
@monotone_on.convex_le ð E (order_dual Î²) _ _ _ _ _ _ _ hf hs r

lemma antitone_on.convex_gt (hf : antitone_on f s) (hs : convex ð s) (r : Î²) :
  convex ð {x â s | r < f x} :=
@monotone_on.convex_lt ð E (order_dual Î²) _ _ _ _ _ _ _ hf hs r

lemma monotone.convex_le (hf : monotone f) (r : Î²) :
  convex ð {x | f x â¤ r} :=
set.sep_univ.subst ((hf.monotone_on univ).convex_le convex_univ r)

lemma monotone.convex_lt (hf : monotone f) (r : Î²) :
  convex ð {x | f x â¤ r} :=
set.sep_univ.subst ((hf.monotone_on univ).convex_le convex_univ r)

lemma monotone.convex_ge (hf : monotone f ) (r : Î²) :
  convex ð {x | r â¤ f x} :=
set.sep_univ.subst ((hf.monotone_on univ).convex_ge convex_univ r)

lemma monotone.convex_gt (hf : monotone f) (r : Î²) :
  convex ð {x | f x â¤ r} :=
set.sep_univ.subst ((hf.monotone_on univ).convex_le convex_univ r)

lemma antitone.convex_le (hf : antitone f) (r : Î²) :
  convex ð {x | f x â¤ r} :=
set.sep_univ.subst ((hf.antitone_on univ).convex_le convex_univ r)

lemma antitone.convex_lt (hf : antitone f) (r : Î²) :
  convex ð {x | f x < r} :=
set.sep_univ.subst ((hf.antitone_on univ).convex_lt convex_univ r)

lemma antitone.convex_ge (hf : antitone f) (r : Î²) :
  convex ð {x | r â¤ f x} :=
set.sep_univ.subst ((hf.antitone_on univ).convex_ge convex_univ r)

lemma antitone.convex_gt (hf : antitone f) (r : Î²) :
  convex ð {x | r < f x} :=
set.sep_univ.subst ((hf.antitone_on univ).convex_gt convex_univ r)

end linear_ordered_add_comm_monoid

section add_comm_group
variables [add_comm_group E] [module ð E] {s t : set E}

lemma convex.combo_eq_vadd {a b : ð} {x y : E} (h : a + b = 1) :
  a â¢ x + b â¢ y = b â¢ (y - x) + x :=
calc
  a â¢ x + b â¢ y = (b â¢ y - b â¢ x) + (a â¢ x + b â¢ x) : by abel
            ... = b â¢ (y - x) + x                   : by rw [smul_sub, convex.combo_self h]

lemma convex.sub {s : set (E Ã E)} (hs : convex ð s) : convex ð ((Î» x : E Ã E, x.1 - x.2) '' s) :=
hs.is_linear_image is_linear_map.is_linear_map_sub

lemma convex_segment (x y : E) : convex ð [x -[ð] y] :=
begin
  rintro p q â¨ap, bp, hap, hbp, habp, rflâ© â¨aq, bq, haq, hbq, habq, rflâ© a b ha hb hab,
  refine â¨a * ap + b * aq, a * bp + b * bq,
    add_nonneg (mul_nonneg ha hap) (mul_nonneg hb haq),
    add_nonneg (mul_nonneg ha hbp) (mul_nonneg hb hbq), _, _â©,
  { rw [add_add_add_comm, âmul_add, âmul_add, habp, habq, mul_one, mul_one, hab] },
  { simp_rw [add_smul, mul_smul, smul_add],
    exact add_add_add_comm _ _ _ _ }
end

lemma convex_open_segment (a b : E) : convex ð (open_segment ð a b) :=
begin
  rw convex_iff_open_segment_subset,
  rintro p q â¨ap, bp, hap, hbp, habp, rflâ© â¨aq, bq, haq, hbq, habq, rflâ© z â¨a, b, ha, hb, hab, rflâ©,
  refine â¨a * ap + b * aq, a * bp + b * bq,
    add_pos (mul_pos ha hap) (mul_pos hb haq),
    add_pos (mul_pos ha hbp) (mul_pos hb hbq), _, _â©,
  { rw [add_add_add_comm, âmul_add, âmul_add, habp, habq, mul_one, mul_one, hab] },
  { simp_rw [add_smul, mul_smul, smul_add],
    exact add_add_add_comm _ _ _ _ }
end

end add_comm_group
end ordered_semiring

section ordered_comm_semiring
variables [ordered_comm_semiring ð]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F] [module ð E] [module ð F] {s : set E}

lemma convex.smul (hs : convex ð s) (c : ð) : convex ð (c â¢ s) :=
hs.linear_image (linear_map.lsmul _ _ c)

lemma convex.smul_preimage (hs : convex ð s) (c : ð) : convex ð ((Î» z, c â¢ z) â»Â¹' s) :=
hs.linear_preimage (linear_map.lsmul _ _ c)

lemma convex.affinity (hs : convex ð s) (z : E) (c : ð) : convex ð ((Î» x, z + c â¢ x) '' s) :=
begin
  have h := (hs.smul c).translate z,
  rwa [âimage_smul, image_image] at h,
end

end add_comm_monoid
end ordered_comm_semiring

section ordered_ring
variables [ordered_ring ð]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F] {s : set E}

lemma convex.add_smul_mem (hs : convex ð s) {x y : E} (hx : x â s) (hy : x + y â s)
  {t : ð} (ht : t â Icc (0 : ð) 1) : x + t â¢ y â s :=
begin
  have h : x + t â¢ y = (1 - t) â¢ x + t â¢ (x + y),
  { rw [smul_add, âadd_assoc, âadd_smul, sub_add_cancel, one_smul] },
  rw h,
  exact hs hx hy (sub_nonneg_of_le ht.2) ht.1 (sub_add_cancel _ _),
end

lemma convex.smul_mem_of_zero_mem (hs : convex ð s) {x : E} (zero_mem : (0 : E) â s) (hx : x â s)
  {t : ð} (ht : t â Icc (0 : ð) 1) : t â¢ x â s :=
by simpa using hs.add_smul_mem zero_mem (by simpa using hx) ht

lemma convex.add_smul_sub_mem (h : convex ð s) {x y : E} (hx : x â s) (hy : y â s)
  {t : ð} (ht : t â Icc (0 : ð) 1) : x + t â¢ (y - x) â s :=
begin
  apply h.segment_subset hx hy,
  rw segment_eq_image',
  exact mem_image_of_mem _ ht,
end

/-- Affine subspaces are convex. -/
lemma affine_subspace.convex (Q : affine_subspace ð E) : convex ð (Q : set E) :=
begin
  intros x y hx hy a b ha hb hab,
  rw [eq_sub_of_add_eq hab, â affine_map.line_map_apply_module],
  exact affine_map.line_map_mem b hx hy,
end

/--
Applying an affine map to an affine combination of two points yields
an affine combination of the images.
-/
lemma convex.combo_affine_apply {a b : ð} {x y : E} {f : E âáµ[ð] F} (h : a + b = 1) :
  f (a â¢ x + b â¢ y) = a â¢ f x + b â¢ f y :=
begin
  simp only [convex.combo_eq_vadd h, â vsub_eq_sub],
  exact f.apply_line_map _ _ _,
end

/-- The preimage of a convex set under an affine map is convex. -/
lemma convex.affine_preimage (f : E âáµ[ð] F) {s : set F} (hs : convex ð s) :
  convex ð (f â»Â¹' s) :=
begin
  intros x y xs ys a b ha hb hab,
  rw [mem_preimage, convex.combo_affine_apply hab],
  exact hs xs ys ha hb hab,
end

/-- The image of a convex set under an affine map is convex. -/
lemma convex.affine_image (f : E âáµ[ð] F) {s : set E} (hs : convex ð s) :
  convex ð (f '' s) :=
begin
  rintro x y â¨x', â¨hx', hx'fâ©â© â¨y', â¨hy', hy'fâ©â© a b ha hb hab,
  refine â¨a â¢ x' + b â¢ y', â¨hs hx' hy' ha hb hab, _â©â©,
  rw [convex.combo_affine_apply hab, hx'f, hy'f]
end

lemma convex.neg (hs : convex ð s) : convex ð ((Î» z, -z) '' s) :=
hs.is_linear_image is_linear_map.is_linear_map_neg

lemma convex.neg_preimage (hs : convex ð s) : convex ð ((Î» z, -z) â»Â¹' s) :=
hs.is_linear_preimage is_linear_map.is_linear_map_neg

end add_comm_group
end ordered_ring

section linear_ordered_field
variables [linear_ordered_field ð]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F] {s : set E}

/-- Alternative definition of set convexity, using division. -/
lemma convex_iff_div :
  convex ð s â â â¦x y : Eâ¦, x â s â y â s â â â¦a b : ðâ¦,
    0 â¤ a â 0 â¤ b â 0 < a + b â (a / (a + b)) â¢ x + (b / (a + b)) â¢ y â s :=
begin
  simp only [convex_iff_segment_subset, subset_def, mem_segment_iff_div],
  refine forallâ_congr (Î» x y hx hy, â¨Î» H a b ha hb hab, H _ â¨a, b, ha, hb, hab, rflâ©, _â©),
  rintro H _ â¨a, b, ha, hb, hab, rflâ©,
  exact H ha hb hab
end

lemma convex.mem_smul_of_zero_mem (h : convex ð s) {x : E} (zero_mem : (0 : E) â s)
  (hx : x â s) {t : ð} (ht : 1 â¤ t) :
  x â t â¢ s :=
begin
  rw mem_smul_set_iff_inv_smul_memâ (zero_lt_one.trans_le ht).ne',
  exact h.smul_mem_of_zero_mem zero_mem hx â¨inv_nonneg.2 (zero_le_one.trans ht), inv_le_one htâ©,
end

lemma convex.add_smul (h_conv : convex ð s) {p q : ð} (hp : 0 â¤ p) (hq : 0 â¤ q) :
  (p + q) â¢ s = p â¢ s + q â¢ s :=
begin
  obtain rfl | hs := s.eq_empty_or_nonempty,
  { simp_rw [smul_set_empty, add_empty] },
  obtain rfl | hp' := hp.eq_or_lt,
  { rw [zero_add, zero_smul_set hs, zero_add] },
  obtain rfl | hq' := hq.eq_or_lt,
  { rw [add_zero, zero_smul_set hs, add_zero] },
  ext,
  split,
  { rintro â¨v, hv, rflâ©,
    exact â¨p â¢ v, q â¢ v, smul_mem_smul_set hv, smul_mem_smul_set hv, (add_smul _ _ _).symmâ© },
  { rintro â¨vâ, vâ, â¨vââ, hââ, rflâ©, â¨vââ, hââ, rflâ©, rflâ©,
    have hpq := add_pos hp' hq',
    exact mem_smul_set.2 â¨_, h_conv hââ hââ (div_pos hp' hpq).le (div_pos hq' hpq).le
      (by rw [âdiv_self hpq.ne', add_div] : p / (p + q) + q / (p + q) = 1),
      by simp only [â mul_smul, smul_add, mul_div_cancel' _ hpq.ne']â© }
end

end add_comm_group
end linear_ordered_field

/-!
#### Convex sets in an ordered space
Relates `convex` and `ord_connected`.
-/

section

lemma set.ord_connected.convex_of_chain [ordered_semiring ð] [ordered_add_comm_monoid E]
  [module ð E] [ordered_smul ð E] {s : set E} (hs : s.ord_connected) (h : is_chain (â¤) s) :
  convex ð s :=
begin
  refine convex_iff_segment_subset.mpr (Î» x y hx hy, _),
  obtain hxy | hyx := h.total hx hy,
  { exact (segment_subset_Icc hxy).trans (hs.out hx hy) },
  { rw segment_symm,
    exact (segment_subset_Icc hyx).trans (hs.out hy hx) }
end

lemma set.ord_connected.convex [ordered_semiring ð] [linear_ordered_add_comm_monoid E] [module ð E]
  [ordered_smul ð E] {s : set E} (hs : s.ord_connected) :
  convex ð s :=
hs.convex_of_chain $ is_chain_of_trichotomous s

lemma convex_iff_ord_connected [linear_ordered_field ð] {s : set ð} :
  convex ð s â s.ord_connected :=
begin
  simp_rw [convex_iff_segment_subset, segment_eq_interval, ord_connected_iff_interval_subset],
  exact forall_congr (Î» x, forall_swap)
end

alias convex_iff_ord_connected â convex.ord_connected _

end

/-! #### Convexity of submodules/subspaces -/

section submodule
open submodule

lemma submodule.convex [ordered_semiring ð] [add_comm_monoid E] [module ð E] (K : submodule ð E) :
  convex ð (âK : set E) :=
by { repeat {intro}, refine add_mem _ (smul_mem _ _ _) (smul_mem _ _ _); assumption }

lemma subspace.convex [linear_ordered_field ð] [add_comm_group E] [module ð E] (K : subspace ð E) :
  convex ð (âK : set E) :=
K.convex

end submodule

/-! ### Simplex -/

section simplex

variables (ð) (Î¹ : Type*) [ordered_semiring ð] [fintype Î¹]

/-- The standard simplex in the space of functions `Î¹ â ð` is the set of vectors with non-negative
coordinates with total sum `1`. This is the free object in the category of convex spaces. -/
def std_simplex : set (Î¹ â ð) :=
{f | (â x, 0 â¤ f x) â§ â x, f x = 1}

lemma std_simplex_eq_inter :
  std_simplex ð Î¹ = (â x, {f | 0 â¤ f x}) â© {f | â x, f x = 1} :=
by { ext f, simp only [std_simplex, set.mem_inter_eq, set.mem_Inter, set.mem_set_of_eq] }

lemma convex_std_simplex : convex ð (std_simplex ð Î¹) :=
begin
  refine Î» f g hf hg a b ha hb hab, â¨Î» x, _, _â©,
  { apply_rules [add_nonneg, mul_nonneg, hf.1, hg.1] },
  { erw [finset.sum_add_distrib, â finset.smul_sum, â finset.smul_sum, hf.2, hg.2,
      smul_eq_mul, smul_eq_mul, mul_one, mul_one],
    exact hab }
end

variable {Î¹}

lemma ite_eq_mem_std_simplex (i : Î¹) : (Î» j, ite (i = j) (1:ð) 0) â std_simplex ð Î¹ :=
â¨Î» j, by simp only; split_ifs; norm_num, by rw [finset.sum_ite_eq, if_pos (finset.mem_univ _)]â©

end simplex
