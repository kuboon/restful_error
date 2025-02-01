require "abstract_controller"
require "action_controller/metal"

module RestfulError
  class ExceptionsController < ::ActionController::Metal
    include AbstractController::Rendering
    include ActionView::Layouts
    include ActionController::Rendering

    def self.controller_path = "restful_error"
    append_view_path File.join(File.dirname(__FILE__), "../../app/views")
    layout nil

    def show
      @exception = request.env["action_dispatch.exception"]
      code = request.path_info[1..].to_i
      status = RestfulError.build_status_from_symbol_or_code(code)
      @status_code = status.code
      @reason_phrase = status.reason_phrase
      @response_message = @exception.try(:response_message) || RestfulError.localized_phrase(@exception.class.name, status) || nil

      render status: status.code, formats: request.format.symbol
    end
  end

  ExceptionsApp = ExceptionsController.action(:show)
end
