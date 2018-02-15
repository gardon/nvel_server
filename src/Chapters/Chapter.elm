module Chapters.Chapter exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import View exposing (..)
import View.Attributes exposing (..)
import Dict exposing (Dict)
import Msgs exposing (Msg)
import Skeleton exposing (..)

view :  MaybeAsset Chapter -> Html Msg
view model =
    case model of
        AssetLoading ->
            div []
                [ h1 [] [ loading "Loading" ]    
            ]

        AssetNotFound ->
            div [ class "container" ]
                [ h1 [] [ text "Chapter not Found" ]
            ]

        Asset chapter ->
            viewChapter chapter

replaceChapter : Model -> Chapter -> Model
replaceChapter model newchapter =
    case model.chapters of 
        Nothing ->
            { model | chapters = Just (Dict.singleton newchapter.nid newchapter) }

        Just chapters ->
            { model | chapters = Just (Dict.insert newchapter.nid newchapter chapters) } 

viewChapter : Chapter -> Html Msg
viewChapter chapter = 
    div []
      (viewChapterContent chapter.content)

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