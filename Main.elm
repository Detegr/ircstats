module Main exposing (..)

import Model exposing (..)
import Views exposing (..)
import Html exposing (..)
import Html.App as App
import Backend


main : Program Never
main =
    App.program { init = initialModel, subscriptions = subscriptions, view = view, update = update }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { state = Loading, rows = [], sortkey = "", reversed = False }, Backend.getStats )


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
            container'


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SortStats sortfunc sortkey ->
            let
                rows =
                    List.sortWith sortfunc model.rows

                reversed =
                    if sortkey == model.sortkey then
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
                    , sortkey = sortkey
                    , reversed = reversed
                  }
                , Cmd.none
                )

        StatsFetchSucceed rows ->
            ( { model | rows = rows, state = Ready }, Cmd.none )

        StatsFetchFail err ->
            ( { model | state = Error "Could not connect to the backend server" }, Cmd.none )
