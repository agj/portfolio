module Main exposing (Document, Model, init, main, subscriptions, update, view)

import Browser
import Browser.Events
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Html exposing (Html)
import Language exposing (Language(..))
import List.Extra exposing (..)
import Palette
import Tag exposing (Tag)
import Utils exposing (..)
import Work exposing (..)
import Works



-- MAIN


type alias Flags =
    { languages : List String
    , viewport : { width : Int, height : Int }
    }


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
    { language : Language
    , tag : Maybe Tag
    , works : List (Work Msg)
    , layoutSize : LayoutSize
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { language = English
      , tag = Nothing
      , works = Works.all
      , layoutSize = getLayoutSize flags.viewport
      }
    , Cmd.none
    )


getLayoutSize : Viewport -> LayoutSize
getLayoutSize viewport =
    if viewport.width < 600 then
        PhoneSize

    else
        DesktopSize


type LayoutSize
    = PhoneSize
    | DesktopSize



-- UPDATE


type Msg
    = SelectedLanguage Language
    | SelectedTag Tag
    | GotViewport Viewport


type alias Viewport =
    { width : Int
    , height : Int
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedLanguage language ->
            ( model, Cmd.none )

        SelectedTag tag ->
            ( { model | tag = Just tag }
            , Cmd.none
            )

        GotViewport viewport ->
            ( { model | layoutSize = getLayoutSize viewport }
            , Cmd.none
            )



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
    column
        [ width <|
            if model.layoutSize == PhoneSize then
                fill

            else
                px 600
        , centerX
        ]
        [ viewIntroduction
        , viewWorks model
        ]


viewIntroduction : Element Msg
viewIntroduction =
    column
        [ width fill
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
            [ linkTag Tag.VisualCommunication <| text "Visual communication"
            , linkTag Tag.Programming <| text "Programming"
            , linkTag Tag.Language <| text "Language"
            , linkTag Tag.Learning <| text "Learning"
            ]
        , standardP []
            [ text "I’m a creator. I make "
            , linkTag Tag.Digital <| text "digital things"
            , text ", such as "
            , linkTag Tag.VideoGame <| text "games"
            , text " and "
            , linkTag Tag.Web <| text "web stuff"
            , text ". I design "
            , linkTag Tag.UserInterface <| text "user interfaces"
            , text " and "
            , linkTag Tag.Graphic <| text "graphics"
            , text ". I shoot and edit "
            , linkTag Tag.Video <| text "videos"
            , text " on occasion."
            ]
        , standardP []
            [ text "I’m a languages nerd. I am fluent in three (Spanish, English, Japanese) and am working on a fourth (Chinese Mandarin). I do "
            , linkTag Tag.Translation <| text "translation"
            , text " work, subtitling too."
            ]
        , standardP []
            [ text "I think a lot about learning. I’ve worked for ed-tech companies programming "
            , linkTag Tag.EducationalSoftware <| text "educational software"
            , text ". I occasionally "
            , linkTag Tag.LanguageTeaching <| text "teach languages"
            , text "."
            ]
        , standardP []
            [ text "Select any highlighted keyword above to see examples of my work."
            ]
        ]


viewWorks : { a | tag : Maybe Tag, works : List (Work Msg) } -> Element Msg
viewWorks model =
    let
        works =
            case model.tag of
                Nothing ->
                    []

                Just tag ->
                    List.filter
                        (\w -> List.member tag w.tags)
                        model.works
    in
    column
        [ width fill
        , padding 20
        , Font.color Palette.light
        , Background.color Palette.dark
        , Font.size Palette.textSizeNormal
        , Border.rounded (fraction 1 Palette.textSizeNormal)
        ]
        (List.map viewWork works)


viewWork : Work Msg -> Element Msg
viewWork work =
    column []
        [ viewWorkTitle work.name
        , viewWorkVisuals work.visuals
        , work.description
        ]


viewWorkTitle : String -> Element Msg
viewWorkTitle title =
    el
        [ Font.size Palette.textSizeLarge
        ]
        (text title)


viewWorkVisuals : List Visual -> Element Msg
viewWorkVisuals visuals =
    row []
        (List.map viewVisualThumbnail visuals)


viewVisualThumbnail : Visual -> Element Msg
viewVisualThumbnail visual =
    let
        thumbnail src =
            image
                [ width (px 40)
                , spacing 5
                ]
                { src = "works/" ++ src
                , description = "thumbnail"
                }
    in
    case visual of
        Image desc ->
            link []
                { url = desc.url
                , label = thumbnail desc.thumbnailUrl
                }

        Video desc ->
            link []
                { url = desc.url
                , label = thumbnail desc.thumbnailUrl
                }


standardP : List (Attribute Msg) -> List (Element Msg) -> Element Msg
standardP attrs children =
    paragraph
        (attrs
            ++ [ paddingXY 0 10
               , spacing <| Palette.textLineSpacing Palette.textSizeNormal
               ]
        )
        children


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


linkTag : Tag -> Element Msg -> Element Msg
linkTag tag child =
    el
        [ Background.color Palette.highlightDark
        , Font.color Palette.light
        , paddingXY 11 3
        , Border.rounded 15
        , onClick (SelectedTag tag)
        ]
        child



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize <|
        \w h ->
            GotViewport { width = w, height = h }
