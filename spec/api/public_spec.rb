# frozen_string_literal: true

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

    it 'Should respond with a timestamp' do
      expect(Time.parse(request.body)).to be_a_kind_of(Time)
    end
  end
end
