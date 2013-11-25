graphUVA
========
Data gathering and analysis within a network.

Running
=======
To run the server use `python graphUVA.py`

Sample JSON
===========

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

Notes
=====
`cabal install http-conduit`

`cabal install hxt`

`cabal install json`

if that fails, first do 
`sudo apt-get install libghc-zlib-dev libghc-zlib-bindings-dev`




