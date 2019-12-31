module Data.Runnerby exposing (data)

import Descriptor exposing (..)
import Tag
import Work exposing (..)


data : Work msg
data =
    { name = "Runnerby"
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
                , l "moshboy" "https://twitter.com/moshboy"
                , t ".)"
                ]
            ]
    , mainVisualUrl = "runnerby/main.png"
    , date = Date "2010"
    , tags =
        [ Tag.VisualCommunication
        , Tag.VideoGame
        , Tag.Digital
        , Tag.Web
        ]
    , visuals =
        [ Video
            { id = "n5uQDt5hXDQ"
            , thumbnailUrl = "runnerby/video1-thumb.jpg"
            , aspectRatio = 256 / 409
            , host = Youtube
            }
        ]
    , links =
        [ { label = "Play"
          , url = "http://www.agj.cl/files/games/runnerby/"
          }
        ]
    , readMoreUrl = Just "http://blog.agj.cl/tag/runnerby/"
    }
