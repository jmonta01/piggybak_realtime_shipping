module PiggybakRealtimeShipping
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakRealtimeShipping
    
    initializer "piggybak_realtime_shipping.add_calculators" do
      Piggybak.config do |config|
        config.shipping_calculators << "::Piggybak::ShippingCalculator::UspsShipping"
        config.shipping_calculators << "::Piggybak::ShippingCalculator::UpsShipping"
      end
    end
  end
end
