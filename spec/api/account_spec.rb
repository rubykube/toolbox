# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Barong account api' do
  let(:public_host) do
    Faraday.new(url: TOOLBOX_HOST + '/api/v2/barong/identity') do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :json
    end
  end
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password(10, 20, true) }

  # works only if captcha is disabled
  context('user creation') do
    let(:request) do
      public_host.post do |req|
        req.url 'users'
        req.headers['Content-Type'] = 'application/json'
        req.body = "{ \"email\": \"#{email}\", \"password\": \"#{password}\" }"
      end
    end

    it 'creates an account in Barong' do
      expect(request.status).to eq(201)
    end
  end
end
