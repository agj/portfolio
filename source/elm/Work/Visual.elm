module Work.Visual exposing (VideoDescription, VideoHost(..), VideoParameter, Visual(..), colorDecoder, decoder, videoHostDecoder)

import Color exposing (Color)
import Json.Decode as Decode exposing (Decoder, andThen, float, list, maybe, oneOf, string)
import Json.Decode.Pipeline exposing (optional, required)


type Visual
    = Image
        { thumbnailUrl : String
        , url : String
        , aspectRatio : Float
        , color : Color
        }
    | Video VideoDescription


type alias VideoDescription =
    { thumbnailUrl : String
    , id : String
    , aspectRatio : Float
    , host : VideoHost
    , color : Color
    , parameters : List VideoParameter
    }


type VideoHost
    = Youtube
    | Vimeo


type alias VideoParameter =
    { key : String
    , value : String
    }



-- DECODERS


decoder : Decoder Visual
decoder =
    let
        imageDecoder =
            Decode.succeed (\tUrl url ar color -> Image { thumbnailUrl = tUrl, url = url, aspectRatio = ar, color = color })
                |> required "thumbnailUrl" string
                |> required "url" string
                |> required "aspectRatio" float
                |> required "color" colorDecoder

        videoDecoder =
            Decode.succeed (\tUrl id ar host color params -> Video { thumbnailUrl = tUrl, id = id, aspectRatio = ar, host = host, color = color, parameters = params })
                |> required "thumbnailUrl" string
                |> required "id" string
                |> required "aspectRatio" float
                |> required "host" videoHostDecoder
                |> required "color" colorDecoder
                |> required "parameters" parametersDecoder
    in
    oneOf
        [ imageDecoder
        , videoDecoder
        ]


videoHostDecoder : Decoder VideoHost
videoHostDecoder =
    string
        |> andThen
            (\hostString ->
                case hostString of
                    "Youtube" ->
                        Decode.succeed Youtube

                    "Vimeo" ->
                        Decode.succeed Vimeo

                    other ->
                        Decode.fail <| "Video host unknown: " ++ other
            )


colorDecoder : Decoder Color
colorDecoder =
    Decode.succeed Color.rgb
        |> required "red" float
        |> required "green" float
        |> required "blue" float


parametersDecoder : Decoder (List VideoParameter)
parametersDecoder =
    Decode.keyValuePairs string
        |> andThen
            (\list ->
                List.map (\( key, value ) -> { key = key, value = value }) list
                    |> Decode.succeed
            )
