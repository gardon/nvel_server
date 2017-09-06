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
import Skeleton exposing (..)


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

viewChapter : Chapter -> Html Msg
viewChapter chapter = 
    div []
        ( [ skeletonRowOneCol [] [ h1 [] [ text chapter.title ] ]
        ] ++ viewChapterContent chapter.content )

viewChapterContent : List Section -> List (Html msg)
viewChapterContent model =
   (List.map viewSection model)

-- For now this is expecting content to be html, in the future it should be more structured and create dom for each component within Elm.
viewSection : Section -> Html msg
viewSection model =
    case model.sectionType of 
      SingleImage ->
        div [] []  

      FullWidthSingleImage ->
        skeletonRowFullWidth [] [ viewImage [ class "u-full-width" ] model.image ]

viewImage : List (Attribute msg) -> Image -> Html msg
viewImage attributes image =
  img (attributes ++ 
    [ src image.uri
    , width image.width
    , height image.height
    , alt image.alt
    , title image.title 
    ]) []

loading : String -> Html msg
loading message = 
    span [ class "loading-icon" ] [ text message ]