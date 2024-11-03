open Lwt.Infix

open App_interface

module APP_CLIENT = APP_API_IDL (Rpc_lwt.GenClient ())

let server_uri = Uri.of_string "https://127.0.0.1:8080/"
let ca_bundle_file = None

let ( >>>= ) x f = x |> Rpc_lwt.T.get >>= f

let main () =
  let rpc call =
    (* TLS *)
    let ssl_ctx =
      let ctx = Ssl.create_context Ssl.TLSv1_2 Ssl.Client_context in
      ca_bundle_file
      |> Option.iter (fun file -> Ssl.load_verify_locations ctx file "") ;
      ctx
    in
    let ssl_client_verify =
      Conduit_lwt_unix_ssl.Client.{hostname=false; ip=true}
    in
    Conduit_lwt_unix.init ~ssl_ctx ~ssl_client_verify ()
    >>= fun ctx ->
    let ctx = Cohttp_lwt_unix.Client.custom_ctx ~ctx () in

    (* HTTP *)
    let req_body = Jsonrpc.string_of_call call |> Cohttp_lwt.Body.of_string in
    Cohttp_lwt_unix.Client.post ~body:req ~ctx server_uri
    >>= fun (_resp, body) ->
    (*
    let code = resp |> Cohttp_lwt.Response.status |> Cohttp.Code.code_of_status in
    *)
    Cohttp_lwt.Body.to_string body
    >>= fun body ->
    (* JSONRPC *)
    Lwt.return (Jsonrpc.response_of_string body)
  in
  APP_CLIENT.hello rpc ()
  >>>= fun result ->
  Printf.printf "Done!\n" ;
  match result with
  | Ok () ->
      Lwt.return ()
  | Error (Idl.DefaultError.InternalError err) ->
      Lwt.return (Printf.printf "Error: %s!\n" err)

let () =
  Lwt_main.run (main ())
