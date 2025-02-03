# frozen_string_literal: true

require "rack/utils"
require "restful_error/status"
require "restful_error/version"
require "restful_error/railtie" if defined? Rails::Railtie

module RestfulError
  autoload :ExceptionsApp, "restful_error/exceptions_app"
  autoload :ApplicationController, "restful_error/application_controller"
  autoload :ExceptionsController, "restful_error/exceptions_controller"

  module Helper
    def status_data
      @status_data ||= RestfulError.build_status_from_symbol_or_code(http_status)
    end
    def response_message
      return @response_message unless @response_message.nil?
      @response_message = RestfulError.localized_phrase(self.class.name, status_data)
    end
  end

  class BaseError < StandardError
    include RestfulError::Helper
    def http_status
      raise NotImplementedError, "http_status must be implemented"
    end
  end

  @cache = {}
  class << self
    def [](code_like)
      status = RestfulError.build_status_from_symbol_or_code(code_like)
      @cache[status.code] ||= build_error_class_for(status)
    end

    def const_missing(const_name)
      status = RestfulError.build_status_from_const(const_name)
      return super unless status

      @cache[status.code] ||= build_error_class_for(status)
    end

    def init_i18n
      return if @init_i18n
      I18n.load_path += Dir["#{File.expand_path("./config/locales")}/*.yml"]
      @init_i18n = true
    end
    def localized_phrase(class_name, status)
      return false unless defined?(I18n)
      init_i18n
      class_key = RestfulError::Inflector.underscore(class_name)
      I18n.t class_key, default: [status.symbol, false], scope: :restful_error
    end

    private

    def build_error_class_for(status)
      klass = Class.new(BaseError) do
        define_method(:http_status) { status.code }
        define_method(:status_data) { status }
      end
      const_set(status.const_name, klass)
      if defined? ActionDispatch::ExceptionWrapper
        ActionDispatch::ExceptionWrapper.rescue_responses[klass.name] = status.code
        klass.define_singleton_method(:inherited) do |subclass|
          ActionDispatch::ExceptionWrapper.rescue_responses[subclass.name] = status.code
        end
      end
      klass
    end
  end
end
