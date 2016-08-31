module Main exposing (..)

import Model exposing (..)
import Views exposing (..)
import Html exposing (..)
import Html.App as App
import Backend
import Array


main : Program Never
main =
    App.program { init = ( mkModel, Backend.getStats ), subscriptions = subscriptions, view = view, update = update }


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model.state of
        Error error ->
            [ errorView error ] |> container

        Ready ->
            statsTable model |> container

        Loading ->
            loadingView


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SortStats sortfunc sortkey ->
            let
                rows =
                    List.sortWith sortfunc (Array.toList model.rows)

                reversed =
                    if sortkey == model.sortkey then
                        not model.reversed
                    else
                        False

                resultRows =
                    if reversed then
                        List.reverse rows
                    else
                        rows
            in
                ( { model
                    | rows = Array.fromList resultRows
                    , sortkey = sortkey
                    , reversed = reversed
                  }
                , Cmd.none
                )

        ToggleRow rownum ->
            let
                row =
                    Array.get rownum model.rows
            in
                case row of
                    Just row ->
                        ( { model | rows = Array.set rownum { row | expanded = not row.expanded } model.rows }
                        , Backend.getContext rownum row.messageid
                        )

                    Nothing ->
                        ( { model | state = Error "Could not find a row to expand" }, Cmd.none )

        ContextFetchSucceed ( rownum, context ) ->
            let
                row =
                    Array.get rownum model.rows
            in
                case row of
                    Just row ->
                        ( { model | rows = Array.set rownum { row | context = Just context } model.rows }, Cmd.none )

                    Nothing ->
                        ( { model | state = Error "Could not find a row to set context to" }, Cmd.none )

        StatsFetchSucceed rows ->
            ( { model | rows = rows, state = Ready }, Cmd.none )

        StatsFetchFail err ->
            ( { model | state = Error (toString err) }, Cmd.none )
