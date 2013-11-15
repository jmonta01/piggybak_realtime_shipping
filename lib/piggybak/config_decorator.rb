Piggybak::Config.class_eval do
  class << self
    attr_accessor :activeshipping_mode
    attr_accessor :origin_country
    attr_accessor :origin_state
    attr_accessor :origin_zip
    attr_accessor :origin_city

    alias_method :core_reset, :reset
    def reset
      core_reset
      @activeshipping_mode = :test #:production #test
      @origin_country = "US"
      @origin_city = "New York"
      @origin_state = "NY"
      @origin_zip = "10001"
    end
  end
end
