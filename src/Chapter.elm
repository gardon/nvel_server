module Chapter exposing (..)

import Http
import Json.Decode as Decode
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Chapter =
  { title : String
  , field_description: String
  }

viewChapter : Chapter -> Html Msg
viewChapter chapter =
  div []
    [
      h2 [] [ text chapter.title ]
    , div [] [ text chapter.field_description ]
    ]

getChapters : Model -> Cmd Msg
getChapters model =
  let
    url =
      model.backendConfig.backendURL ++ "/chapters"
  in
    Http.send ChaptersLoad (Http.get url decodeChapters)

chapterDecoder = Decode.map2 Chapter (Decode.field "title" Decode.string) (Decode.field "field_description" Decode.string)

decodeChapters : Decode.Decoder (List Chapter)
decodeChapters =
  Decode.list chapterDecoder