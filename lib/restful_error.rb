# frozen_string_literal: true

require "rack/utils"
require "restful_error/railtie" if defined? ActionController
require "restful_error/status"

I18n.load_path += Dir["#{File.expand_path("../config/locales")}/*.yml"]

module RestfulError
  class BaseError < StandardError; end

  module Helper
    def restful
      raise NotImplementedError, "http_status must be implemented by including class" unless respond_to?(:http_status)

      @restful ||= Status.new(RestfulError.code_from(http_status))
    end
  end

  @cache = {}
  class << self
    def [](code_like)
      code = RestfulError.code_from(code_like)
      @cache[code] ||= build_error_class_for(code)
    end

    def const_missing(const_name)
      code = RestfulError.code_from(const_name)
      return super unless code

      @cache[code] ||= build_error_class_for(code)
    end

    private

    def build_error_class_for(code)
      status = Status.new(code)
      message = I18n.t status.symbol, default: status.reason_phrase, scope: :restful_error
      klass = Class.new(BaseError) do
        define_method(:http_status) { status.code }
        define_method(:restful) { status }
        define_method(:message) { message }
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
