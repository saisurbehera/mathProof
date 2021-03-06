/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel
-/
import category_theory.generator
import category_theory.preadditive.yoneda

/-!
# Separators in preadditive categories

This file contains characterizations of separating sets and objects that are valid in all
preadditive categories.

-/

universes v u

open category_theory opposite

namespace category_theory
variables {C : Type u} [category.{v} C] [preadditive C]

lemma preadditive.is_separating_iff (š¢ : set C) :
  is_separating š¢ ā ā ā¦X Y : Cā¦ (f : X ā¶ Y), (ā (G ā š¢) (h : G ā¶ X), h ā« f = 0) ā f = 0 :=
āØĪ» hš¢ X Y f hf, hš¢ _ _ (by simpa only [limits.comp_zero] using hf),
 Ī» hš¢ X Y f g hfg, sub_eq_zero.1 $ hš¢ _
  (by simpa only [preadditive.comp_sub, sub_eq_zero] using hfg)ā©

lemma preadditive.is_coseparating_iff (š¢ : set C) :
  is_coseparating š¢ ā ā ā¦X Y : Cā¦ (f : X ā¶ Y), (ā (G ā š¢) (h : Y ā¶ G), f ā« h = 0) ā f = 0 :=
āØĪ» hš¢ X Y f hf, hš¢ _ _ (by simpa only [limits.zero_comp] using hf),
 Ī» hš¢ X Y f g hfg, sub_eq_zero.1 $ hš¢ _
  (by simpa only [preadditive.sub_comp, sub_eq_zero] using hfg)ā©

lemma preadditive.is_separator_iff (G : C) :
  is_separator G ā ā ā¦X Y : Cā¦ (f : X ā¶ Y), (ā h : G ā¶ X, h ā« f = 0) ā f = 0 :=
āØĪ» hG X Y f hf, hG.def _ _ (by simpa only [limits.comp_zero] using hf),
 Ī» hG, (is_separator_def _).2 $ Ī» X Y f g hfg, sub_eq_zero.1 $ hG _
  (by simpa only [preadditive.comp_sub, sub_eq_zero] using hfg)ā©

lemma preadditive.is_coseparator_iff (G : C) :
  is_coseparator G ā ā ā¦X Y : Cā¦ (f : X ā¶ Y), (ā h : Y ā¶ G, f ā« h = 0) ā f = 0 :=
āØĪ» hG X Y f hf, hG.def _ _ (by simpa only [limits.zero_comp] using hf),
 Ī» hG, (is_coseparator_def _).2 $ Ī» X Y f g hfg, sub_eq_zero.1 $ hG _
  (by simpa only [preadditive.sub_comp, sub_eq_zero] using hfg)ā©

lemma is_separator_iff_faithful_preadditive_coyoneda (G : C) :
  is_separator G ā faithful (preadditive_coyoneda.obj (op G)) :=
begin
  rw [is_separator_iff_faithful_coyoneda_obj, ā whiskering_preadditive_coyoneda, functor.comp_obj,
    whiskering_right_obj_obj],
  exact āØĪ» h, by exactI faithful.of_comp _ (forget AddCommGroup), Ī» h, by exactI faithful.comp _ _ā©
end

lemma is_separator_iff_faithful_preadditive_coyoneda_obj (G : C) :
  is_separator G ā faithful (preadditive_coyoneda_obj (op G)) :=
begin
  rw [is_separator_iff_faithful_preadditive_coyoneda, preadditive_coyoneda_obj_2],
  exact āØĪ» h, by exactI faithful.of_comp _ (forgetā _ AddCommGroup.{v}),
         Ī» h, by exactI faithful.comp _ _ā©
end

lemma is_coseparator_iff_faithful_preadditive_yoneda (G : C) :
  is_coseparator G ā faithful (preadditive_yoneda.obj G) :=
begin
  rw [is_coseparator_iff_faithful_yoneda_obj, ā whiskering_preadditive_yoneda, functor.comp_obj,
    whiskering_right_obj_obj],
  exact āØĪ» h, by exactI faithful.of_comp _ (forget AddCommGroup), Ī» h, by exactI faithful.comp _ _ā©
end

lemma is_coseparator_iff_faithful_preadditive_yoneda_obj (G : C) :
  is_coseparator G ā faithful (preadditive_yoneda_obj G) :=
begin
  rw [is_coseparator_iff_faithful_preadditive_yoneda, preadditive_yoneda_obj_2],
  exact āØĪ» h, by exactI faithful.of_comp _ (forgetā _ AddCommGroup.{v}),
         Ī» h, by exactI faithful.comp _ _ā©
end

end category_theory
