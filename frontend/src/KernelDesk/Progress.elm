module KernelDesk.Progress exposing
    ( compactStatusLabel
    , draftsFor
    , progressPercent
    , progressSummary
    , statusFromString
    , statusLabel
    , statusToString
    )

import Dict exposing (Dict)
import KernelDesk.Types exposing (Lesson, Progress, ProgressStatus(..), ProgressSummary)


draftsFor : String -> Dict String Progress -> ( String, ProgressStatus )
draftsFor path progress =
    case Dict.get path progress of
        Just item ->
            ( item.note, item.status )

        Nothing ->
            ( "", NotStarted )


progressSummary : List Lesson -> Dict String Progress -> ProgressSummary
progressSummary lessons progress =
    List.foldl
        (\lesson summary ->
            case Dict.get lesson.path progress |> Maybe.map .status |> Maybe.withDefault NotStarted of
                Reading ->
                    { summary | reading = summary.reading + 1 }

                Understood ->
                    { summary | understood = summary.understood + 1 }

                NotStarted ->
                    summary
        )
        { total = List.length lessons, reading = 0, understood = 0 }
        lessons


progressPercent : ProgressSummary -> String
progressPercent summary =
    if summary.total == 0 then
        "0%"

    else
        String.fromInt (summary.understood * 100 // summary.total) ++ "%"


statusFromString : String -> ProgressStatus
statusFromString rawStatus =
    case rawStatus of
        "reading" ->
            Reading

        "understood" ->
            Understood

        _ ->
            NotStarted


statusToString : ProgressStatus -> String
statusToString status =
    case status of
        NotStarted ->
            "not_started"

        Reading ->
            "reading"

        Understood ->
            "understood"


statusLabel : ProgressStatus -> String
statusLabel status =
    case status of
        NotStarted ->
            "Not started"

        Reading ->
            "Reading"

        Understood ->
            "Understood"


compactStatusLabel : ProgressStatus -> String
compactStatusLabel status =
    case status of
        NotStarted ->
            "New"

        Reading ->
            "Reading"

        Understood ->
            "Done"
