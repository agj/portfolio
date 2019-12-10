module Main exposing (Document, Model, init, main, subscriptions, update, view)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (..)



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
    { }


type alias Flags =
    { languages : List String }


languageCodes =
    Dict.fromList
        [ ( "en", English )
        ]


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        systemLanguage =
            flags.languages
                |> List.map (String.left 2)
                |> find (\s -> Dict.member s languageCodes)
                |> Maybe.andThen (\lc -> Dict.get lc languageCodes)
                |> Maybe.withDefault English
    in
    ( Model systemLanguage systemLanguage, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLanguage newLanguage ->
            ( if newLanguage /= model.language then
                Model newLanguage model.language

              else
                model
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
        content = getContent model.language
    in
    { title = content.title
    , body =
        [ article [ class "container", lang "en" ]
            [ nav [ class "language-selection" ]
                [ languageButton model English "english"
                , languageButton model Spanish "spanish"
                , languageButton model Japanese "japanese"
                ]
            , content.intro
            ]
        ]
    }


languageButton : Model -> Language -> String -> Html Msg
languageButton model language languageName =
    let
        exits =
            model.language

        enters =
            model.previousLanguage

        position =
            case language of
                English ->
                    1

                Spanish ->
                    if (exits == Japanese) || ((exits == Spanish) && (enters == Japanese)) then
                        0

                    else
                        1

                Japanese ->
                    0

        adjusted =
            (language == Spanish)
                && ((enters == English && exits == Japanese)
                        || (enters == Japanese && exits == English)
                   )
    in
    div
        [ classList
            [ ( "language", True )
            , ( "language-" ++ languageName, True )
            , ( "selected", model.language == language )
            , ( "adjusted", adjusted )
            , ( "position-" ++ String.fromInt position, True )
            ]
        , onClick (SetLanguage language)
        ]
        [ text ""
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
