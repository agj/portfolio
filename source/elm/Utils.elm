module Utils exposing (fraction, ifElse, sides, toCssColor, transparentColor, unnest)

import Element


fraction : Float -> Int -> Int
fraction frac num =
    round (frac * toFloat num)


ifElse : Bool -> a -> a -> a
ifElse check yes no =
    if check then
        yes

    else
        no


unnest : List (List a) -> List a
unnest list =
    List.concatMap identity list


toCssColor : Element.Color -> String
toCssColor color =
    let
        { red, green, blue, alpha } =
            Element.toRgb color
    in
    "rgba("
        ++ String.fromInt (round <| red * 255)
        ++ ", "
        ++ String.fromInt (round <| green * 255)
        ++ ", "
        ++ String.fromInt (round <| blue * 255)
        ++ ", "
        ++ String.fromFloat (alpha * 100)
        ++ "%"
        ++ ")"


transparentColor : Float -> Element.Color -> Element.Color
transparentColor opacity color =
    let
        { red, green, blue } =
            Element.toRgb color
    in
    Element.rgba red green blue opacity


sides =
    { left = 0
    , right = 0
    , top = 0
    , bottom = 0
    }
