module Utils exposing (fraction)


fraction : Float -> Int -> Int
fraction frac num =
    round (frac * toFloat num)
