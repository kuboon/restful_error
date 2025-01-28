require 'action_controller'
require 'spec_helper'

describe 'RestfulError' do
  describe RestfulError::ExceptionsController do
    include Rack::Test::Methods
    def app
      RestfulError::ExceptionsController.action(:show)
    end
    describe '404' do
      before do
        env "action_dispatch.exception", RestfulError[404].new
      end
      it do
        get '/404'
        expect(last_response.status).to eq 404
      end
    end
  end
end
