module Backend exposing (..)

import Array exposing (Array)
import Date exposing (Date)
import Http
import Json.Decode exposing (..)
import Model exposing (..)
import Task


date : Decoder Date
date =
    customDecoder string Date.fromString


statsDecoder : Decoder (Array StatRow)
statsDecoder =
    array <|
        object6 StatRow
            ("messageid" := int)
            ("nick" := string)
            ("lines" := int)
            ("random" := string)
            (succeed False)
            (succeed Nothing)


contextDecoder : Int -> Decoder ( Int, Context )
contextDecoder messageid =
    object2 (,)
        (succeed messageid)
    <|
        object2 Context (maybe <| list <| object3 ContextRow ("time" := date) ("nick" := string) ("line" := string)) (succeed Nothing)


getStats : Cmd Msg
getStats =
    Task.perform StatsFetchFail StatsFetchSucceed (Http.get statsDecoder "http://192.168.1.2:8080/stats")


getContext : Int -> Int -> Cmd Msg
getContext rownum messageid =
    Task.perform StatsFetchFail ContextFetchSucceed (Http.get (contextDecoder rownum) <| "http://192.168.1.2:8080/context/" ++ (toString messageid))
