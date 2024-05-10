module VideoEmbed exposing (get)

import Element as Ui exposing (Element)
import Element.Background as UiBackground
import Html exposing (..)
import Html.Attributes exposing (..)
import Palette
import Util.Color as Color
import Utils exposing (..)
import View.CssSvg as CssSvg
import Work.Visual exposing (VideoDescription, VideoHost(..), VideoParameter)


get : VideoDescription -> Int -> Int -> Element msg
get desc width height =
    let
        makeElement theSrc =
            iframe
                [ src theSrc
                , attribute "frameborder" "0"
                , attribute "allowfullscreen" "allowfullscreen"
                , style "width" "100%"
                , style "height" "100%"
                ]
                []
                |> Ui.html
    in
    Ui.el
        [ Ui.centerX
        , Ui.centerY
        , Ui.width (Ui.px width)
        , Ui.height (Ui.px height)
        , UiBackground.color (desc.color |> Color.toElmUi)
        , Html.Attributes.class "popup-visual"
            |> Ui.htmlAttribute
        , Html.Attributes.style "background-image" (CssSvg.patternAngles (Palette.colorAt60 desc.color))
            |> Ui.htmlAttribute
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
                makeElement
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
                makeElement
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
