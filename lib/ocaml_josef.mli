open Core

val librdkafka_version : unit -> string

module Error : sig
  type t =
    | Invalid_topic of string
    | Invalid_config of string
    | Producer_closed
    | Kafka_error of string
  [@@deriving sexp]

  val to_string : t -> string
end

module Topic : sig
  type t [@@deriving sexp]

  val of_string : string -> (t, Error.t) Result.t
  val to_string : t -> string
end

module Config : sig
  type t [@@deriving sexp]

  val create : (string * string) list -> (t, Error.t) Result.t
  val to_alist : t -> (string * string) list
end

module Producer : sig
  type t

  val with_ :
    config:Config.t -> f:(t -> ('a, Error.t) Result.t) -> ('a, Error.t) Result.t

  val produce :
    t ->
    topic:Topic.t ->
    key:string option ->
    payload:string ->
    (unit, Error.t) Result.t

  val flush : t -> timeout_ms:int -> (unit, Error.t) Result.t
  val close : t -> unit
end
