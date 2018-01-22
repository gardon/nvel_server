module Config.Site exposing (..)

import Models exposing (..)

siteInformation : SiteInformation
siteInformation = 
    { title = "Nvel - Digital Graphic Novel"
    , description = ""
    }

homeData : PageData
homeData =
    { title = ""
    }

chaptersListData : PageData
chaptersListData = 
    { title = "Chapters"
    }

notFoundData : PageData
notFoundData =
    { title = "Oops, there was a problem!"
    }