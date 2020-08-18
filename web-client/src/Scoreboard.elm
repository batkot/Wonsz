module Scoreboard exposing 
    ( Command
    , initCommand
    , Model
    , initModel
    , update 
    , view
    )

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src)

import Html.Extra as HE
import Result.Extra as RE

import Lang exposing (HasDict)

import Auth exposing (AuthSession)
import IO.Api exposing (getSeasonOverview, SeasonOverview, SeasonParticipant)

import Effect as Fx

type alias ScoreboardFx = Fx.HttpFx SeasonOverview Command

type Command
    = Init
    | GotSeasonOverview SeasonOverview
    | SeasonOverviewFailure

initCommand : Command
initCommand = Init

type alias Model = SeasonOverview

initModel : SeasonOverview
initModel = SeasonOverview []

update : AuthSession -> Command -> Model -> Fx.Eff ScoreboardFx Model
update auth cmd m = 
    case cmd of
        Init -> 
            let httpFx = Fx.Request (getSeasonOverview auth) (RE.unpack (always SeasonOverviewFailure) GotSeasonOverview)
            in Fx.pure m
                |> Fx.addFx httpFx

        GotSeasonOverview overview ->
            Fx.pure overview

        SeasonOverviewFailure ->
            Fx.pure m

view : HasDict x -> Model -> Html a
view d season = 
    let p = season.participants
        leader = List.head p
            |> Maybe.map (participantView d)
            |> Maybe.withDefault HE.empty
        rest = List.tail p
            |> Maybe.withDefault []
        podium = rest
            |> List.take 2
            |> List.map (participantView d)
        suckers = rest
            |> List.drop 2
            |> List.map (participantView d)
    in div
        [ class "scoreboard" ]
        [ div 
            [ class "leader" ]
            [ leader ]
        , div 
            [ class "rest" ]
            podium
        , div
            [ class "suckers" ]
            suckers
        ]

placeView : Int -> Html a
placeView place = 
    div [ class "place", class (placeClass place) ] [ text (String.fromInt place) ]

placeClass : Int -> String
placeClass place = 
    let placeString = if place < 4 then String.fromInt place else "n"
    in "place-" ++ placeString

participantView : HasDict x -> SeasonParticipant -> Html a
participantView { dict } participant = 
        div [ class "player", class (placeClass participant.place) ]
            [ img [ src participant.avatarUrl ] []
            , placeView participant.place
            , div [ class "name" ] [ text participant.name ]
            , div [ class "score" ] [ text (String.fromInt participant.score ++ " " ++ dict.pointLabel )]
            ]
