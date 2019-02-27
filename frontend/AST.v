

(* The goal here is to make a general case denotable AST *)
(* The approach we'll take is with an environment *)
(* so that terms will denote in an environment *)

Require Import ZArith.
Require Import Coq.Program.Equality.
Require Import Lists.List.

(* Our environment will take the form of an HMap, a heterogeneous map which *)
(* maps keys to types and terms *)

(* TODO: maybe move this out into a section, pull out nats *)
(* TODO: consider using trees instead of functions? *)

(* a tmap will map keys to types *)
Definition tmap := nat -> Type.

(* The empty type environment *)
Definition tempty : tmap := fun _ => False.

(* An HMap is a map of keys to terms *)
Definition HMap (t : tmap) :=
  forall (p : nat),  option (t p).

Definition tmap_add (p : nat) (t : Type) (tm : tmap) :=
  fun x => if Nat.eq_dec p x then t else tm x.

Definition hmap_empty : HMap tempty :=
  fun _ => None.

Definition tmap_lookup_eq (p : nat) (t : Type) (tm : tmap) (x : nat) (prf : p = x) (e : t) : option (tmap_add p t tm x).
  unfold tmap_add.
  destruct (Nat.eq_dec p x).
  exact (Some e).
  congruence.
Defined.

Definition tmap_lookup_neq (p : nat) (t : Type) (tm : tmap) (x : nat) (prf : p <> x) (hm : HMap tm) : option (tmap_add p t tm x).
  unfold tmap_add.
  destruct (Nat.eq_dec p x).
  congruence.
  exact (hm x).
Defined.

Definition hmap_add (p : nat) {t : Type} (e : t) {tm : tmap} (hm : HMap tm) : HMap (tmap_add p t tm) :=
  fun x =>
    match Nat.eq_dec p x with
    | left prf => tmap_lookup_eq p t tm x prf e
    | right prf => tmap_lookup_neq p t tm x prf hm
    end.

(* Try out an example *)
(* 1 -> false : bool, 0 -> 1 : nat *)
Definition hmap_example :=
  hmap_add (S O) false (hmap_add O (S O) hmap_empty).

Eval compute in (hmap_example O).
Eval compute in (hmap_example (S O)).

(* Now we have singly nested maps *)
(* We could try to be fancy and put maps in maps *)
(* But that's hard *)
(* Let's just define a map from nat -> nat -> Type *)
(* a tmap will map keys to types *)
Definition ttmap := nat -> nat -> Type.

(* The empty type environment *)
Definition ttempty : ttmap := fun _ => fun _ => False.

(* An HMap is a map of keys to terms *)
Definition HHMap (t : ttmap) :=
  forall (n m : nat),  option (t n m).

Definition ttmap_add (n m : nat) (t : Type) (tm : ttmap) :=
  fun x y => if Nat.eq_dec n x then
               if Nat.eq_dec m y then
                 t
               else tm x y
             else tm x y.

Definition hhmap_empty : HHMap ttempty :=
  fun _ => fun _ => None.


Definition ttmap_lookup_eq (n m x y : nat) (t : Type) (tm : ttmap) (prf : n = x) (prf': m = y) (e : t) : option (ttmap_add n m t tm x y).
  unfold ttmap_add.
  destruct (Nat.eq_dec n x).
  destruct (Nat.eq_dec m y).
  exact (Some e).
  congruence.
  congruence.
Defined.

Definition ttmap_lookup_neq_1 (n m x y : nat) (t : Type) (tm : ttmap) (prf : n = x) (prf': m <> y) (hm : HHMap tm) : option (ttmap_add n m t tm x y).
  unfold ttmap_add.
  destruct (Nat.eq_dec n x).
  destruct (Nat.eq_dec m y).
  congruence.
  exact (hm x y).
  congruence.
Defined.

Definition ttmap_lookup_neq_2 (n m x y : nat) (t : Type) (tm : ttmap) (prf : n <> x) (hm : HHMap tm) : option (ttmap_add n m t tm x y).
  unfold ttmap_add.
  destruct (Nat.eq_dec n x).
  congruence.
  exact (hm x y).
Defined.

Definition hhmap_add (n m : nat) {t : Type} (e : t) {tm : ttmap} (hm : HHMap tm) : HHMap (ttmap_add n m t tm) :=
  fun x y =>
    match Nat.eq_dec n x with
    | left prf =>
      match Nat.eq_dec m y with
      | left prf' =>
        ttmap_lookup_eq n m x y t tm prf prf' e
      | right prf' =>
        ttmap_lookup_neq_1 n m x y t tm prf prf' hm
      end
    | right prf => ttmap_lookup_neq_2 n m x y t tm prf hm
    end.

Definition ctors :=
  hhmap_add O O O (hhmap_add O (S O) S hhmap_empty).

Definition elims :=
  hmap_add O nat_rect hmap_empty.

(* We can get the nat constructors out *)
Eval compute in (ctors O O).
Eval compute in (ctors O (S O)).

(* Looks a little messy, but we can get the elim out *)
Eval compute in (elims O).

(* Now that we have our map, we can define our language *)
(* The goal is round trip from coq to expr and back *)
(* The things that need to work are: *)
(* closures, constructors, variables, application, eliminators, and perhaps values? *)
(* The goal here is to keep this definition entirely simply typed *)
Inductive expr :=
| Constr :
    (* index into all available inductive types *)
    nat ->
    (* index into constructors for given type *)
    nat ->
    expr
| App :
    (* function *)
    expr ->
    (* argument *)
    expr ->
    expr
| Elim :
    (* index into all available inductive types *)
    nat ->
    expr
| Close :
    (* use de bruijn indexing *)
    expr ->
    expr
| Var :
    (* index for how many levels up it's bound *)
    nat ->
    expr
.

(* Now the hard part: we have to take an environment and expr, and denote them *)
(* We need: hmap containing constructors and eliminators *)



(* Stick all the nasty proof stuff in here *)
(* Everything to make sure that some term can denote correctly in some env *)
(* Basically just a type derivation *)
(* Note that it's computationally relevant, so the final right arrow has to be Type, not Prop *)
Inductive wf_expr {ttm : ttmap} {tm : tmap} (ctors : HHMap ttm) (elims : HMap tm) : list Type -> expr -> Type -> Type :=
| WfConstr:
    forall n m (e : ttm n m) l,
      ctors n m = Some e ->
      wf_expr ctors elims l (Constr n m) (ttm n m)
| WfApp:
    forall e1 e2 (A B : Type) l,
      wf_expr ctors elims l e1 (A -> B) ->
      wf_expr ctors elims l e2 A ->
      wf_expr ctors elims l (App e1 e2) B
| WfElim:
    forall n (e : tm n) l,
      elims n = Some e ->
      wf_expr ctors elims l (Elim n) (tm n)
| WfClose:
    forall e (A B : Type) l,
      wf_expr ctors elims (A :: l) e B ->
      wf_expr ctors elims l (Close e) (A -> B)
| WfVar :
    forall n t l,
      nth_error l n = Some t ->
      wf_expr ctors elims l (Var n) t
.              

Definition nat_rect_t :=
  forall (P : nat -> Type),
    P O -> (forall n, P n -> P (S n)) ->
    forall n, P n.


Definition identity_3_coq :=
  nat_rect (fun _ => nat)
           (O)
           (fun _ n => S n)
           (S (S (S O))).

Definition nat_rec_simple :=
  fun (A : Type) =>
    nat_rect (fun _ => A).

Check nat_rec_simple.

Definition identity_3_ast :=
  (App
     (App
        (App
           (App
              (Elim O)
              (

        (Elim O)
       (Close (
  


Definition wf_example :
  wf_expr ctors elims nil (Elim O) nat_rect_t.
  econstructor; eauto.
  unfold elims.
  simpl.
  reflexivity.
Defined.
  

(*
Definition constr_case (n m : nat) {ttm : ttmap} {tm : tmap} (ctors : HHMap ttm) (elims : HMap tm) {t : Type } (wf : wf_expr ctors elims (Constr n m) t) : t.
  inversion wf.
  exact e.
Defined.
 *)

(* extract the argument type from an application *)
(* 
Lemma get_arg_type :
  forall {ttm : ttmap}
    {tm : tmap}
    (ctors : HHMap ttm) (elims : HMap tm)
    (e1 e2 : expr) (t : Type)
    (wf : wf_expr ctors elims (App e1 e2) t),
    (sigT2
       (fun A => wf_expr ctors elims e1 (A -> t))
       (fun A => wf_expr ctors elims e2 A)).
  intros.
  inversion wf.
  subst.
  econstructor;
    eassumption.
Defined.
*)


Definition denote {ttm : ttmap} {tm : tmap} (ctors : HHMap ttm) (elims : HMap tm) (e : expr) (t : Type) (wf : wf_expr ctors elims e t) : t.
  induction wf.
  (* Constructor *)
  + exact e.
  (* Application *)
  + apply IHwf1.
    apply IHwf2.
  (* Elimintation *)
  + exact e.
Defined.
    

Eval compute in (denote ctors elims (Elim O) nat_rect_t wf_example).
      