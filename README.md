graphUVA
========
People search at the University of Virginia is cumbersome, so we built a chrome extension with typeahead to make the process of looking up computing IDs easier. This extension will help you go from computing ID to name and vice versa.
Press 'enter' on any result to perform a google search. Additionally, Ctrl+Shift+U pulls down the extension for quick access.

This repository contains both a python webserver for querying the LDAP UVa People Search, and the Chrome extension that facilitates this search. The webserver delegates its calls to an executable written in Haskell that scrapes the response from a POST request to `http://www.virginia.edu/cgi-local/ldapweb`.

Running the Webserver
=====================
To run the server do `python graphUVA.py`

Hit the `/search` endpoint with the following query parameter `?q=marisa` and check to see if a response is received.

Sample JSON Response
====================

    { "Right":
      [ { "firstName" : "Bob",
          "lastName"  : "Boo",
          "email"     : "bob@boo.com",
          "other"     : { "phoneNumber" : "123",
                          "status"      : "Undergraduate Student",
                          "department"  : "Engineering Undergraduate-senu"
                        }
        }
      ]
    }


    { "Left": { "err": "Too Many Results" } }


    { "Left": { "err": "No Results" } }


Running Haskell
===============
    $ make

Running `make` produces a `main` executable.

If running `make` fails, do 

    $ sudo apt-get install libghc-zlib-dev libghc-zlib-bindings-dev
    
Setting up EC2
==============
## URL

    ec2-107-22-4-107.compute-1.amazonaws.com

## Setup Instructions
#### Setup EC2 with your public key to make git work easier

    cat ~/.ssh/id_rsa.pub | ssh -i ~/Downloads/graphUVA.pem ubuntu@ec2-107-22-4-107.compute-1.amazonaws.com "cat >> .ssh/authorized_keys"

#### Add the remote git repo

    git remote add aws ubuntu@ec2-107-22-4-107.compute-1.amazonaws.com:~/graphUVA.git

#### Push to remote repo

    git push -u aws master




