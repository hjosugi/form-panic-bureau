module FormPanic.Rules exposing (accepted, configGenerator, rules)

import FormPanic.Types exposing (Config, Model, Rule)
import Random
import String


{-| Roll a fresh rule set. Every parameter is randomized, including whether the
checkboxes must be ticked or deliberately left empty.
-}
configGenerator : Random.Generator Config
configGenerator =
    let
        andMap =
            Random.map2 (|>)

        bool =
            Random.uniform True [ False ]
    in
    Random.constant Config
        |> andMap (Random.int 3 8)
        |> andMap (Random.uniform ".dev" [ ".io", ".jp", ".com", ".net", ".xyz" ])
        |> andMap (Random.int 1 4)
        |> andMap (Random.int 2 6)
        |> andMap bool
        |> andMap bool
        |> andMap bool


rules : Model -> List Rule
rules model =
    let
        cfg =
            model.config

        name =
            String.trim model.fullName

        email =
            String.trim (String.toLower model.email)

        choose want yes no =
            if want then
                yes

            else
                no
    in
    [ { title = "氏名"
      , hint = String.fromInt cfg.nameMin ++ "文字以上"
      , passed = String.length name >= cfg.nameMin
      }
    , { title = "メール"
      , hint = "@ を含み " ++ cfg.emailTld ++ " で終わる"
      , passed = String.contains "@" email && String.endsWith cfg.emailTld email
      }
    , { title = "窓口"
      , hint = String.fromInt cfg.windowOpen ++ "番窓口だけが開いています"
      , passed = model.window == ("window-" ++ String.fromInt cfg.windowOpen)
      }
    , { title = "申請部数"
      , hint = String.fromInt cfg.copiesTarget ++ " 部ちょうどにする"
      , passed = model.copies == cfg.copiesTarget
      }
    , { title = "利用規約"
      , hint = choose cfg.termsWanted "同意する" "同意しない"
      , passed = model.terms
      }
    , { title = "お知らせメール"
      , hint = choose cfg.mailWanted "受け取る" "受け取らない"
      , passed = model.mail
      }
    , { title = "アンケート"
      , hint = choose cfg.surveyWanted "協力する" "協力しない"
      , passed = model.survey
      }
    ]


accepted : Model -> Bool
accepted model =
    List.all .passed (rules model)
