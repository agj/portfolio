module Data.Kotokan exposing (data)

import Descriptor exposing (..)
import Language exposing (..)
import Tag
import Work exposing (..)


data : WorkLanguages msg
data =
    Work.languages
        { english = english
        , japanese = japanese
        , spanish = spanish
        }


english =
    { name = "Come to think of language"
    , description =
        d
            [ p
                [ t "Utilizing a _constructed language_ as their material, I created three works. Graduation project for the Tokyo University of the Arts' New Media master's degree."
                ]
            , p
                [ t "Taking inspiration in the idea that language and thought are intimately related, I undertook this linguistic experiment. I first created a very essential base language —a 'meta-language,'— and by concretizing it into three forms, I created the three works. One is a picture book, which uses its illustrations to communicate the meaning of the written content, and by the last portion of it makes use of the built up knowledge to tell a simple story in comic format. Another one is a set of four postcards under the theme 'puzzle poetry', that have a poem written on their front and the key to its descipherment on the back side. The third work is a video that portrays a conversation between two, who communicate by the movement and position of wooden building blocks. These three works' concern lies in the process of language comprehension."
                ]
            ]
    , mainVisualUrl = "kotokan/main.jpg"
    , date = Date "2017"
    , tags =
        [ Tag.VisualCommunication
        , Tag.Language
        , Tag.Graphic
        , Tag.Video
        ]
    , visuals =
        [ Video
            { id = "201826714"
            , thumbnailUrl = "kotokan/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        , Image
            { url = "kotokan/book01.jpg"
            , thumbnailUrl = "kotokan/book01-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book02.jpg"
            , thumbnailUrl = "kotokan/book02-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book03.jpg"
            , thumbnailUrl = "kotokan/book03-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/postcards01.jpg"
            , thumbnailUrl = "kotokan/postcards01-thumb.jpg"
            , aspectRatio = 1920 / 1090
            }
        , Video
            { id = "199388496"
            , thumbnailUrl = "kotokan/video2-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMore =
        Just
            { url = "http://blog.agj.cl/tag/come-to-think-of-language/"
            , language = English
            }
    }


japanese =
    { name = "ことばから考えてみると"
    , description =
        d
            [ p
                [ t "一つの「人工言語」を素材にして、３つの作品を作りました。東京藝術大学映像研究科メディア映像専攻の修了制作です。"
                ]
            , p
                [ t "「言語と思考が繋がっている」を前提にし、言語で実験してみました。まず基礎的な、基盤のような「メタ言語」を作成し、その言語を３つの形で３つの作品を作りました。絵本は挿絵で言葉の意味を表し、後半はその語彙を漫画という形で利用し物語にします。「パズル・ポエトリー」をテーマに、４枚のポストカードに「詩」を書き、その裏面に詩の意味を解読できるように語彙表が書いてあります。映像で積み木の積み方によって会話をする二人の一場面を描きました。この３つの作品はことばから意味を読み取るプロセスに焦点を当てています。"
                ]
            ]
    , mainVisualUrl = "kotokan/main.jpg"
    , date = Date "2017"
    , tags =
        [ Tag.VisualCommunication
        , Tag.Language
        , Tag.Graphic
        , Tag.Video
        ]
    , visuals =
        [ Video
            { id = "201826714"
            , thumbnailUrl = "kotokan/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        , Image
            { url = "kotokan/book01.jpg"
            , thumbnailUrl = "kotokan/book01-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book02.jpg"
            , thumbnailUrl = "kotokan/book02-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book03.jpg"
            , thumbnailUrl = "kotokan/book03-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/postcards01.jpg"
            , thumbnailUrl = "kotokan/postcards01-thumb.jpg"
            , aspectRatio = 1920 / 1090
            }
        , Video
            { id = "199388496"
            , thumbnailUrl = "kotokan/video2-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMore =
        Just
            { url = "http://blog.agj.cl/2017/04/kotoba-kara-kangaete-miru-to/"
            , language = Japanese
            }
    }


spanish =
    { name = "Pensando en el lenguaje"
    , description =
        d
            [ p
                [ t "Con un _lenguaje artificial_ como material, creé tres obras. Proyecto de graduación del magíster de nuevos medios en Tokyo University of the Arts."
                ]
            , p
                [ t "Realicé este experimento partiendo con el supuesto de que el lenguaje y el pensamiento están íntimamente vinculados. Primero creé un lenguaje elemental, una especie de cimiento lingüístico o 'metalenguaje', y dándole tres formas concretas distintas creé tres obras. La primera, un libro ilustrado, utiliza ilustraciones para inicialmente comunicar su léxico, y acaba haciendo uso de ese vocabulario para contar una historia en formato cómic. Cuatro postales de temática “poesía-puzzle” tienen cada cual en su anverso un poema, y en el reverso la leyenda que permite descifrar el significado del primero. La tercera obra es un video que presenta a dos personajes en una situación simple, que conversan por medio de la ubicación de cubos de madera en distintas posiciones. Con estas tres obras quise poner en foco el proceso de comprensión del lenguaje."
                ]
            ]
    , mainVisualUrl = "kotokan/main.jpg"
    , date = Date "2017"
    , tags =
        [ Tag.VisualCommunication
        , Tag.Language
        , Tag.Graphic
        , Tag.Video
        ]
    , visuals =
        [ Video
            { id = "201826714"
            , thumbnailUrl = "kotokan/video1-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        , Image
            { url = "kotokan/book01.jpg"
            , thumbnailUrl = "kotokan/book01-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book02.jpg"
            , thumbnailUrl = "kotokan/book02-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/book03.jpg"
            , thumbnailUrl = "kotokan/book03-thumb.jpg"
            , aspectRatio = 3693 / 2294
            }
        , Image
            { url = "kotokan/postcards01.jpg"
            , thumbnailUrl = "kotokan/postcards01-thumb.jpg"
            , aspectRatio = 1920 / 1090
            }
        , Video
            { id = "199388496"
            , thumbnailUrl = "kotokan/video2-thumb.jpg"
            , aspectRatio = 640 / 360
            , host = Vimeo
            }
        ]
    , links = []
    , readMore =
        Just
            { url = "http://blog.agj.cl/tag/come-to-think-of-language/"
            , language = English
            }
    }
