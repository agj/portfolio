module SaveState exposing (SaveState, load, save)

import Json.Decode as Decode exposing (Decoder, maybe)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Language exposing (Language)
import Ports
import Tag exposing (Tag)


type alias SaveState =
    { language : Language
    , tag : Maybe Tag
    }


save : SaveState -> Cmd msg
save state =
    Encode.object
        [ ( "language", Language.encoder state.language )
        , ( "tag", Tag.encoder state.tag )
        ]
        |> Encode.encode 0
        |> Ports.saveState


load : String -> Maybe SaveState
load json =
    case Decode.decodeString saveStateDecoder json of
        Ok state ->
            Just state

        Err _ ->
            Nothing



-- INTERNAL


saveStateDecoder : Decoder SaveState
saveStateDecoder =
    Decode.succeed SaveState
        |> required "language" Language.decoder
        |> optional "tag" (maybe Tag.decoder) Nothing
