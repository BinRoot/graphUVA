default:
	cabal install --bindir=./
	rm -rf dist

clean:
	rm -rf *.o *.hi main *~ dist