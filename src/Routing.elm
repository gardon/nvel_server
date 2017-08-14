module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (ChapterId, Route(..), Model)
import Msgs exposing (Msg)
import UrlParser exposing (..)
import Html exposing (text, Html)
import View exposing (viewChapterList)
import Chapters.Chapter exposing (view)

matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map ChaptersRoute top
        , map ChapterRoute (s "chapters" </> int)
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
      ChaptersRoute ->
        viewChapterList model.chapters

      ChapterRoute id ->
        let chapter = 
          case model.chapters of 
            Nothing -> 
              Nothing
            Just chapters ->
              List.head chapters
        in
          [ Chapters.Chapter.view chapter ]

      NotFoundRoute ->
        [ text "Not Found" ]