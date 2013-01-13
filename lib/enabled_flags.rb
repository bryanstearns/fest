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

  def reset_enabled_flags!
    Thread.current[:enabled_flags] = nil
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

  module ControllerStuff
    extend ActiveSupport::Concern

    class DisabledByFlag < StandardError
      attr_accessor :flag
      def initialize(flag)
        @flag = flag
      end
    end

    included do
      prepend_before_filter :reset_enabled_flags!
      before_filter :check_for_disabled_features
      delegate :enabled?, :reset_enabled_flags!, to: :view_context
    end

    def check_enabled_flag(flag)
      disabled = !enabled?(flag)
      flag if disabled && (!block_given? || yield)
    end

    def check_for_disabled_features
      if !view_context.current_user_is_admin? &&
         !view_context.current_page?(maintenance_path)
        disabled_flag = check_enabled_flag(:site)
        disabled_flag ||= check_enabled_flag(:sign_in) do
          current_page? new_user_session_path
        end
        disabled_flag ||= check_enabled_flag(:sign_up) do
          current_page?(new_user_registration_path)
        end
        raise DisabledByFlag.new(disabled_flag) if disabled_flag
      end
    end
  end
end

Warden::Manager.after_set_user do |user, auth, opts|
  if !EnabledFlags.enabled?(:sign_in) && !user.admin?
    auth.logout
    raise EnabledFlags::ControllerStuff::DisabledByFlag.new(:sign_in)
  end
end
