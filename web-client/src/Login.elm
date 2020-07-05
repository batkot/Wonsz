module Login exposing 
    ( LoginCmd
    , LoginData

    , emptyModel
    , update
    , view
    )

import Html exposing (Html, div, input, text)
import Html.Attributes exposing (class, placeholder, type_, value, style)
import Html.Events exposing (onInput, onClick)
import Html.Extra exposing (enter, onKey)

import Result.Extra as RE

import IO.Api as Api

import Http
import Http.Extra as HE

import Auth

type LoginCmd
    = UserNameChanged String
    | PasswordChanged String
    | RequestLogin 
    | LoginFailed String
    | LoggedIn String

type alias LoginData =
    { user : String
    , password : String
    , failMessage : String
    }

emptyModel : LoginData
emptyModel = LoginData "" "" ""

update : HE.Url -> LoginCmd -> LoginData -> (LoginData , Cmd LoginCmd)
update apiUrl cmd model =
    case cmd of
        UserNameChanged userName -> 
            ( { model | user = userName }, Cmd.none )
        PasswordChanged password -> 
            ( { model | password = password }, Cmd.none )
        RequestLogin -> 
            ( model, requestLogin apiUrl model)
        LoginFailed err -> 
            ( { model | failMessage = err }, Cmd.none)
        LoggedIn token -> 
            let c = Auth.authenticate token
                    |> Maybe.map Tuple.second
                    |> Maybe.withDefault Cmd.none
            in (model, c)

requestLogin : HE.Url -> LoginData -> Cmd LoginCmd
requestLogin apiUrl loginData = 
    let errorMap err = case err of
            Http.BadStatus s -> if s == 401 then "Bad credentials" else HE.httpErrorToMessage (Http.BadStatus s)
            x -> HE.httpErrorToMessage x
    in Api.login loginData.user loginData.password
        |> HE.execute apiUrl
        |> Cmd.map (RE.unpack (errorMap >> LoginFailed) LoggedIn)

view : LoginData -> Html LoginCmd
view loginData = 
    let
        error = if String.isEmpty loginData.failMessage then div [] [] else div [] [text loginData.failMessage]
    in
        div [ class "login-form" ]
            [ input 
                [ type_ "text"
                , style "display" "block"
                , placeholder "Username"
                , value loginData.user
                , onInput UserNameChanged
                , onKey enter RequestLogin ] 
                []
            , input 
                [ type_ "password"
                , style "display" "block"
                , placeholder "Password"
                , value loginData.password
                , onInput PasswordChanged
                , onKey enter RequestLogin ] 
                []
            , div 
                [ class "login-btn"
                , onClick RequestLogin ]
                [ text "Login" ]
            , error
            ]
