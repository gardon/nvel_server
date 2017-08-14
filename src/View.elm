module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Json.Decode as Decode


onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
      onWithOptions "click" options (Decode.succeed message)


viewChapterList : Maybe (List Chapter) -> List (Html Msg)
viewChapterList chapters = 
  case chapters of 
    Nothing -> 
        [ text "Loading chapters..."]

    Just chapters -> 
        List.map viewChapterListItem chapters


viewChapterListItem : Chapter -> Html Msg
viewChapterListItem chapter =
  let 
      chapterPath = "/chapters/" ++ chapter.nid
  in
      div []
        [
          h2 [] [ a [ href chapterPath, onLinkClick (ChangeLocation chapterPath) ] [ text chapter.title ] ]
        , div [] [ text chapter.field_description ]
        ]

viewChapter : Chapter -> Html msg
viewChapter chapter = 
    div []
        [ h1 [] [ text chapter.title ]
        , viewChapterContent chapter.content
        ]

viewChapterContent : Maybe (List ChapterContent) -> Html msg
viewChapterContent model =
    case model of 
        Nothing ->
            loading "Loading chapter content..."

        Just list ->
            div [] 
                (List.map viewChapterContentItem list)

viewChapterContentItem : ChapterContent -> Html msg
viewChapterContentItem model =
    div [] [ text model.content ]       

loading : String -> Html msg
loading message = 
    span [ class "loading-icon" ] [ text message ]