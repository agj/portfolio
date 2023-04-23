module Util.AppUrl exposing (toStringWithTrailingSlash)

import AppUrl exposing (AppUrl)
import Regex exposing (Regex)


toStringWithTrailingSlash : AppUrl -> String
toStringWithTrailingSlash appUrl =
    appUrl
        |> AppUrl.toString
        |> ensureTrailingSlash



-- INTERNAL


noTrailingSlashRegex : Regex
noTrailingSlashRegex =
    "([^/])\\?"
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


ensureTrailingSlash : String -> String
ensureTrailingSlash =
    Regex.replaceAtMost 1
        noTrailingSlashRegex
        (\{ match, submatches } ->
            case submatches of
                (Just char) :: _ ->
                    char ++ "/?"

                _ ->
                    match
        )



-- INTERNAL
