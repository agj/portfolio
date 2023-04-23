module View.Icon exposing
    ( Icon
    , IconName(..)
    , icon
    , view
    )

import Element exposing (Element)
import Element.Font
import Html.Attributes
import Phosphor


type IconName
    = Language
    | VisualCommunication
    | Programming
    | Learning
    | Play


type Icon
    = Icon
        { name : IconName
        , size : Int
        }


icon : IconName -> Int -> Icon
icon name size =
    Icon { name = name, size = size }


view : Icon -> Element msg
view (Icon { name, size }) =
    let
        phosphorIcon =
            case name of
                Language ->
                    Phosphor.chatCircle

                VisualCommunication ->
                    Phosphor.eye

                Programming ->
                    Phosphor.bracketsCurly

                Learning ->
                    Phosphor.brain

                Play ->
                    Phosphor.playCircle
    in
    phosphorIcon Phosphor.Fill
        |> Phosphor.toHtml
            [ Html.Attributes.style "vertical-align" "middle"
            ]
        |> Element.html
        |> Element.el
            [ Element.Font.size size
            ]
