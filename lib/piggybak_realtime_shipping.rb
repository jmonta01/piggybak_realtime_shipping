require "piggybak_realtime_shipping/engine"

module PiggybakRealtimeShipping
  def weight

    result = 0

    self.items.each do |li|
      result += li[:variant].item.item.weight.to_f*li[:quantity]
    end
    result
  end


  def packages
    []
  end

  def destination
    location = self.cart? ? location_from_cart : location_from_order
    ActiveMerchant::Shipping::Location.new(
     :country => location[:country],
     :state   => location[:state],
     :city    => location[:city],
     :zip     => location[:zip],
     :address_type => location[:address_type])
  end

  def cart?
    self.respond_to?(:extra_data)
  end

  def location_from_cart
    {:country => Piggybak::Country.find(self.extra_data[:country_id]).abbr,
     :state   => Piggybak::State.find(self.extra_data[:state_id]),
     :city    => self.extra_data[:city],
     :zip     => self.extra_data[:zip],
     :address_type => (self.extra_data[:residential_check] == "true" ? "residential" : "commercial")}
  end

  def location_from_order
    {:country => self.address.country.abbr,
     :state   => self.address.state ? self.address.state.abbr : self.address.state_id, 
     :city    => self.address.city,
     :zip     => self.address.zip,
     :address_type => (self.residential_shipping ? "residential" : "commercial")}
  end
end
