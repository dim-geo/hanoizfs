# hanoizfs
Infinite hanoi rotation backup  (zfs)

http://en.wikipedia.org/wiki/Backup_rotation_scheme#Towers_of_Hanoi

http://lists.debian.org/debian-bsd/2011/12/msg00045.html

use cron or systemd.timer to call hanoizfs.sh periodically

first argument is the duration of a 'day' in seconds, if you want to take daily backups then 86400

second argument is the pool name

third argument is the filesystem name: pool/fs
