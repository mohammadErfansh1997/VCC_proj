
FROM codeberg.org/forgejo/forgejo:9.0.3

# Install required dependencies: curl, jq, sudo, ca-certificates
RUN apk add --no-cache curl jq sudo ca-certificates

# Add our custom entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]