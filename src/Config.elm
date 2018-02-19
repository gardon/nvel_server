module Config exposing (..)

import Http exposing (Header, Request)
import Json.Decode as Decode
import Models exposing (..)
import Msgs exposing (..)
import Resources exposing (..)
import Dict exposing (Dict)
import Language exposing (..)

import Config.Environment exposing (..)
import Config.Site exposing (..)

switchBackend : BackendConfig
switchBackend =
    backend

getLanguage : Language
getLanguage = 
    language

siteInformation : SiteInformation
siteInformation = 
    Config.Site.siteInformation


getChapterFromId : Maybe (Dict String Chapter) -> String -> Maybe Chapter
getChapterFromId chapters id =
    case chapters of 
        Nothing ->
            Nothing
        Just chapters ->
            Dict.get id chapters

chapterData : Model -> String -> PageData
chapterData model id = 
    let 
        chapter = getChapterFromId model.chapters id
        title =
            case chapter of 
                Nothing ->
                    translate model.language NotFound
                Just chapter ->
                    chapter.title

    in 

        { title = title
        , lang = Language.toString model.language
        }

pageData : Model -> PageData 
pageData model = 
    let data = 
        case model.route of
            HomeRoute -> homeData model.language
            ChaptersRoute -> chaptersListData model.language
            ChapterRoute id -> chapterData model id
            AboutRoute -> aboutData model.language
            NotFoundRoute -> notFoundData model.language

        title = 
            if data.title == "" then
                model.siteInformation.title
            else
                data.title ++ " | " ++ model.siteInformation.title
    in 
        { data | title = title }

getSiteInformation : Model -> Cmd Msg
getSiteInformation model = 
  let 
    url = 
      model.backendConfig.backendURL ++ siteInformationEndpoint

  in 
    Http.send UpdateSiteInfo (Http.get url decodeSiteInformation)

