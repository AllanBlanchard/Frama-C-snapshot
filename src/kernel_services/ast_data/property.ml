(**************************************************************************)
(*                                                                        *)
(*  This file is part of Frama-C.                                         *)
(*                                                                        *)
(*  Copyright (C) 2007-2019                                               *)
(*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
(*         alternatives)                                                  *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
(*                                                                        *)
(**************************************************************************)

(* -------------------------------------------------------------------------- *)
(* --- Property Type                                                      --- *)
(* -------------------------------------------------------------------------- *)

open Cil_types
open Cil_datatype

type behavior_or_loop =
    Id_contract of Datatype.String.Set.t * funbehavior
  | Id_loop of code_annotation

type identified_complete =
  kernel_function * kinstr * Datatype.String.Set.t * string list
type identified_disjoint =  identified_complete
type identified_code_annotation =
    kernel_function * stmt * code_annotation

type identified_allocation =
    kernel_function
    * kinstr
    * behavior_or_loop
    * (identified_term list * identified_term list)

type identified_assigns =
    kernel_function
    * kinstr
    * behavior_or_loop
    * from list

type identified_from =
    kernel_function
    * kinstr
    * behavior_or_loop
    * from

type identified_decrease =
    kernel_function * kinstr * code_annotation option * variant

type identified_behavior =
  kernel_function * kinstr * Datatype.String.Set.t * funbehavior

type predicate_kind =
  | PKRequires of funbehavior
  | PKAssumes of funbehavior
  | PKEnsures of funbehavior * termination_kind
  | PKTerminates

let pretty_predicate_kind fmt = function
  | PKRequires _ -> Format.pp_print_string fmt "requires"
  | PKAssumes _ -> Format.pp_print_string fmt "assumes"
  | PKEnsures(_, tk)  ->
    Format.pp_print_string fmt
      (match tk with
      | Normal -> "ensures"
      | Exits -> "exits"
      | Breaks -> "breaks"
      | Continues -> "continues"
      | Returns -> "returns")
  | PKTerminates -> Format.pp_print_string fmt "terminates"

type identified_predicate =
    predicate_kind * kernel_function * kinstr * Cil_types.identified_predicate

type program_point = Before | After

type identified_reachable = kernel_function option * kinstr * program_point

type identified_type_invariant = string * typ * predicate * location

type identified_global_invariant = string * predicate * location

type other_loc =
  | OLContract of kernel_function
  | OLStmt of kernel_function * stmt
  | OLGlob of location

let other_loc_equal le1 le2 =
  match le1, le2 with
  | OLContract kf1, OLContract kf2 -> Kernel_function.equal kf1 kf2
  | OLStmt (_,s1), OLStmt (_,s2) -> Cil_datatype.Stmt.equal s1 s2
  | OLGlob loc1, OLGlob loc2 -> Cil_datatype.Location.equal loc1 loc2
  | (OLContract _ | OLStmt _ | OLGlob _ ), _ -> false

let other_loc_compare le1 le2 =
  match le1, le2 with
  | OLContract kf1, OLContract kf2 -> Kernel_function.compare kf1 kf2
  | OLContract _, _ -> 1 | _, OLContract _ -> -1
  | OLStmt (_,s1), OLStmt (_,s2) -> Cil_datatype.Stmt.compare s1 s2
  | OLStmt _, _ -> 1 | _, OLStmt _ -> -1
  | OLGlob loc1, OLGlob loc2 -> Cil_datatype.Location.compare loc1 loc2

type extended_loc =
  | ELContract of kernel_function
  | ELStmt of kernel_function * stmt
  | ELGlob

type identified_extended = extended_loc * Cil_types.acsl_extension

and identified_axiomatic = string * identified_property list

and identified_lemma =
    string * logic_label list * string list * predicate * location

and identified_axiom = identified_lemma

and identified_instance =
  kernel_function * stmt * Cil_types.identified_predicate option
  * identified_property

and identified_property =
  | IPPredicate of identified_predicate
  | IPExtended of identified_extended
  | IPAxiom of identified_axiom
  | IPAxiomatic of identified_axiomatic
  | IPLemma of identified_lemma
  | IPBehavior of identified_behavior
  | IPComplete of identified_complete
  | IPDisjoint of identified_disjoint
  | IPCodeAnnot of identified_code_annotation
  | IPAllocation of identified_allocation
  | IPAssigns of identified_assigns
  | IPFrom of identified_from
  | IPDecrease of identified_decrease
  | IPReachable of identified_reachable
  | IPPropertyInstance of identified_instance
  | IPTypeInvariant of identified_type_invariant
  | IPGlobalInvariant of identified_global_invariant
  | IPOther of string * other_loc

(* -------------------------------------------------------------------------- *)
(* --- Getters                                                            --- *)
(* -------------------------------------------------------------------------- *)

let ki_of_e_loc = function
  | ELContract _ | ELGlob -> Kglobal
  | ELStmt (_,s) -> Kstmt s

let ki_of_o_loc = function
  | OLContract _ | OLGlob _ -> Kglobal
  | OLStmt (_,s) -> Kstmt s

let e_loc_of_stmt kf = function
  | Kglobal -> ELContract kf
  | Kstmt s -> ELStmt (kf,s)

let o_loc_of_stmt kf = function
  | Kglobal -> OLContract kf
  | Kstmt s -> OLStmt (kf,s)

let get_kinstr = function
  | IPPredicate (_,_,ki,_)
  | IPBehavior(_, ki,_,_)
  | IPComplete (_,ki,_,_)
  | IPDisjoint(_,ki,_,_)
  | IPAllocation (_,ki,_,_)
  | IPAssigns (_,ki,_,_)
  | IPFrom(_,ki,_,_)
  | IPReachable (_, ki, _)
  | IPDecrease (_,ki,_,_) -> ki
  | IPAxiom _
  | IPAxiomatic _
  | IPLemma _  -> Kglobal
  | IPOther(_,loc_e) -> ki_of_o_loc loc_e
  | IPExtended (loc_e, _) -> ki_of_e_loc loc_e
  | IPCodeAnnot (_,s,_)
  | IPPropertyInstance (_, s, _, _) -> Kstmt s
  | IPTypeInvariant _ | IPGlobalInvariant _ -> Kglobal

let kf_of_loc_e = function
  | ELContract kf | ELStmt (kf,_) -> Some kf
  | ELGlob  -> None

let kf_of_loc_o = function
  | OLContract kf | OLStmt (kf,_) -> Some kf
  | OLGlob _ -> None

let get_kf = function
  | IPPredicate (_,kf,_,_)
  | IPBehavior(kf,_,_,_)
  | IPCodeAnnot (kf,_,_)
  | IPComplete (kf,_,_,_)
  | IPDisjoint(kf,_,_,_)
  | IPAllocation(kf,_,_,_)
  | IPAssigns(kf,_,_,_)
  | IPFrom(kf,_,_,_)
  | IPDecrease (kf,_,_,_)
  | IPPropertyInstance (kf, _, _, _) -> Some kf
  | IPAxiom _
  | IPAxiomatic _
  | IPLemma _ -> None
  | IPReachable (kfopt, _, _) -> kfopt
  | IPExtended (loc_e,_) -> kf_of_loc_e loc_e
  | IPOther(_,loc_e) -> kf_of_loc_o loc_e
  | IPTypeInvariant _ | IPGlobalInvariant _ -> None

let loc_of_kf_ki kf = function
  | Kstmt s -> Cil_datatype.Stmt.loc s
  | Kglobal -> Kernel_function.get_location kf

let loc_of_loc_o = function
  | OLContract kf -> Kernel_function.get_location kf
  | OLStmt(_,s) -> Cil_datatype.Stmt.loc s
  | OLGlob loc -> loc

let rec location = function
  | IPPredicate (_,_,_,ip) -> ip.ip_content.pred_loc
  | IPBehavior(kf,ki, _,_)
  | IPComplete (kf,ki,_,_)
  | IPDisjoint(kf,ki,_,_)
  | IPReachable(Some kf, ki, _) -> loc_of_kf_ki kf ki
  | IPReachable(None, Kstmt s, _)
  | IPPropertyInstance (_, s, _, _) -> Cil_datatype.Stmt.loc s
  | IPCodeAnnot (_,s,ca) -> (
    match Cil_datatype.Code_annotation.loc ca with
    | None -> Cil_datatype.Stmt.loc s
    | Some loc -> loc)
  | IPReachable(None, Kglobal, _) -> Cil_datatype.Location.unknown
  | IPAssigns(kf,ki,_,a) ->
    (match a with
      | [] -> loc_of_kf_ki kf ki
      | (t,_) :: _ -> t.it_content.term_loc)
  | IPAllocation(kf,ki,_,fa) ->
    (match fa with
      | [],[] -> loc_of_kf_ki kf ki
      | (t :: _),_
      | _,(t :: _) -> t.it_content.term_loc)
  | IPFrom(_,_,_,(t,_)) -> t.it_content.term_loc
  | IPDecrease (_,_,_,(t,_)) -> t.term_loc
  | IPAxiom (_,_,_,_,loc) -> loc
  | IPAxiomatic (_,l) ->
    (match l with
      | [] -> Cil_datatype.Location.unknown
      | p :: _ -> location p)
  | IPLemma (_,_,_,_,loc) -> loc
  | IPExtended(_,(_,_,loc,_,_)) -> loc
  | IPOther(_,loc_e) -> loc_of_loc_o loc_e
  | IPTypeInvariant(_,_,_,loc) | IPGlobalInvariant(_,_,loc) -> loc

let source ip =
  let loc = location ip in
  if Cil_datatype.Location.equal loc Cil_datatype.Location.unknown
  then None
  else Some (fst loc)

(* Pretty information about the localization of a IPPropertyInstance *)
let pretty_instance_location fmt (kf, stmt) =
  if Kernel_function.(equal kf (find_englobing_kf stmt))
  then Format.fprintf fmt "at stmt %d" stmt.sid
  else
    Format.fprintf fmt "at stmt %d and function %a"
      stmt.sid Kernel_function.pretty kf

let get_pk_behavior = function
  | PKRequires b | PKAssumes b | PKEnsures (b,_) -> Some b
  | PKTerminates -> None

let get_behavior = function
  | IPPredicate (pk,_,_,_) -> get_pk_behavior pk
  | IPBehavior(_, _, _, b) -> Some b
  | IPAllocation(_,_,Id_contract (_,b),_)
  | IPAssigns(_,_,Id_contract (_,b),_)
  | IPFrom(_,_,Id_contract (_,b),_) -> Some b
  | IPAllocation(_,_,Id_loop _,_)
  | IPAssigns(_,_,Id_loop _,_)
  | IPFrom(_,_,Id_loop _,_)
  | IPAxiom _
  | IPAxiomatic _
  | IPExtended _
  | IPLemma _
  | IPCodeAnnot (_,_,_)
  | IPComplete (_,_,_,_)
  | IPDisjoint(_,_,_,_)
  | IPDecrease _
  | IPReachable _
  | IPPropertyInstance _
  | IPTypeInvariant _
  | IPGlobalInvariant _
  | IPOther _ -> None

(* -------------------------------------------------------------------------- *)
(* --- Property Status                                                    --- *)
(* -------------------------------------------------------------------------- *)

let has_status_ext ((_,_,_,status,_) : Cil_types.acsl_extension) = status

let has_status_ca = function
  | AAssert _ | AStmtSpec _ | AInvariant _ | AVariant _ | AAllocation _
  | AAssigns _ -> true
  | AExtended(_,_,e) -> has_status_ext e
  | APragma _ -> false

let has_status_pkind = function
  | PKAssumes _ -> false
  | PKEnsures _ | PKRequires _ | PKTerminates
    -> true

let rec has_status = function
  | IPPredicate(pkind, _, _, _) -> has_status_pkind pkind
  | IPExtended(_,e) -> has_status_ext e
  | IPCodeAnnot(_,_, { annot_content = ca }) -> has_status_ca ca
  | IPPropertyInstance(_,_,_,ip) -> has_status ip
  | IPOther _ | IPReachable _
  | IPAxiom _ | IPAxiomatic _ | IPBehavior _
  | IPDisjoint _ | IPComplete _
  | IPAssigns _ | IPFrom _
  | IPAllocation _ | IPDecrease _ | IPLemma _
  | IPTypeInvariant _ | IPGlobalInvariant _
    -> true

(* -------------------------------------------------------------------------- *)
(* --- Datatype                                                           --- *)
(* -------------------------------------------------------------------------- *)

include Datatype.Make_with_collections
    (struct

      include Datatype.Serializable_undefined

      type t = identified_property
      let name = "Property.t"
      let reprs = [ IPAxiom ("",[],[],Logic_const.ptrue,Location.unknown) ]
      let mem_project = Datatype.never_any_project

      let pp_active fmt active =
        let sep = ref false in
        let print_one a =
          Format.fprintf fmt "%s%s" (if !sep then ", " else "") a;
          sep:=true
        in
        Datatype.String.Set.iter print_one active

      let rec pretty fmt = function
	| IPPredicate (kind,_,_,p) ->
          Format.fprintf fmt "%a@ %a"
            pretty_predicate_kind kind Cil_printer.pp_identified_predicate p
        | IPExtended (_,e) -> Cil_printer.pp_extended fmt e
	| IPAxiom (s,_,_,_,_) -> Format.fprintf fmt "axiom@ %s" s
	| IPAxiomatic(s, _) -> Format.fprintf fmt "axiomatic@ %s" s
	| IPLemma (s,_,_,_,_) -> Format.fprintf fmt "lemma@ %s" s
	| IPTypeInvariant(s,ty,_,_) ->
	  Format.fprintf fmt "invariant@ %s for type %a" s Cil_printer.pp_typ ty
	| IPGlobalInvariant(s,_,_) ->
	  Format.fprintf fmt "global invariant@ %s" s
	| IPBehavior(_kf, ki, active, b) ->
            if Cil.is_default_behavior b then
              Format.pp_print_string fmt "default behavior"
            else
	      Format.fprintf fmt "behavior %s" b.b_name;
	    (match ki with
	    | Kstmt s -> Format.fprintf fmt " for statement %d" s.sid
	    | Kglobal -> ());
            pp_active fmt active
	| IPCodeAnnot(_, _, a) -> Cil_printer.pp_code_annotation fmt a
	| IPComplete(_, _, active, l) ->
	  Format.fprintf fmt "complete@ %a"
	    (Pretty_utils.pp_list ~sep:","
	       (fun fmt s ->  Format.fprintf fmt "@ %s" s))
	    l;
          pp_active fmt active
	| IPDisjoint(_, _, active, l) ->
	  Format.fprintf fmt "disjoint@ %a"
	    (Pretty_utils.pp_list ~sep:","
	       (fun fmt s ->  Format.fprintf fmt " %s" s))
	    l;
          pp_active fmt active
	| IPAllocation(_, _, _, (f,a)) ->
	    Cil_printer.pp_allocation fmt (FreeAlloc(f,a))
	| IPAssigns(_, _, _, l) -> Cil_printer.pp_assigns fmt (Writes l)
	| IPFrom (_,_,_, f) -> Cil_printer.pp_from fmt f
	| IPDecrease(_, _, None,v) -> Cil_printer.pp_decreases fmt v
	| IPDecrease(_, _, _,v) -> Cil_printer.pp_variant fmt v
	| IPReachable(None, Kstmt _, _) ->  assert false
	| IPReachable(None, Kglobal, _) ->
	  Format.fprintf fmt "reachability of entry point"
	| IPReachable(Some kf, Kglobal, _) ->
	  Format.fprintf fmt "reachability of function %a" Kf.pretty kf
	| IPReachable(Some kf, Kstmt stmt, ba) ->
	  Format.fprintf fmt "reachability %s stmt %a in %a"
	    (match ba with Before -> "of" | After -> "post")
	    Cil_datatype.Location.pretty_line (Cil_datatype.Stmt.loc stmt)
	    Kf.pretty kf
	| IPPropertyInstance (kf, ki, _, ip) ->
	  Format.fprintf fmt "status of '%a'%t %a"
	    pretty ip
	    (fun fmt -> match get_kf ip with
	    | Some kf -> Format.fprintf fmt " of %a" Kernel_function.pretty kf
	    | None -> ())
	    pretty_instance_location (kf, ki)
	| IPOther(s,_) -> Format.pp_print_string fmt s

      let rec hash =
	let hash_bhv_loop = function
          | Id_contract (a,b) -> (0, Hashtbl.hash (a,b.b_name))
          | Id_loop ca -> (1, ca.annot_id)
	in
	function
	| IPPredicate (_,_,_,x) -> Hashtbl.hash (1, x.ip_id)
	| IPAxiom (x,_,_,_,_) -> Hashtbl.hash (2, (x:string))
	| IPAxiomatic (x,_) -> Hashtbl.hash (3, (x:string))
	| IPLemma (x,_,_,_,_) -> Hashtbl.hash (4, (x:string))
	| IPCodeAnnot(_,_, ca) -> Hashtbl.hash (5, ca.annot_id)
	| IPComplete(f, ki, x, y) ->
          (* complete list is more likely to discriminate than active list. *)
	  Hashtbl.hash
            (6, Kf.hash f, Kinstr.hash ki,
             (y:string list), (x:Datatype.String.Set.t))
	| IPDisjoint(f, ki, x, y) ->
	  Hashtbl.hash
            (7, Kf.hash f, Kinstr.hash ki,
             (y: string list), (x:Datatype.String.Set.t))
	| IPAssigns(f, ki, b, _l) ->
	  Hashtbl.hash (8, Kf.hash f, Kinstr.hash ki, hash_bhv_loop b)
	| IPFrom(kf,ki,b,(t,_)) ->
          Hashtbl.hash
            (9, Kf.hash kf, Kinstr.hash ki,
             hash_bhv_loop b, Identified_term.hash t)
	| IPDecrease(kf, ki, _ca, _v) ->
        (* At most one loop variant per statement anyway, no
           need to discriminate against the code annotation itself *)
	  Hashtbl.hash (10, Kf.hash kf, Kinstr.hash ki)
	| IPBehavior(kf, s, a, b) ->
	  Hashtbl.hash
            (11, Kf.hash kf, Kinstr.hash s,
             (b.b_name:string), (a:Datatype.String.Set.t))
	| IPReachable(kf, ki, ba) ->
	  Hashtbl.hash(12, Extlib.may_map Kf.hash ~dft:0 kf,
                       Kinstr.hash ki, Hashtbl.hash ba)
	| IPAllocation(f, ki, b, _fa) ->
	  Hashtbl.hash (13, Kf.hash f, Kinstr.hash ki, hash_bhv_loop b)
	| IPPropertyInstance (kf_caller, stmt, _, ip) ->
	  Hashtbl.hash (14, Kf.hash kf_caller,
	                Stmt.hash stmt, hash ip)
	| IPOther(s,_) -> Hashtbl.hash (15, (s:string))
	| IPTypeInvariant(s,_,_,_) -> Hashtbl.hash (16, (s:string))
	| IPGlobalInvariant(s,_,_) -> Hashtbl.hash (17, (s:string))
        | IPExtended (_,(i,_,_,_,_)) -> Hashtbl.hash (18, i)

      let rec equal p1 p2 =
	let eq_bhv (f1,ki1,b1) (f2,ki2,b2) =
	  Kf.equal f1 f2 && Kinstr.equal ki1 ki2
	  &&
            (match b1, b2 with
            | Id_loop ca1, Id_loop ca2 ->
              ca1.annot_id = ca2.annot_id
            | Id_contract (a1,b1), Id_contract (a2,b2) ->
              Datatype.String.Set.equal a1 a2 &&
              Datatype.String.equal b1.b_name b2.b_name
            | Id_loop _, Id_contract _
            | Id_contract _, Id_loop _ -> false)
	in
	match p1, p2 with
	| IPPredicate (_,_,_,s1), IPPredicate (_,_,_,s2) -> s1.ip_id = s2.ip_id
	| IPExtended (_,(i1,_,_,_,_)), IPExtended (_,(i2,_,_,_,_)) -> Datatype.Int.equal i1 i2
	| IPAxiom (s1,_,_,_,_), IPAxiom (s2,_,_,_,_)
	| IPAxiomatic(s1, _), IPAxiomatic(s2, _)
	| IPTypeInvariant(s1,_,_,_), IPTypeInvariant(s2,_,_,_)
	| IPGlobalInvariant(s1,_,_), IPGlobalInvariant(s2,_,_)
	| IPLemma (s1,_,_,_,_), IPLemma (s2,_,_,_,_) ->
	  Datatype.String.equal s1 s2
	| IPCodeAnnot(_,_,ca1), IPCodeAnnot(_,_,ca2) ->
          ca1.annot_id = ca2.annot_id
	| IPComplete(f1, ki1, a1, x1), IPComplete(f2, ki2, a2, x2)
	| IPDisjoint(f1, ki1, a1, x1), IPDisjoint(f2, ki2, a2, x2) ->
	  Kf.equal f1 f2 && Kinstr.equal ki1 ki2 && a1 = a2 && x1 = x2
	| IPAllocation (f1, ki1, b1, _), IPAllocation (f2, ki2, b2, _) ->
          eq_bhv (f1,ki1,b1) (f2,ki2,b2)
	| IPAssigns (f1, ki1, b1, _), IPAssigns (f2, ki2, b2, _) ->
          eq_bhv (f1,ki1,b1) (f2,ki2,b2)
	| IPFrom (f1,ki1,b1,(t1,_)), IPFrom (f2, ki2,b2,(t2,_)) ->
          eq_bhv (f1,ki1,b1) (f2,ki2,b2) && t1.it_id = t2.it_id
	| IPDecrease(f1, ki1, _, _), IPDecrease(f2, ki2, _, _) ->
	  Kf.equal f1 f2 && Kinstr.equal ki1 ki2
	| IPReachable(kf1, ki1, ba1), IPReachable(kf2, ki2, ba2) ->
	  Extlib.opt_equal Kf.equal kf1 kf2 && Kinstr.equal ki1 ki2 && ba1 = ba2
	| IPBehavior(f1, k1, a1, b1), IPBehavior(f2, k2, a2, b2) ->
	  Kf.equal f1 f2
	  && Kinstr.equal k1 k2
          && Datatype.String.Set.equal a1 a2
	  && Datatype.String.equal b1.b_name b2.b_name
	| IPOther(s1,loc_e1), IPOther(s2,loc_e2) ->
	    Datatype.String.equal s1 s2
	    && other_loc_equal loc_e1 loc_e2
	| IPPropertyInstance (kf1, s1, _, ip1),
	  IPPropertyInstance (kf2, s2, _, ip2) ->
	  Kernel_function.equal kf1 kf2 &&
	  Stmt.equal s1 s2 && equal ip1 ip2
	| (IPPredicate _ | IPAxiom _ | IPExtended _ | IPAxiomatic _ | IPLemma _
	  | IPCodeAnnot _ | IPComplete _ | IPDisjoint _ | IPAssigns _
	  | IPFrom _ | IPDecrease _ | IPBehavior _ | IPReachable _
	  | IPAllocation _ | IPOther _ | IPPropertyInstance _
	  | IPTypeInvariant _ | IPGlobalInvariant _), _ -> false

      let rec compare x y =
	let cmp_bhv (f1,ki1,b1) (f2,ki2,b2) =
	  let n = Kf.compare f1 f2 in
	  if n = 0 then
	    let n = Kinstr.compare ki1 ki2 in
	    if n = 0 then
	      match b1, b2 with
	      | Id_contract (a1,b1), Id_contract (a2,b2) ->
	         let n = Datatype.String.compare b1.b_name b2.b_name in
                 if n = 0 then Datatype.String.Set.compare a1 a2 else n
              | Id_loop ca1, Id_loop ca2 ->
		Datatype.Int.compare ca1.annot_id ca2.annot_id
              | Id_contract _, Id_loop _ -> -1
              | Id_loop _, Id_contract _ -> 1
            else n
          else n
	in
	match x, y with
	| IPPredicate (_,_,_,s1), IPPredicate (_,_,_,s2) ->
          Datatype.Int.compare s1.ip_id s2.ip_id
        | IPExtended (_,(i1,_,_,_,_)), IPExtended (_,(i2,_,_,_,_)) ->
          Datatype.Int.compare i1 i2
	| IPCodeAnnot(_,_,ca1), IPCodeAnnot(_,_,ca2) ->
          Datatype.Int.compare ca1.annot_id ca2.annot_id
	| IPBehavior(f1, k1, a1, b1), IPBehavior(f2, k2, a2, b2) ->
	  cmp_bhv (f1, k1, Id_contract (a1,b1)) (f2, k2, Id_contract (a2,b2))
	| IPComplete(f1, ki1, a1, x1), IPComplete(f2, ki2, a2, x2)
	| IPDisjoint(f1, ki1, a1, x1), IPDisjoint(f2, ki2, a2, x2) ->
          let n = Kf.compare f1 f2 in
          if n = 0 then
            let n = Kinstr.compare ki1 ki2 in
            if n = 0 then
              let n = Extlib.compare_basic x1 x2 in
              if n = 0 then
                Datatype.String.Set.compare a1 a2
              else n
            else n
          else n
	| IPAssigns (f1, ki1, b1, _), IPAssigns (f2, ki2, b2, _) ->
          cmp_bhv (f1,ki1,b1) (f2,ki2,b2)
	| IPFrom (f1,ki1,b1,(t1,_)), IPFrom(f2,ki2,b2,(t2,_)) ->
          let n = cmp_bhv (f1,ki1,b1) (f2,ki2,b2) in
          if n = 0 then Identified_term.compare t1 t2 else n
	| IPDecrease(f1, ki1,_,_), IPDecrease(f2, ki2,_,_) ->
	  let n = Kf.compare f1 f2 in
	  if n = 0 then Kinstr.compare ki1 ki2 else n
	| IPReachable(kf1, ki1, ba1), IPReachable(kf2, ki2, ba2) ->
	  let n = Extlib.opt_compare Kf.compare kf1 kf2 in
	  if n = 0 then
	    let n = Kinstr.compare ki1 ki2 in
	    if n = 0 then Transitioning.Stdlib.compare ba1 ba2 else n
	  else
	    n
	| IPAxiom (s1,_,_,_,_), IPAxiom (s2,_,_,_,_)
	| IPAxiomatic(s1, _), IPAxiomatic(s2, _)
	| IPTypeInvariant(s1,_,_,_), IPTypeInvariant(s2,_,_,_)
	| IPLemma (s1,_,_,_,_), IPLemma (s2,_,_,_,_) ->
	    Datatype.String.compare s1 s2
	| IPOther(s1,le1), IPOther(s2,le2) ->
	    let s = Datatype.String.compare s1 s2 in
	    if s <> 0 then s else other_loc_compare le1 le2
	| IPAllocation (f1, ki1, b1, _), IPAllocation (f2, ki2, b2, _) ->
            cmp_bhv (f1,ki1,b1) (f2,ki2,b2)
	| IPPropertyInstance (kf1, s1, _, ip1),
	  IPPropertyInstance (kf2, s2, _, ip2) ->
	  let c = Kernel_function.compare kf1 kf2 in
	  if c <> 0 then c else
	    let c = Stmt.compare s1 s2 in
	    if c <> 0 then c else compare ip1 ip2
	| (IPPredicate _ | IPExtended _ | IPCodeAnnot _ | IPBehavior _ | IPComplete _ |
           IPDisjoint _ | IPAssigns _ | IPFrom _ | IPDecrease _ |
           IPReachable _ | IPAxiom _ | IPAxiomatic _ | IPLemma _ |
           IPOther _ | IPAllocation _ | IPPropertyInstance _ |
	   IPTypeInvariant _ | IPGlobalInvariant _) as x, y ->
          let nb = function
            | IPPredicate _ -> 1
            | IPAssigns _ -> 2
            | IPDecrease _ -> 3
            | IPAxiom _ -> 4
            | IPAxiomatic _ -> 5
	    | IPLemma _ -> 6
            | IPCodeAnnot _ -> 7
            | IPComplete _ -> 8
            | IPDisjoint _ -> 9
            | IPFrom _ -> 10
	    | IPBehavior _ -> 11
	    | IPReachable _ -> 12
	    | IPAllocation _ -> 13
	    | IPOther _ -> 14
	    | IPPropertyInstance _ -> 15
	    | IPTypeInvariant _ -> 16
	    | IPGlobalInvariant _ -> 17
            | IPExtended _ -> 18
	  in
	  Datatype.Int.compare (nb x) (nb y)

     end)

let rec short_pretty fmt p = match p with
  | IPPredicate (_,_,_,{ ip_content = {pred_name = name :: _ }}) ->
    Format.pp_print_string fmt name
  | IPPredicate _ -> pretty fmt p
  | IPExtended (_,(_,name,_,_,_)) -> Format.pp_print_string fmt name
  | IPAxiom (name,_,_,_,_) | IPLemma(name,_,_,_,_)
  | IPTypeInvariant(name,_,_,_) -> Format.pp_print_string fmt name
  | IPGlobalInvariant(name,_,_) -> Format.pp_print_string fmt name
  | IPAxiomatic (name,_) -> Format.pp_print_string fmt name
  | IPBehavior(kf,_,_,{b_name = name }) ->
    Format.fprintf fmt "behavior %s in function %a"
      name Kernel_function.pretty kf
  | IPComplete (kf,_,_,_) ->
    Format.fprintf fmt "complete clause in function %a"
      Kernel_function.pretty kf
  | IPDisjoint (kf,_,_,_) ->
    Format.fprintf fmt "disjoint clause in function %a"
      Kernel_function.pretty kf
  | IPCodeAnnot (_,_,{ annot_content = AAssert (_, _, { pred_name = name :: _ })}) ->
    Format.pp_print_string fmt name
  | IPCodeAnnot(_,_,{annot_content =
                       AInvariant (_,_, { pred_name = name :: _ })})->
    Format.pp_print_string fmt name
  | IPCodeAnnot _ -> pretty fmt p
  | IPAllocation (kf,_,_,_) ->
    Format.fprintf fmt "allocates/frees clause in function %a"
      Kernel_function.pretty kf
  | IPAssigns (kf,_,_,_) ->
    Format.fprintf fmt "assigns clause in function %a"
      Kernel_function.pretty kf
  | IPFrom (kf,_,_,(t,_)) ->
    Format.fprintf fmt "from clause of term %a in function %a"
      Cil_printer.pp_identified_term t Kernel_function.pretty kf
  | IPDecrease(kf,_,_,_) ->
    Format.fprintf fmt "decrease clause in function %a"
      Kernel_function.pretty kf
  | IPPropertyInstance (kf, stmt, _, ip) ->
    Format.fprintf fmt "specialization of %a %a" short_pretty ip
      pretty_instance_location (kf, stmt)
  | IPReachable _ | IPOther _ -> pretty fmt p

let pp_behavior_or_loop_debug fmt = function
  | Id_contract(s,fb) ->
    Format.fprintf fmt "Id_contract(%a,%a)"
      Datatype.String.Set.pretty s
      Cil_types_debug.pp_funbehavior fb
  | Id_loop ca ->
    Format.fprintf fmt "Id_loop(%a)"
      Cil_types_debug.pp_code_annotation ca

let pp_predicate_type_debug fmt = function
  | PKRequires fb ->
    Format.fprintf fmt "PKRequires(%a)"
      Cil_types_debug.pp_funbehavior fb
  | PKAssumes fb ->
    Format.fprintf fmt "PKAssumes(%a)"
      Cil_types_debug.pp_funbehavior fb
  | PKEnsures (fb, tk) ->
    Format.fprintf fmt "PKEnsures(%a,%a)"
      Cil_types_debug.pp_funbehavior fb
      Cil_types_debug.pp_termination_kind tk
  | PKTerminates ->
    Format.fprintf fmt "PKTerminates"

let pp_program_point fmt = function
  | Before -> Format.fprintf fmt "Before"
  | After -> Format.fprintf fmt "After"

let pp_extended_loc fmt = function
  | ELContract kf ->
    Format.fprintf fmt "ELContract(%a)"
      Cil_types_debug.pp_kernel_function kf
  | ELStmt(kf,s) ->
    Format.fprintf fmt "ELStmt(%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_stmt s
  | ELGlob -> Format.pp_print_string fmt "ELGlob"

let pp_other_loc fmt = function
  | OLContract kf ->
    Format.fprintf fmt "ELContract(%a)"
      Cil_types_debug.pp_kernel_function kf
  | OLStmt (kf,s) ->
    Format.fprintf fmt "ELStmt(%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_stmt s
  | OLGlob loc ->
    Format.fprintf fmt "OLGlob(%a)" Cil_types_debug.pp_location loc


let rec pretty_debug fmt = function
  | IPPredicate (pk,kf,ki,ip) ->
    Format.fprintf fmt "IPPredicate(%a,%a,%a,%a)"
      pp_predicate_type_debug pk
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      Cil_types_debug.pp_identified_predicate ip
  | IPExtended (el,ae) ->
    Format.fprintf fmt "IPExtended(%a,%a)"
      pp_extended_loc el
      Cil_types_debug.pp_acsl_extension ae
  | IPCodeAnnot (kf, s, ca) ->
    Format.fprintf fmt "IPCodeAnnot(%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_stmt s
      Cil_types_debug.pp_code_annotation ca
  | IPComplete (kf, ki, a, lb) ->
    Format.fprintf fmt "IPComplete(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      Datatype.String.Set.pretty a
      (Cil_types_debug.pp_list Cil_types_debug.pp_string) lb
  | IPDisjoint (kf, ki, a, lb) ->
    Format.fprintf fmt "IPDisjoint(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      Datatype.String.Set.pretty a
      (Cil_types_debug.pp_list Cil_types_debug.pp_string) lb
  | IPDecrease (kf, ki, oca, variant) ->
    Format.fprintf fmt "IPDecrease(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      (Cil_types_debug.pp_option Cil_types_debug.pp_code_annotation) oca
      Cil_types_debug.pp_variant variant
  | IPAxiom (str,log_lbl_list,str_list,pred,loc) ->
    Format.fprintf fmt "IPAxiom(%a,%a,%a,%a,%a)"
      Cil_types_debug.pp_string str
      (Cil_types_debug.pp_list Cil_types_debug.pp_logic_label) log_lbl_list
      (Cil_types_debug.pp_list Cil_types_debug.pp_string) str_list
      Cil_types_debug.pp_predicate pred
      Cil_types_debug.pp_location loc
  | IPAxiomatic(str, ip_list) ->
    Format.fprintf fmt "IPAxiomatic(%a,%a)"
      Cil_types_debug.pp_string str
      (Cil_types_debug.pp_list pretty_debug) ip_list
  | IPLemma (str,log_lbl_list,str_list,pred,loc) ->
    Format.fprintf fmt "IPLemma(%a,%a,%a,%a,%a)"
      Cil_types_debug.pp_string str
      (Cil_types_debug.pp_list Cil_types_debug.pp_logic_label) log_lbl_list
      (Cil_types_debug.pp_list Cil_types_debug.pp_string) str_list
      Cil_types_debug.pp_predicate pred
      Cil_types_debug.pp_location loc
  | IPTypeInvariant (str,typ,pred,loc) ->
    Format.fprintf fmt "IPTypeInvariant(%a,%a,%a,%a)"
      Cil_types_debug.pp_string str
      Cil_types_debug.pp_typ typ
      Cil_types_debug.pp_predicate pred
      Cil_types_debug.pp_location loc
  | IPGlobalInvariant (str,pred,loc) ->
    Format.fprintf fmt "IPGlobalInvariant(%a,%a,%a)"
      Cil_types_debug.pp_string str
      Cil_types_debug.pp_predicate pred
      Cil_types_debug.pp_location loc
  | IPAllocation (kf, ki, bol, iterm_pair_list) ->
    Format.fprintf fmt "IPAllocation(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      pp_behavior_or_loop_debug bol
      (Cil_types_debug.pp_pair
         (Cil_types_debug.pp_list Cil_types_debug.pp_identified_term)
         (Cil_types_debug.pp_list Cil_types_debug.pp_identified_term)
      ) iterm_pair_list
  | IPAssigns (kf, ki, bol, from_list) ->
    Format.fprintf fmt "IPAssigns(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      pp_behavior_or_loop_debug bol
      (Cil_types_debug.pp_list Cil_types_debug.pp_from) from_list
  | IPFrom (kf, ki, bol, from) ->
    Format.fprintf fmt "IPFrom(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      pp_behavior_or_loop_debug bol
      Cil_types_debug.pp_from from
  | IPReachable (okf, ki, pp) ->
    Format.fprintf fmt "IPReachable(%a,%a,%a)"
      (Cil_types_debug.pp_option Cil_types_debug.pp_kernel_function) okf
      Cil_types_debug.pp_kinstr ki
      pp_program_point pp
  | IPBehavior(kf, ki, a, fb) ->
    Format.fprintf fmt "IPBehavior(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_kinstr ki
      Datatype.String.Set.pretty a
      Cil_types_debug.pp_funbehavior fb
  | IPPropertyInstance (kf, s, oip, ip) ->
    Format.fprintf fmt "IPPropertyInstance(%a,%a,%a,%a)"
      Cil_types_debug.pp_kernel_function kf
      Cil_types_debug.pp_stmt s
      (Cil_types_debug.pp_option Cil_types_debug.pp_identified_predicate) oip
      pretty_debug ip
  | IPOther(s,ol) ->
    Format.fprintf fmt "IPOther(%a,%a)"
      Cil_types_debug.pp_string s
      pp_other_loc ol

(* -------------------------------------------------------------------------- *)
(* --- Legacy Property Names                                              --- *)
(* -------------------------------------------------------------------------- *)

(* Shall be deprecated *)
module LegacyNames =
struct

  module NamesTbl =
    State_builder.Hashtbl(Datatype.String.Hashtbl)(Datatype.Int)
      (struct
	 let name = "PropertyNames"
	 let dependencies = [ ]
	 let size = 97
       end)
  module IndexTbl =
    State_builder.Hashtbl(Hashtbl)(Datatype.String)
      (struct
	 let name = "PropertyIndex"
	 let dependencies = [ Ast.self; NamesTbl.self; Globals.Functions.self ]
	 let size = 97
       end)

  let self = IndexTbl.self

  let kf_prefix kf = (Ast_info.Function.get_vi kf.fundec).vname ^ "_"

  let ident_names names =
    List.filter (function "" -> true
		   | _ as n -> '\"' <> (String.get n 0) ) names

  let pp_names fmt l =
    let l = ident_names l in
    match l with [] -> ()
      | _ -> Format.fprintf fmt "_%a"
          (Pretty_utils.pp_list ~sep:"_" Format.pp_print_string) l

  let pp_code_annot_names fmt ca =
    match ca.annot_content with
      | AAssert(for_bhv,_,named_pred) | AInvariant(for_bhv,_,named_pred) ->
        let pp_for_bhv fmt l =
          match l with
          | [] -> ()
          | _ -> Format.fprintf fmt "_for_%a"
                   (Pretty_utils.pp_list ~sep:"_" Format.pp_print_string) l
        in
        Format.fprintf fmt "%a%a" pp_names named_pred.pred_name pp_for_bhv for_bhv
      | AVariant(term, _) -> pp_names fmt term.term_name
      | _ -> () (* TODO : add some more names ? *)

  let behavior_prefix b =
    if Cil.is_default_behavior b then ""
    else b.b_name ^ "_"

  let variant_suffix = function
    | (_,Some s) -> s
    | _ -> ""

  let string_of_termination_kind = function
      Normal -> "post"
    | Exits -> "exit"
    | Breaks -> "break"
    | Continues -> "continue"
    | Returns -> "return"

  let stmt_prefix _s = "stmt_"

  let ki_prefix = function Kglobal -> "" | Kstmt s -> stmt_prefix s

  let extended_loc_prefix = function
    | ELContract kf -> kf_prefix kf
    | ELStmt (kf,s) -> kf_prefix kf ^ stmt_prefix s
    | ELGlob -> "global_"

  let other_loc_prefix = function
    | OLContract kf -> kf_prefix kf
    | OLStmt (kf,s) -> kf_prefix kf ^ stmt_prefix s
    | OLGlob _ -> "global_"

  let predicate_kind_txt pk ki =
    let name = match pk with
      | PKRequires b -> (behavior_prefix b) ^ "pre"
      | PKAssumes b -> (behavior_prefix b) ^ "assume"
      | PKEnsures (b, tk) -> (behavior_prefix b) ^ string_of_termination_kind tk
      | PKTerminates -> "term"
    in
      (ki_prefix ki) ^ name

  let active_prefix fmt a =
    let print_one a = Format.fprintf fmt "_%s" a in
    Datatype.String.Set.iter print_one a

  let rec id_prop_txt p = match p with
    | IPPredicate (pk,kf,ki,idp) ->
        Format.asprintf "%s%s%a"
          (kf_prefix kf) (predicate_kind_txt pk ki)
          pp_names idp.ip_content.pred_name
    | IPExtended (le,(_,name,_,_,_)) ->
      Format.asprintf  "%sextended%a" (extended_loc_prefix le) pp_names [name]
    | IPCodeAnnot (kf,_, ca) ->
        let name = match ca.annot_content with
          | AAssert (_, Assert, _) -> "assert"
          | AAssert (_, Check, _) -> "check"
          | AInvariant (_,true,_) -> "loop_inv"
          | AInvariant _ -> "inv"
          | APragma _ -> "pragma"
          | AStmtSpec _ -> "contract"
          | AAssigns _ -> "assigns"
          | AVariant _ -> "variant"
          | AAllocation _ -> "allocates"
          | AExtended(_,_,(_,clause,_,_,_)) -> clause
        in Format.asprintf "%s%s%a" (kf_prefix kf) name pp_code_annot_names ca
    | IPComplete (kf, ki, a, lb) ->
        Format.asprintf  "%s%s%acomplete%a"
          (kf_prefix kf) (ki_prefix ki) active_prefix a pp_names lb
    | IPDisjoint (kf, ki, a, lb) ->
        Format.asprintf  "%s%s%adisjoint%a"
          (kf_prefix kf) (ki_prefix ki) active_prefix a pp_names lb
    | IPDecrease (kf,_,None, variant) -> (kf_prefix kf) ^ "decr" ^ (variant_suffix variant)
    | IPDecrease (kf,_,_,variant) -> (kf_prefix kf) ^ "loop_term" ^ (variant_suffix variant)
    | IPAxiom (name,_,_,named_pred,_) ->
	Format.asprintf "axiom_%s%a" name pp_names named_pred.pred_name
    | IPAxiomatic(name, _) -> "axiomatic_" ^ name
    | IPLemma (name,_,_,named_pred,_) ->
	Format.asprintf "lemma_%s%a" name pp_names named_pred.pred_name
    | IPTypeInvariant (name,_,named_pred,_) ->
      Format.asprintf "type_invariant_%s%a"
        name pp_names named_pred.pred_name
    | IPGlobalInvariant (name,named_pred,_) ->
      Format.asprintf "global_invariant_%s%a"
        name pp_names named_pred.pred_name
    | IPAllocation (kf, ki, (Id_contract (a,b)), _) ->
      Format.asprintf "%s%s%a%salloc"
        (kf_prefix kf) (ki_prefix ki) active_prefix a (behavior_prefix b)
    | IPAllocation (kf, Kstmt _s, (Id_loop ca), _) ->
      Format.asprintf "%sloop_alloc%a"
        (kf_prefix kf) pp_code_annot_names ca
    | IPAllocation _ -> assert false
    | IPAssigns (kf, ki, (Id_contract (a,b)), _) ->
      Format.asprintf "%s%s%a%sassign"
        (kf_prefix kf) (ki_prefix ki) active_prefix a (behavior_prefix b)
    | IPAssigns (kf, Kstmt _s, (Id_loop ca), _) ->
      Format.asprintf "%sloop_assign%a"
        (kf_prefix kf) pp_code_annot_names ca
    | IPAssigns _ -> assert false
    | IPFrom (_, _, _, (out,_)) ->
        "from_id_"^(string_of_int (out.it_id))
    | IPReachable _ -> "reachable_stmt"
    | IPBehavior(kf, ki, a, b) ->
      Format.asprintf "%s%s%a%s"
        (kf_prefix kf) (ki_prefix ki) active_prefix a b.b_name
    | IPPropertyInstance (kf, stmt, _, ip) ->
      Format.asprintf "specialization_%s_at_%t" (id_prop_txt ip)
        (fun fmt ->
           Format.fprintf fmt "%a_stmt_%d" Kernel_function.pretty kf stmt.sid)
    | IPOther(s,le) -> other_loc_prefix le ^ s

  (** function used to normalize basename *)
  let normalize_basename s =
    let is_valid_char_id = function
      | 'a'..'z' | 'A' .. 'Z' | '0' .. '9' | '_' -> true
      | _ -> false
    and is_numeric = function
      | '0'..'9' -> true
      | _ -> false
    in
    if s ="" then "property"
    else
      let s = String.map (fun c -> if not (is_valid_char_id c) then '_' else c) s in
      if is_numeric s.[0] then "property_" ^ s else s

  (** returns the name that should be returned by the function [get_prop_name_id] if the given property has [name] as basename. That name is reserved so that [get_prop_name_id prop] can never return an identical name. *)
  let reserve_name_id basename =
    let basename = normalize_basename basename in
      try
	let speed_up_start = NamesTbl.find basename in
	  (* this basename is already reserved *)
	let n,unique_name = Extlib.make_unique_name NamesTbl.mem ~sep:"_" ~start:speed_up_start basename
	in NamesTbl.replace basename (succ n) ; (* to speed up Extlib.make_unique_name for next time *)
	  unique_name
      with Not_found -> (* first time that basename is reserved *)
	NamesTbl.add basename 2 ;
	basename

  (** returns the basename of the property. *)
  let get_prop_basename ip = normalize_basename (id_prop_txt ip)

  (** returns a unique name identifying the property.
      This name is built from the basename of the property. *)
  let get_prop_name_id ip =
    try IndexTbl.find ip
    with Not_found -> (* first time we are asking for a name for that [ip] *)
      let basename = get_prop_basename ip in
      let unique_name = reserve_name_id basename in
	IndexTbl.add ip unique_name ;
	unique_name

end

(* -------------------------------------------------------------------------- *)
(* --- Property Names                                                     --- *)
(* -------------------------------------------------------------------------- *)

module Names =
struct

  open Cil_types

  type part =
    | B of behavior
    | K of kernel_function
    | A of string
    | I of identified_predicate
    | P of predicate
    | T of term
    | S of stmt

  let add_part buffer = function
    | B bhv ->
      if not (Cil.is_default_behavior bhv)
      then Sanitizer.add_string buffer bhv.b_name
    | K kf -> Sanitizer.add_string buffer (Kernel_function.get_name kf)
    | A msg -> Sanitizer.add_string buffer msg
    | S stmt -> Sanitizer.add_string buffer (Printf.sprintf "s%d" stmt.sid)
    | I { ip_content = { pred_name = a } }
    | P { pred_name = a } | T { term_name = a } -> Sanitizer.add_list buffer a

  let rec add_parts buffer = function
    | [] -> ()
    | p::ps ->
      let open Sanitizer in
      add_part buffer p ; add_sep buffer ; add_parts buffer ps

  let rec parts_of_property ip : part list =
    match ip with
    | IPBehavior(kf,Kglobal,_,bhv) ->
      [ K kf ; B bhv ]
    | IPBehavior(kf,Kstmt s,_,bhv) ->
      [ K kf ; B bhv ; S s ]

    | IPPredicate (PKAssumes bhv,kf,_,ip) ->
      [ K kf ; B bhv ; A "assumes" ; I ip ]
    | IPPredicate (PKRequires bhv,kf,_,ip) ->
      [ K kf ; B bhv ; A "requires" ; I ip ]
    | IPPredicate (PKEnsures(bhv,Normal),kf,_,ip) ->
      [ K kf ; B bhv ; A "ensures" ; I ip ]
    | IPPredicate (PKEnsures(bhv,Exits),kf,_,ip) ->
      [ K kf ; B bhv ; A "exits" ; I ip ]
    | IPPredicate (PKEnsures(bhv,Breaks),kf,_,ip) ->
      [ K kf ; B bhv ; A "breaks" ; I ip ]
    | IPPredicate (PKEnsures(bhv,Continues),kf,_,ip) ->
      [ K kf ; B bhv ; A "continues" ; I ip ]
    | IPPredicate (PKEnsures(bhv,Returns),kf,_,ip) ->
      [ K kf ; B bhv ; A "returns" ; I ip ]
    | IPPredicate (PKTerminates,kf,_,ip) ->
      [ K kf ; A "terminates" ; I ip ]

    | IPAllocation(kf,_,Id_contract(_,bhv),_) ->
      [ K kf ; B bhv ; A "allocates" ]
    | IPAllocation(kf,_,Id_loop _,_) ->
      [ K kf ; A "loop_allocates" ]

    | IPAssigns(kf,_,Id_contract(_,bhv),_) ->
      [ K kf ; B bhv ; A "assigns" ]

    | IPAssigns(kf,_,Id_loop _,_) ->
      [ K kf ; A "loop_assigns" ]

    | IPFrom(kf,_,Id_contract(_,bhv),_) ->
      [ K kf ; B bhv ; A "assigns_from" ]

    | IPFrom(kf,_,Id_loop _,_) ->
      [ K kf ; A "loop_assigns_from" ]

    | IPDecrease (kf,_,None,_) ->
      [ K kf ; A "variant" ]

    | IPDecrease (kf,_,Some _,_) ->
      [ K kf ; A "loop_variant" ]

    | IPCodeAnnot (kf,stmt, { annot_content = AStmtSpec _ } ) ->
      [ K kf ; A "contract" ; S stmt ]

    | IPCodeAnnot (kf,stmt, { annot_content = APragma _ } ) ->
      [ K kf ; A "pragma" ; S stmt ]

    | IPCodeAnnot (kf,stmt, { annot_content = AExtended(_,_,(_,clause,_,_,_)) } )
      -> [ K kf ; A clause ; S stmt ]

    | IPCodeAnnot (kf,_, { annot_content = AAssert(_,Assert,p) } ) ->
      [K kf ; A "assert" ; P p ]
    | IPCodeAnnot (kf,_, { annot_content = AAssert(_,Check,p) } ) ->
      [K kf ; A "check" ; P p ]
    | IPCodeAnnot (kf,_, { annot_content = AInvariant(_,true,p) } ) ->
      [K kf ; A "loop_invariant" ; P p ]
    | IPCodeAnnot (kf,_, { annot_content = AInvariant(_,false,p) } ) ->
      [K kf ; A "invariant" ; P p ]
    | IPCodeAnnot (kf,_, { annot_content = AVariant(e,_) } ) ->
      [K kf ; A "loop_variant" ; T e ]
    | IPCodeAnnot (kf,_, { annot_content = AAssigns _ } ) ->
      [K kf ; A "loop_assigns" ]
    | IPCodeAnnot (kf,_, { annot_content = AAllocation _ } ) ->
      [K kf ; A "loop_allocates" ]

    | IPComplete (kf,_,_,cs) ->
      (K kf :: A "complete" :: List.map (fun a -> A a) cs)
    | IPDisjoint(kf,_,_,cs) ->
      (K kf :: A "disjoint" :: List.map (fun a -> A a) cs)

    | IPReachable (None, _, _) -> []
    | IPReachable (Some kf,Kglobal,Before) ->
      [ K kf ; A "reachable" ]
    | IPReachable (Some kf,Kglobal,After) ->
      [ K kf ; A "reachable_post" ]
    | IPReachable (Some kf,Kstmt s,Before) ->
      [ K kf ; A "reachable" ; S s ]
    | IPReachable (Some kf,Kstmt s,After) ->
      [ K kf ; A "reachable_after" ; S s ]

    | IPAxiomatic _
    | IPAxiom _ -> []
    | IPLemma(name,_,_,p,_) ->
      [ A "lemma" ; A name ; P p ]

    | IPTypeInvariant(name,_,_,_)
    | IPGlobalInvariant(name,_,_) ->
      [ A "invariant" ; A name ]

    | IPOther(name,OLGlob _) -> [ A name ]
    | IPOther(name,OLContract kf) -> [ K kf ; A name ]
    | IPOther(name,OLStmt(kf,s)) -> [ K kf ; A name ; S s ]

    | IPExtended(ELGlob,(_,name,_,_,_)) -> [ A name ]
    | IPExtended(ELContract(kf),(_,name,_,_,_)) -> [ K kf ; A name ]
    | IPExtended(ELStmt(kf,s),(_,name,_,_,_)) -> [ K kf ; A name ; S s ]

    | IPPropertyInstance (_, _, _, ip) -> parts_of_property ip

  let get_prop_basename ?truncate ip =
    let buffer =
      match truncate with
      | None -> Sanitizer.create ~truncate:false 20
      | Some n -> Sanitizer.create ~truncate:true n
    in
    add_parts buffer (parts_of_property ip) ;
    Sanitizer.contents buffer

  (* Numerotation of properties with same basename *)
  module NamesTbl =
    State_builder.Hashtbl(Datatype.String.Hashtbl)(Datatype.Int)
      (struct
	let name = "Property.Names.NamesTbl"
        let dependencies = [ ]
        let size = 97
      end)

  (* Computed name of properties *)
  module IndexTbl = (* indexed by Property *)
    State_builder.Hashtbl(Hashtbl)(Datatype.String)
      (struct
	let name = "Property.Names.IndexTbl"
	let dependencies = [ Ast.self; NamesTbl.self; Globals.Functions.self ]
	let size = 97
      end)

  let self = IndexTbl.self

  let compute_name_id basename =
    try
      let speed_up_start = NamesTbl.find basename in
      (* this basename is already reserved *)
      let n,unique_name = Extlib.make_unique_name NamesTbl.mem ~sep:"_" ~start:speed_up_start basename
      in NamesTbl.replace basename (succ n) ; (* to speed up Extlib.make_unique_name for next time *)
      unique_name
    with Not_found -> (* first time that basename is reserved *)
      NamesTbl.add basename 2 ;
      basename

  let get_prop_name_id ip =
    try IndexTbl.find ip
    with Not_found -> (* first time we are asking for a name for that [ip] *)
      let basename = get_prop_basename ip in
      let unique_name = compute_name_id basename in
      IndexTbl.add ip unique_name ;
      unique_name

end

(* -------------------------------------------------------------------------- *)
(* --- Smart Constructors                                                 --- *)
(* -------------------------------------------------------------------------- *)

let ip_other s le = IPOther(s,le)

let ip_reachable_stmt kf ki = IPReachable(Some kf, Kstmt ki, Before)

let ip_reachable_ppt p =
  let kf = get_kf p in
  let ki = get_kinstr p in
  let ba = match p with
    | IPPredicate((PKRequires _ | PKAssumes _ | PKTerminates), _, _, _)
    | IPAxiom _ | IPAxiomatic _ | IPLemma _ | IPComplete _
    | IPDisjoint _ | IPCodeAnnot _ | IPAllocation _
    | IPDecrease _ | IPPropertyInstance _ | IPOther _
    | IPTypeInvariant _ | IPGlobalInvariant _
      -> Before
    | IPPredicate(PKEnsures _, _, _, _) | IPAssigns _ | IPFrom _
    | IPExtended _
    | IPBehavior _
      -> After
    | IPReachable _ -> Kernel.fatal "IPReachable(IPReachable _) is not possible"
  in
  IPReachable(kf, ki, ba)

let ip_of_ensures kf st b (k,p) = IPPredicate (PKEnsures(b,k),kf,st,p)

let ip_of_extended le p = IPExtended (le, p)

let ip_ensures_of_behavior kf st b =
  List.map (ip_of_ensures kf st b) b.b_post_cond

let ip_of_allocation kf st loc = function
  | FreeAllocAny -> None
  | FreeAlloc(f,a) -> Some (IPAllocation (kf,st,loc,(f,a)))

let ip_allocation_of_behavior kf st ~active b =
  let a = Datatype.String.Set.of_list active in
  ip_of_allocation kf st (Id_contract (a,b)) b.b_allocation

let ip_of_assigns kf st loc = function
  | WritesAny -> None
  | Writes [(a,_)] when Logic_utils.is_result a.it_content ->
    (* We're only assigning the result (with dependencies), but no
       global variables, this amounts to \nothing.
     *)
    Some (IPAssigns (kf, st, loc, []))
  | Writes a -> Some (IPAssigns (kf,st,loc,a))

let ip_assigns_of_behavior kf st ~active b =
  let a = Datatype.String.Set.of_list active in
  ip_of_assigns kf st (Id_contract (a,b)) b.b_assigns

let ip_of_from kf st loc from =
  match snd from with
    | FromAny -> None
    | From _ -> Some (IPFrom (kf,st, loc, from))

let ip_from_of_behavior kf st ~active b =
  match b.b_assigns with
  | WritesAny -> []
  | Writes l ->
    let treat_from acc (out, froms) = match froms with
      | FromAny -> acc
      | From _ ->
        let a = Datatype.String.Set.of_list active in
	let ip =
          Extlib.the (ip_of_from kf st (Id_contract (a,b)) (out, froms))
        in
	ip :: acc
    in
    List.fold_left treat_from [] l

let ip_allocation_of_code_annot kf st ca = match ca.annot_content with
  | AAllocation (_,a) -> ip_of_allocation kf st (Id_loop ca) a
  | _ -> None

let ip_assigns_of_code_annot kf st ca = match ca.annot_content with
  | AAssigns (_,a) -> ip_of_assigns kf st (Id_loop ca) a
  | _ -> None

let ip_from_of_code_annot kf st ca = match ca.annot_content with
  | AAssigns(_,WritesAny) -> []
  | AAssigns (_,Writes l) ->
    let treat_from acc (out, froms) = match froms with FromAny -> acc
      | From _ ->
        let ip =
          Extlib.the (ip_of_from kf st (Id_loop ca) (out, froms))
        in
        ip::acc
    in
    List.fold_left treat_from [] l
  | _ -> []

let ip_post_cond_of_behavior kf st ~active b =
  ip_ensures_of_behavior kf st b
  @ (Extlib.list_of_opt (ip_assigns_of_behavior kf st ~active b))
  @ ip_from_of_behavior kf st active b
  @ (Extlib.list_of_opt (ip_allocation_of_behavior kf st ~active b))

let ip_of_behavior kf s ~active b =
  let a = Datatype.String.Set.of_list active in
  IPBehavior(kf, s, a, b)

let ip_of_requires kf st b p = IPPredicate (PKRequires b,kf,st,p)

let ip_requires_of_behavior kf st b =
  List.map (ip_of_requires kf st b) b.b_requires

let ip_of_assumes kf st b p = IPPredicate (PKAssumes b,kf,st,p)

let ip_assumes_of_behavior kf st b =
  List.map (ip_of_assumes kf st b) b.b_assumes

let ip_all_of_behavior kf st ~active b =
  ip_of_behavior kf st ~active b
  :: ip_requires_of_behavior kf st b
  @ ip_assumes_of_behavior kf st b
  @ ip_post_cond_of_behavior kf st ~active b
  @ List.map (ip_of_extended (e_loc_of_stmt kf st)) b.b_extended

let ip_of_complete kf st ~active bhvs =
  let a = Datatype.String.Set.of_list active in IPComplete(kf,st,a,bhvs)

let ip_complete_of_spec kf st ~active s =
  List.map (ip_of_complete kf st ~active) s.spec_complete_behaviors

let ip_of_disjoint kf st ~active bhvs =
  let a = Datatype.String.Set.of_list active in IPDisjoint(kf,st,a,bhvs)

let ip_disjoint_of_spec kf st ~active s =
  List.map (ip_of_disjoint kf st ~active) s.spec_disjoint_behaviors

let ip_of_terminates kf st p = IPPredicate(PKTerminates,kf,st,p)

let ip_terminates_of_spec kf st s = match s.spec_terminates with
  | None -> None
  | Some p -> Some (ip_of_terminates kf st p)

let ip_of_decreases kf st d = IPDecrease(kf,st,None,d)

let ip_decreases_of_spec kf st s =
  Extlib.opt_map (ip_of_decreases kf st) s.spec_variant

let ip_post_cond_of_spec kf st ~active s =
  List.concat
    (List.map (ip_post_cond_of_behavior kf st ~active) s.spec_behavior)

let ip_of_spec kf st ~active s =
  List.concat (List.map (ip_all_of_behavior kf st ~active) s.spec_behavior)
  @ ip_complete_of_spec kf st active s
  @ ip_disjoint_of_spec kf st active s
  @ (Extlib.list_of_opt (ip_terminates_of_spec kf st s))
  @ (Extlib.list_of_opt (ip_decreases_of_spec kf st s))

let ip_axiom s = IPAxiom s
let ip_lemma s = IPLemma s
let ip_type_invariant s = IPTypeInvariant s
let ip_global_invariant s = IPGlobalInvariant s

let ip_property_instance kf stmt ipred iprop =
  IPPropertyInstance (kf, stmt, ipred, iprop)

let ip_of_code_annot kf stmt ca =
  let ki = Kstmt stmt in
  match ca.annot_content with
  | AAssert _ | AInvariant _ -> [ IPCodeAnnot(kf, stmt, ca) ]
  | AStmtSpec (active,s) -> ip_of_spec kf ki active s
  | AVariant t -> [ IPDecrease (kf,ki,(Some ca),t) ]
  | AAllocation _ ->
      Extlib.list_of_opt (ip_allocation_of_code_annot kf ki ca)
    @ ip_from_of_code_annot kf ki ca
  | AAssigns _ ->
    Extlib.list_of_opt (ip_assigns_of_code_annot kf ki ca)
    @ ip_from_of_code_annot kf ki ca
  | APragma p when Logic_utils.is_property_pragma p ->
    [ IPCodeAnnot (kf,stmt,ca) ]
  | APragma _ -> []
  | AExtended(_,_,(_,_,_,status,_ as ext)) ->
    if status then [IPExtended(ELStmt(kf,stmt),ext)] else []

let ip_of_code_annot_single kf stmt ca = match ip_of_code_annot kf stmt ca with
  | [] ->
    (* [JS 2011/06/07] using Kernel.error here seems very strange.
       Actually it is incorrect in case of pragma which is not a property (see
       function ip_of_code_annot above. *)
    Kernel.error
      "@[cannot find a property to extract from code annotation@\n%a@]"
      Cil_printer.pp_code_annotation ca;
    raise (Invalid_argument "ip_of_code_annot_single")
  | [ ip ] -> ip
  | ip :: _ ->
    Kernel.warning
      "@[choosing one of multiple properties associated \
           to code annotation@\n%a@]"
      Cil_printer.pp_code_annotation ca;
    ip

(* Must ensure that the first property is the best one in order to represent
   the annotation (see ip_of_global_annotation_single) *)
let ip_of_global_annotation a =
  let once = true in
  let rec aux acc = function
    | Daxiomatic(name, l, _, _) ->
      let ppts = List.fold_left aux [] l in
      IPAxiomatic(name, ppts) :: (ppts @ acc)
    | Dlemma(name, true, a, b, c, _, d) -> ip_axiom (name,a,b,c,d) :: acc
    | Dlemma(name, false, a, b, c, _, d) -> ip_lemma (name,a,b,c,d) :: acc
    | Dinvariant(l, loc) ->
      let pred = match l.l_body with
	| LBpred p -> p
	| _ -> assert false
      in
      IPGlobalInvariant(l.l_var_info.lv_name,pred,loc) :: acc
    | Dtype_annot(l, loc) ->
      let parameter = match l.l_profile with
	| h :: [] -> h
	| _ -> assert false
      in
      let ty = match parameter.lv_type with
	| Ctype x -> x
	| _ -> assert false
      in
      let pred = match l.l_body with
	| LBpred p -> p
	| _ -> assert false
      in
      IPTypeInvariant(l.l_var_info.lv_name,ty,pred,loc) :: acc
    | Dcustom_annot(_c, _n, _, _) ->
      (* TODO *)
      Kernel.warning ~once "ignoring status of custom annotation";
      acc
    | Dmodel_annot _ | Dfun_or_pred _ | Dvolatile _ | Dtype _ ->
      (* no associated status for these annotations *)
      acc
    | Dextended(ext,_,_) -> IPExtended (ELGlob, ext) :: acc
  in
  aux [] a

let ip_of_global_annotation_single a = match ip_of_global_annotation a with
  | [] -> None
  | ip :: _ ->
    (* the first one is the good one, see ip_of_global_annotation *)
    Some ip

(*
Local Variables:
compile-command: "make -C ../../.."
End:
*)
