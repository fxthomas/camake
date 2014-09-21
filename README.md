Makefile stolen and improved from the
[https://wiki.archlinux.org/index.php/OpenSSL](OpenSSL) page on the Archlinux
Wiki.

Generate a new CA
=================

Just clone the repository and run `make`:

    git clone https://github.com/fxthomas/camake
    make

Generate a new signed certificate
=================================

Run these commands:

    make newkey name=keyname
    make sign item=csr/keyname.csr

Install the root CA
===================

On Linux, Chromium uses `nss-tools` to manage certificates. Run this command to
add the root CA to the list of trusted CAs:

    certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "My Certificate" -i cacert.pem
