module Backend exposing (..)

import Date exposing (Date)
import Http
import Json.Decode exposing (..)
import Model exposing (..)
import Task


dateDecoder : Decoder Date
dateDecoder =
    customDecoder string Date.fromString


statsDecoder : Decoder (List StatRow)
statsDecoder =
    list (object4 StatRow ("time" := dateDecoder) ("nick" := string) ("lines" := int) ("random" := string)) |> object1 identity


getStats : Cmd Msg
getStats =
    Task.perform StatsFetchFail StatsFetchSucceed (Http.get statsDecoder "http://192.168.1.2:8080/stats")
