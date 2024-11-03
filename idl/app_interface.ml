(* Define tpyes (including error types) used in RPC *)
let unit_p = Idl.Param.mk ~name:"unit" Rpc.Types.unit

let default_err = Idl.DefaultError.err

type my_error =
  | Unimplemented of string
  | UnexpectedError of string
[@@deriving rpcty]

module E = Idl.Error.Make (struct
  type t = my_error

  let t = my_error
  let internal_error_of e = Some (UnexpectedError (Printexc.to_string e))
end)

let my_err = E.error

(* Define IDL *)
module APP_API_IDL (R: Idl.RPC) = struct
  let description =
    Idl.Interface.
      {
        name= "App"
      ; namespace= None
      ; description= ["Application"]
      ; version= (0, 0, 1)
      }

  let implementation = R.implement description

  let hello =
    R.declare "hello"
      ["Hello"]
      R.(unit_p @-> returning unit_p default_err)

  let hello_error =
    R.declare "hello_err"
      ["Hello but return error"]
      R.(unit_p @-> returning unit_p default_err)

  let hello_my_error =
    R.declare "hello_my_err"
      ["Hello but return my error"]
      R.(unit_p @-> returning unit_p my_err)
end
