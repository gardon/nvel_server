module Models exposing (..)

import Menu exposing (..)
import Dict exposing (Dict)
import Image exposing (Image)

type alias Model =
  { chapters : Maybe (Dict String Chapter)
  , siteInformation : SiteInformation
  , pageData : PageData
  , backendConfig : BackendConfig
  , menu : List MenuItem
  , route : Route
  }

type alias Chapter =
  { title : String
  , field_description: String
  , nid : String
  , content: List Section
  }

type SectionType
  = SingleImage
  | FullWidthSingleImage

type alias Section =
    { sectionType : SectionType
    , image : Image }

type alias BackendConfig =
    { backendURL : String }

type alias SiteInformation = 
    { title : String 
    , description : String
    }

type alias PageData = 
    { title : String
    }

type Environment = Local

type alias ChapterId = String

type Route
    = ChaptersRoute
    | ChapterRoute ChapterId
    | NotFoundRoute

chapterListEndpoint = "chapters?_format=json"
chapterContentEndpoint = "chapters"


