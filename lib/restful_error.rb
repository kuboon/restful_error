require 'webrick/httpstatus'
require 'webrick/accesslog'

RestfulError = WEBrick::HTTPStatus

require "restful_error/version"
require "restful_error/engine"

module RestfulError
  CodeToError.each do |_, klass|
    code = klass::code
    reason_phrase = klass::reason_phrase
    klass.class_exec do
      define_method(:status_code, ->{ code })
      define_method(:reason_phrase, ->{ reason_phrase })
    end
  end

  module ActionController
    def self.included(base)
      base.rescue_from StandardError do |ex|
        @exception   = ex
        @status_code = Rack::Utils.status_code(@exception.try(:status_code)).nonzero? || ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
        raise if @status_code == 500 && Rails.configuration.consider_all_requests_local

        @message = @exception.message
        default_message = @exception.class.new.message rescue nil

        if @message == default_message
          reason_phrase_key = RestfulError.reason_phrase(@status_code).downcase.gsub(/\s|-/, '_').to_sym
          @message = I18n.t @exception.class.name.underscore, default: [reason_phrase_key, @exception.class.name], scope: :restful_error
        end

        respond_to do |format|
          format.any(:json, :xml, :html){ render 'restful_error/show', status: @status_code }
        end
      end
    end
  end
end
