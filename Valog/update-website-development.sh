#!/bin/sh

#  update-website-development.sh
#  Valog
#
#  Created by Harley-xk on 2020/2/28.
#

export PATH="$PATH:"/usr/local/bin/
cd /root/Projects/nuxt-pages
git stash
git pull
npm run build
supervisorctl restart nuxt-pages
