module Palette exposing
    ( baseColor
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
import Element
import Element.Font as Font exposing (Font)



-- COLOR


baseColor : Color
baseColor =
    Color.hsl 0 0 0.5


colorAt10 : Color -> Element.Color
colorAt10 col =
    col
        |> Color.Manipulate.lighten 0.8
        |> toElmUiColor


colorAt50 : Color -> Element.Color
colorAt50 col =
    col
        |> toElmUiColor


colorAt70 : Color -> Element.Color
colorAt70 col =
    col
        |> Color.Manipulate.darken 0.3
        |> toElmUiColor


colorAt90 : Color -> Element.Color
colorAt90 col =
    col
        |> Color.Manipulate.darken 0.5
        |> toElmUiColor



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


toElmUiColor : Color -> Element.Color
toElmUiColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Element.rgba red green blue alpha
