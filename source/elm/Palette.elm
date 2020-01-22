module Palette exposing (dark, darkish, font, highlightDark, highlightDarker, highlightLight, light, spaceNormal, spaceSmall, spaceSmaller, spaceSmallest, textLineSpacing, textSizeLarge, textSizeNormal, textSizeSmall)

import Color exposing (Color)
import Color.Manipulate
import Element
import Element.Font as Font exposing (Font)



-- COLOR


dark : Element.Color
dark =
    baseDark
        |> toElmUiColor


darkish : Element.Color
darkish =
    baseDarkish
        |> toElmUiColor


light : Element.Color
light =
    Element.rgb 0.9 0.9 0.9


highlightLight : Element.Color
highlightLight =
    baseHighlight |> toElmUiColor


highlightDark : Element.Color
highlightDark =
    baseSecondaryHighlight
        |> Color.Manipulate.darken 0.1
        |> Color.Manipulate.desaturate 0.5
        |> toElmUiColor


highlightDarker : Element.Color
highlightDarker =
    baseSecondaryHighlight
        |> Color.Manipulate.darken 0.3
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


baseHighlight : Color
baseHighlight =
    Color.rgb255 207 255 0


baseSecondaryHighlight : Color
baseSecondaryHighlight =
    Color.rgb255 255 0 204


baseDark : Color
baseDark =
    Color.rgb 0 0 0


baseDarkish : Color
baseDarkish =
    Color.rgb 0.3 0.3 0.3


toElmUiColor : Color -> Element.Color
toElmUiColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Element.rgba red green blue alpha
