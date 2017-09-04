module Chapters exposing (..)

import Models exposing (..)
import Msgs exposing (..)
import Http exposing (Header, Request)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Dict exposing (Dict)
import Resources exposing (..)


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
    url = model.backendConfig.backendURL ++ chapterContentEndpoint ++ "/" ++ chapter.nid ++ "?_format=json"
  in
    Http.send ChapterContentLoad (Http.get url chapterDecoder)


decodeChapterContent : Decode.Decoder (List Section)
decodeChapterContent =
  Decode.list sectionDecoder

chapterDecoder : Decode.Decoder Chapter
chapterDecoder = 
  decode Chapter 
      |> required "title" Decode.string
      |> required "field_description" Decode.string
      |> required "nid" Decode.string
      |> required "content" decodeChapterContent

decodeChapters : Decode.Decoder (Dict String Chapter)
decodeChapters =
  Decode.dict chapterDecoder