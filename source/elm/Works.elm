module Works exposing (all)

import Data.Kotokan
import Data.Runnerby
import Data.TeaRoom
import Work exposing (..)


all : List (Work msg)
all =
    [ Data.Runnerby.data
    , Data.TeaRoom.data
    , Data.Kotokan.data
    ]
