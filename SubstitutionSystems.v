Require Import Foundations.Generalities.uu0.
Require Import Foundations.hlevel1.hProp.
Require Import Foundations.hlevel2.hSet.

Require Import RezkCompletion.precategories.
Require Import RezkCompletion.functors_transformations.
Require Import SubstSystems.UnicodeNotations.
Require Import RezkCompletion.whiskering.
Require Import RezkCompletion.Monads.
Require Import SubstSystems.Auxiliary.
Require Import SubstSystems.PointedFunctors.
Require Import SubstSystems.ProductPrecategory.
Require Import SubstSystems.HorizontalComposition.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Arguments functor_composite {_ _ _} _ _ .
Arguments nat_trans_comp {_ _ _ _ _} _ _ .
Arguments pre_whisker {_ _ _ _ _} _ {_ _} _ .
Local Notation "G ∙ F" := (functor_composite F G : [ _ , _ , _ ]) (at level 35).
Local Notation "α ∙∙ β" := (hor_comp β α) (at level 20).
Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

Local Notation "α 'ø' Z" := (pre_whisker Z α)  (at level 25).
Local Notation "Z ∘ α" := (post_whisker _ _ _ _ α Z) (at level 35).

Section def_hss.

Variable C : precategory.
Variable hs : has_homsets C.

Variable H : functor [C, C, hs] [C, C, hs].

(* formalize [θ] not as a natural transformation, but simply by
   writing down all the axioms 
*)

Local Notation "'U'" := (functor_ptd_forget C hs).
Local Notation "'Ptd'" := (precategory_Ptd C hs).
Local Notation "'EndC'":= ([C, C, hs]) .
Local Notation "A 'XX' B" := (product_precategory A B) (at level 2).

(* Definition U₀ (F : precategory_Ptd C hs) : functor C C := functor_ptd_forget C hs F. *)

Definition θ_source_ob (F : [C, C, hs]) (X : Ptd) : [C, C, hs] := H F ∙ U X.

Definition θ_source_ob' (FX : EndC XX Ptd) : [C, C, hs] := H (pr1 FX) ∙ U (pr2 FX).


Definition θ_source_mor {F F' : [C, C, hs]} {X X' : Ptd} (α : F ⇒ F') (β : X ⇒ X') 
  : θ_source_ob F X ⇒ θ_source_ob F' X' 
  := #H α ∙∙ #U β.

Definition θ_source_mor' {FX FX' : EndC XX Ptd} (αβ : FX ⇒ FX') 
  : θ_source_ob' FX ⇒ θ_source_ob' FX' := hor_comp (#U (pr2 αβ)) (#H (pr1 αβ)).


Definition θ_source_functor_data : functor_data (EndC XX Ptd) EndC.
Proof.
  exists θ_source_ob'.
  exact (@θ_source_mor').
Defined.

Lemma is_functor_θ_source : is_functor θ_source_functor_data.
Proof.
  split; simpl.
  - intro FX.
    apply nat_trans_eq.
    + apply hs.
    + intro c. simpl.
      rewrite functor_id.
      rewrite id_right.
      set (HH:=functor_id H).
      rewrite HH. apply idpath.
  - intros FX FX' FX'' α β.
    apply nat_trans_eq.
    + apply hs.
    + destruct FX as [F X].
      destruct FX' as [F' X'].
      destruct FX'' as [F'' X''].
      intro c ; simpl in *.
      destruct α as [α a].
      destruct β as [β b]. simpl in *.
      rewrite functor_comp.
      set (HH:=functor_comp H).
      rewrite HH; simpl; clear HH.
      repeat rewrite <- assoc.
      apply maponpaths.
      rewrite <- nat_trans_ax.
      destruct a as [a aax].
      destruct b as [b bax]. simpl in *.
      destruct X as [X eta].
      destruct X' as [X' eta'].
      destruct X'' as [X'' eta'']; simpl in *.
      clear aax eta. clear bax eta'. clear eta''.
      set (HHH:=nat_trans_ax (#H β)).
      rewrite <- functor_comp.
      rewrite HHH.
      rewrite assoc.
      rewrite HHH.
      rewrite <- assoc.
      apply maponpaths.
      apply functor_comp.
Qed.

Definition θ_source : functor _ _ := tpair _ _ is_functor_θ_source.

Definition θ_target_ob (FX : EndC XX Ptd) : EndC := H (pr1 FX ∙ U (pr2 FX)).

Definition θ_target_mor (FX FX' : EndC XX Ptd) (αβ : FX ⇒ FX') 
  : θ_target_ob FX ⇒ θ_target_ob FX'
  := #H (pr1 αβ ∙∙ #U(pr2 αβ)).

Definition θ_target_functor_data : functor_data (EndC XX Ptd) EndC.
Proof.
  exists θ_target_ob.
  exact θ_target_mor.
Defined.


Lemma is_functor_θ_target_functor_data : is_functor θ_target_functor_data.
Proof.
  split; simpl.
  - intro FX; simpl.
    unfold θ_target_mor. 
    set (T:= functor_id_id _ _ H).
    apply T; simpl.
    apply nat_trans_eq.
    + apply hs.
    + intro c; simpl.
      rewrite id_left.
      rewrite functor_id.
      apply idpath.
  - intros FX FX' FX''.
    intros α β.
    unfold θ_target_mor.
    set (T:=functor_comp H _ _ _ (pr1 α ∙∙ # U (pr2 α)) (pr1 β ∙∙ # U (pr2 β))).
    simpl in *.
    etransitivity.
    Focus 2.
      apply T. 
    apply maponpaths. clear T.
    simpl.
    destruct α as [α a].
    destruct β as [β b]; simpl in *.
    apply nat_trans_eq.
    + apply hs.
    + intro c.
      unfold hor_comp; simpl.
      destruct FX as [F X];
      destruct FX' as [F' X'];
      destruct FX'' as [F'' X'']; simpl in *.
      repeat rewrite <- assoc. apply maponpaths.
      rewrite <- (nat_trans_ax β).
      rewrite functor_comp.
      repeat rewrite <- assoc; apply maponpaths.
      apply nat_trans_ax.
Qed.      

Definition θ_target : functor _ _ := tpair _ _ is_functor_θ_target_functor_data.

Hypothesis θ : θ_source ⟶ θ_target.

Definition prodcatpair (X : functor C C) (Z : Ptd) : ob EndC XX Ptd.
Proof.
  exists X.
  exact Z.
Defined.
Local Notation "A ⊗ B" := (prodcatpair A B) (at level 10).

Definition prodcatmor {X X' : EndC} {Z Z' : Ptd} (α : X ⇒ X') (β : Z ⇒ Z') 
  : X ⊗ Z ⇒ X' ⊗ Z'.
Proof.
  exists α.
  exact β.
Defined.

Lemma θ_nat_1 (X X' : EndC) (α : X ⇒ X') (Z : Ptd) 
  : compose(C:=EndC) (# H α ∙∙ nat_trans_id (pr1 (U Z))) (θ (X' ⊗ Z)) =
        θ (X ⊗ Z);; # H (α ∙∙ nat_trans_id (pr1 (U Z))).
Proof.
  set (t:=nat_trans_ax θ).
  set (t':=t (X ⊗ Z) (X' ⊗ Z)).
  set (t'':= t' (prodcatmor α (identity _ ))).
  simpl in t''.
  exact t''.
Qed.

Lemma θ_nat_1_pointwise (X X' : EndC) (α : X ⇒ X') (Z : Ptd) (c : C)
  :  pr1 (# H α) ((pr1 Z) c);; pr1 (θ (X' ⊗ Z)) c =
       pr1 (θ (X ⊗ Z)) c;; pr1 (# H (α ∙∙ nat_trans_id (pr1 Z))) c.
Proof.
  set (t := θ_nat_1 _ _ α Z).
  set (t' := nat_trans_eq_weq _ _ hs _ _ _ _ t c).
  clearbody t'.
  simpl in t'.
  set (H':= functor_id (H X') (pr1 Z c)).
  simpl in *.
  transitivity ( pr1 (# H α) ((pr1 Z) c);; # (pr1 (H X')) (identity ((pr1 (pr1 Z)) c));;
       pr1 (θ (X' ⊗ Z)) c ).
  - rewrite <- assoc.
    apply maponpaths.
    match goal with | [|- ?f = _ ] => transitivity (identity _ ;; f) end.
    + apply pathsinv0, id_left.
    + apply cancel_postcomposition.
      apply (!H').
  - apply t'.
Qed.

Lemma θ_nat_2 (X : EndC) (Z Z' : Ptd) (f : Z ⇒ Z')
  : compose (C:=EndC) (identity (H X) ∙∙ pr1 f) (θ (X ⊗ Z')) =
       θ (X ⊗ Z);; # H (identity X ∙∙ pr1 f).
Proof.
  set (t := nat_trans_ax θ).
  set (t' := t (prodcatpair X Z) (prodcatpair X Z') (prodcatmor (identity _ ) f)).
  simpl in t'.
  unfold θ_source_mor' in t'.
  unfold θ_target_mor in t'.
  simpl in t'.
  set (T := functor_id H X).
  simpl in *.
  rewrite T in t'. clear T.
  exact t'.
Qed.

Lemma θ_nat_2_pointwise (X : EndC) (Z Z' : Ptd) (f : Z ⇒ Z') (c : C)
  :  # (pr1 (H X)) ((pr1 f) c);; pr1 (θ (X ⊗ Z')) c =
       pr1 (θ (X ⊗ Z)) c;; pr1 (# H (identity X ∙∙ pr1 f)) c .
Proof.
  set (t:=θ_nat_2 X _ _ f).
  set (t':=nat_trans_eq_weq _ _ hs _ _ _ _ t c).
  clearbody t'; clear t.
  simpl in t'.
  rewrite id_left in t'.
  exact t'.
Qed.
(*
  change (identity X ∙∙ pr1 f) with (functor_composite X
  unfold hor_comp in t'.
  simpl in *.
*)
(*
  assert (TTT: pr1 (#H (identity X ∙∙ pr1 f)) c = pr1 (#H (pr1 f)) c).
*)

(*
  set (H':= functor_id (pre_composition_functor C _ C hs hs  (U F))).
  set (Ha := H' (U F)).
*)
Definition id_Ptd : Ptd.
Proof.
  exists (functor_identity _).
  exact (nat_trans_id _ ).
Defined.

(* 
  does not typecheck cuz the first is of type [H X c] whereas the second 
   is of type [H (X ∙ Id) c] 

  it is best to postpone the formulation of this statement until we see what we need

*)
(* 
Hypothesis θ1 : ∀ (X : EndC) (c : C), 
  pr1 (θ (dirprodpair X id_Ptd)) c = pr1 (identity (H X)) c.
*)



Definition AlgStruct (T : Ptd) : UU := pr1 (H(U T)) ⟶ pr1 (U T).

Definition Alg : UU := Σ T : Ptd, AlgStruct T.

Coercion PtdFromAlg (T : Alg) : Ptd := pr1 T.

Definition τ (T : Alg) : pr1 (H (U T)) ⟶ pr1 (U T) := pr2 T.



(*
Definition bracket (T : Alg) : UU := 
  ∀ (Z : Ptd) (f : Z ⇒ T), iscontr 
   (Σ h : functor_composite (U Z) (U T)  ⟶ (U T),
     (∀ c : C, pr1 (#U f) c = ptd_pt _ (pr1 T) (pr1 (U Z) c) ;; h c) ×
     (∀ c : C, pr1 (θ (prodcatpair (U T) Z))  c ;; pr1 (#H h) c ;; τ _ c = 
        τ _ (pr1 (U Z) c) ;; h c)).

Definition bracket' (T : Alg) : UU := 
  ∀ (Z : Ptd) (f : Z ⇒ T), iscontr 
   (Σ h : (U T) ∙ (U Z)  ⇒ U T,
     (∀ c : C, pr1 (#U f) c = ptd_pt _ (pr1 T) (pr1 (U Z) c) ;; pr1 h c) ×
     (∀ c : C, pr1 (θ (prodcatpair (U T) Z))  c ;; pr1 (#H h) c ;; τ _ c = 
        τ _ (pr1 (U Z) c) ;; pr1 h c)).

Definition bracket'' (T : Alg) : UU := 
  ∀ (Z : Ptd) (f : Z ⇒ T), iscontr 
   (Σ h : (U T) ∙ (U Z)  ⇒ U T,
     (#U f = pre_whisker (U Z) (ptd_pt _ (pr1 T)) ;; h) ×
     (∀ c : C, pr1 (θ (prodcatpair (U T) Z))  c ;; pr1 (#H h) c ;; τ _ c = 
        τ _ (pr1 (U Z) c) ;; pr1 h c)).
*)
Definition bracket (T : Alg) : UU := 
  ∀ (Z : Ptd) (f : Z ⇒ T), iscontr 
   (Σ h : (U T) ∙ (U Z)  ⇒ U T,
     (#U f = pre_whisker (U Z) (ptd_pt _ (pr1 T)) ;; h) ×
     (θ (U T ⊗ Z) ;; #H h ;; τ _  = pre_whisker (U Z) (τ _) ;;  h )).

Definition hss : UU := Σ T : Alg, bracket T.

Coercion AlgFromhss (T : hss) : Alg := pr1 T.

Definition fbracket (T : hss) {Z : Ptd} (f : Z ⇒ T) 
  : (U T) ∙ (U Z) ⇒ U T
  := pr1 (pr1 (pr2 T Z f)).


Definition fbracket_unique_pointwise (T : hss) {Z : Ptd} (f : Z ⇒ T) 
  : ∀ (α : functor_composite (U Z)(U T) ⟶ pr1 (U T)),
     (∀ c : C, pr1 (#U f) c = ptd_pt _ (pr1 (pr1 T)) (pr1 (U Z) c) ;; α c) →
     (∀ c : C, pr1 (θ (U T ⊗ Z))  c ;; pr1 (#H α) c ;; τ _ c = 
        τ _ (pr1 (U Z) c) ;; α c) → α = fbracket T f.
Proof.
  intros α H1 H2.
  apply path_to_ctr.
  split; apply nat_trans_eq; assumption.
Qed.

Definition fbracket_unique (T : hss) {Z : Ptd} (f : Z ⇒ T) 
  : ∀ α : functor_composite (U Z)(U T) ⟶ pr1 (U T),
     (#U f = pre_whisker (U Z) (ptd_pt _ ((pr1 (pr1 T)))) ;; α) →
     (θ (U T ⊗ Z) ;; #H α ;; τ _ = pre_whisker (U Z) (τ _) ;; α) 
   → α = fbracket T f.
Proof.
  intros α H1 H2.
  apply path_to_ctr.
  split;  assumption.
Qed.

Definition fbracket_unique_target_pointwise (T : hss) {Z : Ptd} (f : Z ⇒ T) 
  : ∀ α : functor_composite (U Z)(U T) ⟶ pr1 (U T),
     (#U f = pre_whisker (U Z) (ptd_pt _ ((pr1 (pr1 T)))) ;; α) →
     (θ (U T ⊗ Z) ;; #H α ;; τ _ = pre_whisker (U Z) (τ _) ;; α) 
   → ∀ c, α c = pr1 (fbracket T f) c.
Proof.
  intros α H1 H2.
  set (t:= fbracket_unique _ _ α H1 H2).
  apply (nat_trans_eq_weq _ _ hs _ _ _ _ t).
Qed.

(* Properties of [fbracket] by definition *)

Lemma fbracket_η (T : hss) : ∀ {Z : Ptd} (f : Z ⇒ T),
   #U f = pre_whisker (U Z) (ptd_pt _  (pr1 (pr1 T))) ;; fbracket T f.
Proof.
  intros Z f.
  exact (pr1 (pr2 (pr1 (pr2 T Z f)))).
Qed.

Lemma fbracket_τ (T : hss) : ∀ {Z : Ptd} (f : Z ⇒ T),
    θ (U T ⊗ Z) ;; #H (fbracket T f) ;; τ _  
    = 
    pre_whisker (U Z) (τ _) ;;  fbracket T f .
Proof.
  intros Z f.
  exact (pr2 (pr2 (pr1 (pr2 T Z f)))).
Qed.

Lemma fbracket_natural (T : hss) {Z Z' : Ptd} (f : Z ⇒ Z') (g : Z' ⇒ T) 
  : post_whisker _ _ _ _ (#U f)(U T) ;; fbracket T g = fbracket T (f ;; g).
Proof.
  apply fbracket_unique_pointwise.
  - simpl. intro c.
    set (H':=nat_trans_ax (ptd_pt _ (pr1 (pr1 T)) )).
    rewrite assoc.
    simpl in H'.
    rewrite <- H'.
    rewrite <- assoc.
    apply maponpaths.
    set (X:= nat_trans_eq_weq _ _ hs _ _ _ _  (fbracket_η T g)).
    simpl in X. exact (X _ ).
  - intro c; simpl.
    set (H':=nat_trans_ax (τ T)).
    simpl in H'.
    rewrite assoc.
    rewrite <- H'; clear H'.
    set (H':=fbracket_τ T g).
    simpl in H'.
    Check nat_trans_eq_weq.
    set (X:= nat_trans_eq_weq _ _ hs _ _ _ _ H' c).
    simpl in X.
    rewrite  <- assoc.
    rewrite  <- assoc.
    simpl in *.
    transitivity (  # (pr1 (H ((U T)))) (pr1 (pr1 f) c) ;;
                     (pr1 (θ (prodcatpair (U T) Z')) c);; pr1 (# H (fbracket T g)) c;; (τ T) c).
    Focus 2.
      rewrite <- assoc.
      rewrite <- assoc.
      apply maponpaths.
      repeat rewrite assoc.
      apply X.
    clear X.
    set (A:=θ_nat_2_pointwise).
    simpl in *.
    set (A':= A (U T) Z Z').
    simpl in A'.
    set (A2:= A' f).
    clearbody A2; clear A'; clear A.
    rewrite A2; clear A2.
    repeat rewrite <- assoc.
    apply maponpaths.
    simpl.
    repeat rewrite assoc.
    apply cancel_postcomposition.
    set (A := functor_comp H).
    simpl in A.
    rewrite A.
    apply cancel_postcomposition.
    clear A. clear H'.
    set (A:=horcomp_id_postwhisker C _ _ hs hs).
    rewrite A.
    apply idpath.
Qed.

Lemma compute_fbracket (T : hss) : ∀ {Z : Ptd} (f : Z ⇒ T),
  fbracket T f = post_whisker _ _ _ _ (#U f)(U T) ;; fbracket T (identity _ ). 
Proof.
  intros Z f.
  assert (A : f = f ;; identity _ ).
  { rewrite id_right; apply idpath. }
  rewrite A.
  rewrite <- fbracket_natural.
  rewrite id_right.
  apply idpath.
Qed.

(* not quite clear what this should be *)
(*
Definition fbracket_unique_pointwise (T : hss) {Z : Ptd} (f : Z ⇒ T) 
  : ∀ (α : functor_composite (U Z)(U T) ⟶  (U T) ),
     (∀ c : C, pr1 (#U f) c = ptd_pt _ (pr1 (pr1 T)) (pr1 (U Z) c) ;; α c) →
     (∀ c : C, pr1 (θ (prodcatpair (U T) Z))  c ;; pr1 (#H α) c ;; τ _ c = 
        τ _ (pr1 (U Z) c) ;; α c) → α = fbracket T f.
Proof.
  intros α H1 H2.
  apply path_to_ctr.
  split; assumption.
Qed.
*)

Section mu_from_fbracket.

Variable T : hss.

Local Notation "'η'" := (ptd_pt _ (pr1 (pr1 T))).

Definition μ_0 : functor_identity C ⟶ U T := η. (*ptd_pt _ (pr1 (pr1 T)).*)

Definition μ_0_ptd : id_Ptd ⇒ T.
Proof.
  exists μ_0.
  intro c. simpl. apply id_left.
Defined.

Definition μ_1 : functor_composite (U id_Ptd) (U T) ⟶ U T 
  := fbracket _ μ_0_ptd.

Lemma μ_1_alt_is_nat_trans:
 is_nat_trans (functor_composite (U id_Ptd) (U T)) 
     (U T) (λ c : C, identity ((functor_composite (U id_Ptd) (U T)) c)).
Proof.
  unfold is_nat_trans; simpl; intros.
  rewrite id_right.
  rewrite id_left.
  apply idpath.
Qed.

Definition μ_1_alt : functor_composite (U id_Ptd) (U T) ⟶ U T.
Proof.
  exists (λ c, identity _ ).
  apply μ_1_alt_is_nat_trans.
Defined.
  

Lemma equal_to_identity (a b : C) (f : a ⇒ a) (g g' : a ⇒ b) : 
   f = identity _ → g = g' → f ;; g = g'.
Proof.
  intros.
  subst.
  apply id_left.
Qed.

Lemma μ_1_identity' : μ_1_alt = μ_1.
Proof.
  apply fbracket_unique_pointwise.
  - intros; simpl.
    rewrite id_right.
    apply idpath.
  - intros; simpl.
    rewrite id_right.
    assert (H':pr1 (θ (prodcatpair (U (pr1 T)) id_Ptd)) c;; pr1 (# H μ_1_alt) c = identity _ ).
    { admit. } (* should be given by hypothesis on θ *) 
    apply equal_to_identity.
    + apply H'.
    + apply idpath.
Qed.
  

Lemma μ_1_identity : ∀ c : C, μ_1 c = identity _.
Proof.
  intros c.
  rewrite <- μ_1_identity'.
  apply idpath.
Qed.

(* This is the multiplication of the monad to be constructed *)
Definition μ_2 : functor_composite (U T) (U T) ⟶ U T 
  := fbracket T (identity _ ).
(*
Definition μ_3 := fbracket T μ_2.
*)
Definition functor_with_mu_from_hss : functor_with_μ C.
Proof.
  exists (U T).
  exact μ_2.
Defined.

Definition Monad_data_from_hss : Monad_data C.
Proof.
  exists functor_with_mu_from_hss.
  exact μ_0.
Defined.

Lemma Monad_law_1_from_hss :
  ∀ c : C, μ_0 (pr1 (U T) c);; μ_2 c = identity ((pr1 (U T)) c).
Proof.
  intro c. 
  unfold μ_2. simpl.
  unfold μ_0. simpl.
  set (H':=fbracket_η T (identity _) ).
  set (H2:= nat_trans_eq_weq _ _ hs _ _ _ _ H').
  simpl in H2.
  apply pathsinv0.
  apply H2.
Qed.

Lemma ηη_nat_trans :
  is_nat_trans (functor_identity C) (functor_composite (U T) (U T))
     (λ c : C, η c;; η ((pr1 (U T)) c)).
Proof.
  simpl.
  unfold is_nat_trans.
  simpl.
  intros c c' f.
  set (η_nat := nat_trans_ax η).
  repeat rewrite <- assoc.
  set (H1 := η_nat _ _ (# (pr1 (U T)) f)); clearbody H1.
  simpl in H1.
  
  transitivity (η c ;;  # (pr1 (U T)) f;; η ((pr1 (U T)) c')).
  
  Focus 2.
  repeat rewrite <- assoc.
  apply maponpaths.
  apply H1.
  
  clear H1.
  
  repeat rewrite assoc.
  apply cancel_postcomposition.
  apply η_nat.
Qed.

Definition T_squared : Ptd.
Proof.
  exists (functor_composite (U T) (U T)).
  exists (λ c, η c ;; η (pr1 (U T) c)).
(*  exists (λ c, ptd_pt _ (pr1 (pr1 T)) c ;; ptd_pt _ (pr1 (pr1 T)) (pr1 (U T) c)). *)
  apply ηη_nat_trans.
Defined.


Lemma μ_2_is_ptd_mor :
  ∀ c : C, (ptd_pt C T_squared) c;; μ_2 c = (ptd_pt C (pr1 (pr1 T))) c.
Proof.
  intro c.
  unfold μ_2.
  unfold T_squared. simpl.
  set (H':=Monad_law_1_from_hss c).
  simpl in H'.
  transitivity (η c ;; identity _ ).
  - repeat rewrite <- assoc.
    apply maponpaths.
    apply H'.
  - apply id_right.
Qed.

Definition μ_2_ptd : T_squared ⇒ T.
Proof.
  exists μ_2.
  apply μ_2_is_ptd_mor.
Defined.

Definition μ_3 : U T_squared ∙ U T ⇒ U T := fbracket T μ_2_ptd.

Lemma μ_3_T_μ_2_μ_2 : μ_3 = (U T) ∘ μ_2 ;; μ_2.
Proof.
(*  Print functor_compose.
  Check (U T ∘ μ_2 ;; μ_2).
  Check μ_3.
  set (A:=μ_3).
  set (B:= (U T) ∘ μ_2 ;; μ_2).
  simpl in A.
  simpl in B.
  unfold functor_compose in B.
  unfold functor_composite in *.
  simpl.
  simpl in *
*)
  apply pathsinv0.
  set (H1 := @fbracket_unique T _ μ_2_ptd).
  apply H1; clear H1.
  - apply nat_trans_eq; try assumption.
    intro c; simpl.
    set (H2 := nat_trans_ax η); clearbody H2; simpl in H2.
    rewrite assoc.
    rewrite <- H2.
    set (H3:=Monad_law_1_from_hss); clearbody H3.
    rewrite <- assoc.
    transitivity (μ_2 c ;; identity _ ).
    + rewrite id_right; apply idpath.
    + apply maponpaths.
      apply pathsinv0. apply H3.
  - rewrite functor_comp.
    apply nat_trans_eq; try assumption.
    intro c; simpl.
    set (H1 := θ_nat_2 (U T) _ _ μ_2_ptd); clearbody H1.
    set (H3:=horcomp_id_postwhisker ).
    set (H4 := H3 _ _ _ hs hs _ _ μ_2 (U T)).
    simpl in H1.

    transitivity (pr1 (θ ((U T) ⊗ T_squared)) c;; 
                  pr1 (# H (nat_trans_id (U T) ∙∙ μ_2)) c;; 
                  pr1 (# H μ_2) c;; 
                  (τ T) c).
    repeat rewrite <- assoc.
    apply maponpaths.
    repeat rewrite assoc.
    apply cancel_postcomposition.
    apply cancel_postcomposition.
    rewrite H4.
    apply idpath.
    
    clear H4.
    clear H3.
    
    repeat rewrite assoc.
    unfold identity in H1; simpl in H1.
    set (H2:=nat_trans_eq_weq _ _ hs _ _ _ _ H1 c); clearbody H2.
    simpl in H2.
    rewrite id_left in H2.
    transitivity 
               (# (pr1 (H (U T))) (μ_2 c);; 
                pr1 (θ ((U T) ⊗ T)) c ;;
                 pr1 (# H μ_2) c;; 
                 (τ T) c ).
    repeat rewrite assoc.
    apply cancel_postcomposition.
    apply cancel_postcomposition.
    apply (!H2).
    
    clear H2. clear H1.


    set (H1 := @fbracket_τ T _ (identity _ )); clearbody H1.
    set (H2 := nat_trans_eq_weq _ _ hs _ _ _ _ H1 c); clearbody H2.
    simpl in H2.
    unfold μ_2.
    rewrite <- assoc in H2.
    repeat rewrite <- assoc.
    
    transitivity ( # (pr1 (H (U T))) (pr1(fbracket T (identity T)) c);;
            pr1 (τ T) ((pr1 (U T)) c);; pr1 (fbracket T (identity T)) c).
    + repeat rewrite <- assoc.
      apply maponpaths.
      apply H2.
    + clear H2 H1.
      repeat rewrite assoc.
      apply cancel_postcomposition.
      set (H1 := nat_trans_ax (τ T)).
      apply H1.
Qed.
   
   
    
Lemma μ_3_μ_2_T_μ_2 :  μ_3  = μ_2 ø U T ;; μ_2.
Proof.
  Check μ_3.
  Check (pre_whisker (U T) μ_2 ;; μ_2).
  apply pathsinv0.  
  unfold μ_3.
  set (H1 := @fbracket_unique (*_pointwise*) T _ μ_2_ptd).
  apply H1; clear H1.
  - simpl.
    apply nat_trans_eq; try assumption; intro c.
    simpl.
    set (H1:=Monad_law_1_from_hss (pr1 (U T) c)).
    simpl in H1.
    rewrite assoc.
    unfold μ_0 in H1.
    transitivity (identity _ ;; μ_2 c).
    + rewrite id_left; apply idpath.
    + apply cancel_postcomposition.
      apply (!H1).
  - 
    set (A:=θ (U T ⊗ T_squared)).
    set (H':= functor_comp H).
    set (H2:= H' _ _ _ (μ_2 ø U T) μ_2); clearbody H2; clear H'.
    set (B:= τ T).
    
    generalize dependent H2.
    
(*
    match goal with | [ |- _ -> _ = _ ;; ?f ] => set (F := f) end.
*)
    set (D:= # H (μ_2 ø U T ;; μ_2)).

    
    intro X.
    
    
    match goal with | [  |-  _ ;; ?f ;; _ = _ ] => (set (D':= f)) end.
    
    simpl in *.
    unfold functor_compose in D.

    Unset Printing Notations.
    idtac.
    
    Set Printing Coercions.
    idtac.
    Set Printing All.
    
    idtac.
    
    assert (H2 : D' = D).
    
        
    match goal with | [ H : ?f = ?g |- _ ] => set (E := g) end.

    transitivity (A ;; D ;; B).
    
    
    
    assert (H1 : D = E).
    
    unfold functor_compose in E.
    
   assert (H1 : ).
    
    transitivity (A ;; (E;; B)).
    
    set (D:= # H (pre_whisker (U T) μ_2 ;; μ_2)).
    transitivity (A ;; (# H (μ_2 ø U T ;; μ_2) ;; B)).
    rewrite H2.
    simpl.
    unfold T_squared.
    simpl.
    set (A := pr1 (θ (U T ⊗ T_squared)) c).
    set (B := pr1 (# H (μ_2 ø U T)) c).
    simpl in *.
    
    unfold θ_target_ob in A. simpl in A.
    unfold functor_compose in B.
    simpl in B.
    set (C := compose (C:=C) A  B).
    
    
    transitivity ( pr1 (θ ((U T) ⊗ T_squared)) c;; pr1 (# H (μ_2 ø U T;; μ_2)) c;;
                      (τ T) c).
    
    assert ( θ ((U T) ⊗ T_squared);; # H (μ_2 ø U T;; μ_2);; τ T =
   τ T ø U T_squared;; (μ_2 ø U T;; μ_2) ).
    
    apply nat_trans_eq; try assumption.
    intro c; simpl.
    
    
    
    set (A := θ ( U T ⊗ T_squared)).
    set (B := # H (μ_2 ø U T;; μ_2)).
    simpl in *.
    unfold functor_compose in B.
    unfold θ_target_ob in A.
    simpl in A.
    idtac.
    
    assert ( A;; # H (μ_2 ø pr1 T;; μ_2);; τ T =
   τ T ø functor_composite (pr1 T) (pr1 T);; (μ_2 ø pr1 T;; μ_2) ).
    
    rewrite H2 in B.
    Set Printing Coercions.
    idtac.
    rewrite H2.
    set (Ht := θ ((U T) ⊗ T_squared)).
    set (TT:= τ T).
    generalize dependent H2.
    set (YY := # H (μ_2 ø U T ;; μ_2)).
    destruct 1.
    rewrite H2.
    set (X:= # H (μ_2 ø U T)).
    simpl in Ht.
    unfold θ_target_ob in Ht.
    simpl in Ht.
    simpl in *.
    unfold functor_compose in X.
    simpl in H.
    set (X':=  # H (μ_2 ø U T;; μ_2) ).
    unfold functor_compose in X'.
    set (A := nat_trans_comp Ht X').
    set (A := nat_trans_comp Ht X).
    simpl in *.
*)

(*    unfold θ_target in *. simpl in *.
    unfold θ_target_functor_data in *.
*)

(*    rewrite H2.
    induction H2.
    rewrite <- H2.
    repeat rewrite <- assoc.
*)
(*
    transitivity (θ ((U T) ⊗ T_squared);; # H (μ_2 ø U T) ;; # H μ_2 ;; τ T).
*)
(*  
    set (H1:= θ_nat_1 _ _ μ_2); clearbody H1.
    set (H6 := H1 T).
    set (H3:= (nat_trans_eq_weq _ _ hs  _ _ _ _ H6) ); clearbody  H3.
    apply nat_trans_eq; try assumption.
    intro c.
    set (H4 := H3 c).
    simpl in H4.
    rewrite functor_id in H4.
    rewrite id_right in H4.
    simpl.
    
    transitivity (pr1 (θ ((U T) ⊗ T_squared)) c;; 
                  pr1 (# H (μ_2 ø U T ;; μ_2)) c  ;; τ T c).

    assert (H : ∀ c : C, 
       pr1 (θ (U T ⊗ T_squared)) c = 
         pr1 (θ (U T ⊗ T)) (pr1 (U T) c) ;; pr1 (θ (functor_composite (U T) (U T) ⊗ T)) c ).
*)

Qed.
Check μ_3_μ_2_T_μ_2.
(* Here we prove Thm 10 of the original paper 
   economically by using magic "admit" tactic. *)

Lemma Monad_laws_from_hss : Monad_laws Monad_data_from_hss.
Proof.
  split.
  - unfold Monad_data_from_hss; simpl; split.
    + apply Monad_law_1_from_hss.
    + intro c.
      transitivity (μ_1 c).
      * unfold μ_1.
        set (H':= fbracket_unique_target_pointwise).
        set (H1:= H' _ _ μ_0_ptd).
        set (x:= post_whisker _ _ _ _ μ_0 (U T)).
        set (x':= x ;; μ_2).
        set (H2 := H1 x').
        apply H2; clear H2.
        unfold x'. clear x'.
        unfold x; clear x.
        clear H1. clear H'. clear c.
        simpl.
        apply nat_trans_eq; simpl.
         apply hs.
         intro c.
         set (H':=nat_trans_ax (ptd_pt _ (pr1 (pr1 T)))).
         simpl in H'.
         rewrite assoc.
         rewrite <- H'; clear H'.
         set (H':= fbracket_η T (identity _ )).
         unfold μ_2.
         set (H2 := nat_trans_eq_weq _ _ hs _ _ _ _ H').
         simpl in H2.
         rewrite <- assoc.
         rewrite <- H2.
         rewrite id_right.
         apply idpath. (* done *)

         unfold x'; clear x'.
         unfold x; clear x.
         clear H1. clear H'.
         set (H':=θ_nat_2).
         set (H2 := H' (U T) _ _ μ_0_ptd).
         simpl in H2.
         rewrite functor_comp.
         apply nat_trans_eq; try assumption.
         clear c.
         intro c; simpl.
         set (H3:= nat_trans_eq_weq _ _ hs _ _ _ _ H2 c).
         simpl in H3.
         rewrite id_left in H3.
         rewrite <- horcomp_id_postwhisker.
         repeat rewrite assoc.
         simpl in *.
         transitivity ( # (pr1 (H ( (U T)))) (μ_0 c);; pr1 (θ (prodcatpair (U T) T)) c ;; 
                           pr1 (# H μ_2) c ;; (τ T) c).
           apply cancel_postcomposition.
           apply cancel_postcomposition.
           apply (!H3). (* done *)
           
           clear H3 H2 H'.
           set (H':= fbracket_τ T (identity _ )).
           unfold μ_2.
           simpl.
           set (H2:= nat_trans_eq_weq _ _ hs _ _ _ _ H' c).
             clearbody H2.
           simpl in *.
           repeat rewrite <- assoc.
           transitivity (  # (pr1 (H (U T))) (μ_0 c);;
                             (pr1 (τ T) (pr1 (U T) c);; pr1 (fbracket T (identity T)) c)).
             apply maponpaths.
             rewrite assoc.
             apply H2; clear H2. (* rewrite done *)
            
           clear H2 H'.
           repeat rewrite assoc.
           apply cancel_postcomposition.  
           
           
           set (H':=nat_trans_ax (τ T) ).
           rewrite H'.
           apply idpath.
    * apply μ_1_identity.

  - unfold Monad_data_from_hss; simpl.
    intro c.
    transitivity (pr1 μ_3 c).
    + set (H1 := μ_3_T_μ_2_μ_2).
      set (H2 := nat_trans_eq_weq _ _ hs _ _ _ _ H1).
      apply pathsinv0, H2.
    + set (H1 :=  μ_3_μ_2_T_μ_2).
      set (H2 := nat_trans_eq_weq _ _ hs _ _ _ _ H1).
      apply H2.
Qed.

Definition Monad_from_hss : Monad C.
Proof.
  exists Monad_data_from_hss.
  exact Monad_laws_from_hss.
Defined.

End mu_from_fbracket.

Section hss_morphisms.

Definition isAlgMor {T T' : Alg} (f : T ⇒ T') : UU :=
   #H (# U f) ;; τ T' =  compose (C:=EndC) (τ T) (#U f).

Lemma isaprop_isAlgMor (T T' : Alg) (f : T ⇒ T') : isaprop (isAlgMor f).
Proof.
  apply isaset_nat_trans.
  apply hs.
Qed.

(*
Definition isbracketMor {T T' : hss} (β : T ⇒ T') : UU :=
    ∀ (Z : Ptd) (f : Z ⇒ T), 
       ∀ c : C, pr1 (fbracket _ f) c ;; pr1 (#U β) c
                             = 
                             (pr1 (#U β)) (pr1 (U Z) c) ;; pr1 (fbracket _ (f ;; β )) c.
*)
Definition isbracketMor {T T' : hss} (β : T ⇒ T') : UU :=
    ∀ (Z : Ptd) (f : Z ⇒ T), 
       fbracket _ f ;; #U β
       = 
       pre_whisker (U Z) (#U β) ;; fbracket _ (f ;; β ).


Lemma isaprop_isbracketMor (T T':hss) (β : T ⇒ T') : isaprop (isbracketMor β).
Proof.
  do 2 (apply impred; intro).
  apply isaset_nat_trans.
  apply hs.
Qed.

(*
Definition isbracketMor' {T T' : hss} (β : T ⇒ T') : UU :=
    ∀ (Z : Ptd) (f : Z ⇒ T), 
       nat_trans_comp (fbracket _ f) (#U β)
                             = 
       nat_trans_comp (pre_whisker (U Z) (#U β)) (fbracket _ (f ;; β )).
*)

Definition ishssMor {T T' : hss} (β : T ⇒ T') : UU 
  :=  isAlgMor β × isbracketMor β.
  
Definition hssMor (T T' : hss) : UU 
  := Σ β : T ⇒ T', ishssMor β.

Coercion ptd_mor_from_hssMor (T T' : hss) (β : hssMor T T') : T ⇒ T' := pr1 β.

Definition isAlgMor_hssMor {T T' : hss} (β : hssMor T T') 
  : isAlgMor β := pr1 (pr2 β).
Definition isbracketMor_hssMor {T T' : hss} (β : hssMor T T') 
  : isbracketMor β := pr2 (pr2 β).

Section hssMor_equality.
(* Show that equality of hssMor is equality of underlying nat. transformations *)
Variables T T' : hss.
Variables β β' : hssMor T T'.
Definition hssMor_eq1 : β = β' ≃ (pr1 β = pr1 β').
Proof.
  apply total2_paths_isaprop_equiv.
  intro γ.
  apply isapropdirprod.
  - apply isaprop_isAlgMor.
  - apply isaprop_isbracketMor.
Defined.

(*
Definition hssMor_eq2 : pr1 β = pr1 β' ≃ #U β = #U β'.
Proof.
  apply eq_ptd_mor.
  apply hs.
Defined.
*)

Definition hssMor_eq : β = β' ≃ #U β = #U β'.
Proof.
  eapply weqcomp.
  - apply hssMor_eq1.
  - apply eq_ptd_mor.
    apply hs.
Defined.

End hssMor_equality.

Lemma isaset_hssMor (T T' : hss) : isaset (hssMor T T').
Proof.
  intros β β'.
  apply (isofhlevelweqb _ (hssMor_eq _ _ β β')).
  apply isaset_nat_trans.
  apply hs.
Qed.

Section hss_precategory.

Lemma ishssMor_id (T : hss) : ishssMor (identity T).
Proof.
  split.
  - unfold isAlgMor.
    rewrite functor_id.
    rewrite functor_id.
    rewrite id_left.
    set (H2 := id_right ([C,C,hs])).
    symmetry. apply H2.
  - unfold isbracketMor.
    intros Z f.
    rewrite functor_id.
    rewrite id_right.
    rewrite id_right.
    set (H2:=pre_composition_functor _ _ C _ hs (U Z)).
    set (H2' := functor_id H2). simpl in H2'.
    rewrite H2'.
    rewrite id_left.
    apply idpath.
Qed.

Definition hssMor_id (T : hss) : hssMor _ _ := tpair _ _ (ishssMor_id T).
  
Lemma ishssMor_comp {T T' T'' : hss} (β : hssMor T T') (γ : hssMor T' T'') 
  : ishssMor (β ;; γ).
Proof.
  split.
  - unfold isAlgMor.
    rewrite functor_comp.
    rewrite functor_comp.
    rewrite <- assoc.
    rewrite isAlgMor_hssMor.
    rewrite assoc.
    rewrite isAlgMor_hssMor.
    apply pathsinv0, assoc.
  - unfold isbracketMor.
    intros Z f.
    rewrite functor_comp.
    rewrite assoc.
    rewrite isbracketMor_hssMor.
    rewrite <- assoc.
    set (H2:=functor_comp (pre_composition_functor _ _ C _ hs (U Z)) ).
    simpl in H2.
    rewrite H2; clear H2.
    repeat rewrite <- assoc.
    apply maponpaths.
    rewrite assoc.
    apply isbracketMor_hssMor.
Qed.

Definition hssMor_comp {T T' T'' : hss} (β : hssMor T T') (γ : hssMor T' T'') 
  : hssMor T T'' := tpair _ _ (ishssMor_comp β γ).

Definition hss_obmor : precategory_ob_mor.
Proof.
  exists hss.
  exact hssMor.
Defined.

Definition hss_precategory_data : precategory_data.
Proof.
  exists hss_obmor.
  split.
  - exact hssMor_id.
  - exact @hssMor_comp.
Defined.

Lemma is_precategory_hss : is_precategory hss_precategory_data.
Proof.
  repeat split; intros.
  - apply (invmap (hssMor_eq _ _ _ _ )).
    apply id_left.
  - apply (invmap (hssMor_eq _ _ _ _ )).
    apply id_right.
  - apply (invmap (hssMor_eq _ _ _ _ )).
    apply assoc.
Qed.

Definition hss_precategory : precategory := tpair _ _ is_precategory_hss.

Definition Monad_Mor_laws_from_hssMor (T T' : hss)(β : hssMor T T') 
  : Monad_Mor_laws (T:=Monad_from_hss T) (T':=Monad_from_hss T') (#U β).
Proof.
  (*exists (#U β).*)
  repeat split; simpl.
  - intro c.
    unfold μ_2. simpl.
    set (H':=isbracketMor_hssMor β).
    unfold isbracketMor in H'.
    set (H2:= H' _ (identity _ )).
    set (H3:=(nat_trans_eq_weq _ _ hs _ _ _ _ H2)).
    rewrite id_left in H3.
    simpl in H3.
    rewrite H3; clear H3 H2 H'. 
    rewrite compute_fbracket.
    simpl.
    repeat rewrite assoc.
    apply idpath.
  - unfold μ_0.
    intro c.
    set (H':=ptd_mor_commutes _  (pr1 β)).
    apply H'.
Qed.
    
Definition Monad_Mor_from_hssMor {T T' : hss}(β : hssMor T T') 
  : Monad_Mor (Monad_from_hss T) (Monad_from_hss T')
  := tpair _ (#U β) (Monad_Mor_laws_from_hssMor T T' β).


Definition hss_to_monad_functor_data : functor_data hss_precategory (precategory_Monad C hs).
Proof.
  exists Monad_from_hss.
  exact @Monad_Mor_from_hssMor.
Defined.

Lemma is_functor_hss_to_monad : is_functor hss_to_monad_functor_data.
Proof.  
  split; simpl.
  - intro a.
    apply (invmap (Monad_Mor_equiv hs _ _ )).
    apply idpath.
  - intros a b c f g.
    apply (invmap (Monad_Mor_equiv hs _ _ )).
    apply idpath.
Qed.

Definition hss_to_monad_functor : functor _ _ := tpair _ _ is_functor_hss_to_monad.

Lemma isaset_Monad_Mor (T T' : Monad C) : isaset (Monad_Mor T T').
Proof.
  intros β β'.
  apply (isofhlevelweqb _ (Monad_Mor_equiv hs  _ _)).
  apply isaset_nat_trans.
  apply hs.
Qed.

Definition hssMor_Monad_Mor_eq {T T' : hss} (β β' : hssMor T T') 
  : β = β' ≃ Monad_Mor_from_hssMor β = Monad_Mor_from_hssMor β'.
Proof.
  eapply weqcomp.
  - apply hssMor_eq.
  - apply invweq.
    apply Monad_Mor_equiv.
    apply hs.
Defined.

Lemma faithful_hss_to_monad : faithful hss_to_monad_functor.
Proof.
  unfold faithful.
  intros T T'.
  apply isinclbetweensets.
  - apply isaset_hssMor.
  - apply isaset_Monad_Mor.
  - intros β β'.
    apply (invmap (hssMor_Monad_Mor_eq _ _ )).
Qed.
 
End hss_precategory.

End hss_morphisms.

End def_hss.




