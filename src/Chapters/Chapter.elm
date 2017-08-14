module Chapters.Chapter exposing (..)

import Html exposing (..)
import Models exposing (Chapter, ChapterContent)
import View exposing (loading, viewChapter)


view :  Maybe Chapter -> Html msg
view model =
    case model of
        Nothing ->
            div []
                [ h1 [] [ loading "Loading" ]    
            ]

        Just chapter ->
            viewChapter chapter

replaceChapter : Maybe (List Chapter) -> Chapter -> Maybe (List Chapter)
replaceChapter listchapters newchapter =
    case listchapters of 
        Nothing ->
            Nothing

        Just chapters ->
            let 
                replace index chapter =
                    if (chapter.nid == newchapter.nid) then
                        newchapter
                    else
                        chapter
            in 
                Just (List.indexedMap replace chapters)