module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (ChapterId, Route(..))
import UrlParser exposing (..)

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