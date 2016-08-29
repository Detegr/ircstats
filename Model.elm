module Model exposing (..)

import Date exposing (Date)
import Http


type alias SortFunc =
    StatRow -> StatRow -> Order


type Msg
    = SortStats SortFunc String
    | StatsFetchSucceed (List StatRow)
    | StatsFetchFail Http.Error


type alias StatRow =
    { time : Date, nick : String, lines : Int, random : String }


type alias Model =
    { state : ModelState, rows : List StatRow, sortkey : String, reversed : Bool }


mkModel : Model
mkModel =
    { state = Loading, rows = [], sortkey = "", reversed = False }


type ModelState
    = Ready
    | Loading
    | Error String
