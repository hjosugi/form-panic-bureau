module KernelDesk.View.Source exposing (viewSource)

import Html exposing (Html, code, div, h3, section, span, text)
import Html.Attributes exposing (class)
import KernelDesk.Types exposing (Loadable(..), Msg, SourceFile)


viewSource : Loadable SourceFile -> Html Msg
viewSource sourceState =
    section [ class "card" ]
        [ case sourceState of
            Idle ->
                div [ class "empty-state" ] [ text "左の学習ルートまたは相対パスからファイルを開いてください。" ]

            Loading ->
                div [ class "loading-state" ] [ text "ソースを読み込み中です。" ]

            Failed message ->
                div [ class "error-state" ] [ text message ]

            Loaded source ->
                div []
                    [ div [ class "card-header" ]
                        [ div [ class "source-heading" ]
                            [ span [ class "section-kicker" ] [ text "Source" ]
                            , h3 [ class "mono" ] [ text source.path ]
                            ]
                        , div [ class "source-meta" ]
                            [ span [] [ text (String.fromInt source.lineCount ++ " lines") ]
                            , if source.truncated then
                                span [ class "warning-chip" ] [ text "Preview truncated" ]

                              else
                                text ""
                            ]
                        ]
                    , div [ class "code-scroll" ]
                        [ div [ class "code-block" ]
                            (source.content
                                |> String.lines
                                |> List.indexedMap viewCodeLine
                            )
                        ]
                    ]
        ]


viewCodeLine : Int -> String -> Html msg
viewCodeLine index line =
    div [ class "code-line" ]
        [ span [ class "line-number" ] [ text (String.fromInt (index + 1)) ]
        , code [ class "line-text" ] [ text line ]
        ]
