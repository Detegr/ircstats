module Model exposing (..)

import Date exposing (Date)
import Http
import Array exposing (Array)
import Debounce


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
    | SearchSucceed SearchResult
    | StatsFetchFail Http.Error
    | ToggleRow RowNumber
    | ScrollContext MessageId RowNumber Direction
    | InitSearch String
    | Search String
    | Debounce (Debounce.Msg Msg)


type Direction
    = Up
    | Down


type alias Context =
    { contextRows : Maybe (List DataRow), loadingDirection : Maybe Direction }


type alias StatRow =
    { messageid : Int, nick : String, lines : Int, random : String, expanded : Bool, context : Maybe Context }


type alias DataRow =
    { time : Date, nick : String, line : String }


type alias SearchRow =
    { messageid : Int, row : DataRow, expanded : Bool, context : Maybe Context }


type alias SearchResult =
    Array SearchRow


type alias Model =
    { state : ModelState, rows : Array StatRow, search : Maybe SearchResult, sortkey : String, reversed : Bool, debouncer : Debounce.Model Msg }


mkModel : Model
mkModel =
    { state = Loading, rows = Array.empty, search = Nothing, sortkey = "", reversed = False, debouncer = Debounce.init }


type ModelState
    = Ready
    | Loading
    | Error String
