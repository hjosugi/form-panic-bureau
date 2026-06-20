module KernelDesk.View.Status exposing (viewProgressSummary, viewStatusPill)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, classList, style, title)
import KernelDesk.Progress as Progress
import KernelDesk.Types exposing (ProgressStatus(..), ProgressSummary)


viewProgressSummary : ProgressSummary -> Html msg
viewProgressSummary summary =
    let
        notStarted =
            max 0 (summary.total - summary.reading - summary.understood)
    in
    div [ class "progress-summary" ]
        [ div [ class "progress-summary-row" ]
            [ span [ class "section-kicker" ] [ text "Progress" ]
            , span [ class "progress-total" ]
                [ text (String.fromInt summary.understood ++ "/" ++ String.fromInt summary.total ++ " understood") ]
            ]
        , div [ class "progress-meter", attribute "aria-hidden" "true" ]
            [ span [ class "progress-fill", style "width" (Progress.progressPercent summary) ] [] ]
        , div [ class "progress-counts" ]
            [ span [] [ text (String.fromInt notStarted ++ " new") ]
            , span [] [ text (String.fromInt summary.reading ++ " reading") ]
            , span [] [ text (String.fromInt summary.understood ++ " done") ]
            ]
        ]


viewStatusPill : Bool -> ProgressStatus -> Html msg
viewStatusPill compact status =
    span
        [ classList
            [ ( "status-pill", True )
            , ( "is-compact", compact )
            , ( "is-reading", status == Reading )
            , ( "is-understood", status == Understood )
            ]
        , title (Progress.statusLabel status)
        ]
        [ text
            (if compact then
                Progress.compactStatusLabel status

             else
                Progress.statusLabel status
            )
        ]
