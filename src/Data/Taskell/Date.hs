{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Data.Taskell.Date (
    Day,
    Deadline(..),
    DeadlineFn,
    dayToText,
    dayToOutput,
    textToDay,
    currentDay,
    deadline
) where

import ClassyPrelude

import Data.Time (Day)
import Data.Time.Clock (secondsToDiffTime)
import Data.Time.Format (parseTimeM, formatTime)
import Data.Time.Calendar (diffDays)

data Deadline = Passed | Today | Tomorrow | ThisWeek | Plenty deriving (Show, Eq)
type DeadlineFn = Maybe Day -> Maybe Deadline

dayToText :: Day -> Text
dayToText day = pack $ formatTime defaultTimeLocale "%d-%b" (UTCTime day (secondsToDiffTime 0))

dayToOutput :: Day -> Text
dayToOutput day = pack $ formatTime defaultTimeLocale "%Y-%m-%d" (UTCTime day (secondsToDiffTime 0))

textToTime :: Text -> Maybe UTCTime
textToTime = parseTimeM False defaultTimeLocale "%Y-%m-%d" . unpack

textToDay :: Text -> Maybe Day
textToDay = (utctDay <$>) . textToTime

currentDay :: IO Day
currentDay = utctDay <$> getCurrentTime

daysUntil :: Maybe Day -> Maybe Day -> Maybe Integer
daysUntil = liftA2 diffDays

-- work out the deadline
deadline :: Maybe Day -> Maybe Day -> Maybe Deadline
deadline today date = do
    days <- daysUntil date today
    let d | days < 0 = Passed
          | days == 0 = Today
          | days == 1 = Tomorrow
          | days < 7 = ThisWeek
          | otherwise = Plenty
    return d