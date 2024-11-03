open Lwt.Infix

open App_interface

(* Server side *)
module APP_SERVER = APP_API_IDL (Rpc_lwt.GenServer ())

module APP_Impl  = struct
  let hello () =
    Printf.printf "Hello, world!\n" ;
    (* Rpc_lwt.T.put (Lwt.return_ok ()) *)
    Rpc_lwt.ErrM.return ()

  let hello_error () =
    Printf.printf "Error: Hello, world!\n" ;
    Rpc_lwt.ErrM.return_err (Idl.DefaultError.InternalError "hello_error")

  let hello_my_error () =
    Printf.printf "My error: Hello, world!\n" ;
    Rpc_lwt.ErrM.return_err (Unimplemented "hello_my_error")
end

let rpc_server =
  APP_SERVER.hello APP_Impl.hello ;
  APP_SERVER.hello_error APP_Impl.hello_error ;
  APP_SERVER.hello_my_error APP_Impl.hello_my_error ;
  Rpc_lwt.server APP_SERVER.implementation


(* RPC over HTTP *)
let handler _req body =
  let call = Jsonrpc.call_of_string body in
  rpc_server call >>= fun response ->
  Lwt.return (Jsonrpc.string_of_response response)

(* HTTP server callback *)
let callback (_ch, _conn) req body =
  let uri = Cohttp.Request.uri req in
  let path = Uri.path uri in
  match (Cohttp.Request.meth req, path) with
  | `POST, "/" ->
      Cohttp_lwt.Body.to_string body >>= fun body ->
      handler req body >>= fun response ->
      let headers = Cohttp.Header.init () in
      Cohttp_lwt_unix.Server.respond_string ~headers ~status:`OK ~body:response ()
  | _ ->
      Lwt.fail (Failure "Unknown method")

let main () =
  let host = "127.0.0.1" in
  let port = 8080 in
  let cert = "server.pem" in
  let key = "server.key" in
  (* let mode = `TCP (`Port 8080) in *)
  let mode =
    `TLS (`Crt_file_path cert, `Key_file_path key, `No_password, `Port port)
  in
  Conduit_lwt_unix.init ~src:host () >>= fun ctx ->
  let ctx = Cohttp_lwt_unix.Net.init ~ctx () in
  Cohttp_lwt_unix.Server.make ~callback ()
  |> Cohttp_lwt_unix.Server.create ~ctx ~mode

let () =
  Lwt_main.run (main ())
