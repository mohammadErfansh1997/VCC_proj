#!/bin/sh
set -e

forgejo_cli() {
    sudo -u git forgejo --config /data/gitea/conf/app.ini "$@"
}

echo "[+] Waiting for database..."
until forgejo_cli admin user list >/dev/null 2>&1; do
    echo "[-] DB not ready, retrying..."
    sleep 2
done

echo "[+] Running DB migration..."
forgejo_cli migrate

echo "[+] Creating admin user if not exists..."
if ! forgejo_cli admin user list | grep -q admin; then
    forgejo_cli admin user create --name admin --password password --email admin@example.com --admin
    echo "[+] Admin user created"
fi

echo "[+] Trusting system TLS certificate..."
cp /data/certs/traefik/ca.crt /usr/local/share/ca-certificates/traefik.crt || true
update-ca-certificates || true

echo "[+] Waiting for Dex at https://auth.vcc.internal..."
until curl -kfsSL https://auth.vcc.internal/.well-known/openid-configuration >/dev/null; do
    echo "[-] Dex not ready, retrying..."
    sleep 2
done

echo "[+] Creating Forgejo OpenID client..."
if ! forgejo_cli admin auth list | grep -q "forgejo"; then
    forgejo_cli admin auth add-oauth             --name forgejo             --provider openidConnect             --key forgejo             --secret changeme             --auto-discover-url https://auth.vcc.internal/.well-known/openid-configuration             --group-claim groups             --admin-group admins
    echo "[+] OpenID client 'forgejo' added"
fi

exec /bin/s6-svscan /etc/s6 "$@"
