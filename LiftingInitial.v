Require Import UniMath.Foundations.Generalities.uu0.
Require Import UniMath.Foundations.hlevel1.hProp.
Require Import UniMath.Foundations.hlevel2.hSet.

Require Import UniMath.RezkCompletion.precategories.
Require Import UniMath.RezkCompletion.functors_transformations.
Require Import SubstSystems.UnicodeNotations.
Require Import UniMath.RezkCompletion.whiskering.
Require Import UniMath.RezkCompletion.Monads.
Require Import UniMath.RezkCompletion.limits.products.
Require Import UniMath.RezkCompletion.limits.coproducts.
Require Import UniMath.RezkCompletion.limits.initial.
Require Import SubstSystems.Auxiliary.
Require Import SubstSystems.PointedFunctors.
Require Import SubstSystems.ProductPrecategory.
Require Import SubstSystems.HorizontalComposition.
Require Import SubstSystems.PointedFunctorsComposition.
Require Import SubstSystems.SubstitutionSystems.
Require Import SubstSystems.FunctorsPointwiseCoproduct.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Arguments functor_composite {_ _ _} _ _ .
Arguments nat_trans_comp {_ _ _ _ _} _ _ .
Local Notation "G ∙ F" := (functor_composite F G : [ _ , _ , _ ]) (at level 35).
Local Notation "α ∙∙ β" := (hor_comp β α) (at level 20).
Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

Local Notation "α 'ø' Z" := (pre_whisker Z α)  (at level 25).
Local Notation "Z ∘ α" := (post_whisker _ _ _ _ α Z) (at level 35).

Local Notation "C ⟦ a , b ⟧" := (precategory_morphisms (C:=C) a b) (at level 50).

Arguments θ_source {_ _} _ .
Arguments θ_target {_ _} _ .
Arguments θ_Strength1 {_ _ _} _ .
Arguments θ_Strength2 {_ _ _} _ .

Section Precategory_Algebra.

(** Define the precategory of Id+H-algebras.

    We could define this precategory before that of hss, and
    define hss as a sub-precategory of that of Id+H-algebras
    As a consequence, we would have faithfulness of the forgetful
    functor for free.
    Also, composition and identity would be inherited instead of
    having to be defined twice.

    On the other hand, the category of hss is the main object of 
    investigation, so maybe it is better to give it more explicitly.
    Working with sub-precategories is a pain in the butt.

*)


Variable C : precategory.
Variable hs : has_homsets C.

 Local Notation "'EndC'":= ([C, C, hs]) .
Local Notation "'Ptd'" := (precategory_Ptd C hs).
Local Notation "'U'" := (functor_ptd_forget C hs).

Variable H : functor [C,C,hs] [C,C,hs].

Variable θ : θ_source H ⟶ θ_target H.

Local Notation "'Alg_obj'" := (Alg C hs H).


Definition Alg_mor (A B : Alg_obj) : UU 
  := Σ f : Ptd ⟦A, B⟧, isAlgMor C hs H f. 

(* explicit coercion not necessary, this works, too:
Definition Alg_mor' (A B : Alg_obj) : UU 
  := Σ f : A ⇒ pr1 B, isAlgMor C hs H f.
*)

Coercion Ptd_mor_from_Alg_mor (A B : Alg_obj)(f : Alg_mor A B) : Ptd ⟦A, B⟧ := pr1 f.

Definition isAlgMor_Alg_mor (A B : Alg_obj)(f : Alg_mor A B) : isAlgMor _ _ _ f := pr2 f.

Definition Alg_mor_eq_weq (A B : Alg_obj) (f g : Alg_mor A B) 
  : f = g ≃ #U f = #U g.
Proof.
  eapply weqcomp.
  - apply total2_paths_isaprop_equiv.
    intro h. apply isaprop_isAlgMor.
  - apply eq_ptd_mor.
    apply hs.
Defined.

Definition isAlgMor_id (A : Alg_obj) : isAlgMor C hs H (identity A : Ptd⟦A,A⟧).
Proof.
  unfold isAlgMor.
  rewrite functor_id.
  rewrite functor_id.
  rewrite id_left.
  set (H2 := id_right ([C,C,hs])).
  apply pathsinv0, H2.
Qed.

Definition AlgMor_id (A : Alg_obj) : Alg_mor A A := tpair _ _ (isAlgMor_id A).


Definition isAlgMor_comp (A B D : Alg_obj) (f : Alg_mor A B) (g : Alg_mor B D) 
  : isAlgMor C hs H (f ;; g : Ptd⟦A, D⟧).
Proof.
  unfold isAlgMor.
  rewrite functor_comp.
  rewrite functor_comp.
  rewrite <- assoc.
  rewrite isAlgMor_Alg_mor.
  rewrite assoc.
  rewrite isAlgMor_Alg_mor.
  apply pathsinv0, assoc.
Qed.

Definition AlgMor_comp (A B D : Alg_obj) (f : Alg_mor A B) (g : Alg_mor B D) : Alg_mor A D
  := tpair _ _ (isAlgMor_comp A B D f g).

Definition Alg_precategory_ob_mor : precategory_ob_mor.
Proof.
  exists Alg_obj.
  exact (Alg_mor).
Defined.

Definition Alg_precategory_data : precategory_data.
Proof.
  exists Alg_precategory_ob_mor.
  split.
  - exact AlgMor_id.
  - exact AlgMor_comp.
Defined.

Lemma is_precategory_Alg : is_precategory Alg_precategory_data.
Proof.
  repeat split; intros.
  - apply (invmap (Alg_mor_eq_weq _ _ _ _ )).
    apply (id_left EndC).
  - apply (invmap (Alg_mor_eq_weq _ _ _ _ )).
    apply (id_right EndC).
  - apply (invmap (Alg_mor_eq_weq _ _ _ _ )).
    apply (assoc EndC).
Qed.

Definition precategory_Alg : precategory := tpair _ _ is_precategory_Alg.

Local Notation "'ALG'" := precategory_Alg.

Variable IA : Initial precategory_Alg.

Definition InitAlg : ALG := InitialObject _ IA.

Definition bracket_for_InitAlg : bracket _ _ H θ InitAlg.
Proof.
  intros F α.
  admit.
Admitted.

Definition InitHSS : hss_precategory C hs H θ.
Proof.
  exists InitAlg.
  exact bracket_for_InitAlg.
Defined.

Lemma isInitial_InitHSS : isInitial (hss_precategory C hs H θ) InitHSS.
Proof.
  admit.
Admitted.

Lemma Ihss : Initial (hss_precategory C hs H θ).
Proof.
  exists InitHSS.
  apply isInitial_InitHSS.
Defined.


End Precategory_Algebra.
   