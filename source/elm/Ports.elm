port module Ports exposing (..)


port saveState : String -> Cmd msg


port onScroll : (Bool -> msg) -> Sub msg
