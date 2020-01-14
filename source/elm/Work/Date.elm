module Work.Date exposing (Date, decoder, fromString, toString)

import Json.Decode as Decode exposing (Decoder, andThen, string)


type Date
    = Date String


fromString : String -> Date
fromString string =
    Date string


toString : Date -> String
toString (Date string) =
    string


decoder : Decoder Date
decoder =
    string |> andThen (fromString >> Decode.succeed)
