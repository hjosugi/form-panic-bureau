module KernelDesk.View.Notes exposing (viewNotes)

import Dict
import Html exposing (Html, button, div, h2, label, option, section, select, span, text, textarea)
import Html.Attributes exposing (class, disabled, rows, type_, value, placeholder)
import Html.Events exposing (onClick, onInput)
import KernelDesk.Progress as Progress
import KernelDesk.Types exposing (Model, Msg(..))
import KernelDesk.View.Status as Status


viewNotes : Model -> Html Msg
viewNotes model =
    section [ class "card" ]
        [ div [ class "card-header" ]
            [ h2 [] [ text "Learning note" ]
            , viewCurrentProgressMeta model
            ]
        , div [ class "card-body" ]
            [ div [ class "notes-grid" ]
                [ div [ class "field-group" ]
                    [ label [ class "field-label" ] [ text "Status" ]
                    , Status.viewStatusPill False model.statusDraft
                    , select
                        [ class "select-input"
                        , value (Progress.statusToString model.statusDraft)
                        , onInput StatusChanged
                        , disabled (String.isEmpty (String.trim model.filePath))
                        ]
                        [ option [ value "not_started" ] [ text "Not started" ]
                        , option [ value "reading" ] [ text "Reading" ]
                        , option [ value "understood" ] [ text "Understood" ]
                        ]
                    ]
                , div [ class "field-group" ]
                    [ label [ class "field-label" ] [ text "Note" ]
                    , textarea
                        [ class "note-input"
                        , rows 8
                        , value model.noteDraft
                        , placeholder "関数の責務、呼び出し関係、疑問点を記録します。"
                        , onInput NoteChanged
                        , disabled (String.isEmpty (String.trim model.filePath))
                        ]
                        []
                    ]
                ]
            , div [ class "note-actions" ]
                [ button
                    [ class "primary-button"
                    , type_ "button"
                    , onClick SaveProgress
                    , disabled (model.saving || String.isEmpty (String.trim model.filePath))
                    ]
                    [ text
                        (if model.saving then
                            "Saving..."

                         else
                            "Save locally"
                        )
                    ]
                ]
            ]
        ]


viewCurrentProgressMeta : Model -> Html msg
viewCurrentProgressMeta model =
    let
        path =
            String.trim model.filePath
    in
    case Dict.get path model.progress of
        Just item ->
            if String.isEmpty item.updatedAt then
                text ""

            else
                span [ class "note-meta" ] [ text ("Updated " ++ item.updatedAt) ]

        Nothing ->
            text ""
