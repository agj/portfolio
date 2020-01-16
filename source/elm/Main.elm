module Main exposing (Document, Model, init, main, subscriptions, update, view)

import Browser
import Browser.Events
import CustomEl
import Data.Introduction as Introduction
import Data.Labels as Labels exposing (Labels)
import Descriptor
import Doc exposing (Doc)
import Element exposing (..)
import Element.Background as Background
import Element.Events exposing (..)
import Element.Font as Font
import Html exposing (Html)
import Http
import Language exposing (Language(..))
import Maybe.Extra
import Palette
import SaveState exposing (SaveState)
import Svg
import Svg.Attributes
import Tag exposing (Tag)
import Utils exposing (..)
import VideoEmbed
import Work exposing (..)
import Work.Date as Date exposing (Date)
import Works



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
    { language : Language
    , tag : Maybe Tag
    , viewport : Viewport
    , popupVisual : Maybe Visual
    , data : DataStatus
    }


type DataStatus
    = DataLoading
    | DataLoadError Http.Error
    | DataLoaded (List WorkLanguages)


type alias Flags =
    { languages : List String
    , viewport : { width : Int, height : Int }
    , storedState : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        saveState =
            Maybe.withDefault "" flags.storedState
                |> SaveState.load
    in
    ( { language =
            case saveState of
                Just { language } ->
                    language

                Nothing ->
                    getLanguageFromPreferred flags.languages
      , tag = Maybe.map .tag saveState |> Maybe.Extra.join
      , viewport = flags.viewport
      , popupVisual = Nothing
      , data = DataLoading
      }
    , getData
    )


getData : Cmd Msg
getData =
    Http.get
        { url = "works/data.json"
        , expect = Http.expectJson GotData Work.allWorksDecoder
        }


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
    | SelectedVisual (Maybe Visual)
    | GotViewport Viewport
    | GotData (Result Http.Error (List WorkLanguages))


type alias Viewport =
    { width : Int
    , height : Int
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedLanguage language ->
            ( { model | language = language }
            , SaveState.save { language = language, tag = model.tag }
            )

        SelectedTag tag ->
            ( { model | tag = Just tag }
            , SaveState.save { language = model.language, tag = Just tag }
            )

        SelectedVisual selection ->
            ( { model | popupVisual = selection }
            , Cmd.none
            )

        GotViewport viewport ->
            ( { model | viewport = viewport }
            , Cmd.none
            )

        GotData result ->
            case result of
                Ok data ->
                    ( { model | data = DataLoaded data }
                    , Cmd.none
                    )

                Err err ->
                    ( { model | data = DataLoadError err }
                    , Cmd.none
                    )



-- VIEW


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


view : Model -> Document Msg
view model =
    let
        labels =
            Labels.ofLanguage model.language
    in
    { title = labels.title
    , body =
        [ layout
            ([ Font.family Palette.font
             ]
                ++ (case model.popupVisual of
                        Just visual ->
                            [ inFront (viewPopupVisual model.viewport visual) ]

                        Nothing ->
                            []
                   )
            )
            (viewMain model)
        ]
    }


viewMain : Model -> Element Msg
viewMain model =
    let
        labels =
            Labels.ofLanguage model.language

        layoutSize =
            getLayoutSize model.viewport

        worksBlockWidth =
            if layoutSize == PhoneSize then
                model.viewport.width

            else
                600

        worksBlock =
            el
                [ width (px worksBlockWidth)
                , padding Palette.spaceSmall
                ]
    in
    column
        [ width <| ifElse (layoutSize == PhoneSize) fill (px 600)
        , centerX
        , inFront <| viewLanguageSelector model.language
        , paddingEach { top = Palette.spaceSmall, bottom = 0, left = 0, right = 0 }
        ]
        [ viewTop model.language model.tag
        , case model.data of
            DataLoaded data ->
                let
                    works =
                        Works.ofLanguage model.language data
                in
                worksBlock <|
                    viewWorks (worksBlockWidth - (2 * Palette.spaceSmall)) labels model.tag works

            DataLoading ->
                worksBlock <|
                    viewLoadMessage labels.loading

            DataLoadError err ->
                case err of
                    Http.BadBody msg ->
                        worksBlock <|
                            viewLoadMessage ("Data error!\n\n" ++ msg)

                    _ ->
                        worksBlock <|
                            viewLoadMessage labels.loadError
        ]


viewTop : Language -> Maybe Tag -> Element Msg
viewTop language selectedTag =
    column
        [ Font.color Palette.light
        , Background.color Palette.dark
        , paddingEach { top = Palette.spaceNormal, bottom = Palette.spaceSmall, left = 0, right = 0 }
        ]
        [ viewIntroduction (Introduction.ofLanguage SelectedTag selectedTag language)
        ]


viewLanguageSelector : Language -> Element Msg
viewLanguageSelector language =
    row
        [ spacing Palette.spaceSmallest
        , alignRight
        , paddingEach { right = Palette.spaceSmall, left = 0, top = 0, bottom = 0 }
        ]
        [ viewLanguageButton "EN" English language
        , viewLanguageButton "ES" Spanish language
        , viewLanguageButton "日" Japanese language
        ]


viewLanguageButton : String -> Language -> Language -> Element Msg
viewLanguageButton label language selectedLanguage =
    if language == selectedLanguage then
        none

    else
        el
            [ onClick (SelectedLanguage language)
            , Font.size Palette.textSizeNormal
            , width (px (fraction 2.9 Palette.textSizeNormal))
            , height (px (fraction 2.3 Palette.textSizeNormal))
            , pointer
            , Background.color Palette.highlightDark
            , Font.color Palette.light
            , mouseDown
                [ Background.color Palette.highlightLight
                , Font.color Palette.dark
                ]
            ]
            (el
                [ centerX
                , centerY
                ]
                (text label)
            )


viewIntroduction : Element Msg -> Element Msg
viewIntroduction introductionText =
    el
        [ width fill
        , paddingXY Palette.spaceNormal Palette.spaceSmaller
        , Font.size Palette.textSizeNormal
        ]
        introductionText


viewLoadMessage : String -> Element Msg
viewLoadMessage message =
    viewMessageBlock <|
        Descriptor.p
            [ Descriptor.t message
            ]


viewMessageBlock : Element Msg -> Element Msg
viewMessageBlock child =
    viewWorkBlock [] <|
        [ el
            [ paddingXY Palette.spaceNormal Palette.spaceNormal
            , width fill
            , Font.center
            ]
            child
        ]


viewPopupVisual : Viewport -> Visual -> Element Msg
viewPopupVisual viewport visual =
    let
        reservedSpace =
            fraction 3 Palette.spaceNormal

        viewportVertical =
            toFloat viewport.width / toFloat viewport.height < 1

        usableWidth =
            if viewportVertical then
                viewport.width

            else
                viewport.width - reservedSpace

        usableHeight =
            if viewportVertical then
                viewport.height - reservedSpace

            else
                viewport.height

        usableAR =
            toFloat usableWidth / toFloat usableHeight

        visualAR =
            case visual of
                Image desc ->
                    desc.aspectRatio

                Video desc ->
                    desc.aspectRatio

        visualWidth =
            if visualAR > usableAR then
                usableWidth

            else
                floor (toFloat usableHeight * visualAR)

        visualHeight =
            if visualAR < usableAR then
                usableHeight

            else
                floor (toFloat usableWidth * (1 / visualAR))

        color =
            case visual of
                Image desc ->
                    desc.color

                Video desc ->
                    desc.color

        visualEl =
            case visual of
                Image desc ->
                    image
                        [ width (px visualWidth)
                        , height (px visualHeight)
                        , centerX
                        , centerY
                        , Background.color color
                        ]
                        { src = desc.url
                        , description = ""
                        }

                Video desc ->
                    VideoEmbed.get desc visualWidth visualHeight

        closeButton =
            el
                [ width (px reservedSpace)
                , height (px reservedSpace)
                , padding <| fraction 0.3 reservedSpace
                , alignRight
                , alignTop
                , pointer
                ]
                (image [ width fill, height fill ]
                    { src = "image/icon-close-light.svg"
                    , description = " "
                    }
                )
    in
    el
        [ width fill
        , height fill
        , Background.color (transparentColor 0.8 color)
        , onClick (SelectedVisual Nothing)
        , pointer
        ]
    <|
        if viewportVertical then
            column
                [ width fill
                , height fill
                ]
                [ closeButton
                , visualEl
                ]

        else
            row
                [ width fill
                , height fill
                ]
                [ visualEl
                , closeButton
                ]



-- VIEW WORKS


viewWorks : Int -> Labels -> Maybe Tag -> List Work -> Element Msg
viewWorks blockWidth labels maybeTag works =
    let
        filteredWorks =
            case maybeTag of
                Nothing ->
                    []

                Just Tag.Any ->
                    works

                Just tag ->
                    List.filter
                        (\w -> List.member tag w.tags)
                        works
    in
    if List.isEmpty filteredWorks then
        viewLoadMessage labels.pleaseSelect

    else
        column
            [ width fill
            , spacing Palette.spaceSmall
            ]
            (List.map
                (viewWork blockWidth labels)
                filteredWorks
            )


viewWorkBlock : List (Attribute Msg) -> List (Element Msg) -> Element Msg
viewWorkBlock attrs children =
    column
        ([ width fill
         , Font.color Palette.light
         , Background.color Palette.dark
         , Font.size Palette.textSizeNormal
         ]
            ++ attrs
        )
        children


viewWork : Int -> Labels -> Work -> Element Msg
viewWork blockWidth labels work =
    viewWorkBlock
        [ inFront <| viewWorkReadMore labels work.readMore work.mainVisualColor
        , case work.readMore of
            Just _ ->
                paddingEach { bottom = 1 * Palette.textSizeNormal, top = 0, left = 0, right = 0 }

            Nothing ->
                padding 0
        ]
        [ viewWorkTitle blockWidth
            { title = work.name
            , date = work.date
            , mainVisualUrl = work.mainVisualUrl
            , mainVisualColor = work.mainVisualColor
            , icons =
                { visualCommunication = List.member Tag.VisualCommunication work.tags
                , programming = List.member Tag.Programming work.tags
                , language = List.member Tag.Language work.tags
                , learning = List.member Tag.Learning work.tags
                }
            }
        , viewWorkVisuals blockWidth work.visuals
        , viewWorkLinks work.mainVisualColor work.links
        , viewWorkDescription work.mainVisualColor work.description
        ]


viewWorkTitle : Int -> { title : String, date : Date, mainVisualUrl : String, mainVisualColor : Element.Color, icons : { visualCommunication : Bool, programming : Bool, language : Bool, learning : Bool } } -> Element Msg
viewWorkTitle blockWidth { title, date, mainVisualUrl, mainVisualColor, icons } =
    let
        mainBlock =
            column
                [ width (px blockWidth)
                , height (px blockWidth)
                , Background.image mainVisualUrl
                , CustomEl.backgroundColor mainVisualColor
                ]

        iconsBlock =
            row
                [ paddingXY Palette.spaceNormal Palette.spaceSmall
                ]
                [ viewIcon mainVisualColor "visual-communication" icons.visualCommunication
                , viewIcon mainVisualColor "programming" icons.programming
                , viewIcon mainVisualColor "language" icons.language
                , viewIcon mainVisualColor "learning" icons.learning
                ]

        gradientBlock =
            column
                [ width fill
                , alignBottom
                , paddingEach { left = Palette.spaceNormal, right = Palette.spaceNormal, top = fraction 1 Palette.textSizeLarge, bottom = 0 }
                , Background.gradient
                    { angle = 0
                    , steps =
                        [ transparentColor 0.9 mainVisualColor
                        , transparentColor 0.4 mainVisualColor
                        , transparentColor 0 mainVisualColor
                        ]
                    }
                ]

        yearBlock =
            el
                [ alignBottom
                , paddingXY 0 0
                , Font.size Palette.textSizeSmall
                , Font.glow mainVisualColor 0.5
                , Font.bold
                ]

        titleBlock =
            el
                [ alignBottom
                , paddingXY 0 Palette.spaceSmaller
                , Font.size Palette.textSizeLarge
                , Font.glow mainVisualColor 0.5
                ]
    in
    mainBlock
        [ iconsBlock
        , gradientBlock
            [ yearBlock (text <| Date.toString date)
            , titleBlock <|
                paragraph [] [ text title ]
            ]
        ]


viewIcon : Element.Color -> String -> Bool -> Element msg
viewIcon color name isVisible =
    let
        size =
            fraction 1.5 Palette.spaceNormal
    in
    case isVisible of
        True ->
            icon size color ("icon-" ++ name ++ "-light")

        False ->
            none


viewWorkVisuals : Int -> List Visual -> Element Msg
viewWorkVisuals blockWidth visuals =
    let
        perRow =
            4

        spaceBetween =
            Palette.spaceSmallest

        thumbnailSize =
            toFloat (blockWidth - (spaceBetween * (perRow - 1)))
                / perRow
                |> floor
    in
    if List.isEmpty visuals then
        none

    else
        wrappedRow
            [ spacing spaceBetween
            , width fill
            , paddingEach { top = spaceBetween, bottom = 0, left = 0, right = 0 }
            ]
            (List.map (viewVisualThumbnail thumbnailSize) visuals)


viewVisualThumbnail : Int -> Visual -> Element Msg
viewVisualThumbnail size visual =
    let
        ( thumbnailUrl, color, isVideo ) =
            case visual of
                Image desc ->
                    ( desc.thumbnailUrl, desc.color, False )

                Video desc ->
                    ( desc.thumbnailUrl, desc.color, True )
    in
    el
        ([ width (px size)
         , height (px size)
         , onClick (SelectedVisual (Just visual))
         , pointer
         , Background.color color
         ]
            ++ ifElse isVideo
                [ inFront <|
                    el
                        [ alignRight
                        , alignBottom
                        ]
                        (icon (fraction 0.3 size) color "icon-play-light")
                ]
                []
        )
        (image
            [ width (px size)
            , height (px size)
            ]
            { src = thumbnailUrl
            , description = " "
            }
        )


viewWorkLinks : Element.Color -> List Link -> Element Msg
viewWorkLinks color links =
    let
        makeLink link =
            newTabLink
                (centerX :: linkStyle color)
                { url = link.url
                , label = text link.label
                }
    in
    if List.isEmpty links then
        none

    else
        wrappedRow
            [ paddingEach { left = Palette.spaceNormal, right = Palette.spaceNormal, top = Palette.spaceNormal, bottom = 0 }
            , width fill
            ]
        <|
            List.map makeLink links


viewWorkDescription : Element.Color -> Doc -> Element Msg
viewWorkDescription color doc =
    el [ paddingXY Palette.spaceNormal Palette.spaceSmall ]
        (Descriptor.fromDoc color doc)


viewWorkReadMore : Labels -> Maybe Work.ReadMore -> Element.Color -> Element Msg
viewWorkReadMore labels readMore color =
    case readMore of
        Nothing ->
            none

        Just desc ->
            let
                label =
                    case desc.language of
                        English ->
                            labels.readMoreEnglish

                        Japanese ->
                            labels.readMoreJapanese

                        Spanish ->
                            labels.readMoreSpanish
            in
            el
                [ alignRight
                , alignBottom
                , moveDown <| 0.3 * toFloat Palette.textSizeNormal
                , moveLeft <| toFloat Palette.spaceNormal
                ]
            <|
                newTabLink (linkStyle color)
                    { url = desc.url
                    , label = text label
                    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize <|
        \w h ->
            GotViewport { width = w, height = h }



-- OTHER


linkStyle : Element.Color -> List (Element.Attribute Msg)
linkStyle backgroundColor =
    [ Background.color backgroundColor -- Palette.highlightDark
    , paddingXY
        (fraction 0.6 Palette.textSizeNormal)
        (fraction 0.4 Palette.textSizeNormal)
    , centerX
    , pointer
    , mouseDown
        [ Background.color Palette.highlightLight
        , Font.color Palette.dark
        ]
    ]


getLanguageFromPreferred : List String -> Language
getLanguageFromPreferred codes =
    codes
        |> List.map (String.left 2)
        |> List.filterMap Language.fromCode
        |> List.head
        |> Maybe.withDefault English


icon : Int -> Element.Color -> String -> Element msg
icon size color name =
    el
        [ Element.width <| px size
        , Element.height <| px size
        , Element.padding <| fraction 0.1 size
        , CustomEl.radialGradient
            [ ( 0.5, transparentColor 0.5 color )
            , ( 1, rgba 0 0 0 0 )
            ]
        ]
        (CustomEl.imageInline
            [ Element.width fill
            , Element.height fill
            ]
            { src = "image/" ++ name ++ ".svg"
            , description = " "
            }
        )
