module View.CssSvg exposing (patternAngles, patternOverlappingCircles)

import Color exposing (Color)
import Regex exposing (Regex)
import Url


patternOverlappingCircles : Color -> String
patternOverlappingCircles color =
    """
    <path
        fill="{color}"
        d="
            M 0,6
            A 6,6 0,0,0 6,0
            A 6,6 0,0,0 0,6
            M 6,0
            A 6,6 0,0,0 12,6
            A 6,6 0,0,0 6,0
            M 12,6
            A 6,6 0,0,0 6,12
            A 6,6 0,0,0 12,6
            M 6,12
            A 6,6 0,0,0 0,6
            A 6,6 0,0,0 6,12
        "
    />
    """
        |> String.replace "{color}" (Color.toCssString color)
        |> in12x12Svg


patternAngles : Color -> String
patternAngles color =
    """
    <path
        fill="{color}"
        d="
            M 0,6
            L 12,0
            L 12,6
            L 0,12
            Z
        "
    />
    """
        |> String.replace "{color}" (Color.toCssString color)
        |> in12x12Svg



-- INTERNAL


in12x12Svg : String -> String
in12x12Svg nodes =
    """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12">
        {nodes}
    </svg>
    """
        |> String.replace "{nodes}" nodes
        |> wrap


wrap : String -> String
wrap svg =
    let
        svgEncoded =
            svg
                |> String.trim
                |> regexReplace "\\s+" " "
                |> Url.percentEncode
    in
    "url('data:image/svg+xml,{svg}')"
        |> String.replace "{svg}" svgEncoded


regexReplace : String -> String -> String -> String
regexReplace regexString replacement text =
    let
        regex =
            Regex.fromString regexString
                |> Maybe.withDefault Regex.never
    in
    Regex.replace regex (\_ -> replacement) text
