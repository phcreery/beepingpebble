import os

inf := $embed_file('.beepingpebble/apps/welcome.desktop')

write_file('de2', inf.to_string()) or { panic('file not writable') }
