# frozen_string_literal: true

require "spec_helper"

describe RestfulError do
  describe "RestfullError[404]" do
    subject { described_class[404].new }

    it do
      expect(subject.http_status).to eq 404
      expect(subject.restful.reason_phrase).to eq "Not Found"
    end
  end

  describe "RestfullError[:bad_request]" do
    subject { described_class[:bad_request].new }

    it do
      expect(subject.http_status).to eq 400
      expect(subject.restful.reason_phrase).to eq "Bad Request"
    end
  end

  describe described_class::Forbidden do
    subject { described_class.new }

    it do
      expect(subject.http_status).to eq 403
      expect(subject.restful.reason_phrase).to eq "Forbidden"
    end
  end

  describe "custom class" do
    subject { klass.new }

    let(:klass) do
      Class.new(StandardError) do
        include RestfulError::Helper
        def http_status = 404
      end
    end

    it do
      expect(subject.restful.symbol).to eq :not_found
    end
  end
end
