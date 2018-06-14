# -*- coding: utf-8 -*-
#
# Copyright (C) 2006-2012 Sebastien Helleu <flashcode@flashtux.org>
# Copyright (C) 2011 Nils Görs <weechatter@arcor.de>
# Copyright (C) 2011 ArZa <arza@arza.us>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Run command on highlight/private message or new DCC.
#
# History:
#
# 2012-01-03, Sebastien Helleu <flashcode@flashtux.org>:
#     version 0.8: make script compatible with Python 3.x
# 2011-04-16, ArZa <arza@arza.us>:
#     version 0.7: fix default beep command
# 2011-03-11, nils_2 <weechatter@arcor.de>:
#     version 0.6: add additional command options for dcc and highlight
# 2011-03-09, nils_2 <weechatter@arcor.de>:
#     version 0.5: add option for beep command and dcc
# 2009-05-02, Sebastien Helleu <flashcode@flashtux.org>:
#     version 0.4: sync with last API changes
# 2008-11-05, Sebastien Helleu <flashcode@flashtux.org>:
#     version 0.3: conversion to WeeChat 0.3.0+
# 2007-08-10, Sebastien Helleu <flashcode@flashtux.org>:
#     version 0.2: upgraded licence to GPL 3
# 2006-09-02, Sebastien Helleu <flashcode@flashtux.org>:
#     version 0.1: initial release
#

SCRIPT_NAME    = 'beep'
SCRIPT_AUTHOR  = 'Sebastien Helleu <flashcode@flashtux.org>'
SCRIPT_VERSION = '0.8'
SCRIPT_LICENSE = 'GPL3'
SCRIPT_DESC    = 'Run command on highlight/private message or new DCC'

import_ok = True

try:
    import weechat
except:
    print('This script must be run under WeeChat.')
    print('Get WeeChat now at: http://www.weechat.org/')
    import_ok = False

try:
    import os, sys
except ImportError as message:
    print('Missing package(s) for %s: %s' % (SCRIPT_NAME, message))
    import_ok = False

beep_default_options = {
    'highlight' : '$bell',
    'pv'        : '$bell',
    'dcc'       : '$bell',
}
beep_options = {}

def init_config():
    global beep_default_options, beep_options
    for option, default_value in beep_default_options.items():
        if not weechat.config_is_set_plugin(option):
            weechat.config_set_plugin(option, default_value)
        beep_options[option] = weechat.config_get_plugin(option)

def config_changed(data, option, value):
    init_config()
    return weechat.WEECHAT_RC_OK

def beep_cb(data, signal, signal_data):
    global beep_options
    if beep_options[data]:
        if beep_options[data] == '$bell':
            f = open('/dev/tty', 'w')
            f.write('\a')
            f.close()
        else:
            os.system(beep_options[data])
    return weechat.WEECHAT_RC_OK

if __name__ == '__main__' and import_ok:
    if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION,
                        SCRIPT_LICENSE, SCRIPT_DESC, '', ''):
        init_config()
        weechat.hook_config('plugins.var.python.%s.*' % SCRIPT_NAME, 'config_changed', '')
        weechat.hook_signal('weechat_highlight', 'beep_cb', 'highlight')
        weechat.hook_signal('irc_pv', 'beep_cb', 'pv')
        weechat.hook_signal('irc_dcc', 'beep_cb', 'dcc')
