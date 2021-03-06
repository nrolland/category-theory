Set Warnings "-notation-overridden".

Require Export Lib.Setoid.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Unset Transparent Obligations.

Ltac simplify :=
  repeat
    (match goal with
     | [ H : () |- _ ] => destruct H
     | [ |- () ] => exact tt

     | [ H : _ ∧ _ |- _ ] =>
       let H' := fresh "H" in destruct H as [H H']
     | [ |- _ ∧ _ ] => split

     | [ H : _ <--> _ |- _ ] =>
       let H' := fresh "H" in destruct H as [H H']
     | [ |- _ <--> _ ] => split

     | [ H : _ <-> _ |- _ ] =>
       let H' := fresh "H" in destruct H as [H H']
     | [ |- _ <-> _ ] => split

     | [ H : _ * _ |- _ ] =>
       let x := fresh "x" in
       let y := fresh "y" in
       destruct H as [x y]
     | [ |- _ * _ ] => split

     | [ H : { _ : _ & _ } |- _ ] =>
       let x := fresh "x" in
       let e := fresh "e" in
       destruct H as [x e]
     | [ |- { _ : _ & _ } ] =>
       unshelve (refine (existT _ _ _))
     end; intros).

Ltac cat :=
  try split;
  autorewrite with categories;
  auto with category_laws;
  try reflexivity.

Hint Constructors Equivalence.

Hint Unfold Reflexive.
Hint Unfold Symmetric.
Hint Unfold Transitive.

Hint Extern 1 (Reflexive ?X) =>
  unfold Reflexive; auto.
Hint Extern 1 (Symmetric ?X) =>
  unfold Symmetric; intros; auto.
Hint Extern 1 (Transitive ?X) =>
  unfold Transitive; intros; auto.
Hint Extern 1 (Equivalence ?X) =>
  apply Build_Equivalence.
Hint Extern 1 (Proper _ _) => unfold Proper; auto.
Hint Extern 8 (respectful _ _ _ _) =>
  unfold respectful; auto.

Hint Extern 4 (?A ≈ ?A) => reflexivity : category_laws.
Hint Extern 6 (?X ≈ ?Y) =>
  apply Equivalence_Symmetric : category_laws.
Hint Extern 7 (?X ≈ ?Z) =>
  match goal with
    [H : ?X ≈ ?Y, H' : ?Y ≈ ?Z |- ?X ≈ ?Z] => transitivity Y
  end : category_laws.

Ltac equivalence := constructor; repeat intro; simpl; cat; intuition.
Ltac proper := repeat intro; simpl; cat; intuition.

Global Obligation Tactic :=
  program_simpl; autounfold;
  try solve [
    repeat match goal with
    | [ |- Equivalence _ ] => equivalence
    | [ |- Equivalence _ ] => equivalence
    | [ |- Proper _ _ ] => proper
    | [ |- respectful _ _ _ _ ] => proper
    | [ |- Proper _ _ ] => proper
    | [ |- respectful _ _ _ _ ] => proper
    end;
    program_simpl; autounfold in *;
    simpl in *; intros; simplify;
    simpl in *; cat].
