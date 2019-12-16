module Palette exposing (dark, highlightDark, highlightLight, light, textLineSpacing, textSizeNormal)

import Element exposing (..)


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


textSizeNormal : Int
textSizeNormal =
    18


textLineSpacing : Int -> Int
textLineSpacing fontSize =
    round (toFloat fontSize * 0.4)
