# subwatch.sh
A bash script to check for new subdomains

## Prerequisites:
Make sure to setup your `/etc/ssmtp/ssmtp.conf` file. This script will send an email using the credentials in that file via ssmtp linux command.

## Usage:
```bash
# ./subwatch.sh <directory> <file>
```

## Example:
```bash
# ./subwatch.sh /home/work/ /home/wordlists/domains.txt
```
