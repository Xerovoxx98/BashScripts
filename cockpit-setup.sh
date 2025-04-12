#!/bin/bash
apt update && apt upgrade
apt install gpg git
curl -sSL https://repo.45drives.com/setup | bash
apt install cockit-file-sharing -y
apt install cockpit-identities -y
apt install cockpit-navigator -y
