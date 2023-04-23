module Palette exposing
    ( baseColor
    , baseColorAt10
    , baseColorAt50
    , baseColorAt70
    , baseColorAt90
    , colorAt10
    , colorAt50
    , colorAt70
    , colorAt90
    , font
    , spaceLarge
    , spaceNormal
    , spaceSmall
    , spaceSmaller
    , spaceSmallest
    , textLineSpacing
    , textSizeLarge
    , textSizeNormal
    , textSizeSmall
    )

import Color exposing (Color)
import Color.Manipulate
import Element.Font as Font exposing (Font)
import Util.Color as Color



-- COLOR


colorAt10 : Color -> Color
colorAt10 col =
    col
        |> lighten 0.9


colorAt50 : Color -> Color
colorAt50 col =
    col


colorAt70 : Color -> Color
colorAt70 col =
    col
        |> darken 0.5


colorAt90 : Color -> Color
colorAt90 col =
    col
        |> darken 0.8


baseColor : Color
baseColor =
    Color.hsl 0.88 1 0.4


baseColorAt10 : Color
baseColorAt10 =
    colorAt10 baseColor


baseColorAt50 : Color
baseColorAt50 =
    colorAt50 baseColor


baseColorAt70 : Color
baseColorAt70 =
    colorAt70 baseColor


baseColorAt90 : Color
baseColorAt90 =
    colorAt90 baseColor



-- TEXT


font : List Font
font =
    [ Font.typeface "mplus-1p"
    , Font.sansSerif
    ]


textSizeSmall : Int
textSizeSmall =
    11


textSizeNormal : Int
textSizeNormal =
    14


textSizeLarge : Int
textSizeLarge =
    24


textLineSpacing : Int -> Int
textLineSpacing fontSize =
    round (toFloat fontSize * 0.6)



-- SPACING


spaceLarge : Int
spaceLarge =
    26


spaceNormal : Int
spaceNormal =
    20


spaceSmall : Int
spaceSmall =
    10


spaceSmaller : Int
spaceSmaller =
    5


spaceSmallest : Int
spaceSmallest =
    2



-- INTERNAL


lighten : Float -> Color -> Color
lighten amount color =
    color
        |> Color.Manipulate.scaleHsl
            { saturationScale = 0
            , lightnessScale = amount
            , alphaScale = 0
            }


darken : Float -> Color -> Color
darken amount color =
    lighten -amount color
