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
    
Setting up EC2
==============
## URL

    ec2-54-227-185-9.compute-1.amazonaws.com

## Setup Instructions
#### Setup EC2 with your public key to make git work easier

    cat ~/.ssh/id_rsa.pub | ssh -i ~/Downloads/graphUVA.pem ubuntu@ec2-54-227-185-9.compute-1.amazonaws.com "cat >> .ssh/authorized_keys"

#### Add the remote git repo

    git remote add aws ubuntu@ec2-54-227-185-9.compute-1.amazonaws.com:~/graphUVA.git

#### Push to remote repo

    git push -u aws master




