module Language exposing (translate,toString)

import Models exposing (..)

type alias Translator =
    Phrase -> String

toString : Language -> String
toString lang = 
    case lang of 
        En ->
            "en"
        Pt_Br ->
            "pt-br"

translate : Language -> Translator
translate lang =
    case lang of
        En -> 
            translateEn

        Pt_Br ->
            translatePtBr

translatePtBr : Translator
translatePtBr phrase =
    case phrase of 
        MenuHome -> "Capa"
        MenuArchive -> "Índice"
        MenuAbout -> "Prefácio"
        CurrentChapter -> "Último Capítulo"
        StartFromBeginning -> "Começo da história"
        ReadIt -> "Ler agora"
        ListAllChapters -> "Lista de capítulos"
        MailchimpText -> "Assine a lista para saber de novos capítulos!"
        MailchimpSmall -> "(A lista só é usada para avisar de conteúdo novo)"
        MailchimpButton -> "Assinar"
        Loading -> "Carregando..."
        NotFound -> "Não encontrado"

translateEn : Translator
translateEn phrase =
    case phrase of 
        MenuHome -> "Home"
        MenuArchive -> "Index"
        MenuAbout -> "About"
        CurrentChapter -> "Current Chapter"
        StartFromBeginning -> "Start from beginning"
        ReadIt -> "Read it"
        ListAllChapters -> "List all chapters"
        MailchimpText -> "Don't miss an update, sign-up to get notified!"
        MailchimpSmall -> "(It's really only used when there are updates)"
        MailchimpButton -> "Subscribe"
        Loading -> "Loading..."
        NotFound -> "Not Found"