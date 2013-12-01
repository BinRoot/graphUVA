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


Running Haskell
===============
    $ make

Running `make` produces a `main` executable.

If running `make` fails, do 

    $ sudo apt-get install libghc-zlib-dev libghc-zlib-bindings-dev




