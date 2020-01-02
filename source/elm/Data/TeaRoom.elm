module Data.TeaRoom exposing (data)

import Descriptor exposing (..)
import Language exposing (..)
import Tag
import Work exposing (..)


data : WorkLanguages msg
data =
    Work.languages
        { english = english
        , japanese = japanese
        , spanish = spanish
        }


english =
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
            , thumbnailUrl = "tearoom/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMoreUrl = Just "http://blog.agj.cl/tag/the-tea-room/"
    }


japanese =
    { name = "待庵"
    , description =
        d
            [ p
                [ t "バーチャル・リアリティ・ハードウェア HTC Vive 用ソフトです。韓国芸術総合学校が主催したワークショップで、東京藝術大学からの学生７人チームによって作成。「待庵」という、千利休が設計した２畳の茶室をVRで再現し、そこにいくつかのインタラクティブ要素を仕込みました。その要素の中の一つがユーザーを異常な別空間に移動させます。"
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
            , thumbnailUrl = "tearoom/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMoreUrl = Just "http://blog.agj.cl/tag/the-tea-room/"
    }


spanish =
    { name = "The tea room"
    , description =
        d
            [ p
                [ t "Software para uso con el hardware de realidad virtual HTC Vive, creado durante un workshop de dos semanas organizado por la Universidad Nacional de Artes de Corea, con un equipo de siete estudiantes de la Universidad Nacional de Bellas Artes y Música de Tokyo. Creamos un espacio virtual basado en una pieza dedicada a la ceremonia japonesa del té, conformada por un espacio de sólo dos _tatamis,_ que fue diseñada por el maestro del té Sen no Rikyu en concordancia con su apreciación por la simpleza rústica. En el lugar hay varios elementos interactivos inesperados, uno de los cuales transporta al usuario a un entorno diferente y desconocido."
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
            , thumbnailUrl = "tearoom/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMoreUrl = Just "http://blog.agj.cl/tag/the-tea-room/"
    }
