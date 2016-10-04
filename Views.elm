module Views exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (class, colspan, placeholder, src)
import Html.Events exposing (onClick, onInput)
import Model exposing (..)
import String
import Date.Format exposing (format)


pageHeader : Html a
pageHeader =
    h1 [ class "page-header" ] [ (text "IRCStats") ]


container : List (Html Msg) -> Html Msg
container inner =
    div [ class "container" ] (pageHeader :: inner)


searchBox : Html Msg
searchBox =
    div [ class "form-group" ] [ input [ class "form-control", placeholder "Search", onInput InitSearch ] [] ]


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
    case model.search of
        Nothing ->
            [ table [ class "table table-hover table-bordered table-responsive" ]
                [ statsTableHeader [ "Nick", "Lines", "Random line" ]
                , tbody [] <| List.concatMap statRowToHtml (Array.toIndexedList model.rows)
                ]
            ]

        Just search ->
            [ table [ class "table table-hover table-bordered table-responsive" ]
                [ tbody
                    []
                    (List.map
                        (\row -> tr [] [ td [] [ text (styleContextRow row) ] ])
                        (Array.toList search)
                    )
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
        case ( row.context, row.expanded ) of
            ( Just context, True ) ->
                case context.contextRows of
                    Just _ ->
                        List.append ret [ expandedRow row rownum context ]

                    Nothing ->
                        ret

            _ ->
                ret


styleContextRow : ContextRow -> String
styleContextRow row =
    let
        t =
            row.time
    in
        (format "%H:%M" t) ++ " <" ++ row.nick ++ "> " ++ row.line ++ "\n"


expandedRow : StatRow -> Int -> Context -> Html Msg
expandedRow row rownum context =
    let
        spinner =
            img [ src "static/spinner2.gif" ] []

        scrollerLoading : String -> Html Msg
        scrollerLoading txt =
            span [] [ text (txt ++ " "), spinner, text "\n" ]

        mkScroller : String -> Maybe Direction -> Direction -> Html Msg
        mkScroller txt dir wantedDir =
            let
                notLoading =
                    a [ class "clickable", onClick <| ScrollContext row.messageid rownum wantedDir ] [ text txt, text "\n" ]
            in
                case dir of
                    Just dir ->
                        if dir == wantedDir then
                            scrollerLoading txt
                        else
                            notLoading

                    _ ->
                        notLoading

        topScroller : String -> Maybe Direction -> Html Msg
        topScroller txt dir =
            mkScroller txt dir Up

        bottomScroller : String -> Maybe Direction -> Html Msg
        bottomScroller txt dir =
            mkScroller txt dir Down

        contextData =
            case context.contextRows of
                Just contextData ->
                    contextData

                Nothing ->
                    []
    in
        tr []
            [ td [ colspan 3 ]
                [ pre [] <|
                    [ topScroller "Previous lines" context.loadingDirection ]
                        ++ (List.map (styleContextRow >> text) contextData)
                        ++ [ bottomScroller "Next lines" context.loadingDirection ]
                ]
            ]


errorView : String -> Html a
errorView err =
    div [ class "well" ] [ text err ]
