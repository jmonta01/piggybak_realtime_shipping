require 'active_shipping'

module Piggybak
  class ShippingCalculator::FedEx
    include ActiveMerchant::Shipping

    KEYS = ["key", "password", "account", "login"]

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
          response = fedex.find_rates(origin, object.destination, object.packages, {Piggybak.config.activeshipping_mode})

          calculated_rates = {}
          response.rates.each do |rate|
            next if rate.total_price == 0

            freight = rate.total_price.to_f / 100

            handling = ((object.line_item_total + freight)*0.03).to_c + 3.00

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
      return false if object.weight < 14

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
