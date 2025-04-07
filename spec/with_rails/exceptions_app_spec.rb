# frozen_string_literal: true

require "action_controller"
require "i18n"
require "json"
require "spec_helper"

RSpec.describe "exceptions_app" do
  include Rack::Test::Methods
  def app = RestfulError::ExceptionsApp.new

  let(:body) { request; last_response.body }

  shared_context "html" do
    let(:request) { get "/#{status_code}", {}, 'HTTP_ACCEPT' => 'text/html' }
  end
  shared_context "json" do
    let(:request) { get "/#{status_code}", {}, 'HTTP_ACCEPT' => 'application/json' }
    let(:json) { JSON.parse(body) }
  end

  before do
    env "action_dispatch.exception", exception
  end
  describe RestfulError[404] do
    let(:status_code) { 404 }
    let(:exception) { described_class.new }
    context 'html' do
      include_context "html"
      context 'default message' do
        it do
          expect(body).to include "<p>Page not found</p>"
          # expect(body).to include "</html>" # layout is rendered
          expect(last_response.status).to eq status_code
        end
      end
    end
    context 'json' do
      include_context "json"
      context 'default message' do
        it do
          expect(json).to eq({status_code: 404, reason_phrase: "Not Found", response_message: 'Page not found'}.stringify_keys)
          expect(last_response.status).to eq status_code
        end
      end
      context 'custom message' do
        let(:klass) do
          Class.new(described_class) do
            def response_message = "custom message"
          end
        end
        let(:exception) { klass.new }
        it do
          expect(json).to eq({status_code: 404, reason_phrase: "Not Found", response_message: 'custom message'}.stringify_keys)
          expect(last_response.status).to eq status_code
        end
      end
    end
    context 'css' do
      let(:request) { get "/#{status_code}", {}, 'HTTP_ACCEPT' => 'text/css' }

      it do
        expect(body).not_to include "<p>"
        expect(last_response.status).to eq status_code
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
