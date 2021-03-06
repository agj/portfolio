module Doc.Text exposing (Text, content, create, format)

import Doc.Format exposing (Format)


type Text
    = Text
        { content : String
        , format : Format
        }


content : Text -> String
content (Text text) =
    text.content


format : Text -> Format
format (Text text) =
    text.format


create : Format -> String -> Text
create fmt cnt =
    Text { content = cnt, format = fmt }
