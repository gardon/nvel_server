module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Menu exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Dict exposing (Dict)
import Image exposing (Image, Derivative)
import Skeleton exposing (..)
import Date.Format

-- Needs a recursive elaboration
srcset : List Derivative -> Attribute msg
srcset derivatives =
  derivatives
    |> List.map (\derivative -> derivative.uri ++ " " ++ derivative.size)
    |> List.intersperse ", "
    |> String.concat 
    |> attribute "srcset"

sizes : List String -> Attribute msg
sizes sizes =
  sizes
    |> List.intersperse ", "
    |> String.concat
    |> attribute "sizes"

onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
      onWithOptions "click" options (Decode.succeed message)

viewHome : Maybe (Dict String Chapter) -> List (Html Msg)
viewHome chapters =
  case chapters of
    Nothing ->
      [ text "Loading chapters..."]

    Just chapters ->
      let 
          list = sortChapterList chapters
          content = 
            case List.head (List.reverse list) of
              Nothing ->
                []

              Just current ->
                case List.head list of
                  Nothing ->
                    [ viewChapterFeaturedCurrent current ]

                  Just first ->
                    if current == first then
                        [ viewChapterFeaturedCurrent current ]
                    else 
                        [ viewChapterFeaturedCurrent current, viewChapterFeaturedFirst first ]
      in
          [ div [ class "container" ] content ]


viewChapterList : Maybe (Dict String Chapter) -> List (Html Msg)
viewChapterList chapters = 
  case chapters of 
    Nothing -> 
        [ text "Loading chapters..."]

    Just chapters -> 
        List.map viewChapterListItem (sortChapterList chapters)

sortChapterList : Dict String Chapter -> List Chapter
sortChapterList chapters = 
  List.sortBy .index (Dict.values chapters)

viewChapterFeatured : String -> String -> Chapter -> Html Msg
viewChapterFeatured caption featured_class chapter = 
  let 
      chapterPath = "/chapters/" ++ chapter.nid
  in
      div [ class ("chapter-featured " ++ featured_class)]
        [ viewImage [] chapter.thumbnail
        , h3 [] [ text caption ] 
        , h2 [] [ a [ href chapterPath, onLinkClick (ChangeLocation chapterPath) ] [ text chapter.title ] ]
        , linkButtonPrimary chapterPath "Read it"
        , div [] [ text chapter.field_description ]
        , div [] [ text (String.concat chapter.authors) ]
        , div [] [ text (Date.Format.format "%Y %b %e" chapter.date)]
        ]

viewChapterFeaturedCurrent : Chapter -> Html Msg
viewChapterFeaturedCurrent chapter =
  viewChapterFeatured "Current chapter" "current-chapter" chapter

viewChapterFeaturedFirst : Chapter -> Html Msg
viewChapterFeaturedFirst chapter =
  viewChapterFeatured "Start from the beginning" "first-chapter" chapter

linkButtonPrimary : String -> String -> Html Msg
linkButtonPrimary path title = 
  a [ href path, onLinkClick (ChangeLocation path), class "button button-primary" ] [ text title ]

viewChapterListItem : Chapter -> Html Msg
viewChapterListItem chapter =
  let 
      chapterPath = "/chapters/" ++ chapter.nid
      chapterNumber = "#" ++ (toString chapter.index) ++ ": "
  in
      div [ class "chapter-list-item"]
        [
          h3 [] [ text chapterNumber ]
        , h2 [] [ a [ href chapterPath, onLinkClick (ChangeLocation chapterPath) ] [ text chapter.title ] ]
        , div [] [ text chapter.field_description ]
        , viewImage [] chapter.thumbnail
        , div [] [ text (String.concat chapter.authors) ]
        , div [] [ text (Date.Format.format "%Y %b %e" chapter.date)]
        ]

viewChapter : Chapter -> Html Msg
viewChapter chapter = 
    div []
        ( [ skeletonRowOneCol [] [ h1 [] [ text chapter.title ] ]
        ] ++ viewChapterContent chapter.content )

viewChapterContent : List Section -> List (Html msg)
viewChapterContent model =
   (List.map viewSection model)

viewSection : Section -> Html msg
viewSection model =
    case model.sectionType of 
      SingleImage ->
        div [] []  

      FullWidthSingleImage ->
        skeletonRowFullWidth [] [ viewImage [ class "u-full-width", sizes [ "100w" ] ] model.image ]

viewImage : List (Attribute msg) -> Image -> Html msg
viewImage attributes image =
  img ( attributes ++ 
    [ src image.uri
    , width image.width
    , height image.height
    , alt image.alt
    , title image.title
    , srcset image.derivatives 
    ]) []

viewMenu : List MenuItem -> Html Msg 
viewMenu menu =
  nav [ class "navbar"] [
      div [ class "container" ] [ 
        ul [ class "navbar-list" ] (List.map viewMenuItem menu)
      ]
  ]

viewMenuItem : MenuItem -> Html Msg
viewMenuItem item =
  li [ class "navbar-item" ] [ 
      a [ href item.path, onLinkClick (ChangeLocation item.path), class "navbar-link" ] [ text item.title ]
  ]

loading : String -> Html msg
loading message = 
    span [ class "loading-icon" ] [ text message ]