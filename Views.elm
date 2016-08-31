module Views exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (class, colspan, src)
import Html.Events exposing (onClick)
import Model exposing (..)
import String
import Date.Format exposing (format)


pageHeader : Html a
pageHeader =
    h1 [ class "page-header" ] [ (text "IRCStats") ]


container : List (Html Msg) -> Html Msg
container inner =
    div [ class "container" ] (pageHeader :: inner)


loadingView : Html Msg
loadingView =
    div [ class "container" ] [ pageHeader, img [ class "img-responsive center-block", src "static/spinner.gif" ] [] ]


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
                    [ onClick <| SortStats sortfunc h ]

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
    let
        indexedList =
            Array.toIndexedList model.rows
    in
        [ table [ class "table table-hover table-bordered table-responsive" ]
            [ statsTableHeader [ "Nick", "Lines", "Random line" ]
            , tbody [] <| List.concatMap statRowToHtml indexedList
            ]
        ]


statRowToHtml : ( Int, StatRow ) -> List (Html Msg)
statRowToHtml ( rownum, row ) =
    let
        cols =
            [ td [] [ text row.nick ]
            , td [] [ text <| toString row.lines ]
            , td [] [ text row.random ]
            ]

        ret =
            [ tr [ class "clickable", onClick <| ToggleRow rownum ] cols ]
    in
        if row.expanded then
            case row.context of
                Just context ->
                    List.append ret [ expandedRow context ]

                Nothing ->
                    ret
        else
            ret


styleContextRow : ContextRow -> String
styleContextRow row =
    let
        t =
            row.time
    in
        (format "%H:%M" t) ++ " <" ++ row.nick ++ "> " ++ row.line ++ "\n"


expandedRow : List ContextRow -> Html Msg
expandedRow context =
    tr []
        [ td [ colspan 3 ]
            [ pre [] <| List.map (styleContextRow >> text) context
            ]
        ]


errorView : String -> Html a
errorView err =
    div [ class "well" ] [ text err ]
