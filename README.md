INSTALLER FOR https://github.com/Project-OSRM/osrm-backend

1. Open config/deploy.rb and change the hosts, map_generation_env for machine in which map is prepared and map_execution_env for host in which the prepared osrm-installer is copied and run.
2. Make sure ubuntu user is present on both the servers with passwordless sudo access

To set up osrm on these machines, run:

`cap mana:setup`



NOTES:

We install maps for Peru. Africa and North America. For North America Latest (being largest map):

1. Map extraction and contraction takes large amounts of time. Use a 32 core, 120 GB ram with min ~100 gb harddisk for getting the entire setup. Do not require anything higher than that.

2. Old version is maintained at api.distance-source.gocloudlogistics.com and installer for that is available at https://github.com/cloudlogistics/osrm_installer/tree/osrm-0.4.2
