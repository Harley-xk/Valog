#!/bin/sh

#  redepoly.sh
#  Valog
#
#  Created by Harley-xk on 2020/3/13.
#

git stash
git pull

vapor fetch
vapor build --verbose

supervisorctl restart Valog
