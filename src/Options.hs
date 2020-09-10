module Options
    ( parseHarpoonOption,
      HarpoonOption (..),
      Query (..),
    ) where

data Query = SearchQuery String
           | GetQuery String
           deriving (Show)

data HarpoonOption = HELP
                   | GET Query
                   | SEARCH Query
                   | INVALID String
                   deriving (Show)

parseHarpoonOption :: [String] -> HarpoonOption
parseHarpoonOption ("help":_)    = HELP
parseHarpoonOption ("get":xs)    = getPackage xs
parseHarpoonOption ("search":xs) = searchPackage xs
parseHarpoonOption (s:_)         = INVALID $ "Invalid option : " ++ s
parseHarpoonOption []            = INVALID "No option given, try harpoon help."

searchPackage :: [String] -> HarpoonOption
searchPackage []      = INVALID "No search guery given."
searchPackage ("":xs) = INVALID "Invalid search query given."
searchPackage (l:xs)  = SEARCH $ SearchQuery l

getPackage :: [String] -> HarpoonOption
getPackage []      = INVALID "No get query given."
getPackage ("":xs) = INVALID "Invalid get query given."
getPackage (l:xs)  = GET $ GetQuery l
