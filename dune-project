(lang dune 3.14)

(name ocaml_josef)

(generate_opam_files true)

(package
 (name ocaml_josef)
 (synopsis "OCaml bindings for librdkafka")
 (depends ocaml dune core ctypes ctypes-foreign alcotest))
