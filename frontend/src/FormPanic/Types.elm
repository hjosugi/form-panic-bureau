module FormPanic.Types exposing
    ( Flags
    , Model
    , Msg(..)
    , Rule
    , Screen(..)
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


type alias Model =
    { screen : Screen
    , secondsLeft : Int
    , elapsed : Int
    , fullName : String
    , email : String
    , window : String
    , terms : Bool
    , notRobot : Bool
    , decoy : Bool
    , slider : String
    , captcha : String
    , dodges : Int
    , message : String
    }


type Msg
    = Start
    | Restart
    | Tick Time.Posix
    | FullNameChanged String
    | EmailChanged String
    | WindowChanged String
    | ToggleTerms Bool
    | ToggleRobot Bool
    | ToggleDecoy Bool
    | SliderChanged String
    | CaptchaChanged String
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


initialModel : Model
initialModel =
    { screen = Ready
    , secondsLeft = timeLimit
    , elapsed = 0
    , fullName = ""
    , email = ""
    , window = "none"
    , terms = False
    , notRobot = False
    , decoy = False
    , slider = "50"
    , captcha = ""
    , dodges = 0
    , message = "60秒以内に、受付フォームをなんとか受理させてください。"
    }
