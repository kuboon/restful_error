# frozen_string_literal: true

require "action_controller"
require "spec_helper"

RSpec.describe "RestfulError.exceptions_app" do
  let(:app) { RestfulError.exceptions_app }
  let(:env) { {} }
  let(:request) { Rack::MockRequest.new(app) }

  it "renders 404" do
    env["action_dispatch.exception"] = ActionController::RoutingError.new("Not Found")
    env["PATH_INFO"] = "/404"
    response = request.get("/404", env)
    expect(response.status).to eq 404
    expect(response.body).to include "Not Found"
  end
end
