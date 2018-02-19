module Config.Site exposing (..)

import Models exposing (..)
import Language exposing (..)

-- TODO: make this file repleceable as well.

siteInformation : SiteInformation
siteInformation = 
    { title = ""
    , description = ""
    , facebook_page = ""
    , instagram_handle = ""
    , deviantart_profile = ""
    , aboutContent = ""
    }

homeData : Language -> PageData
homeData language =
    { title = ""
    , lang = Language.toString language
    }

chaptersListData : Language -> PageData
chaptersListData language = 
    { title = "Chapters"
    , lang = Language.toString language
    }

aboutData : Language -> PageData
aboutData language =
    { title = "About"
    , lang = Language.toString language
    }

notFoundData : Language -> PageData
notFoundData language =
    { title = "Oops, there was a problem!"
    , lang = Language.toString language
    }

language : Language
language = Pt_Br