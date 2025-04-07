module RestfulError
  class ExceptionsController < SuperController
    def self.controller_path = "restful_error"
    append_view_path File.join(File.dirname(__FILE__), "../../app/views")

    layout nil

    def show
      @exception = request.env["action_dispatch.exception"]
      code = @exception.try(:http_status) || request.path_info[1..].to_i
      status = RestfulError.build_status_from_symbol_or_code(code)
      @status_code = status.code
      @reason_phrase = status.reason_phrase
      @response_message = @exception.try(:response_message) || RestfulError.localized_phrase(@exception.class.name, status) || nil
      render status: status.code, formats: request.format.symbol
    rescue ActionView::MissingTemplate
      render status: status.code, formats: :text
    end
  end
end
