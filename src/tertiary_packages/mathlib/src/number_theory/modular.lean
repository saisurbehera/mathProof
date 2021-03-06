/-
Copyright (c) 2021 Alex Kontorovich and Heather Macbeth and Marc Masdeu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alex Kontorovich, Heather Macbeth, Marc Masdeu
-/

import analysis.complex.upper_half_plane
import linear_algebra.general_linear_group
import analysis.matrix

/-!
# The action of the modular group SL(2, ā¤) on the upper half-plane

We define the action of `SL(2,ā¤)` on `ā` (via restriction of the `SL(2,ā)` action in
`analysis.complex.upper_half_plane`). We then define the standard fundamental domain
(`modular_group.fundamental_domain`, `š`) for this action and show
(`modular_group.exists_smul_mem_fundamental_domain`) that any point in `ā` can be
moved inside `š`.

Standard proofs make use of the identity

`g ā¢ z = a / c - 1 / (c (cz + d))`

for `g = [[a, b], [c, d]]` in `SL(2)`, but this requires separate handling of whether `c = 0`.
Instead, our proof makes use of the following perhaps novel identity (see
`modular_group.smul_eq_lc_row0_add`):

`g ā¢ z = (a c + b d) / (c^2 + d^2) + (d z - c) / ((c^2 + d^2) (c z + d))`

where there is no issue of division by zero.

Another feature is that we delay until the very end the consideration of special matrices
`T=[[1,1],[0,1]]` (see `modular_group.T`) and `S=[[0,-1],[1,0]]` (see `modular_group.S`), by
instead using abstract theory on the properness of certain maps (phrased in terms of the filters
`filter.cocompact`, `filter.cofinite`, etc) to deduce existence theorems, first to prove the
existence of `g` maximizing `(gā¢z).im` (see `modular_group.exists_max_im`), and then among
those, to minimize `|(gā¢z).re|` (see `modular_group.exists_row_one_eq_and_min_re`).
-/

/- Disable these instances as they are not the simp-normal form, and having them disabled ensures
we state lemmas in this file without spurious `coe_fn` terms. -/
local attribute [-instance] matrix.special_linear_group.has_coe_to_fun
local attribute [-instance] matrix.general_linear_group.has_coe_to_fun

open complex matrix matrix.special_linear_group upper_half_plane
noncomputable theory

local notation `SL(` n `, ` R `)`:= special_linear_group (fin n) R
local prefix `āā`:1024 := @coe _ (matrix (fin 2) (fin 2) ā¤) _


open_locale upper_half_plane complex_conjugate

local attribute [instance] fintype.card_fin_even

namespace modular_group

section upper_half_plane_action

/-- For a subring `R` of `ā`, the action of `SL(2, R)` on the upper half-plane, as a restriction of
the `SL(2, ā)`-action defined by `upper_half_plane.mul_action`. -/
instance {R : Type*} [comm_ring R] [algebra R ā] : mul_action SL(2, R) ā :=
mul_action.comp_hom ā (map (algebra_map R ā))

lemma coe_smul (g : SL(2, ā¤)) (z : ā) : ā(g ā¢ z) = num g z / denom g z := rfl
lemma re_smul (g : SL(2, ā¤)) (z : ā) : (g ā¢ z).re = (num g z / denom g z).re := rfl
@[simp] lemma smul_coe (g : SL(2, ā¤)) (z : ā) : (g : SL(2,ā)) ā¢ z = g ā¢ z := rfl

@[simp] lemma neg_smul (g : SL(2, ā¤)) (z : ā) : -g ā¢ z = g ā¢ z :=
show ā(-g) ā¢ _ = _, by simp [neg_smul g z]

lemma im_smul (g : SL(2, ā¤)) (z : ā) : (g ā¢ z).im = (num g z / denom g z).im := rfl

lemma im_smul_eq_div_norm_sq (g : SL(2, ā¤)) (z : ā) :
  (g ā¢ z).im = z.im / (complex.norm_sq (denom g z)) :=
im_smul_eq_div_norm_sq g z

@[simp] lemma denom_apply (g : SL(2, ā¤)) (z : ā) : denom g z = āāg 1 0 * z + āāg 1 1 := by simp

end upper_half_plane_action

section bottom_row

/-- The two numbers `c`, `d` in the "bottom_row" of `g=[[*,*],[c,d]]` in `SL(2, ā¤)` are coprime. -/
lemma bottom_row_coprime {R : Type*} [comm_ring R] (g : SL(2, R)) :
  is_coprime ((āg : matrix (fin 2) (fin 2) R) 1 0) ((āg : matrix (fin 2) (fin 2) R) 1 1) :=
begin
  use [- (āg : matrix (fin 2) (fin 2) R) 0 1, (āg : matrix (fin 2) (fin 2) R) 0 0],
  rw [add_comm, neg_mul, āsub_eq_add_neg, ādet_fin_two],
  exact g.det_coe,
end

/-- Every pair `![c, d]` of coprime integers is the "bottom_row" of some element `g=[[*,*],[c,d]]`
of `SL(2,ā¤)`. -/
lemma bottom_row_surj {R : Type*} [comm_ring R] :
  set.surj_on (Ī» g : SL(2, R), @coe _ (matrix (fin 2) (fin 2) R) _ g 1) set.univ
    {cd | is_coprime (cd 0) (cd 1)} :=
begin
  rintros cd āØbā, a, gcd_eqnā©,
  let A := ![![a, -bā], cd],
  have det_A_1 : det A = 1,
  { convert gcd_eqn,
    simp [A, det_fin_two, (by ring : a * (cd 1) + bā * (cd 0) = bā * (cd 0) + a * (cd 1))] },
  refine āØāØA, det_A_1ā©, set.mem_univ _, _ā©,
  ext; simp [A]
end

end bottom_row

section tendsto_lemmas

open filter continuous_linear_map
local attribute [instance] matrix.normed_group matrix.normed_space
local attribute [simp] coe_smul

/-- The function `(c,d) ā |cz+d|^2` is proper, that is, preimages of bounded-above sets are finite.
-/
lemma tendsto_norm_sq_coprime_pair (z : ā) :
  filter.tendsto (Ī» p : fin 2 ā ā¤, ((p 0 : ā) * z + p 1).norm_sq)
  cofinite at_top :=
begin
  let Ļā : (fin 2 ā ā) āā[ā] ā := linear_map.proj 0,
  let Ļā : (fin 2 ā ā) āā[ā] ā := linear_map.proj 1,
  let f : (fin 2 ā ā) āā[ā] ā := Ļā.smul_right (z:ā) + Ļā.smul_right 1,
  have f_def : āf = Ī» (p : fin 2 ā ā), (p 0 : ā) * āz + p 1,
  { ext1,
    dsimp only [linear_map.coe_proj, real_smul,
      linear_map.coe_smul_right, linear_map.add_apply],
    rw mul_one, },
  have : (Ī» (p : fin 2 ā ā¤), norm_sq ((p 0 : ā) * āz + ā(p 1)))
    = norm_sq ā f ā (Ī» p : fin 2 ā ā¤, (coe : ā¤ ā ā) ā p),
  { ext1,
    rw f_def,
    dsimp only [function.comp],
    rw [of_real_int_cast, of_real_int_cast], },
  rw this,
  have hf : f.ker = ā„,
  { let g : ā āā[ā] (fin 2 ā ā) :=
      linear_map.pi ![im_lm, im_lm.comp ((z:ā) ā¢ (conj_ae  : ā āā[ā] ā))],
    suffices : ((z:ā).imā»Ā¹ ā¢ g).comp f = linear_map.id,
    { exact linear_map.ker_eq_bot_of_inverse this },
    apply linear_map.ext,
    intros c,
    have hz : (z:ā).im ā  0 := z.2.ne',
    rw [linear_map.comp_apply, linear_map.smul_apply, linear_map.id_apply],
    ext i,
    dsimp only [g, pi.smul_apply, linear_map.pi_apply, smul_eq_mul],
    fin_cases i,
    { show ((z : ā).im)ā»Ā¹ * (f c).im = c 0,
      rw [f_def, add_im, of_real_mul_im, of_real_im, add_zero, mul_left_comm,
        inv_mul_cancel hz, mul_one], },
    { show ((z : ā).im)ā»Ā¹ * ((z : ā) * conj (f c)).im = c 1,
      rw [f_def, ring_hom.map_add, ring_hom.map_mul, mul_add, mul_left_comm, mul_conj,
        conj_of_real, conj_of_real, ā of_real_mul, add_im, of_real_im, zero_add,
        inv_mul_eq_iff_eq_mulā hz],
      simp only [of_real_im, of_real_re, mul_im, zero_add, mul_zero] } },
  have hā := (linear_equiv.closed_embedding_of_injective hf).tendsto_cocompact,
  have hā : tendsto (Ī» p : fin 2 ā ā¤, (coe : ā¤ ā ā) ā p) cofinite (cocompact _),
  { convert tendsto.pi_map_Coprod (Ī» i, int.tendsto_coe_cofinite),
    { rw Coprod_cofinite },
    { rw Coprod_cocompact } },
  exact tendsto_norm_sq_cocompact_at_top.comp (hā.comp hā)
end


/-- Given `coprime_pair` `p=(c,d)`, the matrix `[[a,b],[*,*]]` is sent to `a*c+b*d`.
  This is the linear map version of this operation.
-/
def lc_row0 (p : fin 2 ā ā¤) : (matrix (fin 2) (fin 2) ā) āā[ā] ā :=
((p 0:ā) ā¢ linear_map.proj 0 + (p 1:ā) ā¢ linear_map.proj 1 : (fin 2 ā ā) āā[ā] ā).comp
  (linear_map.proj 0)

@[simp] lemma lc_row0_apply (p : fin 2 ā ā¤) (g : matrix (fin 2) (fin 2) ā) :
  lc_row0 p g = p 0 * g 0 0 + p 1 * g 0 1 :=
rfl

lemma lc_row0_apply' (a b : ā) (c d : ā¤) (v : fin 2 ā ā) :
  lc_row0 ![c, d] ![![a, b], v] = c * a + d * b :=
by simp

/-- Linear map sending the matrix [a, b; c, d] to the matrix [acā + bdā, - adā + bcā; c, d], for
some fixed `(cā, dā)`. -/
@[simps] def lc_row0_extend {cd : fin 2 ā ā¤} (hcd : is_coprime (cd 0) (cd 1)) :
  (matrix (fin 2) (fin 2) ā) āā[ā] matrix (fin 2) (fin 2) ā :=
linear_equiv.Pi_congr_right
![begin
    refine linear_map.general_linear_group.general_linear_equiv ā (fin 2 ā ā)
      (general_linear_group.to_linear (plane_conformal_matrix (cd 0 : ā) (-(cd 1 : ā)) _)),
    norm_cast,
    rw neg_sq,
    exact hcd.sq_add_sq_ne_zero
  end,
  linear_equiv.refl ā (fin 2 ā ā)]

/-- The map `lc_row0` is proper, that is, preimages of cocompact sets are finite in
`[[* , *], [c, d]]`.-/
theorem tendsto_lc_row0 {cd : fin 2 ā ā¤} (hcd : is_coprime (cd 0) (cd 1)) :
  tendsto (Ī» g : {g : SL(2, ā¤) // āāg 1 = cd}, lc_row0 cd ā(āg : SL(2, ā)))
    cofinite (cocompact ā) :=
begin
  let mB : ā ā (matrix (fin 2) (fin 2)  ā) := Ī» t, ![![t, (-(1:ā¤):ā)], coe ā cd],
  have hmB : continuous mB,
  { simp only [continuous_pi_iff, fin.forall_fin_two],
    have : ā c : ā, continuous (Ī» x : ā, c) := Ī» c, continuous_const,
    exact āØāØcontinuous_id, @this (-1 : ā¤)ā©, āØthis (cd 0), this (cd 1)ā©ā© },
  refine filter.tendsto.of_tendsto_comp _ (comap_cocompact hmB),
  let fā : SL(2, ā¤) ā matrix (fin 2) (fin 2) ā :=
    Ī» g, matrix.map (āg : matrix _ _ ā¤) (coe : ā¤ ā ā),
  have cocompact_ā_to_cofinite_ā¤_matrix :
    tendsto (Ī» m : matrix (fin 2) (fin 2) ā¤, matrix.map m (coe : ā¤ ā ā)) cofinite (cocompact _),
  { simpa only [Coprod_cofinite, Coprod_cocompact]
      using tendsto.pi_map_Coprod (Ī» i : fin 2, tendsto.pi_map_Coprod
        (Ī» j : fin 2, int.tendsto_coe_cofinite)) },
  have hfā : tendsto fā cofinite (cocompact _) :=
    cocompact_ā_to_cofinite_ā¤_matrix.comp subtype.coe_injective.tendsto_cofinite,
  have hfā : closed_embedding (lc_row0_extend hcd) :=
    (lc_row0_extend hcd).to_continuous_linear_equiv.to_homeomorph.closed_embedding,
  convert hfā.tendsto_cocompact.comp (hfā.comp subtype.coe_injective.tendsto_cofinite) using 1,
  ext āØg, rflā© i j : 3,
  fin_cases i; [fin_cases j, skip],
  -- the following are proved by `simp`, but it is replaced by `simp only` to avoid timeouts.
  { simp only [mB, mul_vec, dot_product, fin.sum_univ_two, _root_.coe_coe, coe_matrix_coe,
      int.coe_cast_ring_hom, lc_row0_apply, function.comp_app, cons_val_zero, lc_row0_extend_apply,
      linear_map.general_linear_group.coe_fn_general_linear_equiv,
      general_linear_group.to_linear_apply, coe_plane_conformal_matrix, neg_neg, mul_vec_lin_apply,
      cons_val_one, head_cons] },
  { convert congr_arg (Ī» n : ā¤, (-n:ā)) g.det_coe.symm using 1,
    simp only [fā, mul_vec, dot_product, fin.sum_univ_two, matrix.det_fin_two, function.comp_app,
      subtype.coe_mk, lc_row0_extend_apply, cons_val_zero,
      linear_map.general_linear_group.coe_fn_general_linear_equiv,
      general_linear_group.to_linear_apply, coe_plane_conformal_matrix, mul_vec_lin_apply,
      cons_val_one, head_cons, map_apply, neg_mul, int.cast_sub, int.cast_mul, neg_sub],
    ring },
  { refl }
end

/-- This replaces `(gā¢z).re = a/c + *` in the standard theory with the following novel identity:

  `g ā¢ z = (a c + b d) / (c^2 + d^2) + (d z - c) / ((c^2 + d^2) (c z + d))`

  which does not need to be decomposed depending on whether `c = 0`. -/
lemma smul_eq_lc_row0_add {p : fin 2 ā ā¤} (hp : is_coprime (p 0) (p 1)) (z : ā) {g : SL(2,ā¤)}
  (hg : āāg 1 = p) :
  ā(g ā¢ z) = ((lc_row0 p ā(g : SL(2, ā))) : ā) / (p 0 ^ 2 + p 1 ^ 2)
    + ((p 1 : ā) * z - p 0) / ((p 0 ^ 2 + p 1 ^ 2) * (p 0 * z + p 1)) :=
begin
  have nonZ1 : (p 0 : ā) ^ 2 + (p 1) ^ 2 ā  0 := by exact_mod_cast hp.sq_add_sq_ne_zero,
  have : (coe : ā¤ ā ā) ā p ā  0 := Ī» h, hp.ne_zero ((@int.cast_injective ā _ _ _).comp_left h),
  have nonZ2 : (p 0 : ā) * z + p 1 ā  0 := by simpa using linear_ne_zero _ z this,
  field_simp [nonZ1, nonZ2, denom_ne_zero, -upper_half_plane.denom, -denom_apply],
  rw (by simp : (p 1 : ā) * z - p 0 = ((p 1) * z - p 0) * ā(det (āg : matrix (fin 2) (fin 2) ā¤))),
  rw [āhg, det_fin_two],
  simp only [int.coe_cast_ring_hom, coe_matrix_coe, coe_fn_eq_coe,
    int.cast_mul, of_real_int_cast, map_apply, denom, int.cast_sub],
  ring,
end

lemma tendsto_abs_re_smul (z:ā) {p : fin 2 ā ā¤} (hp : is_coprime (p 0) (p 1)) :
  tendsto (Ī» g : {g : SL(2, ā¤) // āāg 1 = p}, |((g : SL(2, ā¤)) ā¢ z).re|)
    cofinite at_top :=
begin
  suffices : tendsto (Ī» g : (Ī» g : SL(2, ā¤), āāg 1) ā»Ā¹' {p}, (((g : SL(2, ā¤)) ā¢ z).re))
    cofinite (cocompact ā),
  { exact tendsto_norm_cocompact_at_top.comp this },
  have : ((p 0 : ā) ^ 2 + p 1 ^ 2)ā»Ā¹ ā  0,
  { apply inv_ne_zero,
    exact_mod_cast hp.sq_add_sq_ne_zero },
  let f := homeomorph.mul_rightā _ this,
  let ff := homeomorph.add_right (((p 1:ā)* z - p 0) / ((p 0 ^ 2 + p 1 ^ 2) * (p 0 * z + p 1))).re,
  convert ((f.trans ff).closed_embedding.tendsto_cocompact).comp (tendsto_lc_row0 hp),
  ext g,
  change ((g : SL(2, ā¤)) ā¢ z).re = (lc_row0 p ā(āg : SL(2, ā))) / (p 0 ^ 2 + p 1 ^ 2)
  + (((p 1:ā )* z - p 0) / ((p 0 ^ 2 + p 1 ^ 2) * (p 0 * z + p 1))).re,
  exact_mod_cast (congr_arg complex.re (smul_eq_lc_row0_add hp z g.2))
end

end tendsto_lemmas

section fundamental_domain

local attribute [simp] coe_smul re_smul

/-- For `z : ā`, there is a `g : SL(2,ā¤)` maximizing `(gā¢z).im` -/
lemma exists_max_im (z : ā) :
  ā g : SL(2, ā¤), ā g' : SL(2, ā¤), (g' ā¢ z).im ā¤ (g ā¢ z).im :=
begin
  classical,
  let s : set (fin 2 ā ā¤) := {cd | is_coprime (cd 0) (cd 1)},
  have hs : s.nonempty := āØ![1, 1], is_coprime_one_leftā©,
  obtain āØp, hp_coprime, hpā© :=
    filter.tendsto.exists_within_forall_le hs (tendsto_norm_sq_coprime_pair z),
  obtain āØg, -, hgā© := bottom_row_surj hp_coprime,
  refine āØg, Ī» g', _ā©,
  rw [im_smul_eq_div_norm_sq, im_smul_eq_div_norm_sq, div_le_div_left],
  { simpa [ā hg] using hp (āāg' 1) (bottom_row_coprime g') },
  { exact z.im_pos },
  { exact norm_sq_denom_pos g' z },
  { exact norm_sq_denom_pos g z },
end

/-- Given `z : ā` and a bottom row `(c,d)`, among the `g : SL(2,ā¤)` with this bottom row, minimize
  `|(gā¢z).re|`.  -/
lemma exists_row_one_eq_and_min_re (z:ā) {cd : fin 2 ā ā¤} (hcd : is_coprime (cd 0) (cd 1)) :
  ā g : SL(2,ā¤), āāg 1 = cd ā§ (ā g' : SL(2,ā¤), āāg 1 = āāg' 1 ā
  |(g ā¢ z).re| ā¤ |(g' ā¢ z).re|) :=
begin
  haveI : nonempty {g : SL(2, ā¤) // āāg 1 = cd} :=
    let āØx, hxā© := bottom_row_surj hcd in āØāØx, hx.2ā©ā©,
  obtain āØg, hgā© := filter.tendsto.exists_forall_le (tendsto_abs_re_smul z hcd),
  refine āØg, g.2, _ā©,
  { intros g1 hg1,
    have : g1 ā ((Ī» g : SL(2, ā¤), āāg 1) ā»Ā¹' {cd}),
    { rw [set.mem_preimage, set.mem_singleton_iff],
      exact eq.trans hg1.symm (set.mem_singleton_iff.mp (set.mem_preimage.mp g.2)) },
    exact hg āØg1, thisā© },
end

/-- The matrix `T = [[1,1],[0,1]]` as an element of `SL(2,ā¤)` -/
def T : SL(2,ā¤) := āØ![![1, 1], ![0, 1]], by norm_num [matrix.det_fin_two]ā©

/-- The matrix `T' (= Tā»Ā¹) = [[1,-1],[0,1]]` as an element of `SL(2,ā¤)` -/
def T' : SL(2,ā¤) := āØ![![1, -1], ![0, 1]], by norm_num [matrix.det_fin_two]ā©

/-- The matrix `S = [[0,-1],[1,0]]` as an element of `SL(2,ā¤)` -/
def S : SL(2,ā¤) := āØ![![0, -1], ![1, 0]], by norm_num [matrix.det_fin_two]ā©

/-- The standard (closed) fundamental domain of the action of `SL(2,ā¤)` on `ā` -/
def fundamental_domain : set ā :=
{z | 1 ā¤ (complex.norm_sq z) ā§ |z.re| ā¤ (1 : ā) / 2}

localized "notation `š` := modular_group.fundamental_domain" in modular

/-- If `|z|<1`, then applying `S` strictly decreases `im` -/
lemma im_lt_im_S_smul {z : ā} (h: norm_sq z < 1) : z.im < (S ā¢ z).im :=
begin
  have : z.im < z.im / norm_sq (z:ā),
  { have imz : 0 < z.im := im_pos z,
    apply (lt_div_iff z.norm_sq_pos).mpr,
    nlinarith },
  convert this,
  simp only [im_smul_eq_div_norm_sq],
  field_simp [norm_sq_denom_ne_zero, norm_sq_ne_zero, S]
end

/-- Any `z : ā` can be moved to `š` by an element of `SL(2,ā¤)`  -/
lemma exists_smul_mem_fundamental_domain (z : ā) : ā g : SL(2,ā¤), g ā¢ z ā š :=
begin
  -- obtain a gā which maximizes im (g ā¢ z),
  obtain āØgā, hgāā© := exists_max_im z,
  -- then among those, minimize re
  obtain āØg, hg, hg'ā© := exists_row_one_eq_and_min_re z (bottom_row_coprime gā),
  refine āØg, _ā©,
  -- `g` has same max im property as `gā`
  have hgā' : ā (g' : SL(2,ā¤)), (g' ā¢ z).im ā¤ (g ā¢ z).im,
  { have hg'' : (g ā¢ z).im = (gā ā¢ z).im,
    { rw [im_smul_eq_div_norm_sq, im_smul_eq_div_norm_sq, denom_apply, denom_apply, hg] },
    simpa only [hg''] using hgā },
  split,
  { -- Claim: `1 ā¤ ānorm_sq ā(g ā¢ z)`. If not, then `Sā¢gā¢z` has larger imaginary part
    contrapose! hgā',
    refine āØS * g, _ā©,
    rw mul_action.mul_smul,
    exact im_lt_im_S_smul hgā' },
  { show |(g ā¢ z).re| ā¤ 1 / 2, -- if not, then either `T` or `T'` decrease |Re|.
    rw abs_le,
    split,
    { contrapose! hg',
      refine āØT * g, by simp [T, matrix.mul, matrix.dot_product, fin.sum_univ_succ], _ā©,
      rw mul_action.mul_smul,
      have : |(g ā¢ z).re + 1| < |(g ā¢ z).re| :=
        by cases abs_cases ((g ā¢ z).re + 1); cases abs_cases (g ā¢ z).re; linarith,
      convert this,
      simp [T] },
    { contrapose! hg',
      refine āØT' * g, by simp [T', matrix.mul, matrix.dot_product, fin.sum_univ_succ], _ā©,
      rw mul_action.mul_smul,
      have : |(g ā¢ z).re - 1| < |(g ā¢ z).re| :=
        by cases abs_cases ((g ā¢ z).re - 1); cases abs_cases (g ā¢ z).re; linarith,
      convert this,
      simp [T', sub_eq_add_neg] } }
end

end fundamental_domain

end modular_group
