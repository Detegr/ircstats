module Main exposing (..)

import Model exposing (..)
import Views exposing (..)
import Backend exposing (..)
import Html exposing (..)
import Html.App as App


main : Program Never
main =
    App.program { init = ( initialModel, Cmd.none ), subscriptions = subscriptions, view = view, update = update }


initialModel : Model
initialModel =
    case decodeStats statsDecoder of
        Ok stats ->
            { rows = stats, reversed = False }

        Err err ->
            { rows = [], reversed = False }


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none


view : Model -> Html.Html Msg
view model =
    statsTable model |> container


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SortStats sortfunc ->
            let
                rows =
                    List.sortWith sortfunc model.rows

                reversed =
                    if rows == model.rows then
                        not model.reversed
                    else
                        False
            in
                ( { model
                    | rows =
                        if reversed then
                            List.reverse rows
                        else
                            rows
                    , reversed = reversed
                  }
                , Cmd.none
                )

        UpdateStats ->
            ( model, Cmd.none )
