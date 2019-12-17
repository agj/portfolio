module Main exposing (Document, Model, init, main, subscriptions, update, view)

import Browser
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Html exposing (Html)
import List.Extra exposing (..)
import Palette
import Utils exposing (..)
import Work exposing (Work)
import Works


type Msg
    = SetLanguage String
    | SetTag String


type alias Flags =
    { languages : List String }



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { selection : Maybe String
    , works : List (Work Msg)
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { selection = Nothing, works = [] }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetTag tag ->
            ( { model | selection = Just tag }, Cmd.none )

        SetLanguage language ->
            ( model, Cmd.none )



-- VIEW


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


view : Model -> Document Msg
view model =
    { title = "Portfolio"
    , body =
        [ layout [] (viewMain model) ]
    }


viewMain : Model -> Element Msg
viewMain model =
    column []
        [ column
            [ width (px 500)
            , centerX
            , padding 20
            , Font.color Palette.light
            , Background.color Palette.dark
            , Font.size Palette.textSizeNormal
            , Border.rounded (fraction 1 Palette.textSizeNormal)
            ]
            [ standardP []
                [ text "My name is "
                , el [ Font.bold ] (text "Ale Grilli")
                , text ". I’m based in Santiago, Chile. My work is concerned with various intersections of the following four areas."
                ]
            , list []
                [ linkWork "/" <| text "Visual communication"
                , linkWork "/" <| text "Programming"
                , linkWork "/" <| text "Language"
                , linkWork "/" <| text "Learning"
                ]
            , standardP []
                [ text "I’m a creator. I make "
                , linkWork "/" <| text "digital things"
                , text ", such as "
                , linkWork "/" <| text "games"
                , text " and "
                , linkWork "/" <| text "web stuff"
                , text ". I design "
                , linkWork "/" <| text "user interfaces"
                , text " and "
                , linkWork "/" <| text "graphics"
                , text ". I shoot and edit "
                , linkWork "/" <| text "videos"
                , text " on occasion."
                ]
            , standardP []
                [ text "I’m a languages nerd. I am fluent in three (Spanish, English, Japanese) and am working on a fourth (Chinese Mandarin). I do "
                , linkWork "/" <| text "translation"
                , text " work, subtitling too."
                ]
            , standardP []
                [ text "I think a lot about learning. I’ve worked for ed-tech companies programming "
                , linkWork "/" <| text "educational software"
                , text ". I occasionally "
                , linkWork "/" <| text "teach languages"
                , text "."
                ]
            , standardP []
                [ text "Select any highlighted keyword above to see examples of my work."
                ]
            ]
        , viewWorks model
        ]


viewWorks model =
    column
        [ width (px 500)
        , centerX
        , padding 20
        , Font.color Palette.light
        , Background.color Palette.dark
        , Font.size Palette.textSizeNormal
        , Border.rounded (fraction 1 Palette.textSizeNormal)
        ]
        (List.map viewWork Works.all)


viewWork : Work Msg -> Element Msg
viewWork work =
    column []
        [ text work.name
        , work.description
        ]


standardP : List (Attribute Msg) -> List (Element Msg) -> Element Msg
standardP attrs children =
    paragraph
        (attrs
            ++ [ paddingXY 0 10
               , spacing <| Palette.textLineSpacing Palette.textSizeNormal
               ]
        )
        children



-- standardLink : String ->


list : List (Attribute Msg) -> List (Element Msg) -> Element Msg
list attrs children =
    let
        toRow : Element Msg -> Element Msg
        toRow child =
            row [ spacing (fraction 0.3 Palette.textSizeNormal) ]
                [ text "→"
                , child
                ]

        rows : List (Element Msg)
        rows =
            List.map toRow children
    in
    column
        (attrs
            ++ [ paddingXY 0 10
               , spacing <| Palette.textLineSpacing Palette.textSizeNormal
               ]
        )
        rows


linkWork : String -> Element Msg -> Element Msg
linkWork tag child =
    el
        [ Background.color Palette.highlightDark
        , Font.color Palette.light
        , paddingXY 11 3
        , Border.rounded 15
        , onClick (SetTag tag)
        ]
        child



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
