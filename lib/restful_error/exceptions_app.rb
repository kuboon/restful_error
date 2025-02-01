require "abstract_controller"
require "action_controller/metal"

module RestfulError
  class ExceptionsApp
    Config = Struct.new(:enable, :inherit_from, :fallback)
    def self.config
      Config.new.tap do |config|
        config.enable = true
        config.inherit_from = "::ApplicationController"
      end
    end

    def initialize(config = self.class.config)
      @config = config
    end
    def call(env)
      return @config.fallback.call(env) unless @config.enable
      app.call(env)
    rescue Exception => _e
      raise unless @config.fallback
      @config.fallback.call(env)
    end

    def app
      @app ||= begin
        # To use "layouts/application" we need inherit from ::ApplicationController
        # It is not defined at config time, so we need to load it here
        if @config.inherit_from && Object.const_defined?(@config.inherit_from)
          inherit_from = @config.inherit_from.constantize
        else
          inherit_from = RestfulError::ApplicationController
        end
        RestfulError.const_set("SuperController", inherit_from)
        ExceptionsController.action(:show)
      end
    end
  end
end
