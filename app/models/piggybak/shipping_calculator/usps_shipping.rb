require 'active_shipping'

module Piggybak
  class ShippingCalculator::UspsShipping
    include ActiveMerchant::Shipping

    KEYS = ["login", "password", "service_name"]

    def self.request_rates(method, object)
      begin
        return {} if object.weight == 0

        Rails.cache.fetch("usps-#{object.cache_key}", :expires_in => 5.minutes) do
          h_meta = method.metadata.inject({}) { |h, b| h[b.key.to_sym] = b.value; h }

          usps = USPS.new(:login => h_meta[:login],
                          :password => h_meta[:password])

          origin = Location.new(:country => Piggybak.config.origin_country,
                                :state => Piggybak.config.origin_state,
                                :city => Piggybak.config.origin_city,
                                :zip => Piggybak.config.origin_zip)

          response = usps.find_rates(origin, object.destination, object.packages, {Piggybak.config.activeshipping_mode})

          calculated_rates = {}

          response.rates.each do |rate|
            freight = rate.total_price.to_f / 100

            next if rate.service_name == 'USPS Media Mail' && object.weight < 16
            next if rate.service_name == 'USPS First-Class Mail Parcel' && object.weight >= 14

            # padding based on destination and weight
            padding = (object.weight >= 14 || object.destination.country.to_s != 'United States') ? 3.00 : 1.50 

            handling = ((object.line_item_total + freight)*0.03).to_c + padding

            calculated_rates[rate.service_name] = ((freight + handling)*100).to_i.to_f / 100
          end

          calculated_rates
        end
      rescue Exception => e
        Rails.logger.warn "Shipping calculation issue: #{e.inspect}"
        return {}
      end
    end

    def self.available?(method, object)
      rates = request_rates(method, object)

      h_meta = method.metadata.inject({}) { |h, b| h[b.key.to_sym] = b.value; h }

      rates.has_key?(h_meta[:service_name])
    end 

    def self.rate(method, object)
      rates = request_rates(method, object)

      h_meta = method.metadata.inject({}) { |h, b| h[b.key.to_sym] = b.value; h }
      rates[h_meta[:service_name]] || 0
    end 
  end
end
