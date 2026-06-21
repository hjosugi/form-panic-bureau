module FormPanic.Rules exposing (accepted, rules)

import FormPanic.Types exposing (Model, Rule)
import String


rules : Model -> List Rule
rules model =
    let
        name =
            String.trim model.fullName

        email =
            String.trim model.email
    in
    [ { title = "氏名"
      , hint = "3文字以上"
      , passed = String.length name >= 3
      }
    , { title = "メール"
      , hint = "@ と . を含む"
      , passed = String.contains "@" email && String.contains "." email
      }
    , { title = "窓口"
      , hint = "3番窓口だけが開いています"
      , passed = model.window == "window-3"
      }
    , { title = "規約"
      , hint = "利用規約に同意"
      , passed = model.terms
      }
    , { title = "ロボット確認"
      , hint = "ロボットではない可能性を認める"
      , passed = model.notRobot
      }
    , { title = "罠チェック"
      , hint = "取り消しチェックは空欄"
      , passed = not model.decoy
      }
    , { title = "番号つまみ"
      , hint = "42に合わせる"
      , passed = model.slider == "42"
      }
    , { title = "CAPTCHA"
      , hint = "PANIC と入力"
      , passed = String.trim model.captcha == "PANIC"
      }
    ]


accepted : Model -> Bool
accepted model =
    List.all .passed (rules model)
