module EnabledFlags
  def enabled?(key)
    enabled_flags[key.to_sym] != "false"
  end

  def enabled_flags
    Thread.current[:enabled_flags] ||= Hash.new do |hash, key|
      Rails.cache.fetch("enabled/#{key}") { "true" }.tap do |result|
        hash[key] = result
      end
    end
  end

  def set_enabled_value(key, value)
    raise ArgumentError unless [true, false].include?(value)
    Rails.cache.write("enabled/#{key}", enabled_flags[key] = value.inspect)
  end

  def self.enabled_object
    Object.new.tap {|obj| obj.extend EnabledFlags }
  end

  def self.enabled?(key)
    enabled_object.enabled?(key)
  end

  def self.set_enabled_value(key, value)
    enabled_object.set_enabled_value(key, value)
  end
end
