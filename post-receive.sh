#!/bin/sh

# This post-receive hook can be used on server of a gogs or gitea
# installation to send information about new commits into a MS-Teams
# channel.
#
# Here you can find more information about hooks in git in general:
#
# https://git-scm.com/book/gr/v2/Customizing-Git-Git-Hooks
#
# post-receive
#
# The post-receive hook runs after the entire process is completed and
# can be used to update other services or notify users. It takes the
# same stdin data as the pre-receive hook.

# The target URL of the webhook
URL="https://outlook.office.com/webhook/ADD_YOU_URL"

# conforms to "PRETTY FORMATS" in 'man git log'
# It can be formatted with markdown syntax.
GIT_MSG_TEMPLATE="**%an** made a new Commit: *%s*%n"

#####

# some information for the committer (displayed during git push)
echo "Sending information to the Office365-Team"

# reading changed references from stdin
STDIN=$(cat <&0)
REF1=$(echo $STDIN|cut -d ' ' -f 1)

# Fetch last commit message and format output
MSG=$(git log --pretty=format:$GIT_MSG_TEMPLATE $REF1..HEAD)

# template for MS-Teams message cards
# https://docs.microsoft.com/en-us/outlook/actionable-messages/actionable-messages-via-connectors
DATA="
{
  '@context': 'http://schema.org/extensions',
  '@type': 'MessageCard',
  'themeColor': '0072C6',
  'title': 'Neuer Commit',
  'text': '$MSG',
}"

# sending post request to the web service
curl -s -d "$DATA" -X POST "$URL" >> /dev/null
