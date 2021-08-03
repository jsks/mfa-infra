#!/usr/bin/env zsh
# 
# Pre-populate password store with wireguard keys for server & client.
###

setopt err_return pipe_fail

preshared=$(wg genpsk)

<<EOF | pass insert --multiline wg/mfa-server
$(wg genkey | tee >(wg pubkey | sed 's/^/PublicKey: /'))
PresharedKey: $preshared
EOF

<<EOF | pass insert --multiline wg/mfa-client
$(wg genkey | tee >(wg pubkey | sed 's/^/PublicKey: /'))
PresharedKey: $preshared
EOF
