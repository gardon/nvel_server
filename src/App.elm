-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html
port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Header, Request)
import Json.Decode as Decode
import Routing exposing (parseLocation, routeContent)
import Navigation exposing (Location, newUrl)
import List exposing (head)

import Models exposing (..)
import View exposing (..)
import Config exposing (..)
import Skeleton exposing (..)
import Chapters exposing (..)
import Chapters.Chapter
import Menu exposing (..)
import Msgs exposing (..)


main =
  Navigation.program OnLocationChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- UPDATE

init : Location -> (Model, Cmd Msg)
init location =
  let
    chapters = Nothing
    siteInformation = Config.siteInformation
    pageData = { title = "Loading..." }
    backendConfig = switchBackend Local
    menu = Menu.menu
    route = parseLocation location
    model = Model chapters siteInformation pageData backendConfig menu route
  in 
    ( model
    , Cmd.batch [ getSiteInformation model, getChapters model, updatePageData (Config.pageData model) ]
    )


port updatePageData : PageData -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChaptersLoad (Ok chapters) ->
      let newmodel = { model | chapters = Just chapters }
      in 
        ( newmodel , updatePageData (Config.pageData newmodel))

    ChaptersLoad (Err error) ->
      ( model, Cmd.none)

    ChapterContentLoad (Ok chapter) ->
      (Chapters.Chapter.replaceChapter model chapter, Cmd.none)

    ChapterContentLoad (Err _) ->
      (model, Cmd.none)

    UpdateSiteInfo (Ok siteInformation) ->
      ({ model | siteInformation = siteInformation } , Cmd.none)

    UpdateSiteInfo (Err _) ->
      (model, Cmd.none)

    ChangeLocation path ->
      (model, newUrl path)

    OnLocationChange location ->
      let
          newRoute =
              parseLocation location
          newmodel = { model | route = newRoute }
      in
          ( newmodel, updatePageData (pageData newmodel))

    UpdatePageData data ->
      ( { model | pageData = data } , updatePageData data)



-- VIEW


view : Model -> Html Msg
view model =
  let 
    content = routeContent model
  in 
    div [] [
      skeletonRow [ style [ ("margin-top", "15%") ] ] [
        skeletonColumn TwelveColumns []
          [ text "Here goes the menu" ]
        ]

      ,skeletonRow [] [
        skeletonColumn TwelveColumns []
          content
        ]
      ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP


