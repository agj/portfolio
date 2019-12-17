module Data.Runnerby exposing (data)

import Descriptor exposing (..)
import Work exposing (..)


data : Work msg
data =
    { name = "Runnerby"
    , tags =
        [ "videogame"
        ]
    , description =
        d
            [ p
                [ t "A game controlled by a single key (spacebar), which makes a perpetually running character jump. Uses Flash."
                ]
            , p
                [ t "Designed around simplicity of controls, but difficulty of execution."
                ]
            , p
                [ t "(Playthrough video by "
                , l "Alexey Zubkov" "https://twitter.com/ortoslon"
                , t ".)"
                ]
            ]
    }
