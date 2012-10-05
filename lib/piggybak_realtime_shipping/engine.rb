module PiggybakRealtimeShipping
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakRealtimeShipping

    require 'piggybak/config_decorator'    

    initializer "piggy_back_realtime_shipping.include_on_piggybak_cart_and_order" do 
      Piggybak::Order.send(:include, PiggybakRealtimeShipping)
      Piggybak::Cart.send(:include, PiggybakRealtimeShipping)
    end

    initializer "piggybak_realtime_shipping.add_calculators" do
      Piggybak.config do |config|
        config.shipping_calculators << "::Piggybak::ShippingCalculator::UpsShipping"
        config.shipping_calculators << "::Piggybak::ShippingCalculator::UspsShipping"
        config.shipping_calculators << "::Piggybak::ShippingCalculator::FedEx"
      end
    end
  end
end
