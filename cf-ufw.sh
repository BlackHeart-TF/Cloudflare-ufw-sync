#!/bin/zsh

# Define the comment for Cloudflare IPs
cf_comment="Cloudflare IP"

# Fetch the latest Cloudflare IPs (IPv4 and IPv6)
cloudflare_ips=$(curl -s https://www.cloudflare.com/ips-v{4,6})

# Loop through the list of Cloudflare IPs
for cfip in $cloudflare_ips; do
    # Check if there's an existing rule for this Cloudflare IP and comment
    if ! ufw status numbered | grep -q "$cfip.*$cf_comment"; then
        # If not, add the rule for the current Cloudflare IP
        ufw allow proto tcp from $cfip to any port 80,443 comment "$cf_comment"
    fi
done
#regex='[\ []\s*\S+[]\ ]\s((\S+)(\/\d+)?\s)?([0-9,]+)\/([a-z]+)(\s\(v6\))?\s+(ALLOW|DENY)\s(IN|OUT)\s+(\S+)(\s\(v6\))?\s*(\(out\)\s)?(# .+)?'
regex="\[\s*(\S+)\]\s((\S+)(\/\d+)?\s)?([0-9,]+)\/([a-z]+)(\s\(v6\))?\s+(ALLOW|DENY)\s(IN|OUT)\s+(\S+)(\s\(v6\))?\s*(\(out\)\s)?(# .+)?"
# Loop through all rules to find and remove any rules that no longer apply
echo $regex
ufw status numbered | grep "$cf_comment" | while read -r line; do
    # Match the full UFW rule with a regex to capture the rule number, IP, and ports

    if [[ "$line" =~ $regex ]]; then
        rule_num="${match[1]}"      # Rule number (e.g., [1], [2], etc.)
        ip_address="${match[10]}"     # IP address (either from or to)
        port="${match[5]}"           # Port(s) (e.g., 80,443/tcp)
        proto="${match[6]}"
        # Check if the IP address is in the Cloudflare list
        if ! echo "$cloudflare_ips" | grep -q "$ip_address"; then
            # If not, delete the rule
            echo "Deleting rule $rule_num for IP: $ip_address on port: $port"
            ufw delete $rule_num
        fi
    fi
done

# Reload UFW to apply changes
ufw reload > /dev/null

#"\[\s*(\d+)\]\s((\d+\.\d+\.\d+\.\d+)(\/\d+)?\s)?(\S+)\s+(ALLOW|DENY)\s(IN|OUT)\s+(\S+)\s*(\(out\)\s)?(# .+)?"