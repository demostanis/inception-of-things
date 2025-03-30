#!/bin/sh

# https://stackoverflow.com/questions/47948887/login-to-gitlab-with-username-and-password-using-curl

gitlab_host="https://gitlab.demolinux.local"
gitlab_user="root"
gitlab_password="$(make -s gitlab-initial-password)"

trap 'rm -f cookies.txt' EXIT

body_header=$(curl -k -c cookies.txt -i "${gitlab_host}/users/sign_in" -s)

csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /csrf-token"[[:blank:]]content="(.+?)"/' | sed -n 1p)

curl -k -b cookies.txt -c cookies.txt -i "${gitlab_host}/users/sign_in" \
    --data "user[login]=${gitlab_user}&user[password]=${gitlab_password}" \
    --data-urlencode "authenticity_token=${csrf_token}" -s >/dev/null

body_header=$(curl -k -H 'user-agent: curl' -b cookies.txt -i "${gitlab_host}/-/user_settings/personal_access_tokens" -s)
csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /csrf-token"[[:blank:]]content="(.+?)"/' | sed -n 1p)

body_header=$(curl -k -L -b cookies.txt "${gitlab_host}/-/user_settings/personal_access_tokens" \
    --data-urlencode "authenticity_token=${csrf_token}" \
    --data 'personal_access_token[name]=golab-generated&personal_access_token[expires_at]=&personal_access_token[scopes][]=api' -s)

echo "$body_header" | jq -r .new_token
