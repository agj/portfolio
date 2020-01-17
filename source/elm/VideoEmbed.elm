module VideoEmbed exposing (get)

import Element exposing (Element)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils exposing (..)
import Work.Visual exposing (VideoDescription, VideoHost(..), VideoParameter)


get : VideoDescription -> Int -> Int -> Element msg
get desc width height =
    let
        color =
            toCssColor desc.color

        standard fixedSrc =
            Element.html <|
                iframe
                    [ src fixedSrc
                    , attribute "frameborder" "0"
                    , attribute "allowfullscreen" "allowfullscreen"
                    , style "width" (String.fromInt width ++ "px")
                    , style "height" (String.fromInt height ++ "px")
                    , style "background-color" color
                    ]
                    []
    in
    Element.el
        [ Element.centerX
        , Element.centerY
        ]
        (case desc.host of
            Vimeo ->
                let
                    params =
                        [ { key = "color", value = "ffffff" }
                        , { key = "title", value = "0" }
                        , { key = "byline", value = "0" }
                        , { key = "portrait", value = "0" }
                        , { key = "autoplay", value = "1" }
                        ]
                in
                standard
                    ("https://player.vimeo.com/video/"
                        ++ desc.id
                        ++ "?"
                        ++ parseParameters (params ++ desc.parameters)
                    )

            Youtube ->
                let
                    params =
                        [ { key = "rel", value = "0" }
                        , { key = "autoplay", value = "1" }
                        , { key = "color", value = "white" }
                        ]
                in
                standard
                    ("https://www.youtube-nocookie.com/embed/"
                        ++ desc.id
                        ++ "?"
                        ++ parseParameters (params ++ desc.parameters)
                    )
        )



-- INTERNAL


parseParameters : List VideoParameter -> String
parseParameters params =
    let
        toString param =
            param.key
                ++ "="
                ++ param.value
    in
    params
        |> List.map toString
        |> String.join "&"
