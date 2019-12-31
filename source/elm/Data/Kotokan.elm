module Data.Kotokan exposing (data)

import Descriptor exposing (..)
import Tag
import Work exposing (..)


data : Work msg
data =
    { name = "Come to think of language"
    , description =
        d
            [ p
                [ t "Utilizing a _constructed language_ as their material, I created three works. Graduation project for the Tokyo University of the Arts' New Media master's degree."
                ]
            , p
                [ t "Taking inspiration in the idea that language and thought are intimately related, I undertook this linguistic experiment. I first created a very essential base language —a 'meta-language,'— and by concretizing it into three forms, I created the three works. One is a picture book, which uses its illustrations to communicate the meaning of the written content, and by the last portion of it makes use of the built up knowledge to tell a simple story in comic format. Another one is a set of four postcards under the theme 'puzzle poetry', that have a poem written on their front and the key to its descipherment on the back side. The third work is a video that portrays a conversation between two, who communicate by the movement and position of wooden building blocks. These three works' concern lies in the process of language comprehension."
                ]
            ]
    , mainVisualUrl = "kotokan/main.jpg"
    , date = Date "2017"
    , tags =
        [ Tag.VisualCommunication
        , Tag.Language
        , Tag.Graphic
        , Tag.Video
        ]
    , visuals =
        [ Video
            { id = "201826714"
            , thumbnailUrl = "kotokan/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        , Image
            { url = "kotokan/book01.jpg"
            , thumbnailUrl = "kotokan/book01-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book02.jpg"
            , thumbnailUrl = "kotokan/book02-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book03.jpg"
            , thumbnailUrl = "kotokan/book03-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/postcards01.jpg"
            , thumbnailUrl = "kotokan/postcards01-thumb.jpg"
            , aspectRatio = 1920 / 1090
            }
        , Video
            { id = "199388496"
            , thumbnailUrl = "kotokan/video2-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMoreUrl = Just "http://blog.agj.cl/tag/come-to-think-of-language/"
    }
