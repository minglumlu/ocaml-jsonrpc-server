(lang dune 3.16)

(name app)

(generate_opam_files true)

(authors "Ming Lu")

(license LICENSE)

(package
 (allow_empty)
 (name app-server)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
   (topics "to describe" your project)
 )
)

(package
 (allow_empty)
 (name app-client)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
   (topics "to describe" your project)
 )
)

(package
 (allow_empty)
 (name app-idl)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
   (topics "to describe" your project)
 )
)

(package
 (allow_empty)
 (name app-interface-generators)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
   (topics "to describe" your project)
 )
)


; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
