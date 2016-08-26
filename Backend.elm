module Backend exposing (..)

import Json.Decode exposing (..)
import Model exposing (..)


statsString : String
statsString =
    "{\"data\": [{\"nick\": \"nick1\", \"lines\": 123, \"random\": \"bcd\"},{\"nick\": \"nick2\", \"lines\": 321, \"random\": \"abc\"},{\"nick\": \"nick3\", \"lines\": 222, \"random\": \"lul\"}]}"


statsDecoder : Decoder (List StatRow)
statsDecoder =
    "data" := list (object3 StatRow ("nick" := string) ("lines" := int) ("random" := string)) |> object1 identity


decodeStats : Decoder a -> Result String a
decodeStats decoder =
    decodeString decoder statsString
