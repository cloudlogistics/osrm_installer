#### Installer for Open Source Routing Machine (OSRM)

##### To user this installer, the following are required:

1. A high performance server ~( 32 cores, 120 GB RAM and min 100GB HDD), for generating files required for osrm-routed to run.
2. A smaller server ~( 4 cores, 32GB RAM and ~100GB HDD). The more the cores, the more the threads that can be run.
3. Each server should have user 'ubuntu' or any user with passwordless sudo permission

##### To configure the script for these servers:

Open config/deploy.rb and look for `server` directive. Update the ip-addresses on :map_generation_env with the IP address of the performance machine and :map_execution_env with that of smaller server.

Now, run:

`cap mana:setup`

This will prepare both servers with all runtime requirements before map generatiopn. The steps in the process are:

1. clone and build OSRM in the perf machine.
2. Generate files required for running OSRM from map data (from openstreetmaps)
3. generate ssh key pair in smaller machine, and copy its public key to perf machine.
4. rsync map executables and from perf machine to small machine
5. generate init files for osrm-north-america, peru and africa
6. Start OSRM routed.

These steps are executed in sequence. To install all the three maps, viz., North America, Africa and Peru, it should take at least 5 to 6 hours.

##### To update OSRM version

To change the version of installed OSRM backend, update `default['osrm']['branch']` value. This setting can be found in `attributes/default.rb`


NOTES:

We install maps for Peru. Africa and North America. For North America Latest (being largest map):

1. Map extraction and contraction takes large amounts of time. Use a 32 core, 120 GB ram with min ~100 gb harddisk for getting the entire setup. Do not require anything higher than that.

2. An older version is maintained at api.distance-source.gocloudlogistics.com and installer for that is available at https://github.com/cloudlogistics/osrm_installer/tree/osrm-0.4.2
