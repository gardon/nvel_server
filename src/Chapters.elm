module Chapters exposing (..)

import Models exposing (..)
import Msgs exposing (..)
import Http exposing (Header, Request)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Dict exposing (Dict)
import List exposing (..)
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
      |> required "index" Decode.int
      |> required "thumbnail" imageDecoder
      |> required "authors" (Decode.list Decode.string)
      |> required "publication_date" dateDecoder
      |> required "featured_image" imageDecoder

decodeChapters : Decode.Decoder (Dict String Chapter)
decodeChapters =
  Decode.dict chapterDecoder

zoomImage : Model -> String -> Int -> Model
zoomImage model chapter section = 
  case model.chapters of 
    Nothing -> 
      model
    Just chapters ->
      { model | chapters = Dict.update chapter (zoomImageSection section) chapters |> Just }

zoomImageSection : Int -> Maybe Chapter -> Maybe Chapter
zoomImageSection index chapter =
  case chapter of 
    Nothing ->
      Nothing
    Just chapter ->
    let 
      content = chapter.content
      section = drop (index-1) content 
      |> head
    in
      case section of 
        Nothing ->
          Just chapter
        Just section ->
          let newsection = 
            if section.zoomed == True then
              { section | zoomed = False }
            else
              { section | zoomed = True }
          in 
            { chapter | content = concat [ take (index-1) content, [ newsection ], drop index content ] } |> Just
