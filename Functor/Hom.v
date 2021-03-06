Set Warnings "-notation-overridden".

Require Import Category.Lib.
Require Export Category.Theory.Natural.
Require Import Category.Structure.Closed.
Require Import Category.Construction.Opposite.
Require Import Category.Instance.Nat.
Require Import Category.Instance.Sets.
Require Import Category.Instance.Cat.
Require Import Category.Instance.Cat.Cartesian.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Unset Transparent Obligations.

(* Bifunctors can be curried:

  C × D ⟶ E --> C ⟶ [D, E] ~~~ (C, D) -> E --> C -> D -> E

  Where ~~~ should be read as "Morally equivalent to".

  Note: We do not need to define Bifunctors as a separate class, since they
  can be derived from functors mapping to a category of functors. So in the
  following two definitions, [P] is effectively our bifunctor.

  The trick to [bimap] is that both the [Functor] instances we need (for
  [fmap] and [fmap1]), and the [Natural] instance, can be found in the
  category of functors we're mapping to by applying [P]. *)

Definition fmap1 `{P : C ⟶ [D, E]} {A : C} `(f : X ~{D}~> Y) :
  P A X ~{E}~> P A Y := fmap f.

Definition bimap `{P : C × D ⟶ E} {X W : C} {Y Z : D}
           (f : X ~{C}~> W) (g : Y ~{D}~> Z) :
  P (X, Y) ~{E}~> P (W, Z).
Proof.
  apply fmap.
  exact (f, g).
Defined.

Definition curried_bimap `{P : C ⟶ [D, E]} {X W : C} {Y Z : D}
           (f : X ~{C}~> W) (g : Y ~{D}~> Z) :
  P X Y ~{E}~> P W Z := let N := @fmap _ _ P _ _ f in transform[N] _ ∘ fmap1 g.

Definition contramap `{F : C^op ⟶ D} `(f : X ~{C}~> Y) :
  F Y ~{D}~> F X := fmap (op f).

Definition dimap `{P : C^op ⟶ [D, E]} `(f : X ~{C}~> W) `(g : Y ~{D}~> Z) :
  P W Y ~{E}~> P X Z := curried_bimap (op f) g.

Program Instance HomFunctor `(C : Category) : C^op × C ⟶ Sets := {
  fobj := fun p => {| carrier   := @hom C (fst p) (snd p)
                    ; is_setoid := @homset (C) (fst p) (snd p) |};
  fmap := fun X Y (f : X ~{C^op × C}~> Y) =>
            {| morphism := fun g => snd f ∘ g ∘ fst f |}
}.

Program Definition Internal_HomFunctor `(C : Category)
        `{E : @Cartesian C} `{O : @Closed C _} : C^op ∏ C ⟶ C := {|
  fobj := fun p => @Exp C E O (fst p) (snd p);
  fmap := fun X Y f => _
|}.
Next Obligation.
  exact (curry (h0 ∘ eval ∘ (second h))).
Defined.
Next Obligation.
  unfold Internal_HomFunctor_obligation_1.
  proper; simpl.
  destruct x, y; simpl in *.
  rewrite a, b.
  reflexivity.
Qed.
Next Obligation. unfold second; simpl; cat. Qed.
Next Obligation.
  unfold Internal_HomFunctor_obligation_1; simpl.
  rewrite <- !comp_assoc.
  rewrite curry_comp.
  symmetry.
  rewrite curry_comp.
  rewrite <- comp_assoc.
  apply compose_respects.
    reflexivity.
  symmetry.
  rewrite curry_comp_l.
  rewrite <- !comp_assoc.
  rewrite <- first_second.
  rewrite !comp_assoc.
  rewrite ump_exponents.
  rewrite <- !comp_assoc.
  rewrite second_comp.
  reflexivity.
Qed.

Notation "a ≈> b":= (Internal_HomFunctor _ (a, b))
  (at level 89) : category_scope.
Notation "a ≈{ C }≈> b":= (Internal_HomFunctor C (a, b))
  (at level 89) : category_scope.

Program Definition Curried_HomFunctor `(C : Category) : C^op ⟶ [C, Sets] := {|
  fobj := fun X => {|
    fobj := fun Y => {| carrier := @hom C X Y
                      ; is_setoid := @homset C X Y |};
    fmap := fun Y Z (f : Y ~{C}~> Z) =>
              {| morphism := fun (g : X ~{C}~> Y) =>
                               (f ∘ g) : X ~{C}~> Z |}
  |};
  fmap := fun X Y (f : X ~{C^op}~> Y) => {|
    transform := fun _ => {| morphism := fun g => g ∘ op f |}
  |}
|}.
Next Obligation.
  simpl; intros.
  unfold op.
  apply comp_assoc.
Qed.

Coercion Curried_HomFunctor : Category >-> Functor.

Notation "'Hom' ( A , ─ )" := (@Curried_HomFunctor _ A) : category_scope.

Program Instance CoHomFunctor_Alt `(C : Category) : C × C^op ⟶ Sets :=
  HomFunctor C ○ @swap Cat _ _ _.

Program Instance CoHomFunctor `(C : Category) : C × C^op ⟶ Sets := {
  fobj := fun p => {| carrier   := @hom (C^op) (fst p) (snd p)
                    ; is_setoid := @homset (C^op) (fst p) (snd p) |};
  fmap := fun X Y (f : X ~{C × C^op}~> Y) =>
    {| morphism := fun g => snd f ∘ g ∘ fst f |}
}.

Program Instance Curried_CoHomFunctor `(C : Category) : C ⟶ [C^op, Sets] := {
  fobj := fun X => {|
    fobj := fun Y => {| carrier := @hom (C^op) X Y
                      ; is_setoid := @homset (C^op) X Y |};
    fmap := fun Y Z (f : Y ~{C^op}~> Z) =>
              {| morphism := fun (g : X ~{C^op}~> Y) =>
                               (f ∘ g) : X ~{C^op}~> Z |}
  |};
  fmap := fun X Y (f : X ~{C}~> Y) => {|
    transform := fun _ => {| morphism := fun g => g ∘ op f |}
  |}
}.
Next Obligation.
  simpl; intros.
  symmetry.
  apply comp_assoc.
Qed.

(*
Require Import Category.Instance.Cat.Closed.

Program Instance CoHomFunctor `(C : Category) : C × C^op ⟶ Sets.
Next Obligation.
  pose (Curried_CoHomFunctor C).
  pose (@uncurry Cat _ _ C (C^op) Sets).
  destruct h; simpl in morphism.
  (* This does not work due to universe problems. *)
  apply (morphism f).
*)

(* Coercion Curried_CoHomFunctor : Category >-> Functor. *)

Notation "'Hom' ( ─ , A )" := (@Curried_CoHomFunctor _ A) : category_scope.
