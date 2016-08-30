module Model exposing (..)

import Date exposing (Date)
import Http
import Array exposing (Array)


type alias SortFunc =
    StatRow -> StatRow -> Order


type Msg
    = SortStats SortFunc String
    | StatsFetchSucceed (Array StatRow)
    | StatsFetchFail Http.Error
    | ToggleRow Int


type alias StatRow =
    { time : Date, nick : String, lines : Int, random : String, expanded : Bool }


type alias Model =
    { state : ModelState, rows : Array StatRow, sortkey : String, reversed : Bool }


mkModel : Model
mkModel =
    { state = Loading, rows = Array.empty, sortkey = "", reversed = False }


type ModelState
    = Ready
    | Loading
    | Error String
