-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode



main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL

type alias Chapter =
  { title : String
  , field_description: String
  }

type alias Model =
  { chapters : List Chapter
  }


init : (Model, Cmd Msg)
init =
  ( Model []
  , getChapters
  )



-- UPDATE


type Msg
  = ChaptersLoad (Result Http.Error (List Chapter))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChaptersLoad (Ok chapters) ->
      ({ model | chapters = chapters } , Cmd.none)

    ChaptersLoad (Err _) ->
      (model, Cmd.none)



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ ul []
      (List.map viewChapter model.chapters)
    ]

viewChapter : Chapter -> Html Msg
viewChapter chapter =
  li []
    [
      h2 [] [ text chapter.title ]
    , div [] [ text chapter.field_description ]
    ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP


getChapters : Cmd Msg
getChapters =
  let
    url =
      "http://server.nvel.docksal/chapters"
  in
    Http.send ChaptersLoad (Http.get url decodeChapters)

chapterDecoder = Decode.map2 Chapter (Decode.field "title" Decode.string) (Decode.field "field_description" Decode.string)

decodeChapters : Decode.Decoder (List Chapter)
decodeChapters =
  Decode.list chapterDecoder
