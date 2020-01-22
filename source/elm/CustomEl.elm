module CustomEl exposing (backgroundColor, glow, imageInline, inlineCenter, radialGradient, style, svgFilter)

import Element exposing (..)
import Html.Attributes as Attributes
import Utils exposing (..)



-- ELEMENTS


imageInline : List (Element.Attribute msg) -> { src : String, description : String } -> Element msg
imageInline attrs desc =
    image
        ([ style "display" "inline-flex"
         ]
            ++ attrs
        )
        desc



-- ATTRIBUTES


backgroundColor : Element.Color -> Element.Attribute msg
backgroundColor color =
    style "background-color" (toCssColor color)


svgFilter : String -> Element.Attribute msg
svgFilter id =
    style "filter" ("url(#" ++ id ++ ")")


inlineCenter : Element.Attribute msg
inlineCenter =
    style "vertical-align" "middle"


radialGradient : List ( Float, Element.Color ) -> Element.Attribute msg
radialGradient colors =
    let
        process ( position, color ) =
            toCssColor color
                ++ " "
                ++ String.fromFloat (position * 100.0)
                ++ "%"

        processedColors =
            List.map process colors
    in
    style "background" <|
        "radial-gradient(closest-side, "
            ++ String.join ", " processedColors
            ++ ")"


glow : { color : Element.Color, strength : Float, size : Float } -> Element.Attribute msg
glow { color, strength, size } =
    let
        colorCss =
            toCssColor color

        value =
            "0 0 "
                ++ String.fromFloat size
                ++ "px "
                ++ colorCss
    in
    style "text-shadow" <|
        String.join ", "
            (List.repeat (max 1 (round strength)) value)


style : String -> String -> Element.Attribute msg
style attribute value =
    Element.htmlAttribute <| Attributes.style attribute value
