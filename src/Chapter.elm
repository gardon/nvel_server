module Chapter exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Chapter =
  { title : String
  , field_description: String
  }

chapterListEndpoint = "chapters"

viewChapterList : Maybe (List Chapter) -> List (Html msg)
viewChapterList chapters = 
  case chapters of 
    Nothing -> 
        [ text "Loading chapters..."]

    Just chapters -> 
        List.map viewChapterListItem chapters

viewChapterListItem : Chapter -> Html msg
viewChapterListItem chapter =
  div []
    [
      h2 [] [ text chapter.title ]
    , div [] [ text chapter.field_description ]
    ]
