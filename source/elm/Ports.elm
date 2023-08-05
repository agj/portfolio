port module Ports exposing (..)

import Json.Encode exposing (Value)



-- OUTBOUND


port saveState : String -> Cmd msg


port getViewport : () -> Cmd msg


port scrollTo : String -> Cmd msg



-- INBOUND


port gotViewport : (Value -> msg) -> Sub msg
