module Model exposing (..)

import Date exposing (Date)
import Http
import Array exposing (Array)


type alias MessageId =
    Int


type alias RowNumber =
    Int


type alias SortFunc =
    StatRow -> StatRow -> Order


type Msg
    = SortStats SortFunc String
    | StatsFetchSucceed (Array StatRow)
    | ContextFetchSucceed ( RowNumber, Context )
    | StatsFetchFail Http.Error
    | ToggleRow RowNumber
    | ScrollContext MessageId RowNumber Direction


type Direction
    = Up
    | Down


type alias Context =
    { contextRows : Maybe (List ContextRow), loadingDirection : Maybe Direction }


type alias StatRow =
    { messageid : Int, nick : String, lines : Int, random : String, expanded : Bool, context : Maybe Context }


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
