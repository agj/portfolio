module Util.Bool exposing (ifElse)


ifElse : Bool -> a -> a -> a
ifElse check yes no =
    if check then
        yes

    else
        no
