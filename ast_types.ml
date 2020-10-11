open Core

type 'a loc = 'a Location.loc = {
  txt: 'a;
  loc: Location.t;
}

type variable_id = string loc
type procedure_id = string loc
type channel_id = string loc
type type_id = string loc

type prim_ty =
  | Pty_unit
  | Pty_bool
  | Pty_ureal
  | Pty_preal
  | Pty_real
  | Pty_fnat of int
  | Pty_nat
[@@deriving sexp, equal]

type base_ty = {
  bty_desc: base_ty_desc;
  bty_loc: Location.t;
}

and base_ty_desc =
  | Bty_prim of prim_ty
  | Bty_arrow of base_ty * base_ty
  | Bty_dist of base_ty

type base_tyv =
  | Btyv_prim of prim_ty
  | Btyv_arrow of base_tyv * base_tyv
  | Btyv_dist of base_tyv
[@@deriving sexp, equal]

type binop =
  | Bop_add
  | Bop_sub
  | Bop_mul
  | Bop_div
  | Bop_eq
  | Bop_ne
  | Bop_lt
  | Bop_le
  | Bop_gt
  | Bop_ge
  | Bop_and
  | Bop_or

type 'a dist =
  | D_ber of 'a
  | D_unif
  | D_beta of 'a * 'a
  | D_gamma of 'a * 'a
  | D_normal of 'a * 'a
  | D_cat of 'a list
  | D_geo of 'a

type exp = {
  exp_desc: exp_desc;
  exp_loc: Location.t;
}

and exp_desc =
  | E_var of variable_id
  | E_triv
  | E_bool of bool
  | E_cond of exp * exp * exp
  | E_real of float
  | E_nat of int
  | E_binop of binop loc * exp * exp
  | E_abs of variable_id * base_ty * exp
  | E_app of exp * exp
  | E_let of exp * variable_id * exp
  | E_dist of exp dist

type value =
  | V_triv
  | V_bool of bool
  | V_real of float
  | V_nat of int
  | V_clo of environment * variable_id * base_ty * exp
  | V_dist of value dist

and environment = value String.Map.t

type cmd = {
  cmd_desc: cmd_desc;
  cmd_loc: Location.t;
}

and cmd_desc =
  | M_ret of exp
  | M_bnd of cmd * variable_id * cmd
  | M_call of procedure_id * exp list
  | M_sample_recv of exp * channel_id
  | M_sample_send of exp * channel_id
  | M_branch_recv of cmd * cmd * channel_id
  | M_branch_send of exp * cmd * cmd * channel_id

type sess_ty = {
  sty_desc: sess_ty_desc;
  sty_loc: Location.t;
}

and sess_ty_desc =
  | Sty_one
  | Sty_conj of base_ty * sess_ty
  | Sty_imply of base_ty * sess_ty
  | Sty_ichoice of sess_ty * sess_ty
  | Sty_echoice of sess_ty * sess_ty
  | Sty_var of type_id

type sess_tyv =
  | Styv_one
  | Styv_conj of base_tyv * sess_tyv
  | Styv_imply of base_tyv * sess_tyv
  | Styv_ichoice of sess_tyv * sess_tyv
  | Styv_echoice of sess_tyv * sess_tyv
  | Styv_var of string
[@@deriving sexp, equal]

type proc_sig = {
  psig_param_tys: (variable_id * base_ty) list;
  psig_ret_ty: base_ty;
  psig_sess_left: (channel_id * type_id) option;
  psig_sess_right: (channel_id * type_id) option;
}

type proc_sig_val = {
  psigv_param_tys: (string * base_tyv) list;
  psigv_ret_ty: base_tyv;
  psigv_sess_left: (string * string) option;
  psigv_sess_right: (string * string) option;
}

type proc = {
  proc_sig: proc_sig;
  proc_body: cmd;
  proc_loc: Location.t;
}

type sess_or_proc =
  | Top_sess of type_id * sess_ty
  | Top_proc of procedure_id * proc

type prog = sess_or_proc list
