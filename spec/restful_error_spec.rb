require 'spec_helper'

describe RestfulError do
  it 'has a version number' do
    expect(RestfulError::VERSION).not_to be nil
  end

  describe 'Wrapper' do
    require 'active_record/errors'
    subject { ex.extend(RestfulError::Helper) }
    context 'with number' do
      let(:ex){ Class.new(RestfulError[404]).new }
      it do
        expect(subject.restful.status_code).to eq 404
      end
    end
    context 'with phrase' do
      let(:ex){ Class.new(RestfulError::NotFound).new }
      it do
        expect(subject.restful.status_code).to eq 404
      end
    end
  end
end
