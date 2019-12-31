module Data.TeaRoom exposing (data)

import Descriptor exposing (..)
import Tag
import Work exposing (..)


data : Work msg
data =
    { name = "The tea room"
    , description =
        d
            [ p
                [ t "Software for use with the HTC Vive hardware, created during a two-week workshop hosted by the Korea National University of Arts, with a team of seven students from the Tokyo University of the Arts. We created a virtual space based on a two-tatami-small room for the Japanese tea ceremony, which was designed by tea master Sen no Rikyu following his appreciation of rustic simplicity. In the room there are several unexpected interactive elements, and a trigger that transports the user to a different and alien environment."
                ]
            ]
    , mainVisualUrl = "tearoom/main.jpg"
    , date = Date "2017"
    , tags =
        [ Tag.VisualCommunication
        , Tag.Programming
        , Tag.Digital
        , Tag.VideoGame
        ]
    , visuals =
        [ Video
            { id = "216446958"
            , thumbnailUrl = "tearoom/thumb01.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMoreUrl = Just "http://blog.agj.cl/tag/the-tea-room/"
    }
