module CustomEl exposing (backgroundColor, imageInline, inlineCenter, radialGradient, svgFilter)

import Debug
import Element exposing (..)
import Html.Attributes as Attributes
import Utils exposing (..)


backgroundColor : Element.Color -> Element.Attribute msg
backgroundColor color =
    style "background-color" (toCssColor color)


svgFilter : String -> Element.Attribute msg
svgFilter id =
    style "filter" ("url(#" ++ id ++ ")")


imageInline : List (Element.Attribute msg) -> { src : String, description : String } -> Element msg
imageInline attrs desc =
    image
        ([ style "display" "inline-flex"
         ]
            ++ attrs
        )
        desc


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
    -- style "background" "radial-gradient(closest-side, rgba(0, 0, 0, 100%) 0%, rgba(255, 255, 255, 0) 100%)"
    Debug.log "style"
        (style "background" <|
            "radial-gradient(closest-side, "
                ++ String.join ", " processedColors
                ++ ")"
        )



-- INTERNAL


style : String -> String -> Element.Attribute msg
style attribute value =
    Element.htmlAttribute <| Attributes.style attribute value
