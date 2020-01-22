module Data.Settings exposing (Settings, forFormat)

import LayoutFormat exposing (LayoutFormat(..))


type alias Settings =
    { mainVisualAspectRatio : Float
    , worksBlockWidth : Maybe Int
    , thumbnailsPerRow : Int
    }


forFormat : LayoutFormat -> Settings
forFormat format =
    case format of
        PhoneLayout ->
            phone

        DesktopLayout ->
            desktop



-- INTERNAL


phone : Settings
phone =
    { mainVisualAspectRatio = 1
    , worksBlockWidth = Nothing
    , thumbnailsPerRow = 3
    }


desktop : Settings
desktop =
    { mainVisualAspectRatio = 1.77
    , worksBlockWidth = Just 600
    , thumbnailsPerRow = 5
    }
