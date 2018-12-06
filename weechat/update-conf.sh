#!/bin/sh
diff -ru conf/ ~/.weechat/ | patch -p0 -s
