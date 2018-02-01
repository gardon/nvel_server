module Config.Site exposing (..)

import Models exposing (..)

siteInformation : SiteInformation
siteInformation = 
    { title = ""
    , description = ""
    , facebook_page = ""
    , instagram_handle = ""
    , deviantart_profile = ""
    , aboutContent = ""
    }

homeData : PageData
homeData =
    { title = ""
    }

chaptersListData : PageData
chaptersListData = 
    { title = "Chapters"
    }

aboutData : PageData
aboutData =
    { title = "About"
    }

notFoundData : PageData
notFoundData =
    { title = "Oops, there was a problem!"
    }

language : Language
language = Pt_Br