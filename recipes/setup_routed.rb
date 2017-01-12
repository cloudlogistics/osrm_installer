osrm_routed 'north-america' do
  user   'ubuntu'
  listen '0.0.0.0'
  port   5000
end

osrm_routed 'peru' do
  user   'ubuntu'
  listen '0.0.0.0'
  port   5001
end

osrm_routed 'africa' do
  user   'ubuntu'
  listen '0.0.0.0'
  port   5002
end
