module Chapters exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Http exposing (Header, Request)
import Json.Decode as Decode

chapterListEndpoint = "chapters"

viewChapterList : Maybe (List Chapter) -> List (Html Msg)
viewChapterList chapters = 
  case chapters of 
    Nothing -> 
        [ text "Loading chapters..."]

    Just chapters -> 
        List.map viewChapterListItem chapters


onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
      onWithOptions "click" options (Decode.succeed message)

viewChapterListItem : Chapter -> Html Msg
viewChapterListItem chapter =
  div []
    [
      h2 [] [ a [ href "/chapters/1", onLinkClick (ChangeLocation "/chapters/1") ] [ text chapter.title ] ]
    , div [] [ text chapter.field_description ]
    ]

-- Http

getChapters : Model -> Cmd Msg
getChapters model =
  let
    url =
      model.backendConfig.backendURL ++ chapterListEndpoint
  in
    Http.send ChaptersLoad (Http.get url decodeChapters)

chapterDecoder = 
  Decode.field "field_description" Decode.string
    |> Decode.map2 Chapter (Decode.field "title" Decode.string)

decodeChapters : Decode.Decoder (List Chapter)
decodeChapters =
  Decode.list chapterDecoder