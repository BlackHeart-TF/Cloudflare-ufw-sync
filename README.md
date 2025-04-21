# Cloudflare-ufw-sync
Automatically sync cloudflare's IP address list with UFW. 
It uses comments to track its own entries, making it safe to use with existing UFW setups, just remove any cloudflare ones first.

## Requirements
- Needs **zsh** for the RegEx implementation
- obviously needs **ufw** firewall
- and **curl** to pull the updated IP lists from cloudflare

## setup
Simply Run the script to add the current cloudflare proxy IP addresses, and remove old ones, if they were added from the script before.
This should be safe to use in existing UFW configurations, but as always, make a backup before testing.

```bash
sudo ./cf-ufw.sh
```

you can make it self updating with a cron job
```bash
sudo crontab -e
```

add a line like this to run weekly
```cron
0 0 * * 1 /your/path/to/cf-ufw.sh > /dev/null 2>&1
```

## Issues
Please report any issues, or volenteer to give a bash friendly regex line