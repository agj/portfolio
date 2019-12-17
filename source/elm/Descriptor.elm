module Descriptor exposing (d, l, p, t)

import Element exposing (..)
import Palette


p : List (Element msg) -> Element msg
p children =
    paragraph
        [ paddingXY 0 10
        , spacing <| Palette.textLineSpacing Palette.textSizeNormal
        ]
        children


l : String -> String -> Element msg
l label url =
    link []
        { label = text label
        , url = url
        }


t =
    text


d =
    column []
