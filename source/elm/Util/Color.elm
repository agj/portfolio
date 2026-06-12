module Util.Color exposing (setOpacity, toElmUi)

import Color exposing (Color)
import Element as Ui


toElmUi : Color -> Ui.Color
toElmUi color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Ui.rgba red green blue alpha


setOpacity : Float -> Color -> Color
setOpacity opacity color =
    let
        { red, green, blue } =
            Color.toRgba color
    in
    Color.rgba red green blue opacity
