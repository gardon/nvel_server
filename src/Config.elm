module Config exposing (..)

type alias BackendConfig =
    { backendURL : String }

type alias SiteInformation = 
    { title : String 
    , description : String}

localBackend : BackendConfig
localBackend = {
    backendURL = "http://server.nvel.docksal/"
    }

siteInformationEndpoint = "nvel_base?_format=json"

type Environment = Local

switchBackend : Environment -> BackendConfig
switchBackend env =
    case env of
        Local -> 
            localBackend

siteInformation : SiteInformation
siteInformation = {
    title = "Nvel - My Digital Graphic Novel"
    , description = ""
    }