open App_interface

module AppCode = APP_API_IDL (Codegen.Gen ())

let interfaces =
  Codegen.Interfaces.create
    ~name:"App"
    ~title:"App"
    ~description:["Interface for the App"]
    ~interfaces:[AppCode.implementation ()]

let () =
  (*
  let code = Pythongen.of_interfaces interfaces |> Pythongen.string_of_ts in
  Printf.printf "%s\n" code ;
  *)
  let md = Markdowngen.to_string interfaces in
  Printf.printf "%s\n" md

