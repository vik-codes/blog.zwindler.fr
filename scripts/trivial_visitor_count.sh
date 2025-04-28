#!/bin/bash
cd /var/log/nginx
zgrep -v "[A-z]*[bB]ot" newblog.access.log newblog.access.log.1 newblog.access.log.[2-6].gz  | grep -e "GET /20../../../"  | wc -l
