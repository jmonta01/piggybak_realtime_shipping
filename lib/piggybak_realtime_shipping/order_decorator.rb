require "piggybak_realtime_shipping/engine"

module PiggybakRealtimeShipping
   module OrderDecorator
    extend ActiveSupport::Concern

    def weight
      result = 0
  
      self.line_items.each do |li|
        if !li._destroy
          weight += li.variant.item.weight.to_f*li.quantity.to_i
        end
      end
  
      result
    end
  
    def packages
      [ActiveMerchant::Shipping::Package.new(self.weight, [], :units => :imperial)]
    end
  
    def destination
      address = self.shipping_address
  
      location = ActiveMerchant::Shipping::Location.new(:country => address.country.abbr,
                                   :state => address.state ? address.state.abbr : address.state_id,
                                   :city => address.city,
                                   :zip => address.zip)
  
      location
    end

   def cache_key
      li_details = []
      self.line_items.each do |li|
        if !li._destroy
          li_details << "#{li.variant_id}-#{li.quantity.to_i}"
        end
      end
      cart_info = li_details.join('--')
  
      address = self.shipping_address
        cache_key = "#{cart_info}-#{address.country_id}-#{address.state_id}-#{address.zip}-#{address.city}-#{self.residential_shipping}"
      Digest::MD5.hexdigest(cache_key)
    end
  end
end
