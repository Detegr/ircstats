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


type alias StatsTable =
    { rows : List StatRow, sortkey : String, reversed : Bool }


type alias Model =
    StatsTable
