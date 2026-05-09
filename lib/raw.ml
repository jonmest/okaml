open Ctypes
open Foreign

let librdkafka = Dl.dlopen ~filename:"librdkafka.so" ~flags:[ Dl.RTLD_NOW ]
let foreign name typ = foreign ~from:librdkafka name typ

let rd_kafka_version_str =
  foreign "rd_kafka_version_str" (void @-> returning string)

let version () = rd_kafka_version_str ()
