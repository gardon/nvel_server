module Chapters exposing (..)

import Models exposing (..)
import Msgs exposing (..)
import Http exposing (Header, Request)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)


-- Http

getChapters : Model -> Cmd Msg
getChapters model =
  let
    url =
      model.backendConfig.backendURL ++ chapterListEndpoint
  in
    Http.send ChaptersLoad (Http.get url decodeChapters)

getChapterContent : Model -> Chapter -> Cmd Msg
getChapterContent model chapter = 
  let 
    url = model.backendConfig.backendURL ++ chapterContentEndpoint ++ "/" ++ chapter.nid
  in
    Http.send ChapterContentLoad (Http.get url chapterDecoder)


chapterContentDecoder : Decode.Decoder ChapterContent
chapterContentDecoder =
  decode ChapterContent
      |> required "content" Decode.string

decodeChapterContent : Decode.Decoder (List ChapterContent)
decodeChapterContent =
  Decode.list chapterContentDecoder

chapterDecoder : Decode.Decoder Chapter
chapterDecoder = 
  decode Chapter 
      |> required "title" Decode.string
      |> required "field_description" Decode.string
      |> required "nid" Decode.string
      |> hardcoded Nothing

decodeChapters : Decode.Decoder (List Chapter)
decodeChapters =
  Decode.list chapterDecoder