module Config exposing (..)

type alias BackendConfig =
    { backendURL : String }

type alias SiteInformation = 
    { sitename : String }

localBackend : BackendConfig
localBackend = {
    backendURL = "http://server.nvel.docksal/"
    }

type Environment = Local

switchBackend : Environment -> BackendConfig
switchBackend env =
    case env of
        Local -> 
            localBackend

siteInformation : SiteInformation
siteInformation = {
    sitename = "Nvel - My Digital Graphic Novel"
    }