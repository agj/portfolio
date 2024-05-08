port module Ports exposing (getViewport, gotViewport, saveState, scrollTo, scrolledOverWork)

import Json.Decode as Decode
import Json.Encode exposing (Value)


scrolledOverWork : (Int -> msg) -> msg -> Sub msg
scrolledOverWork success error =
    scrolledOverWorkPort <|
        \value ->
            case Decode.decodeValue Decode.int value of
                Ok workIndex ->
                    success workIndex

                Err _ ->
                    error



-- OUTBOUND


port saveState : String -> Cmd msg


port getViewport : () -> Cmd msg


port scrollTo : String -> Cmd msg



-- INBOUND


port gotViewport : (Value -> msg) -> Sub msg


port scrolledOverWorkPort : (Value -> msg) -> Sub msg
