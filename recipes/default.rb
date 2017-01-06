include_recipe 'osrm'

osrm_map 'peru' do
  action          :create
  user            'ubuntu'
  stxxl_size      250000
  stxxl_file      '/tmp/stxxl'
end

osrm_routed 'peru' do
  user   'osrm'
  listen '0.0.0.0'
  port   5001
end
