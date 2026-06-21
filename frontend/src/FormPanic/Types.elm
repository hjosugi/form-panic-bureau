module FormPanic.Types exposing
    ( Config
    , Flags
    , Model
    , Msg(..)
    , Rule
    , Screen(..)
    , currentFace
    , defaultConfig
    , initialModel
    , timeLimit
    )

import Time


type alias Flags =
    { demoMode : Bool }


type Screen
    = Ready
    | Playing
    | Won
    | Lost


{-| The randomized rule set for a single round. Generated fresh every game so
no two rounds ask for exactly the same thing.
-}
type alias Config =
    { nameMin : Int
    , emailTld : String
    , windowOpen : Int
    , copiesTarget : Int
    , termsWanted : Bool
    , mailWanted : Bool
    , surveyWanted : Bool
    }


type alias Model =
    { screen : Screen
    , secondsLeft : Int
    , elapsed : Int
    , flip : Int
    , config : Config
    , fullName : String
    , email : String
    , window : String
    , terms : Bool
    , mail : Bool
    , survey : Bool
    , copies : Int
    , dodges : Int
    , misclicks : Int
    , message : String
    }


type Msg
    = Start
    | GotConfig Config
    | Restart
    | Tick Time.Posix
    | Flip Time.Posix
    | FullNameChanged String
    | EmailChanged String
    | WindowChanged String
    | ToggleTerms Bool
    | ToggleMail Bool
    | ToggleSurvey Bool
    | AdjustCopies Int
    | ButtonDodged
    | Submit


type alias Rule =
    { title : String
    , hint : String
    , passed : Bool
    }


timeLimit : Int
timeLimit =
    60


{-| What the Accept button shows right now. It cycles on a fixed interval, and
only the "ACCEPT" face actually submits the form.
-}
currentFace : Int -> String
currentFace flip =
    case modBy 4 flip of
        0 ->
            "ACCEPT"

        2 ->
            "ACCEPT"

        1 ->
            "DENY"

        _ ->
            "REJECT"


defaultConfig : Config
defaultConfig =
    { nameMin = 3
    , emailTld = ".dev"
    , windowOpen = 3
    , copiesTarget = 3
    , termsWanted = True
    , mailWanted = False
    , surveyWanted = True
    }


initialModel : Model
initialModel =
    { screen = Ready
    , secondsLeft = timeLimit
    , elapsed = 0
    , flip = 0
    , config = defaultConfig
    , fullName = ""
    , email = ""
    , window = "none"
    , terms = False
    , mail = False
    , survey = False
    , copies = 1
    , dodges = 0
    , misclicks = 0
    , message = "60秒以内に、受付フォームをなんとか受理させてください。"
    }
