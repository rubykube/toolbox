# frozen_string_literal: true

require 'spec_helper'
require 'time'

RSpec.describe 'Peatio public api' do
  let(:public_host) do
    Faraday.new(url: TOOLBOX_HOST + '/api/v2/peatio/public') do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :json
    end
  end

  describe 'get /public/timestamp' do
    let(:request) { public_host.get('timestamp') }

    it 'should respond with a timestamp' do
      expect(Time.parse(request.body)).to be_a_kind_of(Time)
    end
  end

  # TODO: rewrite to match real markets data

  context 'get /public/markets' do
    let(:request) { public_host.get('markets') }

    it 'should respond with array of hashes' do
      expect(request.body).to be_an_instance_of(Array)
      expect(request.body.first).to be_an_instance_of(Hash)
    end
  end
end
