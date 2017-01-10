include_recipe 'osrm'

osrm_map 'north-america' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

osrm_routed 'north-america' do
  user   'ubuntu'
  listen '0.0.0.0'
  port   5000
end

osrm_map 'peru' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

osrm_routed 'peru' do
  user   'ubuntu'
  listen '0.0.0.0'
  port   5001
end

osrm_map 'africa' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

osrm_routed 'africa' do
  user   'ubuntu'
  listen '0.0.0.0'
  port   5002
end
