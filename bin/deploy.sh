#!/bin/sh

# This presumes Nginx is installed and has an upstart script.
scp deployment/data/post-receive server:/root/

ssh server << SCRIPT
if ! test -d /repos/101ideas.cz; then
  git init --bare /repos/101ideas.cz
fi

if ! test -d /repos/blog.101ideas.cz; then
  git init --bare /repos/blog.101ideas.cz
fi

cp /root/post-receive /repos/101ideas.cz/hooks/
chmod +x /repos/101ideas.cz/hooks/post-receive

cp /root/post-receive /repos/blog.101ideas.cz/hooks/
chmod +x /repos/blog.101ideas.cz/hooks/post-receive

rm /root/post-receive
SCRIPT
