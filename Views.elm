module Views exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import String


pageHeader : Html a
pageHeader =
    h1 [ class "page-header" ] [ (text "IRCStats") ]


container : List (Html Msg) -> Html Msg
container inner =
    div [ class "container" ] (pageHeader :: inner)


mkSortFunc : String -> Maybe SortFunc
mkSortFunc header =
    -- This is pretty ugly :(
    case String.toLower header of
        "nick" ->
            Just (\a b -> compare a.nick b.nick)

        "lines" ->
            Just (\a b -> compare a.lines b.lines)

        "random line" ->
            Just (\a b -> compare a.random b.random)

        _ ->
            Nothing


thFromHeader : String -> Html Msg
thFromHeader h =
    let
        attributes =
            case mkSortFunc h of
                Just sortfunc ->
                    [ onClick <| SortStats sortfunc ]

                Nothing ->
                    []
    in
        th attributes [ String.toUpper h |> text ]


statsTableHeader : List String -> Html Msg
statsTableHeader headers =
    thead [ class "clickable" ]
        [ tr [] (List.map thFromHeader headers)
        ]


statsTable : Model -> List (Html Msg)
statsTable model =
    [ table [ class "table table-striped table-bordered table-responsive" ]
        [ statsTableHeader [ "Nick", "Lines", "Random line" ]
        , tbody [] <| List.map statRowToHtml model.rows
        ]
    ]


statRowToHtml : StatRow -> Html b
statRowToHtml row =
    tr []
        [ td [] [ text row.nick ]
        , td [] [ text <| toString row.lines ]
        , td [] [ text row.random ]
        ]
