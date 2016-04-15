(**************************************************************************)
(*                                                                        *)
(*  This file is part of Frama-C.                                         *)
(*                                                                        *)
(*  Copyright (C) 2007-2010                                               *)
(*    CEA (Commissariat � l'�nergie atomique et aux �nergies              *)
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

(* $Id: kf_state.mli,v 1.7 2008-04-01 09:25:22 uid568 Exp $ *)

(** Keep information attached to kernel functions. *)

open Db_types

val mark_as_called: kernel_function -> unit
val add_caller: caller:kernel_function*Cil_types.stmt -> kernel_function -> unit
val mark_as_terminates: kernel_function -> unit
val mark_as_never_terminates: kernel_function -> unit

(*
Local Variables:
compile-command: "LC_ALL=C make -C ../.. -j"
End:
*)
