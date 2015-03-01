require 'webrick/httpstatus'
require 'webrick/accesslog'

RestfulError = WEBrick::HTTPStatus

load "restful_error/version.rb"
require 'restful_error/engine'
require 'restful_error/wrapper'

module RestfulError
  CodeToError.each do |_, klass|
    code = klass::code
    reason_phrase = klass::reason_phrase
    klass.class_exec do
      define_method(:status_code, ->{ code })
      define_method(:reason_phrase, ->{ reason_phrase })
    end
  end

  module Helper
    def restful
      @restful ||= Wrapper.new(self)
    end
  end

  module ActionController
    def render_exception(ex)
      @exception     = ex.extend(Helper)
      ex.restful.set_env(env)
      @status_code   = ex.restful.status_code
      @reason_phrase = ex.restful.reason_phrase
      @message       = ex.restful.message

      raise if @status_code == 500 && Rails.configuration.consider_all_requests_local

      respond_to do |format|
        format.any(:json, :xml, :html){ render 'restful_error/show', status: @status_code }
      end
    end
    def self.included(base)
      base.rescue_from StandardError do |ex|
        render_exception ex
      end
    end
  end
end
