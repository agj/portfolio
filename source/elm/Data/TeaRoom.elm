module Data.TeaRoom exposing (data)

import Descriptor exposing (..)
import Work exposing (..)


data : Work msg
data =
    { name = "The tea room"
    , tags =
        [ "videogame"
        , "vr"
        ]
    , description =
        d
            [ p
                [ t "Software for use with the HTC Vive hardware, created during a two-week workshop hosted by the Korea National University of Arts, with a team of seven students from the Tokyo University of the Arts. We created a virtual space based on a two-tatami-small room for the Japanese tea ceremony, which was designed by tea master Sen no Rikyu following his appreciation of rustic simplicity. In the room there are several unexpected interactive elements, and a trigger that transports the user to a different and alien environment."
                ]
            ]
    }
