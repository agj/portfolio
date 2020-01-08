module Doc.Format exposing (Format, create, isBold, isItalic, link, setBold, setItalic, setLink)

import Doc.Link exposing (Link)


type Format
    = Format
        { bold : Bool
        , italic : Bool
        , link : Maybe Link
        }


isBold : Format -> Bool
isBold (Format format) =
    format.bold


isItalic : Format -> Bool
isItalic (Format format) =
    format.italic


link : Format -> Maybe Link
link (Format format) =
    format.link


create : Format
create =
    Format
        { bold = False
        , italic = False
        , link = Nothing
        }


setBold : Bool -> Format -> Format
setBold status (Format format) =
    Format { format | bold = status }


setItalic : Bool -> Format -> Format
setItalic status (Format format) =
    Format { format | italic = status }


setLink : Maybe Link -> Format -> Format
setLink maybeLink (Format format) =
    Format { format | link = maybeLink }
