module Utils exposing
    ( fraction
    , ifElse
    , sides
    , unnest
    )


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


sides =
    { left = 0
    , right = 0
    , top = 0
    , bottom = 0
    }
