module Chapters.Chapter exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import View exposing (..)
import View.Attributes exposing (..)
import Dict exposing (Dict)
import Msgs exposing (Msg)
import Skeleton exposing (..)
import Markdown

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
    List.append [ h1 [ class "chapter-title hidden"] [ text chapter.title ] ] (viewChapterContent chapter.content)
    |> div []

viewChapterContent : List Section -> List (Html Msg)
viewChapterContent model =
   (List.map viewSection model)

viewSection : Section -> Html Msg
viewSection model =
    case model.sectionType of 
      SingleImage ->
        let 
            newclass = if model.zoomed then
                "section-single-image zoomed"
            else
                "section-single-image"
        in
            skeletonRow [ class newclass, "section-" ++ model.chapter ++ "-" ++ (toString model.id) |> id] 
                [ viewImage 
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClick (Msgs.ToggleZoomedImage model.chapter model.id)
                    ] 
                    model.image 
                ]  

      FullWidthSingleImage ->
        let 
            newclass = if model.zoomed then
                "section-full-width-image zoomed"
            else
                "section-full-width-image"
        in
            skeletonRowFullWidth [ class newclass, "section-" ++ model.chapter ++ "-" ++ (toString model.id) |> id ] 
                [ viewImage 
                    [ class "u-full-width"
                    , sizes [ "100w" ] 
                    , onClick (Msgs.ToggleZoomedImage model.chapter model.id)
                    ] 
                    model.image 
                ]

      Spacer ->
        skeletonRowFullWidth [ class "section-spacer" ] []

      TitlePanel features ->
        skeletonRow [ class "section-title" ] 
        [ viewImage [] model.image
        , h2 [ class "chapter-title" ] [ text features.title ]
        , h3 [ class "author" ] [ text features.author ]
        , Markdown.toHtmlWith markdownOptions [ class "extra" ] features.extra
        , div [ class "copyright" ] [ text features.copyright ]
        ]