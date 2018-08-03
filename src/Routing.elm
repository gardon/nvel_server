module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (ChapterId, Route(..), Model, MaybeAsset(..))
import Msgs exposing (Msg)
import UrlParser exposing (..)
import Html exposing (text, Html)
import View exposing (viewChapterList, viewHome, viewAbout, templateHome, templatePages, templateChapter)
import Chapters.Chapter exposing (view)
import Dict exposing (Dict)

matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map ChaptersRoute (s "chapters" </> top)
        , map ChapterRoute (s "chapters" </> string)
        , map ChaptersRoute (s "chapters")
        , map AboutRoute (s "about")
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
        let content = viewHome model
        in templateHome model content

      ChaptersRoute ->
        let content = viewChapterList model
        in templatePages model content

      ChapterRoute id ->
        let 
          chapter = 
            case model.chapters of 
              Nothing -> 
                AssetLoading
              Just chapters ->
                let c = Dict.get id chapters
                in 
                  case c of 
                    Nothing ->
                      AssetNotFound
                    Just chapter ->
                      Asset chapter


          content = [ Chapters.Chapter.view chapter]
          
        in
          templateChapter model chapter content

      AboutRoute ->
        let content = [ viewAbout model ]
        in templatePages model content

      NotFoundRoute ->
        let content = [ text "Not Found"  ]
        in templatePages model content