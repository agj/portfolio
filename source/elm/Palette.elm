module Palette exposing (..)

import Element exposing (..)



-- COLOR


dark : Color
dark =
    rgb 0.1 0.1 0.1


light : Color
light =
    rgb 0.9 0.9 0.9


highlightLight : Color
highlightLight =
    rgb 1 0.5 1


highlightDark : Color
highlightDark =
    rgb 0.5 0 0.5



-- TEXT


textSizeNormal : Int
textSizeNormal =
    18


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


spaceSmall =
    10


spaceSmaller =
    5


spaceSmallest =
    2
