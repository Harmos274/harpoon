module Parser
    ( dotHarpoonParser,
      HarpoonPackage (..),
    ) where

import Data.List (isPrefixOf, stripPrefix)

newtype Deps = Deps String deriving (Show)

data Name = Name String | NONAME            deriving (Show)
data Version = Version String | NOVERSION   deriving (Show)
data Type = DLL | BIN | NOTYPE              deriving (Show)
data InnerDeps = InnerDeps [Deps] | NOIDEPS deriving (Show)
data OuterDeps = OuterDeps [Deps] | NOODEPS deriving (Show)
data TempInnerDeps = TempInnerDeps [Deps] | NOTIDEPS deriving (Show)
data TempOuterDeps = TempOuterDeps [Deps] | NOTODEPS deriving (Show)
data CompilationBackend = CMAKE | MAKE | NINJA | SCRIPT | NOBACKEND deriving (Show)

data HarpoonPackage = HarpoonPackage Name Version Type InnerDeps OuterDeps TempInnerDeps TempOuterDeps CompilationBackend | InvalidPackage String deriving (Show)


newHarpoonPackage :: HarpoonPackage
newHarpoonPackage = HarpoonPackage NONAME NOVERSION NOTYPE NOIDEPS NOODEPS NOTIDEPS NOTODEPS NOBACKEND


dotHarpoonParser :: String -> HarpoonPackage
dotHarpoonParser [] = InvalidPackage "Empty file"
dotHarpoonParser s  = (checkParsedHP . dotHarpoonParser' . lines) s

checkParsedHP :: HarpoonPackage -> HarpoonPackage
checkParsedHP (HarpoonPackage NONAME _ _ _ _ _ _ _)    = InvalidPackage "Incomplete file, See the README for further informations."
checkParsedHP (HarpoonPackage _ NOVERSION _ _ _ _ _ _) = InvalidPackage "Incomplete file, See the README for further informations."
checkParsedHP (HarpoonPackage _ _ NOTYPE _ _ _ _ _)    = InvalidPackage "Incomplete file, See the README for further informations."
checkParsedHP (HarpoonPackage _ _ _ _ _ _ _ NOBACKEND) = InvalidPackage "Incomplete file, See the README for further informations."
checkParsedHP hp = hp

dotHarpoonParser' :: [String] -> HarpoonPackage
dotHarpoonParser' [] = InvalidPackage "The file does not match the right format. See the README for further informations."
dotHarpoonParser' s  = foldl fillHarpoonOption newHarpoonPackage s

fillHarpoonOption :: HarpoonPackage -> String -> HarpoonPackage
fillHarpoonOption hp@HarpoonPackage {} s = fillHarpoonOption' hp s
fillHarpoonOption hp _                   = hp

fillHarpoonOption' :: HarpoonPackage -> String -> HarpoonPackage
fillHarpoonOption' hp line | "Name : "               `isPrefixOf` line = updateNameHP               hp $ stripPrefix "Name :" line
                           | "Version : "            `isPrefixOf` line = updateVersionHP            hp $ stripPrefix "Version : " line
                           | "Type : "               `isPrefixOf` line = updateTypeHP               hp $ stripPrefix "Type : " line
                           | "InnerDeps : "          `isPrefixOf` line = updateInnerDepsHP          hp $ stripPrefix "InnerDeps : " line
                           | "OuterDeps : "          `isPrefixOf` line = updateOuterDepsHP          hp $ stripPrefix "OuterDeps : " line
                           | "TempInnerDeps : "      `isPrefixOf` line = updateTempInnerDepsHP      hp $ stripPrefix "TempInnerDeps : " line
                           | "TempOuterDeps : "      `isPrefixOf` line = updateTempOuterDepsHP      hp $ stripPrefix "TempOuterDeps : " line
                           | "CompilationBackend : " `isPrefixOf` line = updateCompilationBackendHP hp $ stripPrefix "CompilationBackend : " line
                           | otherwise                                 = InvalidPackage $ "Unknown category : " ++ (head . words) line

updateNameHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateNameHP (HarpoonPackage NONAME ver ty id od tid tod cb) (Just s) = HarpoonPackage (Name s) ver ty id od tid tod cb
updateNameHP s@InvalidPackage {} _                                    = s
updateNameHP _ _                                                      = InvalidPackage "Invalid definition of name"

updateVersionHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateVersionHP (HarpoonPackage nam NOVERSION ty id od tid tod cb) (Just s) = HarpoonPackage nam (Version s) ty id od tid tod cb
updateVersionHP _ _                                                         = InvalidPackage "Invalid definition of version"

updateTypeHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateTypeHP (HarpoonPackage nam ver NOTYPE id od tid tod cb) (Just "DLL") = HarpoonPackage nam ver DLL id od tid tod cb
updateTypeHP (HarpoonPackage nam ver NOTYPE id od tid tod cb) (Just "dll") = HarpoonPackage nam ver DLL id od tid tod cb
updateTypeHP (HarpoonPackage nam ver NOTYPE id od tid tod cb) (Just "BIN") = HarpoonPackage nam ver BIN id od tid tod cb
updateTypeHP (HarpoonPackage nam ver NOTYPE id od tid tod cb) (Just "bin") = HarpoonPackage nam ver BIN id od tid tod cb
updateTypeHP (HarpoonPackage nam ver NOTYPE id od tid tod cb) (Just s)     = InvalidPackage $ "Invalid option for type : " ++ s
updateTypeHP s@InvalidPackage {} _                                         = s
updateTypeHP _ _                                                           = InvalidPackage "Invalid definition of type"

updateInnerDepsHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateInnerDepsHP (HarpoonPackage nam ver ty NOIDEPS od tid tod cb) (Just s) = HarpoonPackage nam ver ty (InnerDeps . map Deps $ words s) od tid tod cb
updateInnerDepsHP s@InvalidPackage {} _                                      = s
updateInnerDepsHP _ _                                                        = InvalidPackage "Invalid definition of inner deps"

updateOuterDepsHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateOuterDepsHP (HarpoonPackage nam ver ty id NOODEPS tid tod cb) (Just s) = HarpoonPackage nam ver ty id (OuterDeps . map Deps $ words s) tid tod cb
updateOuterDepsHP s@InvalidPackage {} _                                      = s
updateOuterDepsHP _ _                                                        = InvalidPackage "Invalid definition of outer deps"

updateTempInnerDepsHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateTempInnerDepsHP (HarpoonPackage nam ver ty id od NOTIDEPS tod cb) (Just s) = HarpoonPackage nam ver ty id od (TempInnerDeps . map Deps $ words s) tod cb
updateTempInnerDepsHP s@InvalidPackage {} _                                      = s
updateTempInnerDepsHP _ _                                                        = InvalidPackage "Invalid definition of temp inner deps"

updateTempOuterDepsHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateTempOuterDepsHP (HarpoonPackage nam ver ty id od tid NOTODEPS cb) (Just s) = HarpoonPackage nam ver ty id od tid (TempOuterDeps . map Deps $ words s) cb
updateTempOuterDepsHP s@InvalidPackage {} _                                      = s
updateTempOuterDepsHP _ _                                                        = InvalidPackage "Invalid definition of temp outer deps"

updateCompilationBackendHP :: HarpoonPackage -> Maybe String -> HarpoonPackage
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "CMAKE")  = HarpoonPackage nam ver ty id od tid tod CMAKE
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "cmake")  = HarpoonPackage nam ver ty id od tid tod CMAKE
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "MAKE")   = HarpoonPackage nam ver ty id od tid tod MAKE
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "make")   = HarpoonPackage nam ver ty id od tid tod MAKE
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "NINJA")  = HarpoonPackage nam ver ty id od tid tod NINJA
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "ninja")  = HarpoonPackage nam ver ty id od tid tod NINJA
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "SCRIPT") = HarpoonPackage nam ver ty id od tid tod SCRIPT
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just "script") = HarpoonPackage nam ver ty id od tid tod SCRIPT
updateCompilationBackendHP (HarpoonPackage nam ver ty id od tid tod NOBACKEND) (Just s)        = InvalidPackage $ "Invalid backend : " ++ s
updateCompilationBackendHP s@InvalidPackage {} _                                               = s
updateCompilationBackendHP _ _                                                                 = InvalidPackage "Invalid definition of compilation backend"
