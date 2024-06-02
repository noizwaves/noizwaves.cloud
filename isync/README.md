# isync

Inspired by https://github.com/jon6fingrs/mbsync/tree/main

1. `mkdir -p ~/cloud-data/isync/state`
1. Run:
```bash
mkdir -p ~/.cert

openssl s_client -connect imap.gmail.com:993 -showcerts 2>&1 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sed -ne '1,/-END CERTIFICATE-/p' > ~/.cert/imap.gmail.com.pem

mbsync -Va
```
