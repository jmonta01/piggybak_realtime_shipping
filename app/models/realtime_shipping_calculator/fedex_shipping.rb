class RealtimeShippingCalculator::FedexShipping < RealtimeShippingCalculator
  KEYS = ["key", "password", "account", "login"]

  def self.description
    "Real-time Fedex"
  end

  def self.request_rates(method, object)
    begin
      return {} if object.weight == 0

      Rails.cache.fetch("fedex-#{object.cache_key}", :expires_in => 5.minutes) do
        h_meta = method.metadata.inject({}) { |h, b| h[b.key.to_sym] = b.value; h }

        fedex = FedEx.new(:login => h_meta[:login],
                      :password => h_meta[:password],
                      :key => h_meta[:key],
                      :account => h_meta[:account])

        origin = Location.new(:country => Piggybak.config.origin_country,
                              :city => Piggybak.config.origin_city,
                              :state => Piggybak.config.origin_state,
                              :zip => Piggybak.config.origin_zip)

        response = fedex.find_rates(origin, object.destination, object.packages, {:test => Piggybak.config.activeshipping_mode})

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
