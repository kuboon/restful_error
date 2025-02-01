require "restful_error/exceptions_app"

module RestfulError
  class Railtie < Rails::Railtie
    config.restful_error = ActiveSupport::OrderedOptions.new
    config.restful_error.exceptions_app = RestfulError::ExceptionsApp.config
    config.restful_error.exceptions_app.fallback = ActionDispatch::PublicExceptions.new(Rails.public_path)

    initializer "restful_error.exceptions_app", before: :build_middleware_stack do |app|
      app.config.exceptions_app = RestfulError::ExceptionsApp.new
    end
  end
end
