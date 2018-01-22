module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (ChapterId, Route(..), Model)
import Msgs exposing (Msg)
import UrlParser exposing (..)
import Html exposing (text, Html)
import View exposing (viewChapterList, viewHome)
import Chapters.Chapter exposing (view)
import Dict exposing (Dict)

matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map ChapterRoute (s "chapters" </> string)
        , map ChaptersRoute (s "chapters")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

routeContent : Model -> List (Html Msg)
routeContent model = case model.route of 
      HomeRoute ->
        viewHome model.chapters

      ChaptersRoute ->
        viewChapterList model.chapters

      ChapterRoute id ->
        let chapter = 
          case model.chapters of 
            Nothing -> 
              Nothing
            Just chapters ->
              Dict.get id chapters
          
        in
          [ Chapters.Chapter.view chapter ]

      NotFoundRoute ->
        [ text "Not Found" ]