module Main exposing (..)

import Array
import Backend
import Debounce
import Html exposing (..)
import Html.App as App
import Model exposing (..)
import String
import Task
import Time exposing (millisecond)
import Views exposing (..)


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

        Loading ->
            loadingView

        _ ->
            (searchBox :: statsTable model) |> container


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
                        ( model, Cmd.none )

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

        ScrollContext messageid rownum direction ->
            let
                row =
                    Array.get rownum model.rows

                scrollAmount =
                    5

                msgid =
                    case direction of
                        Up ->
                            messageid - scrollAmount

                        Down ->
                            messageid + scrollAmount
            in
                case row of
                    Just row ->
                        let
                            ctx =
                                case row.context of
                                    Just ctx ->
                                        Just { ctx | loadingDirection = Just direction }

                                    Nothing ->
                                        Nothing
                        in
                            ( { model | rows = Array.set rownum { row | messageid = msgid, context = ctx } model.rows }
                            , Backend.getContext rownum msgid
                            )

                    Nothing ->
                        ( model, Cmd.none )

        StatsFetchSucceed rows ->
            ( { model | rows = rows, state = Ready }, Cmd.none )

        StatsFetchFail err ->
            ( { model | state = Error (toString err) }, Cmd.none )

        InitSearch txt ->
            ( model, mkCmd <| Debounce <| Debounce.Bounce <| mkCmd (Search txt) )

        Search txt ->
            if String.length txt >= 5 then
                ( model, Backend.getSearch txt )
            else
                ( { model | search = Nothing }, Cmd.none )

        SearchSucceed rows ->
            ( { model | search = Just rows, state = Ready }, Cmd.none )

        Debounce a ->
            let
                ( newdebouncer, eff ) =
                    Debounce.update (250 * millisecond) a model.debouncer
            in
                ( { model | debouncer = newdebouncer }
                , Cmd.map
                    (\r ->
                        case r of
                            Err a' ->
                                Debounce a'

                            Ok a' ->
                                a'
                    )
                    eff
                )


mkCmd : a -> Cmd a
mkCmd =
    Task.perform (Debug.crash << toString) identity << Task.succeed
