# frozen_string_literal: true

require 'spec_helper'
require 'time'

RSpec.describe 'Peatio public api' do
  let(:public_host) do
    Faraday.new(url: TOOLBOX_HOST + '/api/v2/peatio/public') do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  describe 'get /public/timestamp' do
    let(:request) { public_host.get('timestamp') }

    it 'should respond with a timestamp' do
      expect(Time.parse(request.body)).to be_a_kind_of(Time)
    end
  end

  # TODO: rewrite to match real markets data

  context 'markets' do
    let(:markets) { public_host.get('markets').body }
    let(:depth) do
      public_host.get('markets/' + markets.first['id'] + '/depth').body
    end

    it 'should respond with array of markets' do
      expect(markets).to be_an_instance_of(Array)
      expect(markets.first).to be_an_instance_of(Hash)
    end

    it 'should respond with market depth' do
      expect(depth).to be_an_instance_of(Hash)
      expect(depth['asks']).to be_an_instance_of(Array)
      expect(depth['bids']).to be_an_instance_of(Array)
    end
  end

  context 'fees' do
    let(:fees) { public_host.get('fees/' + action).body }

    context 'trading' do
      let(:action) { 'trading' }

      it('should return fees information') do
        expect(fees).to be_an_instance_of(Array)
        expect(fees.first).to be_an_instance_of(Hash)
        expect(fees.first['market']).to be_an_instance_of(String)
        expect(fees.first['ask_fee']).to be_an_instance_of(Hash)
        expect(fees.first['bid_fee']).to be_an_instance_of(Hash)
      end
    end

    context 'deposit' do
      let(:action) { 'deposit' }

      it('should return fees information') do
        expect(fees).to be_an_instance_of(Array)
        expect(fees.first).to be_an_instance_of(Hash)
        expect(fees.first['currency']).to be_an_instance_of(String)
        expect(fees.first['fee']).to be_an_instance_of(Hash)
      end
    end

    context 'deposit' do
      let(:action) { 'deposit' }

      it('should return fees information') do
        expect(fees).to be_an_instance_of(Array)
        expect(fees.first).to be_an_instance_of(Hash)
        expect(fees.first['currency']).to be_an_instance_of(String)
        expect(fees.first['fee']).to be_an_instance_of(Hash)
      end
    end
  end
end
