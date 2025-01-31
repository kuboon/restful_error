# frozen_string_literal: true

require "rack/utils"
require "restful_error/railtie" if defined? ActionController
require "restful_error/status"
require "restful_error/version"

I18n.load_path += Dir["#{File.expand_path("../config/locales")}/*.yml"] if defined? I18n

module RestfulError
  class BaseError < StandardError
    attr_reader :response_message
    def initialize(message = nil)
      @response_message = message
      super
    end
  end

  module Helper
    def restful
      raise NotImplementedError, "http_status must be implemented by including class" unless respond_to?(:http_status)

      @restful ||= RestfulError.build_status_from_symbol_or_code(http_status)
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

    private

    def build_error_class_for(status)
      message = defined?(I18n) ? I18n.t(status.symbol, default: status.reason_phrase, scope: :restful_error) : status.reason_phrase
      klass = Class.new(BaseError) do
        define_method(:http_status) { status.code }
        define_method(:restful) { status }
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
