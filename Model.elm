module Model exposing (..)

import Date exposing (Date)
import Http
import Array exposing (Array)


type alias SortFunc =
    StatRow -> StatRow -> Order


type Msg
    = SortStats SortFunc String
    | StatsFetchSucceed (Array StatRow)
    | ContextFetchSucceed ( Int, List ContextRow )
    | StatsFetchFail Http.Error
    | ToggleRow Int


type alias StatRow =
    { messageid : Int, nick : String, lines : Int, random : String, expanded : Bool, context : Maybe (List ContextRow) }


type alias ContextRow =
    { time : Date, nick : String, line : String }


type alias Model =
    { state : ModelState, rows : Array StatRow, sortkey : String, reversed : Bool }


mkModel : Model
mkModel =
    { state = Loading, rows = Array.empty, sortkey = "", reversed = False }


type ModelState
    = Ready
    | Loading
    | Error String
