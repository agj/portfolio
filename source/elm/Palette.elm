module Palette exposing (dark, highlightDark, highlightDarker, highlightLight, light, spaceNormal, spaceSmall, spaceSmaller, spaceSmallest, textLineSpacing, textSizeLarge, textSizeNormal, textSizeSmall)

import Color exposing (Color)
import Color.Manipulate
import Element



-- COLOR


dark : Element.Color
dark =
    Element.rgb 0.1 0.1 0.1


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
    round (toFloat fontSize * 0.4)



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


toElmUiColor : Color -> Element.Color
toElmUiColor color =
    let
        { red, green, blue } =
            Color.toRgba color
    in
    Element.rgb red green blue
