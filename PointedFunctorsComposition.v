Require Import UniMath.Foundations.Generalities.uu0.
Require Import UniMath.Foundations.hlevel1.hProp.
Require Import UniMath.Foundations.hlevel2.hSet.

Require Import UniMath.RezkCompletion.precategories.
Require Import UniMath.RezkCompletion.functors_transformations.
Require Import UnicodeNotations.
Require Import SubstSystems.PointedFunctors.
Require Import SubstSystems.HorizontalComposition.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Local Notation "G □ F" := (functor_composite _ _ _ F G) (at level 35).

Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

Section def_ptd.

  Variable C : precategory.
  Variable hs : has_homsets C.

Definition ptd_composite (Z Z' : ptd_obj C hs) : ptd_obj C hs.
Proof.
  exists (functor_composite _ _ _ (pr1 Z) (pr1 Z') : [C,C,hs] ).
  apply (hor_comp (ptd_pt _ _ Z) (ptd_pt _ _ Z')).
Defined.

End def_ptd.













