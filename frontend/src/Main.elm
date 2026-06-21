module Main exposing (main)

import Browser
import FormPanic.Rules exposing (accepted)
import FormPanic.Types exposing (Flags, Model, Msg(..), Screen(..), initialModel)
import FormPanic.View exposing (view)
import Time


main : Program Flags Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.screen of
        Playing ->
            Time.every 1000 Tick

        _ ->
            Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start ->
            ( { initialModel
                | screen = Playing
                , message = "受付開始。フォームは協力してくれません。"
              }
            , Cmd.none
            )

        Restart ->
            ( initialModel, Cmd.none )

        Tick _ ->
            tick model

        FullNameChanged value ->
            ( { model | fullName = value }, Cmd.none )

        EmailChanged value ->
            ( { model | email = value }, Cmd.none )

        WindowChanged value ->
            ( { model | window = value }, Cmd.none )

        ToggleTerms checked ->
            ( { model | terms = checked }, Cmd.none )

        ToggleRobot checked ->
            ( { model | notRobot = checked }, Cmd.none )

        ToggleDecoy checked ->
            ( { model | decoy = checked }, Cmd.none )

        SliderChanged value ->
            ( { model | slider = value }, Cmd.none )

        CaptchaChanged value ->
            ( { model | captcha = value }, Cmd.none )

        ButtonDodged ->
            dodgeButton model

        Submit ->
            submit model


tick : Model -> ( Model, Cmd Msg )
tick model =
    if model.secondsLeft <= 1 then
        ( { model
            | screen = Lost
            , secondsLeft = 0
            , message = "時間切れです。番号札は自動的に粉砕されました。"
          }
        , Cmd.none
        )

    else
        ( { model
            | secondsLeft = model.secondsLeft - 1
            , elapsed = model.elapsed + 1
          }
        , Cmd.none
        )


dodgeButton : Model -> ( Model, Cmd Msg )
dodgeButton model =
    if model.screen == Playing then
        ( { model
            | dodges = model.dodges + 1
            , message = "Accept ボタンが逃げました。窓口ではよくあることです。"
          }
        , Cmd.none
        )

    else
        ( model, Cmd.none )


submit : Model -> ( Model, Cmd Msg )
submit model =
    if accepted model then
        ( { model
            | screen = Won
            , message = "ACCEPTED。理不尽フォームを突破しました。"
          }
        , Cmd.none
        )

    else
        ( { model | message = "まだ不備があります。左のチェックリストを疑ってください。" }, Cmd.none )
