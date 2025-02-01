require "abstract_controller"
require "action_controller/metal"

module RestfulError
  class ApplicationController < ::ActionController::Metal
    abstract!
    include AbstractController::Rendering
    include ActionView::Layouts
    include ActionController::Rendering
  end
end
