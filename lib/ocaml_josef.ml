open Core

let librdkafka_version () = Raw.version ()

module Error = struct
  type t =
    | Invalid_topic of string
    | Invalid_config of string
    | Producer_closed
    | Kafka_error of string
  [@@deriving sexp]

  let to_string t = Sexp.to_string_hum [%sexp (t : t)]
end

module Topic = struct
  type t = Topic of string [@@deriving sexp]

  let of_string s =
    if String.is_empty s then
      Error (Error.Invalid_topic "topic cannot be empty")
    else Ok (Topic s)

  let to_string (Topic s) = s
end

module Config = struct
  type t = Config of (string * string) list [@@deriving sexp]

  let create entries =
    let has_empty_key =
      List.exists entries ~f:(fun (key, _) -> String.is_empty key)
    in

    if has_empty_key then
      Error (Error.Invalid_config "config keys cannot be empty")
    else Ok (Config entries)

  let to_alist (Config entries) = entries
end

module Producer = struct
  type t = { mutable closed : bool }

  let create ~config:_ = Ok { closed = false }
  let close t = t.closed <- true

  let with_ ~config ~f =
    match create ~config with
    | Error err -> Error err
    | Ok producer ->
        let result = f producer in
        close producer;
        result

  let produce t ~topic ~key:_ ~payload:_ =
    if t.closed then Error Error.Producer_closed
    else
      let _topic_name = Topic.to_string topic in
      Ok ()

  let flush t ~timeout_ms:_ =
    if t.closed then Error Error.Producer_closed else Ok ()
end
