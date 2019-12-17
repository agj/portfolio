module Work exposing (Work)

import Element exposing (..)


type alias Work msg =
    { name : String
    , description : Element msg
    , tags : List String
    }
