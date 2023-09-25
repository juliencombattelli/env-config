if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    # Needed for Internet accesses based on Requests Python package (like pip)
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
fi
