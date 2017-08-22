module Config exposing (..)

import Http exposing (Header, Request)
import Json.Decode as Decode
import Models exposing (..)
import Msgs exposing (..)
import Resources exposing (..)
import Dict exposing (Dict)

localBackend : BackendConfig
localBackend = {
    backendURL = "http://server.nvel.docksal/"
    }

siteInformationEndpoint = "nvel_base?_format=json"

switchBackend : Environment -> BackendConfig
switchBackend env =
    case env of
        Local -> 
            localBackend

siteInformation : SiteInformation
siteInformation = 
    { title = "Nvel - Digital Graphic Novel"
    , description = ""
    }

chaptersListData : PageData
chaptersListData = 
    { title = "Chapters"
    }

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
                    "Not Found"
                Just chapter ->
                    chapter.title

    in 

        { title = title
        }

notFoundData : PageData
notFoundData =
    { title = "Oops, there was a problem!"
    }

pageData : Model -> PageData 
pageData model = 
    let data = 
        case model.route of
            ChaptersRoute -> chaptersListData
            ChapterRoute id -> chapterData model id
            NotFoundRoute -> notFoundData

    in 
        { data | title = data.title ++ " | " ++ model.siteInformation.title}

getSiteInformation : Model -> Cmd Msg
getSiteInformation model = 
  let 
    url = 
      model.backendConfig.backendURL ++ siteInformationEndpoint

  in 
    Http.send UpdateSiteInfo (getAuth url decodeSiteInformation)

decodeSiteInformation : Decode.Decoder SiteInformation
decodeSiteInformation = 
  Decode.field "description" Decode.string
    |> Decode.map2 SiteInformation (Decode.field "title" Decode.string)