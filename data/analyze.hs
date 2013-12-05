{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, NoMonomorphismRestriction #-}

import System.Directory (getDirectoryContents)
import Data.String.Utils (endswith, startswith, replace)
import Data.Map (fromList, size, keys, elems)
import Data.List (intersperse)
import qualified Data.Map as M
import Text.CSV (parseCSV)
import Text.XML.HXT.Core
import Text.HandsomeSoup (css, fromUrl)
import Data.Char (toLower, isLetter, isUpper)
import Database.MongoDB
import System.Environment 
import Network.HTTP

main :: IO ()
main = do
  args <- getArgs
  let doc = fromUrl (head args) -- "http://aig.alumni.virginia.edu/du/about-du/members/"
--  let doc = fromUrl "http://www.commerce.virginia.edu/about/art/Pages/default.aspx"
--  let doc = fromUrl "http://www.medicine.virginia.edu/clinical/departments/radonc/Faculty/cancer-biology-faculty.html"
  divs <- runX $ doc >>> css "td" //> getText
  let str =  concat $ intersperse " " $ filter (\x -> or (map isLetter x)) divs
  
  pipe <- runIOE $ connect (readHostPort mongoURL)
  {-
  resFirstName <- mapM (\x -> access pipe master "graphuva" (runFirstNameFind x)) 
         (map clean (words str))
  let foundPeopleFirstName = filter (not.null) $ map (\(Right x) -> x) resFirstName
  print foundPeopleFirstName
  resLastName <- mapM (\x -> access pipe master "graphuva" (runLastNameFind x)) 
         (map clean (words str))
  let foundPeopleLastName = filter (not.null) $ map (\(Right x) -> x) resLastName
  print foundPeopleLastName
-}

  let cleanTupes = (map clean (words (clean str)))
  let tupes = filter isName $ createTuples cleanTupes
      
--  print tupes
  
  resFullName <- mapM (\x -> dbAccess x pipe) tupes
  resFullName' <- mapM (\x -> dbAccess' x pipe) tupes
  let foundPeopleFullName = filter (not.null) $ map (\(Right x) -> x) resFullName
  let foundPeopleFullName' = filter (not.null) $ map (\(Right x) -> x) resFullName'
  firstNames <- mapM (\x -> look "firstName" x) (concat foundPeopleFullName)
  firstNames' <- mapM (\x -> look "firstName" x) (concat foundPeopleFullName')
  lastNames <- mapM (\x -> look "lastName" x) (concat foundPeopleFullName)
  lastNames' <- mapM (\x -> look "lastName" x) (concat foundPeopleFullName')
  let names = zipWith (\x y -> (show x) ++ " " ++ (show y)) 
              (firstNames ++ firstNames') 
              (lastNames ++ lastNames')
  print $ map (Data.String.Utils.replace "\"" "") names
  Database.MongoDB.close pipe

dbAccess x pipe = access pipe master "graphuva" 
                  (runFullNameFind firstName lastName)
  where firstName = (head.words) x
        lastName = (last.words) x

dbAccess' x pipe = access pipe master "graphuva" 
                  (runFullNameFind' firstName lastName)
  where firstName = (head.words) x
        lastName = (last.words) x

isName str = (isUpper (head firstName)) && (isUpper (head lastName))
             && (length(firstName) > 1) && (length(lastName) > 1)
  where firstName = head $ words str
        lastName = last $ words str

createTuples (x:y:[]) = [(x++ " " ++y)]
createTuples (x:y:zs) = (x++ " " ++y) : createTuples (y:zs)

clean str = ((Data.String.Utils.replace "\n" "")
             .(Data.String.Utils.replace "\r" "")
             .(Data.String.Utils.replace "\t" "")             
             .(Data.String.Utils.replace "\"" "")
             .(Data.String.Utils.replace "(" "")
             .(Data.String.Utils.replace ")" "")
             .(Data.String.Utils.replace "<" "")
             .(Data.String.Utils.replace ">" "")
             .(Data.String.Utils.replace "." "")
             .(Data.String.Utils.replace "," "")
             .(Data.String.Utils.replace "?" "")
             .(Data.String.Utils.replace ";" "")
             .(Data.String.Utils.replace "\160" " "))
              str

runFullNameFind fname lname = do
  auth "hermes" "hermes"
  rest =<< find (select ["firstName" =: lname, "lastName" =: fname] "people2")

runFullNameFind' fname lname = do
  auth "hermes" "hermes"
  rest =<< find (select ["firstName" =: fname, "lastName" =: lname] "people2")

runFirstNameFind fname = do
  auth "hermes" "hermes"
  rest =<< find (select ["firstName" =: fname] "people2")

runLastNameFind lname = do
  auth "hermes" "hermes"
  rest =<< find (select ["lastName" =: lname] "people2")

mongoURL = "ds053788.mongolab.com:53788"

findFirstName fname = rest =<< find (select ["firstName" =: fname] "people2")
findLastName lname = rest =<< find (select ["LastName" =: lname] "people2")

getTxtFiles :: [String] -> [String]  
getTxtFiles files = filter (endswith ".txt") files

getAssocList :: [[String]] -> [(String, Person)]
getAssocList [] = []
getAssocList (c:csv) = if (startswith "#" l) || (l == "done!") 
                     then getAssocList csv
                     else (l, person c) : getAssocList csv
  where l = last c
        
person ps = 
  Person { firstName = map toLower (head ps)
         , lastName = map toLower (ps !! 1)
         , email = ""
         , other = [ ("status", "")
                   , ("department", "")
                   , ("computingId", "") ] }

data Person = Person 
              { firstName :: String
              , lastName :: String
              , email :: String
              , other :: [(String, String)]
              } deriving (Show, Eq)
        
