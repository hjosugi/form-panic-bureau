module KernelDesk.Api exposing
    ( fetchLessons
    , fetchProgress
    , fetchRepo
    , fetchSource
    , httpErrorToString
    , saveProgress
    )

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import KernelDesk.Progress as Progress
import KernelDesk.Types exposing (ApiPayload(..), GitChange, Lesson, Msg(..), Progress, ProgressStatus, RepoSnapshot, SourceFile)
import Url.Builder


fetchRepo : Cmd Msg
fetchRepo =
    Http.get
        { url = "/api/repo"
        , expect = Http.expectJson RepoReceived (apiPayloadDecoder repoDecoder)
        }


fetchLessons : Cmd Msg
fetchLessons =
    Http.get
        { url = "/api/learning-path"
        , expect = Http.expectJson LessonsReceived (Decode.list lessonDecoder)
        }


fetchProgress : Cmd Msg
fetchProgress =
    Http.get
        { url = "/api/progress"
        , expect = Http.expectJson ProgressReceived (apiPayloadDecoder (Decode.list progressDecoder))
        }


fetchSource : String -> Cmd Msg
fetchSource path =
    Http.get
        { url =
            Url.Builder.absolute
                [ "api", "file" ]
                [ Url.Builder.string "path" path ]
        , expect = Http.expectJson (SourceReceived path) (apiPayloadDecoder sourceDecoder)
        }


saveProgress : String -> ProgressStatus -> String -> Cmd Msg
saveProgress path status note =
    Http.post
        { url = "/api/progress"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "path", Encode.string path )
                    , ( "status", Encode.string (Progress.statusToString status) )
                    , ( "note", Encode.string note )
                    ]
                )
        , expect = Http.expectJson (ProgressSaved path) (apiPayloadDecoder progressDecoder)
        }


apiPayloadDecoder : Decoder value -> Decoder (ApiPayload value)
apiPayloadDecoder decoder =
    Decode.oneOf
        [ Decode.map ApiOk decoder
        , Decode.map ApiError (Decode.field "error" Decode.string)
        ]


repoDecoder : Decoder RepoSnapshot
repoDecoder =
    Decode.map8 RepoSnapshot
        (Decode.field "root" Decode.string)
        (Decode.field "isGitRepo" Decode.bool)
        (Decode.field "branch" Decode.string)
        (Decode.field "remote" Decode.string)
        (Decode.field "headSummary" Decode.string)
        (Decode.field "headAuthor" Decode.string)
        (Decode.field "headDate" Decode.string)
        (Decode.field "changes" (Decode.list gitChangeDecoder))


gitChangeDecoder : Decoder GitChange
gitChangeDecoder =
    Decode.map2 GitChange
        (Decode.field "code" Decode.string)
        (Decode.field "path" Decode.string)


lessonDecoder : Decoder Lesson
lessonDecoder =
    Decode.map6 Lesson
        (Decode.field "id" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "path" Decode.string)
        (Decode.field "area" Decode.string)
        (Decode.field "goal" Decode.string)
        (Decode.field "questions" (Decode.list Decode.string))


sourceDecoder : Decoder SourceFile
sourceDecoder =
    Decode.map4 SourceFile
        (Decode.field "path" Decode.string)
        (Decode.field "content" Decode.string)
        (Decode.field "lineCount" Decode.int)
        (Decode.field "truncated" Decode.bool)


progressDecoder : Decoder Progress
progressDecoder =
    Decode.map4 Progress
        (Decode.field "path" Decode.string)
        (Decode.field "status" (Decode.map Progress.statusFromString Decode.string))
        (Decode.field "note" Decode.string)
        (Decode.field "updatedAt" Decode.string)


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Request timed out."

        Http.NetworkError ->
            "Backendに接続できません。Gleam serverを確認してください。"

        Http.BadStatus statusCode ->
            "Backend returned HTTP " ++ String.fromInt statusCode ++ "."

        Http.BadBody details ->
            "Invalid response: " ++ details
