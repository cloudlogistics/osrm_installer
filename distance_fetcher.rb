require 'net/http'

class DistanceFetcher

  SERVER_URL="54.185.77.65"

  def self.run(limit=nil)
    summary = []
    total_time = Benchmark.ms do
      # scope = Delivery.where(state: :delivered).where("coalesce(distance_value, 0.0) > 0.0").includes(:stops => :address)
      scope = Delivery.where(state: :delivered).where("coalesce(distance_value, 0.0) > 0.0").includes(:stops => :address)
      scope = scope.limit(limit) if limit
      scope.all.in_groups_of(100).each_with_index do |group, i|
        time_per_100 = Benchmark.ms do
          group.each do |d|
            next if d.blank?
            begin
              if d.stops.all? { |s| a = s.address; a.present? && a.lat.present? && a.lng.present? }
                path_params = d.stops.map { |v| "loc=#{v.address.lat},#{v.address.lng}" }.join("&")
                url = URI.parse("http://#{SERVER_URL}:5000/viaroute?" + path_params)
                req = Net::HTTP::Get.new(url.request_uri)
                res = nil
                req_time = Benchmark.ms do
                  res = Net::HTTP.start(url.host, url.port) { |http|
                    http.request(req)
                  }
                end
                body = JSON.parse(res.body)
                if body["route_summary"].present? && body["route_summary"]["total_distance"].to_f > 0.0
                  dist = body["route_summary"]["total_distance"].to_f / 1000 * 0.621371
                  margin = (d.distance_value - dist).abs
                  p "id #{d.id}, distance set #{d.distance_value}, #distance calculated #{dist}. Accuracy #{margin} "
                  summary << [d.id, d.distance_value, dist, margin, req_time]
                end
              end
            rescue => e
              p e
            end
          end
        end

        p "Time per 100 #{time_per_100} for #{i}rd group"
      end
    end

    p "Total process time #{total_time}"

    p summary.map { |v| v[2] }.sum / summary.size


    # CSV.open(Rails.root.join("file123.csv"), "wb") do |csv|
    #   csv << ["ID", "Exist", "Requested", "difference", "req_time"]
    #   summary.each do |summar|
    #     csv << summar
    #   end
    # end 
    # p "File generated"

  end

end