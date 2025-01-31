# frozen_string_literal: true

require "action_controller"
require "i18n"
require "spec_helper"
require "restful_error/railtie" # require again for run after restful_error_spec

RSpec.describe RestfulError::ExceptionsController do
  include Rack::Test::Methods
  def app = RestfulError.exceptions_app

  shared_context "json" do
    let(:request) { get "/#{status_code}", {}, 'HTTP_ACCEPT' => 'application/json' }
    let(:json) { request; JSON.parse(last_response.body) }
  end

  before do
    env "action_dispatch.exception", exception
  end
  describe RestfulError[404] do
    let(:status_code) { 404 }
    include_context "json" do
      context 'default message' do
        let(:exception) { described_class.new }
        it do
          expect(json).to eq({status_code: 404, reason_phrase: "Not Found", response_message: 'Page not found'}.stringify_keys)
          expect(last_response.status).to eq status_code
        end
      end
      context 'custom message' do
        let(:exception) { described_class.new("custom message") }
        it do
          expect(json).to eq({status_code:, reason_phrase: "Not Found", response_message: "custom message"}.stringify_keys)
        end
      end
    end
  end
  context ActionController::RoutingError do
    let(:exception) { described_class.new("no route") }
    let(:status_code) { 404 }
    include_context "json" do
      it do
        expect(json).to eq({status_code:, reason_phrase: "Not Found", response_message: 'Requested resource is not found'}.stringify_keys)
        expect(last_response.status).to eq status_code
      end
    end
  end
end
