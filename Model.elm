module Model exposing (..)


type alias SortFunc =
    StatRow -> StatRow -> Order


type Msg
    = UpdateStats
    | SortStats SortFunc


type alias StatRow =
    { nick : String, lines : Int, random : String }


type alias StatsTable =
    { rows : List StatRow, reversed : Bool }


type alias Model =
    StatsTable
