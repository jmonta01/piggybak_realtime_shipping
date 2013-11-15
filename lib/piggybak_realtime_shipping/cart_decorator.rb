require "piggybak_realtime_shipping/engine"


module PiggybakRealtimeShipping
  module CartDecorator
    extend ActiveSupport::Concern

    def weight
      result = 2
  
      # self.items.each do |li|
      #   result += li[:variant].item.weight.to_f*li[:quantity]
      # end
      result
    end
  
    def packages
      [ActiveMerchant::Shipping::Package.new(self.weight, [], :units => :imperial)]
    end
  
    def destination
      country = Piggybak::Country.find(self.extra_data[:country_id])
      state = Piggybak::State.find(self.extra_data[:state_id])

      location = ActiveMerchant::Shipping::Location.new(:country => country.abbr,
                               :state => state ? state.abbr : self.extra_data[:state_id],
                               :city => self.extra_data[:city],
                               :zip => self.extra_data[:zip])

      location      
    end

    def cache_key
      cart_info = self.items.map { |i| "#{i[:variant].id}-#{i[:quantity]}" }.join('--')
      self.extra_data ||= {}
      cache_key = "#{cart_info}-#{self.extra_data[:country_id]}-#{self.extra_data[:state_id]}-#{self.extra_data[:zip]}-#{self.extra_data[:city]}"
      Digest::MD5.hexdigest(cache_key)
    end
  end
end
