module RestfulError
  class Wrapper
    def initialize(ex)
      @ex = ex
    end
    def set_env(env)
      @env = env
    end
    def status_code
      Rack::Utils.status_code(@ex.try(:status_code)).nonzero? || ActionDispatch::ExceptionWrapper.new(@env, @ex).status_code
    end
    def reason_phrase
      RestfulError.reason_phrase(status_code)
    end
    def reason_phrase_key
      reason_phrase.downcase.gsub(/\s|-/, '_').to_sym
    end
    def message
      return message if message = @ex.try(:status_message)
      I18n.t @ex.class.name.underscore, default: [reason_phrase_key, @ex.class.name], scope: :restful_error
    end
  end
end
