INSTALLER FOR https://github.com/Project-OSRM/osrm-backend

1. Open config/deploy.rb and change the host
2. Make sure ubuntu user is present on the server with passwordless sudo access

To set up osrm on such a machine, run:

`cap mana:setup`



NOTES:

We install maps for Peru. Africa and North America. For North America Latest (being largest map):

1. Map extraction and contraction takes large amounts of time. Use a 32 core, 120 GB ram with min ~100 gb harddisk for getting the entire setup. Do not require anything higher than that.

2. Old version is maintained at api.distance-source.gocloudlogistics.com and installer for that is available at https://github.com/cloudlogistics/osrm_installer/tree/osrm-0.4.2
