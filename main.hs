import Network.HTTP
import Network.URI
import Data.Char

main = do
  rsp <- simpleHTTP $ uvaRequest "abb"
  v <- fmap (takeWhile isAscii) (getResponseBody rsp)
  putStrLn v
  

data Person = Person { firstName :: String
                     , lastName :: String
                     , email :: String
                     , department :: String
                     , other :: [(String, String)] -- grad status, department, phonenumber, etc
                     }

data SearchResultErr = NoResultsErr | TooManyResultsErr

data SearchResult = Either [Person] SearchResultErr


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
