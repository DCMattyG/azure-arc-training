#!/bin/sh

# Block Azure IMDS
sudo ufw --force enable
sudo ufw deny out from any to 169.254.169.254
sudo ufw default allow incoming
