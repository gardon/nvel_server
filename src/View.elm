module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Dict exposing (Dict)
import Image exposing (Image)


onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
      onWithOptions "click" options (Decode.succeed message)


viewChapterList : Maybe (Dict String Chapter) -> List (Html Msg)
viewChapterList chapters = 
  case chapters of 
    Nothing -> 
        [ text "Loading chapters..."]

    Just chapters -> 
        List.map viewChapterListItem (Dict.values chapters)


viewChapterListItem : Chapter -> Html Msg
viewChapterListItem chapter =
  let 
      chapterPath = "/chapters/" ++ chapter.nid
  in
      div []
        [
          h2 [] [ a [ href chapterPath, onLinkClick (ChangeLocation chapterPath) ] [ text chapter.title ] ]
        , div [ property "innerHTML" (Encode.string chapter.field_description) ] []
        ]

viewChapter : Chapter -> Html msg
viewChapter chapter = 
    div []
        [ h1 [] [ text chapter.title ]
        , viewChapterContent chapter.content
        ]

viewChapterContent : List Section -> Html msg
viewChapterContent model =
    div [] 
        (List.map viewSection model)

-- For now this is expecting content to be html, in the future it should be more structured and create dom for each component within Elm.
viewSection : Section -> Html msg
viewSection model =
    case model.sectionType of 
      SingleImage ->
        div [] []  

      FullWidthSingleImage ->
        div [] [ viewImage model.image ]

viewImage : Image -> Html msg
viewImage image =
  img [ src image.uri, width (Result.withDefault 0 (String.toInt image.width)), height (Result.withDefault 0 (String.toInt image.height)), alt image.alt, title image.title ] []

loading : String -> Html msg
loading message = 
    span [ class "loading-icon" ] [ text message ]