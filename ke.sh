for f in $(find . -maxdepth 1 -type f -executable | sort); do echo "== $f"; $f; done
