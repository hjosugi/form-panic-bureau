module KernelDesk.View.Learning exposing (viewLearningPath, viewSelectedLesson)

import Dict
import Html exposing (Html, button, div, h2, li, p, section, span, text, ul)
import Html.Attributes exposing (class, classList, type_)
import Html.Events exposing (onClick)
import KernelDesk.Progress as Progress
import KernelDesk.Types exposing (Lesson, Loadable(..), Model, Msg(..), ProgressStatus(..))
import KernelDesk.View.Status as Status


viewLearningPath : Model -> Html Msg
viewLearningPath model =
    section [ class "card" ]
        [ div [ class "card-header" ] [ h2 [] [ text "Linux learning path" ] ]
        , case model.lessons of
            Idle ->
                div [ class "empty-state" ] [ text "No learning path." ]

            Loading ->
                div [ class "loading-state" ] [ text "学習ルートを読み込み中です。" ]

            Failed message ->
                div [ class "error-state" ] [ text message ]

            Loaded lessons ->
                div [ class "card-body" ]
                    [ Status.viewProgressSummary (Progress.progressSummary lessons model.progress)
                    , ul [ class "lesson-list" ]
                        (List.map (viewLessonButton model) lessons)
                    ]
        ]


viewLessonButton : Model -> Lesson -> Html Msg
viewLessonButton model lesson =
    let
        isSelected =
            case model.selectedLesson of
                Just selectedLesson ->
                    selectedLesson.id == lesson.id

                Nothing ->
                    False

        status =
            Dict.get lesson.path model.progress
                |> Maybe.map .status
                |> Maybe.withDefault NotStarted
    in
    li []
        [ button
            [ classList
                [ ( "lesson-button", True )
                , ( "is-selected", isSelected )
                ]
            , type_ "button"
            , onClick (SelectLesson lesson)
            ]
            [ div [ class "lesson-title-row" ]
                [ span [ class "lesson-title" ] [ text lesson.title ]
                , Status.viewStatusPill True status
                ]
            , span [ class "lesson-area" ] [ text lesson.area ]
            , span [ class "lesson-path" ] [ text lesson.path ]
            ]
        ]


viewSelectedLesson : Maybe Lesson -> Html Msg
viewSelectedLesson maybeLesson =
    case maybeLesson of
        Nothing ->
            text ""

        Just lesson ->
            section [ class "card" ]
                [ div [ class "card-header" ]
                    [ h2 [] [ text lesson.title ]
                    , span [ class "area-chip" ] [ text lesson.area ]
                    ]
                , div [ class "card-body" ]
                    [ div [ class "lesson-focus" ]
                        [ span [ class "section-kicker" ] [ text "Focus" ]
                        , p [] [ text lesson.goal ]
                        ]
                    , div [ class "question-panel" ]
                        [ span [ class "section-kicker" ] [ text "Questions" ]
                        , ul [ class "question-list" ]
                            (List.map (\question -> li [] [ text question ]) lesson.questions)
                        ]
                    ]
                ]
