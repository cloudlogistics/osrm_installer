INSTALLER FOR https://github.com/DennisOSRM/Project-OSRM

To set up a barebones machine,

`cap mana:setup`

NOTES:

For North America Latest map:

1. The map extraction takes most of the time, and can run in threads, means the more the cpus the machine has, the better it is. With 4 cores, it took almost 3 hours. Recommended 8 cores or more.

2. Need min 100gb of hard disk space. This can help increasing the performance as osrm depends on stxxl. Check `config/cookbooks/osrm/providers/map_extract.rb`

3. 32 GB ram is not sufficient, as the step, osrm-prepare (step 1: osrm-extract, step 2: osrm-prepare) just ran out of 32 GB we had. Recommended 128GB.
