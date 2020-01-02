module Data.Runnerby exposing (data)

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


japanese =
    { name = "Runnerby"
    , description =
        d
            [ p
                [ t "単純な操作でありながら難しい、という目的を目指してこのゲームを作りました。壁や天井でもとどまりなく走るキャラが、スペースキーを打つと跳ねます。その操作だけを使い探検する2Dゲームです。プレイの際はまず画面をクリックし、そしてスペースバーを打ってください。"
                ]
            , p
                [ t "（プレイ動画は"
                , l "moshboy" "https://twitter.com/moshboy"
                , t "より）。"
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


spanish =
    { name = "Runnerby"
    , description =
        d
            [ p
                [ t "Un juego controlado por sólo una tecla (espacio), la cual hace saltar al personaje que nunca para de correr. Utiliza Flash. En la pantalla de título, haz click dentro del juego y luego presiona espacio para comenzar."
                ]
            , p
                [ t "Diseñado buscando sencillez en control, pero dificultad de ejecución."
                ]
            , p
                [ t "(Video por "
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
