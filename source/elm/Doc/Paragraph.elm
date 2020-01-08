module Doc.Paragraph exposing (Paragraph, content, create)

import Doc.Text exposing (Text)


type Paragraph
    = Paragraph (List Text)


content : Paragraph -> List Text
content (Paragraph texts) =
    texts


create : List Text -> Paragraph
create texts =
    Paragraph texts
