module VideoEmbed exposing (get)

import Element exposing (Element)
import Html exposing (..)
import Html.Attributes exposing (..)
import Work exposing (VideoDescription, VideoHost(..))


get : VideoDescription -> Int -> Int -> Element msg
get desc width height =
    let
        standard fixedSrc =
            Element.html <|
                iframe
                    [ src fixedSrc
                    , attribute "frameborder" "0"
                    , attribute "allowfullscreen" "allowfullscreen"
                    , style "width" (String.fromInt width ++ "px")
                    , style "height" (String.fromInt height ++ "px")
                    ]
                    []
    in
    Element.el
        [ Element.centerX
        , Element.centerY
        ]
        (case desc.host of
            Vimeo ->
                standard ("https://player.vimeo.com/video/" ++ desc.id ++ "?color=ffffff&title=0&byline=0&portrait=0")

            Youtube ->
                standard ("https://www.youtube-nocookie.com/embed/" ++ desc.id ++ "?rel=0&showinfo=0")
        )
