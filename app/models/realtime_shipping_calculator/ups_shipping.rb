class RealtimeShippingCalculator::UpsShipping < RealtimeShippingCalculator
  KEYS = ["login", "password", "key", "service_name", "origin_account"]

  def self.description
    "Real-time UPS"
  end

  def self.available?(method, object)
    object.items.length > 0
  end

  def self.request_rates(method, object)
    begin
      return {} if object.weight == 0

      Rails.cache.fetch("ups-#{object.cache_key}", :expires_in => 5.minutes) do
        h_meta = method.metadata.inject({}) { |h, b| h[b.key.to_sym] = b.value; h }

        ups = UPS.new(:login => h_meta[:login],
                      :password => h_meta[:password],
                      :key => h_meta[:key],
                      :origin_account => h_meta[:origin_account])

        origin = Location.new(:country => Piggybak.config.origin_country,
                              :state => Piggybak.config.origin_state,
                              :city => Piggybak.config.origin_city,
                              :zip => Piggybak.config.origin_zip)

        response = ups.find_rates(origin, object.destination, object.packages, {:test => Piggybak.config.activeshipping_mode})

        calculated_rates = {}
        response.rates.each do |rate|
          next if rate.total_price == 0
          calculated_rates[rate.service_name] = rate.total_price.to_f / 100
        end
        calculated_rates
      end
    rescue Exception => e
      Rails.logger.warn "Shipping calculation issue: #{e.inspect}"
      return {}
    end
  end
end
