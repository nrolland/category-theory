Set Warnings "-notation-overridden".

Require Import Category.Lib.
Require Export Category.Theory.Isomorphism.
Require Export Category.Theory.Natural.
Require Export Category.Instance.Sets.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Unset Transparent Obligations.

Section Adjunction.

Context `{C : Category}.
Context `{D : Category}.
Context `{F : D ⟶ C}.
Context `{U : C ⟶ D}.

Class Adjunction := {
  adj_iso  {a b} : F a ~{C}~> b ≊ a ~{D}~> U b;

  adj_left'  {X Y} := to (@adj_iso X Y);
  adj_right' {X Y} := from (@adj_iso X Y);

  (* adj_left and adj_right must be natural in both arguments *)

  adj_left_nat_l' {a b c} (f : F b ~> c) (g : a ~> b) :
    adj_left' _ _ (f ∘ fmap[F] g) ≈ adj_left' _ _ f ∘ g;
  adj_left_nat_r' {a} {b} {c : C} (f : b ~> c) (g : F a ~> b) :
    adj_left' _ _ (f ∘ g) ≈ fmap[U] f ∘ adj_left' _ _ g;

  adj_right_nat_l' {a b c} (f : b ~> U c) (g : a ~> b) :
    adj_right' _ _ (f ∘ g) ≈ adj_right' _ _ f ∘ fmap[F] g;
  adj_right_nat_r' {a} {b} {c : C} (f : b ~> c) (g : a ~> U b) :
    adj_right' _ _ (fmap[U] f ∘ g) ≈ f ∘ adj_right' _ _ g
}.

Context `{@Adjunction}.

Definition adj_left  {X Y} := @adj_left' _ X Y.
Definition adj_right {X Y} := @adj_right' _ X Y.
Arguments adj_left' {_ _ _} /.
Arguments adj_right' {_ _ _} /.

Definition adj_left_nat_l {a b c} (f : F b ~> c) (g : a ~> b) :
  adj_left (f ∘ fmap[F] g) ≈ adj_left f ∘ g := @adj_left_nat_l' _ a b c f g.
Definition adj_left_nat_r {a} {b} {c : C} (f : b ~> c) (g : F a ~> b) :
  adj_left (f ∘ g) ≈ fmap[U] f ∘ adj_left g := @adj_left_nat_r' _ a b c f g.

Definition adj_right_nat_l {a b c} (f : b ~> U c) (g : a ~> b) :
  adj_right (f ∘ g) ≈ adj_right f ∘ fmap[F] g := @adj_right_nat_l' _ a b c f g.
Definition adj_right_nat_r {a} {b} {c : C} (f : b ~> c) (g : a ~> U b) :
  adj_right (fmap[U] f ∘ g) ≈ f ∘ adj_right g := @adj_right_nat_r' _ a b c f g.

Corollary adj_left_right {a b} (f : a ~> U b) : adj_left (adj_right f) ≈ f.
Proof.
  unfold adj_left, adj_right; simpl.
  pose proof (iso_to_from (@adj_iso H a b)) as HA.
  simpl in HA.
  apply HA.
Qed.

Definition adj_right_left {a b} (f : F a ~> b) : adj_right (adj_left f) ≈ f.
Proof.
  unfold adj_left, adj_right; simpl.
  pose proof (iso_from_to (@adj_iso H a b)) as HA.
  simpl in HA.
  apply HA.
Qed.

Global Program Instance parametric_morphism_adj_left a b :
  Proper (equiv ==> equiv) (@adj_left a b).
Next Obligation.
  proper.
  unfold adj_left; simpl in *.
  destruct adj_iso; simpl in *.
  destruct to; simpl in *.
  rewrite X; reflexivity.
Qed.

Global Program Instance parametric_morphism_adj_right a b :
  Proper (equiv ==> equiv) (@adj_right a b).
Next Obligation.
  proper.
  unfold adj_right; simpl in *.
  destruct adj_iso; simpl in *.
  destruct from; simpl in *.
  rewrite X; reflexivity.
Qed.

Definition unit   {a : D} : a ~> U (F a) := adj_left id.
Definition counit {a : C} : F (U a) ~> a := adj_right id.

Corollary adj_left_unit  {a b} (f : F a ~> b) :
  adj_left f ≈ fmap f ∘ unit.
Proof.
  rewrite <- (id_right f).
  rewrite adj_left_nat_r.
  rewrite fmap_comp; cat.
Qed.

Corollary adj_right_counit {a b} (f : a ~> U b) :
  adj_right f ≈ counit ∘ fmap f.
Proof.
  rewrite <- (id_left f).
  rewrite adj_right_nat_l.
  rewrite fmap_comp; cat.
Qed.

Corollary counit_fmap_unit  {a} : counit ∘ fmap[F] unit ≈ @id C (F a).
Proof.
  unfold unit, counit.
  rewrite <- adj_right_nat_l.
  rewrite <- fmap_id.
  rewrite adj_right_nat_r; cat.
  apply adj_right_left.
Qed.

Corollary fmap_counit_unit  {a} : fmap[U] counit ∘ unit ≈ @id D (U a).
Proof.
  unfold unit, counit.
  rewrite <- adj_left_nat_r.
  rewrite <- (@fmap_id _ _ F).
  rewrite adj_left_nat_l; cat.
  apply adj_left_right.
Qed.

Corollary adj_right_unit {a} : adj_right unit ≈ @id C (F a).
Proof. apply adj_right_left. Qed.

Corollary adj_left_counit {a} : adj_left counit ≈ @id D (U a).
Proof. apply adj_left_right. Qed.

End Adjunction.

Arguments Adjunction {C D} F U.

Notation "F ⊣ G" := (@Adjunction _ _ F G) (at level 70) : category_scope.

Section AdjunctionMor.

Context `{C : Category}.
Context `{D : Category}.
Context `{F : D ⟶ C}.
Context `{U : C ⟶ D}.

(* Another way to define an adjunction is by providing the unit and counit
   morphisms. *)

Class AdjunctionMor := {
  unit' {a : D} : a ~> U (F a);
  counit' {a : C} : F (U a) ~> a;

  unit_nat {X Y} (f : X ~> Y) :
    fmap[U] (fmap[F] f) ∘ @unit' X ≈ @unit' Y ∘ f;
  counit_nat {X Y} (f : X ~> Y) :
    f ∘ @counit' X ≈ @counit' Y ∘ fmap[F] (fmap[U] f);

  counit_fmap_unit' {X} : counit' ∘ fmap[F] unit' ≈ @id C (F X);
  fmap_counit_unit' {X} : fmap[U] counit' ∘ unit' ≈ @id D (U X)
}.

Program Definition adj_from_unit_conuit `{A : AdjunctionMor} : F ⊣ U := {|
  adj_iso := fun a b =>
    {| to   := {| morphism := fun f => fmap f ∘ @unit' A a |}
     ; from := {| morphism := fun f => @counit' A b ∘ fmap f |} |}
|}.
Next Obligation. proper; rewrite X; reflexivity. Qed.
Next Obligation. proper; rewrite X; reflexivity. Qed.
Next Obligation.
  rewrite fmap_comp.
  rewrite <- comp_assoc.
  rewrite unit_nat.
  rewrite comp_assoc.
  rewrite fmap_counit_unit'; cat.
Qed.
Next Obligation.
  rewrite fmap_comp.
  rewrite comp_assoc.
  rewrite <- counit_nat.
  rewrite <- comp_assoc.
  rewrite counit_fmap_unit'; cat.
Qed.
Next Obligation.
  rewrite fmap_comp.
  rewrite <- comp_assoc.
  rewrite unit_nat.
  rewrite comp_assoc.
  reflexivity.
Qed.
Next Obligation.
  rewrite fmap_comp.
  rewrite comp_assoc.
  reflexivity.
Qed.
Next Obligation.
  rewrite fmap_comp.
  rewrite comp_assoc.
  reflexivity.
Qed.
Next Obligation.
  rewrite fmap_comp.
  rewrite comp_assoc.
  rewrite <- counit_nat.
  rewrite <- comp_assoc.
  reflexivity.
Qed.

End AdjunctionMor.
