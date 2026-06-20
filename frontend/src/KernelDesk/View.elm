module KernelDesk.View exposing (view)

import Html exposing (Html, button, div, h1, header, input, main_, p, section, span, text)
import Html.Attributes exposing (attribute, class, classList, disabled, placeholder, title, type_, value)
import Html.Events exposing (onClick, onInput)
import KernelDesk.Types exposing (Model, Msg(..), Notice, NoticeKind(..))
import KernelDesk.View.Learning as Learning
import KernelDesk.View.Notes as Notes
import KernelDesk.View.Repo as Repo
import KernelDesk.View.Source as Source


view : Model -> Html Msg
view model =
    div [ class "app-shell" ]
        [ viewHeader
        , div [ class "workspace" ]
            [ div [ class "sidebar" ]
                [ Repo.viewRepoCard model
                , Learning.viewLearningPath model
                ]
            , main_ [ class "content-column" ]
                [ viewNotice model.notice
                , viewPathToolbar model
                , Learning.viewSelectedLesson model.selectedLesson
                , Source.viewSource model.source
                , Notes.viewNotes model
                ]
            ]
        ]


viewHeader : Html msg
viewHeader =
    header [ class "topbar" ]
        [ div [ class "brand" ]
            [ h1 [] [ text "KernelDesk" ]
            , p [] [ text "Local Git management and Linux kernel code learning" ]
            ]
        , div [ class "topbar-note mono" ] [ text "Elm + Gleam + Node.js FFI" ]
        ]


viewNotice : Maybe Notice -> Html Msg
viewNotice maybeNotice =
    case maybeNotice of
        Nothing ->
            text ""

        Just notice ->
            div
                [ classList
                    [ ( "notice", True )
                    , ( "is-positive", notice.kind == Positive )
                    ]
                , attribute "role"
                    (if notice.kind == Positive then
                        "status"

                     else
                        "alert"
                    )
                ]
                [ span [] [ text notice.message ]
                , button [ type_ "button", onClick DismissNotice, title "閉じる" ] [ text "Close" ]
                ]


viewPathToolbar : Model -> Html Msg
viewPathToolbar model =
    section [ class "card" ]
        [ div [ class "path-toolbar" ]
            [ input
                [ class "text-input mono"
                , type_ "text"
                , value model.filePath
                , placeholder "例: init/main.c"
                , attribute "aria-label" "Repository relative path"
                , onInput FilePathChanged
                ]
                []
            , button
                [ class "primary-button"
                , type_ "button"
                , onClick LoadFile
                , disabled (String.isEmpty (String.trim model.filePath))
                ]
                [ text "Open file" ]
            ]
        ]
