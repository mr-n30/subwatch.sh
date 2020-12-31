#!/bin/bash -e

# Where to save output
OUTPUT_DIR=$1
# Path to file we're going to run crt.sh on
INPUT_FILE=$2

# Make sure to setup /etc/ssmtp/ssmtp.conf
# with proper credentials
# Where to send mail to
RECIPIENT=

if [[ "$#" -ne 2  ]]
then
    echo -e "Usage:\n  $0 <directory> <file>"
    echo -e "Example:\n  $0 /home/work/ /home/wordlists/domains.txt"
    exit 1
fi

for DOMAIN in $(cat $INPUT_FILE); do
    # Create directories to save output to
    # if it doesn't already exist
    mkdir -p $OUTPUT_DIR/$DOMAIN

    # If old.txt does exist then
    # create new.txt
    if test -f $OUTPUT_DIR/$DOMAIN/old.txt; then
            curl -s "https://crt.sh/?q=$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > $OUTPUT_DIR/$DOMAIN/new.txt

            # Check if files are the same
            # and contain no diffs
            if cmp -s $OUTPUT_DIR/$DOMAIN/old.txt $OUTPUT_DIR/$DOMAIN/new.txt; then
                # Do nothing
                echo "[+] Files are the same..."
                echo "[+] Nothing to do..."

            # If they do contain diffs then
            # check what they are, write it
            # to a file, and send it via
            # email
            else
                #echo "[DEBUG] Files contain differences. SENDING EMAIL NOW."
                echo "Subject: New subdomain(s) found on: $DOMAIN" > $OUTPUT_DIR/$DOMAIN/diff.txt
                echo "Subdomain(s): " >> $OUTPUT_DIR/$DOMAIN/diff.txt
                diff $OUTPUT_DIR/$DOMAIN/old.txt $OUTPUT_DIR/$DOMAIN/new.txt | awk -F'>' ' { print $2 } ' | sed 's/\s//g' | sed '/^$/d' >> $OUTPUT_DIR/$DOMAIN/diff.txt
                ssmtp $RECIPIENT < $OUTPUT_DIR/$DOMAIN/diff.txt

                # Cleanup and mv new.txt into old.txt
                # thus on the next run a new.txt will
                # be created
                mv $OUTPUT_DIR/$DOMAIN/new.txt $OUTPUT_DIR/$DOMAIN/old.txt

                # TODO:
                # Add screenshot functionality via aquatone
                # and send it as an email attachment or HTML <img>
            fi

    # Else if old.txt doesn't exist then
    # create it
    else
            curl -s "https://crt.sh/?q=$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > $OUTPUT_DIR/$DOMAIN/old.txt
    fi
done

