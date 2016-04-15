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

(* $Id: register.ml,v 1.7 2009-02-18 21:56:10 uid528 Exp $ *)

(*
Local Variables:
compile-command: "LC_ALL=C make -C ../.. -j"
End:
*)

let main _fmt = 
  let forceout = Inout_parameters.ForceOut.get () in
  let forceexternalout = Inout_parameters.ForceExternalOut.get () in
  if forceout || forceexternalout
  then begin
    !Db.Semantic_Callgraph.topologically_iter_on_functions
      (fun kf ->
	 if Kernel_function.is_definition kf 
	 then begin
	   if forceout
	   then Inout_parameters.result "%a" !Db.Outputs.display kf ;
	   if forceexternalout
	   then Inout_parameters.result "%a" !Db.Outputs.display_external kf ;
	 end)
  end

let () = Db.Main.extend main
