module Model exposing (..)

import Date exposing (Date)
import Http


type alias SortFunc =
    StatRow -> StatRow -> Order


type Msg
    = SortStats SortFunc
    | StatsFetchSucceed (List StatRow)
    | StatsFetchFail Http.Error


type alias StatRow =
    { time : Date, nick : String, lines : Int, random : String }


type alias StatsTable =
    { rows : List StatRow, reversed : Bool }


type alias Model =
    StatsTable
