/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang, Eric Wieser
-/
import ring_theory.localization.at_prime
import ring_theory.graded_algebra.basic

/-!
# Homogeneous Localization

## Notation
- `ฮน` is a commutative monoid;
- `R` is a commutative semiring;
- `A` is a commutative ring and an `R`-algebra;
- `๐ : ฮน โ submodule R A` is the grading of `A`;
- `x : ideal A` is a prime ideal.

## Main definitions and results

This file constructs the subring of `Aโ` where the numerator and denominator have the same grading,
i.e. `{a/b โ Aโ | โ (i : ฮน), a โ ๐แตข โง b โ ๐แตข}`.

* `homogeneous_localization.num_denom_same_deg`: a structure with a numerator and denominator field
  where they are required to have the same grading.

However `num_denom_same_deg ๐ x` cannot have a ring structure for many reasons, for example if `c`
is a `num_denom_same_deg`, then generally, `c + (-c)` is not necessarily `0` for degree reasons ---
`0` is considered to have grade zero (see `deg_zero`) but `c + (-c)` has the same degree as `c`. To
circumvent this, we quotient `num_denom_same_deg ๐ x` by the kernel of `c โฆ c.num / c.denom`.

* `homogeneous_localization.num_denom_same_deg.embedding` : for `x : prime ideal of A` and any
  `c : num_denom_same_deg ๐ x`, or equivalent a numerator and a denominator of the same degree,
  we get an element `c.num / c.denom` of `Aโ`.
* `homogeneous_localization`: `num_denom_same_deg ๐ x` quotiented by kernel of `embedding ๐ x`.
* `homogeneous_localization.val`: if `f : homogeneous_localization ๐ x`, then `f.val` is an element
  of `Aโ`. In another word, one can view `homogeneous_localization ๐ x` as a subring of `Aโ`
  through `homogeneous_localization.val`.
* `homogeneous_localization.num`: if `f : homogeneous_localization ๐ x`, then `f.num : A` is the
  numerator of `f`.
* `homogeneous_localization.num`: if `f : homogeneous_localization ๐ x`, then `f.denom : A` is the
  denominator of `f`.
* `homogeneous_localization.deg`: if `f : homogeneous_localization ๐ x`, then `f.deg : ฮน` is the
  degree of `f` such that `f.num โ ๐ f.deg` and `f.denom โ ๐ f.deg`
  (see `homogeneous_localization.num_mem` and `homogeneous_localization.denom_mem`).
* `homogeneous_localization.num_mem`: if `f : homogeneous_localization ๐ x`, then `f.num_mem` is a
  proof that `f.num โ f.deg`.
* `homogeneous_localization.denom_mem`: if `f : homogeneous_localization ๐ x`, then `f.denom_mem`
  is a proof that `f.denom โ f.deg`.
* `homogeneous_localization.eq_num_div_denom`: if `f : homogeneous_localization ๐ x`, then
  `f.val : Aโ` is equal to `f.num / f.denom`.

* `homogeneous_localization.local_ring`: `homogeneous_localization ๐ x` is a local ring.

## References

* [Robin Hartshorne, *Algebraic Geometry*][Har77]


-/

noncomputable theory

open_locale direct_sum big_operators pointwise
open direct_sum set_like

variables {ฮน R A: Type*}
variables [add_comm_monoid ฮน] [decidable_eq ฮน]
variables [comm_ring R] [comm_ring A] [algebra R A]
variables (๐ : ฮน โ submodule R A) [graded_algebra ๐]
variables (x : ideal A) [ideal.is_prime x]

local notation `at ` x := localization.at_prime x

namespace homogeneous_localization

section
/--
Let `x` be a prime ideal, then `num_denom_same_deg ๐ x` is a structure with a numerator and a
denominator with same grading such that the denominator is not contained in `x`.
-/
@[nolint has_inhabited_instance]
structure num_denom_same_deg :=
(deg : ฮน)
(num denom : ๐ deg)
(denom_not_mem : (denom : A) โ x)

end

namespace num_denom_same_deg

open set_like.graded_monoid submodule

variable {๐}
@[ext] lemma ext {c1 c2 : num_denom_same_deg ๐ x} (hdeg : c1.deg = c2.deg)
  (hnum : (c1.num : A) = c2.num) (hdenom : (c1.denom : A) = c2.denom) :
  c1 = c2 :=
begin
  rcases c1 with โจi1, โจn1, hn1โฉ, โจd1, hd1โฉ, h1โฉ,
  rcases c2 with โจi2, โจn2, hn2โฉ, โจd2, hd2โฉ, h2โฉ,
  dsimp only [subtype.coe_mk] at *,
  simp only,
  exact โจhdeg, by subst hdeg; subst hnum, by subst hdeg; subst hdenomโฉ,
end

instance : has_one (num_denom_same_deg ๐ x) :=
{ one :=
  { deg := 0,
    num := โจ1, one_memโฉ,
    denom := โจ1, one_memโฉ,
    denom_not_mem := ฮป r, (infer_instance : x.is_prime).ne_top $ x.eq_top_iff_one.mpr r } }

@[simp] lemma deg_one : (1 : num_denom_same_deg ๐ x).deg = 0 := rfl
@[simp] lemma num_one : ((1 : num_denom_same_deg ๐ x).num : A) = 1 := rfl
@[simp] lemma denom_one : ((1 : num_denom_same_deg ๐ x).denom : A) = 1 := rfl

instance : has_zero (num_denom_same_deg ๐ x) :=
{ zero := โจ0, 0, โจ1, one_memโฉ, ฮป r, (infer_instance : x.is_prime).ne_top $ x.eq_top_iff_one.mpr rโฉ }

@[simp] lemma deg_zero : (0 : num_denom_same_deg ๐ x).deg = 0 := rfl
@[simp] lemma num_zero : (0 : num_denom_same_deg ๐ x).num = 0 := rfl
@[simp] lemma denom_zero : ((0 : num_denom_same_deg ๐ x).denom : A) = 1 := rfl

instance : has_mul (num_denom_same_deg ๐ x) :=
{ mul := ฮป p q,
  { deg := p.deg + q.deg,
    num := โจp.num * q.num, mul_mem p.num.prop q.num.propโฉ,
    denom := โจp.denom * q.denom, mul_mem p.denom.prop q.denom.propโฉ,
    denom_not_mem := ฮป r, or.elim
      ((infer_instance : x.is_prime).mem_or_mem r) p.denom_not_mem q.denom_not_mem } }

@[simp] lemma deg_mul (c1 c2 : num_denom_same_deg ๐ x) : (c1 * c2).deg = c1.deg + c2.deg := rfl
@[simp] lemma num_mul (c1 c2 : num_denom_same_deg ๐ x) :
  ((c1 * c2).num : A) = c1.num * c2.num := rfl
@[simp] lemma denom_mul (c1 c2 : num_denom_same_deg ๐ x) :
  ((c1 * c2).denom : A) = c1.denom * c2.denom := rfl

instance : has_add (num_denom_same_deg ๐ x) :=
{ add := ฮป c1 c2,
  { deg := c1.deg + c2.deg,
    num := โจc1.denom * c2.num + c2.denom * c1.num,
      add_mem _ (mul_mem c1.denom.2 c2.num.2)
        (add_comm c2.deg c1.deg โธ mul_mem c2.denom.2 c1.num.2)โฉ,
    denom := โจc1.denom * c2.denom, mul_mem c1.denom.2 c2.denom.2โฉ,
    denom_not_mem := ฮป r, or.elim
      ((infer_instance : x.is_prime).mem_or_mem r) c1.denom_not_mem c2.denom_not_mem } }

@[simp] lemma deg_add (c1 c2 : num_denom_same_deg ๐ x) : (c1 + c2).deg = c1.deg + c2.deg := rfl
@[simp] lemma num_add (c1 c2 : num_denom_same_deg ๐ x) :
  ((c1 + c2).num : A) = c1.denom * c2.num + c2.denom * c1.num := rfl
@[simp] lemma denom_add (c1 c2 : num_denom_same_deg ๐ x) :
  ((c1 + c2).denom : A) = c1.denom * c2.denom := rfl

instance : has_neg (num_denom_same_deg ๐ x) :=
{ neg := ฮป c, โจc.deg, โจ-c.num, neg_mem _ c.num.2โฉ, c.denom, c.denom_not_memโฉ }

@[simp] lemma deg_neg (c : num_denom_same_deg ๐ x) : (-c).deg = c.deg := rfl
@[simp] lemma num_neg (c : num_denom_same_deg ๐ x) : ((-c).num : A) = -c.num := rfl
@[simp] lemma denom_neg (c : num_denom_same_deg ๐ x) : ((-c).denom : A) = c.denom := rfl

instance : comm_monoid (num_denom_same_deg ๐ x) :=
{ one := 1,
  mul := (*),
  mul_assoc := ฮป c1 c2 c3, ext _ (add_assoc _ _ _) (mul_assoc _ _ _) (mul_assoc _ _ _),
  one_mul := ฮป c, ext _ (zero_add _) (one_mul _) (one_mul _),
  mul_one := ฮป c, ext _ (add_zero _) (mul_one _) (mul_one _),
  mul_comm := ฮป c1 c2, ext _ (add_comm _ _) (mul_comm _ _) (mul_comm _ _) }

instance : has_pow (num_denom_same_deg ๐ x) โ :=
{ pow := ฮป c n, โจn โข c.deg, โจc.num ^ n, pow_mem n c.num.2โฉ, โจc.denom ^ n, pow_mem n c.denom.2โฉ,
    begin
      cases n,
      { simp only [pow_zero],
        exact ฮป r, (infer_instance : x.is_prime).ne_top $ (ideal.eq_top_iff_one _).mpr r, },
      { exact ฮป r, c.denom_not_mem $
          ((infer_instance : x.is_prime).pow_mem_iff_mem n.succ (nat.zero_lt_succ _)).mp r }
    endโฉ }

@[simp] lemma deg_pow (c : num_denom_same_deg ๐ x) (n : โ) : (c ^ n).deg = n โข c.deg := rfl
@[simp] lemma num_pow (c : num_denom_same_deg ๐ x) (n : โ) : ((c ^ n).num : A) = c.num ^ n := rfl
@[simp] lemma denom_pow (c : num_denom_same_deg ๐ x) (n : โ) :
  ((c ^ n).denom : A) = c.denom ^ n := rfl

section has_scalar
variables {ฮฑ : Type*} [has_scalar ฮฑ R] [has_scalar ฮฑ A] [is_scalar_tower ฮฑ R A]

instance : has_scalar ฮฑ (num_denom_same_deg ๐ x) :=
{ smul := ฮป m c, โจc.deg, m โข c.num, c.denom, c.denom_not_memโฉ }

@[simp] lemma deg_smul (c : num_denom_same_deg ๐ x) (m : ฮฑ) : (m โข c).deg = c.deg := rfl
@[simp] lemma num_smul (c : num_denom_same_deg ๐ x) (m : ฮฑ) : ((m โข c).num : A) = m โข c.num := rfl
@[simp] lemma denom_smul (c : num_denom_same_deg ๐ x) (m : ฮฑ) :
  ((m โข c).denom : A) = c.denom := rfl

end has_scalar

variable (๐)

/--
For `x : prime ideal of A` and any `p : num_denom_same_deg ๐ x`, or equivalent a numerator and a
denominator of the same degree, we get an element `p.num / p.denom` of `Aโ`.
-/
def embedding (p : num_denom_same_deg ๐ x) : at x :=
localization.mk p.num โจp.denom, p.denom_not_memโฉ

end num_denom_same_deg

end homogeneous_localization

/--
For `x : prime ideal of A`, `homogeneous_localization ๐ x` is `num_denom_same_deg ๐ x` modulo the
kernel of `embedding ๐ x`. This is essentially the subring of `Aโ` where the numerator and
denominator share the same grading.
-/
@[nolint has_inhabited_instance]
def homogeneous_localization : Type* :=
quotient (setoid.ker $ homogeneous_localization.num_denom_same_deg.embedding ๐ x)

namespace homogeneous_localization

open homogeneous_localization homogeneous_localization.num_denom_same_deg

variables {๐} {x}
/--
View an element of `homogeneous_localization ๐ x` as an element of `Aโ` by forgetting that the
numerator and denominator are of the same grading.
-/
def val (y : homogeneous_localization ๐ x) : at x :=
quotient.lift_on' y (num_denom_same_deg.embedding ๐ x) $ ฮป _ _, id

@[simp] lemma val_mk' (i : num_denom_same_deg ๐ x) :
  val (quotient.mk' i) = localization.mk i.num โจi.denom, i.denom_not_memโฉ :=
rfl

variable (x)
lemma val_injective :
  function.injective (@homogeneous_localization.val _ _ _ _ _ _ _ _ ๐ _ x _) :=
ฮป a b, quotient.rec_on_subsingletonโ' a b $ ฮป a b h, quotient.sound' h

instance has_pow : has_pow (homogeneous_localization ๐ x) โ :=
{ pow := ฮป z n, (quotient.map' (^ n)
    (ฮป c1 c2 (h : localization.mk _ _ = localization.mk _ _), begin
      change localization.mk _ _ = localization.mk _ _,
      simp only [num_pow, denom_pow],
      convert congr_arg (ฮป z, z ^ n) h;
      erw localization.mk_pow;
      refl,
    end) : homogeneous_localization ๐ x โ homogeneous_localization ๐ x) z }

section has_scalar
variables {ฮฑ : Type*} [has_scalar ฮฑ R] [has_scalar ฮฑ A] [is_scalar_tower ฮฑ R A]
variables [is_scalar_tower ฮฑ A A]

instance : has_scalar ฮฑ (homogeneous_localization ๐ x) :=
{ smul := ฮป m, quotient.map' ((โข) m)
    (ฮป c1 c2 (h : localization.mk _ _ = localization.mk _ _), begin
      change localization.mk _ _ = localization.mk _ _,
      simp only [num_smul, denom_smul],
      convert congr_arg (ฮป z : at x, m โข z) h;
      rw localization.smul_mk;
      refl,
    end) }

@[simp] lemma smul_val (y : homogeneous_localization ๐ x) (n : ฮฑ) :
  (n โข y).val = n โข y.val :=
begin
  induction y using quotient.induction_on,
  unfold homogeneous_localization.val has_scalar.smul,
  simp only [quotient.lift_onโ'_mk, quotient.lift_on'_mk],
  change localization.mk _ _ = n โข localization.mk _ _,
  dsimp only,
  rw localization.smul_mk,
  congr' 1,
end

end has_scalar

instance : has_neg (homogeneous_localization ๐ x) :=
{ neg := quotient.map' has_neg.neg
    (ฮป c1 c2 (h : localization.mk _ _ = localization.mk _ _), begin
      change localization.mk _ _ = localization.mk _ _,
      simp only [num_neg, denom_neg, โlocalization.neg_mk],
      exact congr_arg (ฮป c, -c) h
    end) }

instance : has_add (homogeneous_localization ๐ x) :=
{ add := quotient.mapโ' (+) (ฮป c1 c2 (h : localization.mk _ _ = localization.mk _ _)
    c3 c4 (h' : localization.mk _ _ = localization.mk _ _), begin
    change localization.mk _ _ = localization.mk _ _,
    simp only [num_add, denom_add, โlocalization.add_mk],
    convert congr_arg2 (+) h h';
    erw [localization.add_mk];
    refl
  end) }

instance : has_sub (homogeneous_localization ๐ x) :=
{ sub := ฮป z1 z2, z1 + (-z2) }

instance : has_mul (homogeneous_localization ๐ x) :=
{ mul := quotient.mapโ' (*) (ฮป c1 c2 (h : localization.mk _ _ = localization.mk _ _)
    c3 c4 (h' : localization.mk _ _ = localization.mk _ _), begin
    change localization.mk _ _ = localization.mk _ _,
    simp only [num_mul, denom_mul],
    convert congr_arg2 (*) h h';
    erw [localization.mk_mul];
    refl,
  end) }

instance : has_one (homogeneous_localization ๐ x) :=
{ one := quotient.mk' 1 }

instance : has_zero (homogeneous_localization ๐ x) :=
{ zero := quotient.mk' 0 }

lemma zero_eq :
  (0 : homogeneous_localization ๐ x) = quotient.mk' 0 := rfl

lemma one_eq :
  (1 : homogeneous_localization ๐ x) = quotient.mk' 1 := rfl

variable {x}
lemma zero_val : (0 : homogeneous_localization ๐ x).val = 0 :=
localization.mk_zero _

lemma one_val : (1 : homogeneous_localization ๐ x).val = 1 :=
localization.mk_one

@[simp] lemma add_val (y1 y2 : homogeneous_localization ๐ x) :
  (y1 + y2).val = y1.val + y2.val :=
begin
  induction y1 using quotient.induction_on,
  induction y2 using quotient.induction_on,
  unfold homogeneous_localization.val has_add.add,
  simp only [quotient.lift_onโ'_mk, quotient.lift_on'_mk],
  change localization.mk _ _ = localization.mk _ _ + localization.mk _ _,
  dsimp only,
  rw [localization.add_mk],
  refl
end

@[simp] lemma mul_val (y1 y2 : homogeneous_localization ๐ x) :
  (y1 * y2).val = y1.val * y2.val :=
begin
  induction y1 using quotient.induction_on,
  induction y2 using quotient.induction_on,
  unfold homogeneous_localization.val has_mul.mul,
  simp only [quotient.lift_onโ'_mk, quotient.lift_on'_mk],
  change localization.mk _ _ = localization.mk _ _ * localization.mk _ _,
  dsimp only,
  rw [localization.mk_mul],
  refl,
end

@[simp] lemma neg_val (y : homogeneous_localization ๐ x) :
  (-y).val = -y.val :=
begin
  induction y using quotient.induction_on,
  unfold homogeneous_localization.val has_neg.neg,
  simp only [quotient.lift_onโ'_mk, quotient.lift_on'_mk],
  change localization.mk _ _ = - localization.mk _ _,
  dsimp only,
  rw [localization.neg_mk],
  refl,
end

@[simp] lemma sub_val (y1 y2 : homogeneous_localization ๐ x) :
  (y1 - y2).val = y1.val - y2.val :=
by rw [show y1 - y2 = y1 + (-y2), from rfl, add_val, neg_val]; refl

@[simp] lemma pow_val (y : homogeneous_localization ๐ x) (n : โ) :
  (y ^ n).val = y.val ^ n :=
begin
  induction y using quotient.induction_on,
  unfold homogeneous_localization.val has_pow.pow,
  simp only [quotient.lift_onโ'_mk, quotient.lift_on'_mk],
  change localization.mk _ _ = (localization.mk _ _) ^ n,
  rw localization.mk_pow,
  dsimp only,
  congr' 1,
end

instance : comm_ring (homogeneous_localization ๐ x) :=
(homogeneous_localization.val_injective x).comm_ring _ zero_val one_val add_val mul_val neg_val
  sub_val (ฮป z n, smul_val x z n) (ฮป z n, smul_val x z n) pow_val

end homogeneous_localization

namespace homogeneous_localization

open homogeneous_localization homogeneous_localization.num_denom_same_deg

variables {๐} {x}

/-- numerator of an element in `homogeneous_localization x`-/
def num (f : homogeneous_localization ๐ x) : A :=
(quotient.out' f).num

/-- denominator of an element in `homogeneous_localization x`-/
def denom (f : homogeneous_localization ๐ x) : A :=
(quotient.out' f).denom

/-- For an element in `homogeneous_localization x`, degree is the natural number `i` such that
  `๐ i` contains both numerator and denominator. -/
def deg (f : homogeneous_localization ๐ x) : ฮน :=
(quotient.out' f).deg

lemma denom_not_mem (f : homogeneous_localization ๐ x) :
  f.denom โ x :=
(quotient.out' f).denom_not_mem

lemma num_mem (f : homogeneous_localization ๐ x) : f.num โ ๐ f.deg :=
(quotient.out' f).num.2

lemma denom_mem (f : homogeneous_localization ๐ x) : f.denom โ ๐ f.deg :=
(quotient.out' f).denom.2

lemma eq_num_div_denom (f : homogeneous_localization ๐ x) :
  f.val = localization.mk f.num โจf.denom, f.denom_not_memโฉ :=
begin
  have := (quotient.out_eq' f),
  apply_fun homogeneous_localization.val at this,
  rw โ this,
  unfold homogeneous_localization.val,
  simp only [quotient.lift_on'_mk'],
  refl,
end

lemma ext_iff_val (f g : homogeneous_localization ๐ x) : f = g โ f.val = g.val :=
{ mp := ฮป h, h โธ rfl,
  mpr := ฮป h, begin
    induction f using quotient.induction_on,
    induction g using quotient.induction_on,
    rw quotient.eq,
    unfold homogeneous_localization.val at h,
    simpa only [quotient.lift_on'_mk] using h,
  end }

lemma is_unit_iff_is_unit_val (f : homogeneous_localization ๐ x) :
  is_unit f.val โ is_unit f :=
โจฮป h1, begin
  rcases h1 with โจโจa, b, eq0, eq1โฉ, (eq2 : a = f.val)โฉ,
  rw eq2 at eq0 eq1,
  clear' a eq2,
  induction b using localization.induction_on with data,
  rcases data with โจa, โจb, hbโฉโฉ,
  dsimp only at eq0 eq1,
  have b_f_denom_not_mem : b * f.denom โ x.prime_compl := ฮป r, or.elim
    (ideal.is_prime.mem_or_mem infer_instance r) (ฮป r2, hb r2) (ฮป r2, f.denom_not_mem r2),
  rw [f.eq_num_div_denom, localization.mk_mul,
    show (โจb, hbโฉ : x.prime_compl) * โจf.denom, _โฉ = โจb * f.denom, _โฉ, from rfl,
    show (1 : at x) = localization.mk 1 1, by erw localization.mk_self 1,
    localization.mk_eq_mk', is_localization.eq] at eq1,
  rcases eq1 with โจโจc, hcโฉ, eq1โฉ,
  simp only [โ subtype.val_eq_coe] at eq1,
  change a * f.num * 1 * c = _ at eq1,
  simp only [one_mul, mul_one] at eq1,
  have mem1 : a * f.num * c โ x.prime_compl :=
    eq1.symm โธ ฮป r, or.elim (ideal.is_prime.mem_or_mem infer_instance r) (by tauto)(by tauto),
  have mem2 : f.num โ x,
  { contrapose! mem1,
    erw [not_not],
    exact ideal.mul_mem_right _ _ (ideal.mul_mem_left _ _ mem1), },
  refine โจโจf, quotient.mk' โจf.deg, โจf.denom, f.denom_memโฉ, โจf.num, f.num_memโฉ, mem2โฉ, _, _โฉ, rflโฉ;
  simp only [ext_iff_val, mul_val, val_mk', โ subtype.val_eq_coe, f.eq_num_div_denom,
    localization.mk_mul, one_val];
  convert localization.mk_self _;
  simpa only [mul_comm]
end, ฮป โจโจ_, b, eq1, eq2โฉ, rflโฉ, begin
  simp only [ext_iff_val, mul_val, one_val] at eq1 eq2,
  exact โจโจf.val, b.val, eq1, eq2โฉ, rflโฉ
endโฉ

instance : local_ring (homogeneous_localization ๐ x) :=
{ exists_pair_ne := โจ0, 1, ฮป r, by simpa [ext_iff_val, zero_val, one_val, zero_ne_one] using rโฉ,
  is_local := ฮป a, begin
    simp only [โ is_unit_iff_is_unit_val, sub_val, one_val],
    induction a using quotient.induction_on',
    simp only [homogeneous_localization.val_mk', โ subtype.val_eq_coe],
    by_cases mem1 : a.num.1 โ x,
    { right,
      have : a.denom.1 - a.num.1 โ x.prime_compl := ฮป h, a.denom_not_mem
        ((sub_add_cancel a.denom.val a.num.val) โธ ideal.add_mem _ h mem1 : a.denom.1 โ x),
      apply is_unit_of_mul_eq_one _ (localization.mk a.denom.1 โจa.denom.1 - a.num.1, thisโฉ),
      simp only [sub_mul, localization.mk_mul, one_mul, localization.sub_mk, โ subtype.val_eq_coe,
        submonoid.coe_mul],
      convert localization.mk_self _,
      simp only [โ subtype.val_eq_coe, submonoid.coe_mul],
      ring, },
    { left,
      change _ โ x.prime_compl at mem1,
      apply is_unit_of_mul_eq_one _ (localization.mk a.denom.1 โจa.num.1, mem1โฉ),
      rw [localization.mk_mul],
      convert localization.mk_self _,
      simpa only [mul_comm], },
end }

end homogeneous_localization
