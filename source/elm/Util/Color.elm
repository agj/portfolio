module Util.Color exposing (..)

import Color exposing (Color)
import Element


toElmUi : Color -> Element.Color
toElmUi color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Element.rgba red green blue alpha


setOpacity : Float -> Color -> Color
setOpacity opacity color =
    let
        { red, green, blue } =
            Color.toRgba color
    in
    Color.rgba red green blue opacity
