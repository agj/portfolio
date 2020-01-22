module LayoutFormat exposing (..)


type LayoutFormat
    = PhoneLayout
    | DesktopLayout


fromDimensions : { width : Int, height : Int } -> LayoutFormat
fromDimensions { width } =
    if width < 600 then
        PhoneLayout

    else
        DesktopLayout
