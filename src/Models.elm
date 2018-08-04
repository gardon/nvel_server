module Models exposing (..)

import Dict exposing (Dict)
import Image exposing (Image)
import Date exposing (Date)
import Navigation exposing (Location)

type alias Model =
  { chapters : Maybe (Dict String Chapter)
  , siteInformation : SiteInformation
  , pageData : PageData
  , backendConfig : BackendConfig
  , menu : List MenuItem
  , route : Route
  , language : Language
  , navbar : Bool
  , location : Location
  }

type alias MenuItem = 
  { title : Phrase
  , path : String
  , route : Route
  }

type alias Chapter =
  { title : String
  , field_description: String
  , nid : String
  , content: List Section
  , index: Int
  , thumbnail: Image
  , authors: List String
  , date: Date
  , featured_image: Image
  }

type MaybeAsset a
  = AssetNotFound
  | AssetLoading
  | Asset a

type SectionType
  = SingleImage
  | FullWidthSingleImage
  | TitlePanel TitlePanelFeatures
  | Spacer
  | Text String

type alias Section =
    { sectionType : SectionType
    , image : Image 
    , chapter : String
    , id : Int 
    , zoomed: Bool
    }

type alias TitlePanelFeatures =
    { title : String
    , author : String
    , copyright : String
    , extra : String
    }

type alias BackendConfig =
    { backendURL : String }

type alias SiteInformation = 
    { title : String 
    , description : String
    , facebook_page : String
    , instagram_handle : String
    , deviantart_profile : String
    , aboutContent : String
    }

type alias PageData = 
    { title : String
    , lang: String
    }

type Environment = Local

type alias ChapterId = String

type Route
    = HomeRoute
    | ChaptersRoute
    | ChapterRoute ChapterId
    | AboutRoute
    | NotFoundRoute

type SocialIconType
    = FacebookIcon
    | InstagramIcon
    | DeviantArtIcon

type Language
    = En
    | Pt_Br

type Phrase
    = MenuHome
    | MenuArchive
    | MenuAbout
    | CurrentChapter
    | StartFromBeginning
    | ReadIt
    | ListAllChapters
    | MailchimpText 
    | MailchimpSmall 
    | MailchimpButton
    | Loading
    | NotFound
    | NextChapter

type NavbarAction
    = Show
    | Hide

siteInformationEndpoint = "nvel_base?_format=json"
chapterListEndpoint = "chapters?_format=json"
chapterContentEndpoint = "chapters"


