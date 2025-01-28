require "abstract_controller"
require "action_controller/metal"

module RestfulError
  class ExceptionsController < ::ActionController::Metal
    include AbstractController::Rendering
    include ActionView::Layouts

    append_view_path File.join(File.dirname(__FILE__), "../../app/views")

    def show
      @exception = request.env["action_dispatch.exception"]
      status = Status.new(request.path_info[1..].to_i)
      @status_code = status.code
      @reason_phrase = status.reason_phrase
      @message = @exception.try(:response_message)
      unless @message
        class_name = @exception.class.name
        class_key = RestfulError::Inflector.underscore(class_name)
        @message = I18n.t class_key, default: [ status.symbol, @reason_phrase ], scope: :restful_error
      end

      self.status = status.code
      render "restful_error/show"
    end
  end

  def self.exceptions_app
    ExceptionsController.action(:show)
  end
end
