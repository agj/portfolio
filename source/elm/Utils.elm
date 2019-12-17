module Utils exposing (fraction)

import Element exposing (..)
import Palette


fraction : Float -> Int -> Int
fraction frac num =
    round (frac * toFloat num)
