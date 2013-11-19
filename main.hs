import Network.HTTP
import Network.URI
import Data.Char

main = do
  rsp <- simpleHTTP $ uvaRequest "abb"
  rawResult <- fmap (takeWhile isAscii) (getResponseBody rsp)
  print rawResult

data Person = Person 
              { firstName :: String
              , lastName :: String
              , email :: String
              , department :: String
              , other :: [(String, String)] -- grad status, department, phonenumber, etc
              } deriving Show
              
data SearchResultErr = NoResultsErr | TooManyResultsErr deriving Show

type SearchResult = Either SearchResultErr [Person]

uvaRequest :: String -> Request_String
uvaRequest query = Request { 
    rqURI = case parseURI "http://www.virginia.edu/cgi-local/ldapweb" of Just u -> u
  , rqMethod = POST
  , rqHeaders = [ mkHeader HdrContentType "text/html"
                , mkHeader HdrContentLength $ show $ length body
                ]
  , rqBody = body
  }
  where body = "whitepages=" ++ query
