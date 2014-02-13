graphUVA
========
People search at the University of Virginia is cumbersome, so we built a chrome extension with typeahead to make the process of looking up computing IDs easier. This extension will help you go from computing ID to name and vice versa.
Press 'enter' on any result to perform a google search. Additionally, Ctrl+Shift+F pulls down the extension for quick access.

[The Old Search](http://www.virginia.edu/search/):
===============

![People Search](http://i.imgur.com/1JKSO6V.png)

This repository contains both a python webserver for querying the LDAP UVa People Search, and the Chrome extension that facilitates this search. The webserver delegates its calls to an executable written in Haskell that scrapes the response from a POST request to `http://www.virginia.edu/cgi-local/ldapweb`.

[Our New Chrome Extension](https://chrome.google.com/webstore/detail/uva-people-search/jdebncmmapengneahngfihdnoajlfmbn):
=========================

![Screenshot](http://i.imgur.com/1CfdETa.png)


Links
=====================
[Home Page](http://uvasear.ch)


[Chrome Extension](https://chrome.google.com/webstore/detail/uva-people-search/jdebncmmapengneahngfihdnoajlfmbn/details)


[@binroot](https://twitter.com/binroot), [@jasdev](https://twitter.com/jasdev)

Running the Webserver
=====================
To run the server do `python graphUVA.py`

Hit the `/search` endpoint with the following query parameter `?q=marisa` and check to see if a response is received.

Sample JSON Response
====================
GET request to `/search` endpoint: [uvasear.ch/search?q=anat](http://uvasear.ch/search?q=anat)
    
    [
      {
        status: "Undergraduate Student",
        comp_id: "lol2lol",
        name: "Soulja Boi",
        value: "Soulja Boi (lol2lol)",
        tokens: [
          "Soulja",
          "Boi",
          "lol2lol@virginia.edu"
        ],
        phoneNumber: 7039119111,
        department: "Engineering Undergraduate-senu",
        email: "lol2lol@virginia.edu"
      }
    ]

    [] is returned if there are too many or no results

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




