module Works exposing (all)

import Data.Runnerby
import Data.TeaRoom
import Work exposing (..)


all : List (Work msg)
all =
    [ Data.Runnerby.data
    , Data.TeaRoom.data
    ]
