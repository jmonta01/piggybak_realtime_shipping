module PiggybakRealtimeShipping
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakRealtimeShipping

    require 'piggybak/config_decorator'    
    require 'piggybak_realtime_shipping/order_decorator'
    require 'piggybak_realtime_shipping/cart_decorator'

    config.to_prepare do
      Piggybak::Order.send(:include, ::PiggybakRealtimeShipping::OrderDecorator)
      Piggybak::Cart.send(:include, ::PiggybakRealtimeShipping::CartDecorator)
    end

    initializer "piggybak_realtime_shipping.reset_config" do
      Piggybak.config.reset
    end

    initializer "piggybak_realtime_shipping.add_calculators" do
      Piggybak.config do |config|
        config.shipping_calculators << "::RealtimeShippingCalculator::UpsShipping"
        config.shipping_calculators << "::RealtimeShippingCalculator::UspsShipping"
        config.shipping_calculators << "::RealtimeShippingCalculator::FedexShipping"
      end
    end
  end
end
