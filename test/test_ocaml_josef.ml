open Core

let ok_or_fail = function
  | Ok x -> x
  | Error err -> failwith (Ocaml_josef.Error.to_string err)

let test_topic_roundtrip () =
  match Ocaml_josef.Topic.of_string "com.company.partner" with
  | Error err -> failwith (Ocaml_josef.Error.to_string err)
  | Ok topic ->
      Alcotest.(check string)
        "topic string" "com.company.partner"
        (Ocaml_josef.Topic.to_string topic)

let test_empty_topic_rejected () =
  match Ocaml_josef.Topic.of_string "" with
  | Ok _ -> failwith "did not reject"
  | Error _ -> ()

let test_empty_config () =
  match Ocaml_josef.Config.create [ ("", "value") ] with
  | Ok _ -> failwith "expected config with empty key to be rejected"
  | Error _ -> ()

let test_producer_with_runs_function () =
  let config =
    Ocaml_josef.Config.create [ ("bootstrap.servers", "localhost:9092") ]
    |> ok_or_fail
  in

  let result =
    Ocaml_josef.Producer.with_ ~config ~f:(fun _producer -> Ok "ran")
  in

  Alcotest.(check (result string string))
    "with_ result" (Ok "ran")
    (Result.map_error result ~f:Ocaml_josef.Error.to_string)

let test_librdkafka_version () =
  let version = Ocaml_josef.librdkafka_version () in
  Alcotest.(check bool)
    "version is not empty" true
    (not (String.is_empty version))

let () =
  Alcotest.run "Ocaml_josef"
    [
      ( "topic",
        [
          Alcotest.test_case "roundtrip" `Quick test_topic_roundtrip;
          Alcotest.test_case "empty rejected" `Quick test_empty_topic_rejected;
        ] );
      ("config", [ Alcotest.test_case "empty config" `Quick test_empty_config ]);
      ( "producer",
        [
          Alcotest.test_case "producer runs function" `Quick
            test_producer_with_runs_function;
        ] );
      ( "librdkafka",
        [ Alcotest.test_case "version" `Quick test_librdkafka_version ] );
    ]
