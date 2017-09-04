module Chapters.Chapter exposing (..)

import Html exposing (..)
import Models exposing (Model, Chapter)
import View exposing (loading, viewChapter)
import Dict exposing (Dict)


view :  Maybe Chapter -> Html msg
view model =
    case model of
        Nothing ->
            div []
                [ h1 [] [ loading "Loading" ]    
            ]

        Just chapter ->
            viewChapter chapter

replaceChapter : Model -> Chapter -> Model
replaceChapter model newchapter =
    case model.chapters of 
        Nothing ->
            { model | chapters = Just (Dict.singleton newchapter.nid newchapter) }

        Just chapters ->
            { model | chapters = Just (Dict.insert newchapter.nid newchapter chapters) } 