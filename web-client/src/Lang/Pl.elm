module Lang.Pl exposing (dictionary)

import Lang exposing (Dict)

dictionary : Dict
dictionary =
    { loginPlaceholder = "Użytkownik"
    , passwordPlaceholder = "Hasło"
    , loginAction = "Zaloguj"
    , logoutAction = "Wyloguj"
    , badCredentialsMessage = "Złe dane"
    , connectionErrorMessage = "Brak połączenia"

    , notFoundMessage = "Nie znaleziono"
    , confirmLabel = "Ok"
    , denyLabel = "Anuluj"
    , loadErrorMessage = "Nie można załadować"

    , changePasswordAction = "Zmień hasło"
    , currentPasswordPlaceholder  = "Aktualne hasło"
    , newPasswordPlaceholder = "Nowe hasło"

    , pointLabel = "pkt."

    , dashboardTitle = "Tabele"
    }
