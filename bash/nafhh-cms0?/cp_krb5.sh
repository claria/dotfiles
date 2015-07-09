#! /bin/sh

function copykrb5 {
    KRB5_PATH=$HOME/.krb5_cache
    CREDENTIAL_PATH=${KRB5CCNAME/FILE:/}
    # Move to Home
    cp ${CREDENTIAL_PATH} $KRB5_PATH
    # Reset KRB5CCNAME
    export KRB5CCNAME=FILE:$KRB5_PATH
}
