require 'active_shipping'

class RealtimeShippingCalculator
  include ActiveMerchant::Shipping

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
