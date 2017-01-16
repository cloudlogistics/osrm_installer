include_recipe 'osrm'

osrm_map 'north-america' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

osrm_map 'peru' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

osrm_map 'africa' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

include_recipe 'osrm_installer::setup_routed'
