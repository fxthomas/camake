OPENSSL   =	openssl
CNF       = openssl.cnf
CA        = ${OPENSSL} ca -config ${CNF}
REQ       = ${OPENSSL} req -config ${CNF}
GENPKEY   = ${OPENSSL} genpkey

KEY=		private/cakey.pem
KEYMODE=	RSA

CACERT=		cacert.pem
CADAYS=		3650

CRL=		crl.pem
INDEX=		index.txt
SERIAL=		serial


CADEPS=		${CNF} ${KEY} ${CACERT}

all:	${CRL}

${CRL}:	${CADEPS}
	echo "01" > crlnumber
	${CA} -gencrl -out ${CRL}

${CACERT}: ${CNF} ${KEY}
	${REQ} -key ${KEY} -x509 -new -days ${CADAYS} -out ${CACERT}
	rm -f ${INDEX}
	touch ${INDEX}
	echo 100001 > ${SERIAL}

${KEY}: ${CNF}
	mkdir -m0700 -p $(dir ${KEY})
	touch ${KEY}
	chmod 0600 ${KEY}
	${OPENSSL} genpkey -algorithm ${KEYMODE} -out ${KEY}

newcert: ${CADEPS}
	mkdir -p csr/
	${GENPKEY} -algorithm RSA -out "${item}" -pkeyopt rsa_keygen_bits:4096
	${REQ} -new -key "${item}" -out "csr/$(subst .key,.csr,$(notdir item))"

revoke:	${CADEPS} ${item}
	@test -n $${item:?'usage: ${MAKE} revoke item=cert.pem'}
	${CA} -revoke ${item}
	${MAKE} ${CRL}

sign:	${CADEPS} ${item}
	@test -n $${item:?'usage: ${MAKE} sign item=request.csr'}
	mkdir -p newcerts
	${CA} -in ${item} -out ${item:.csr=.crt} 
