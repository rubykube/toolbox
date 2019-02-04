require 'spec_helper'

RSpec.describe 'Quick testing', :type => :request do
  let!(:url) { '/api/v2/barong/identity/sessions' }
  let!(:request_params) do
    { email: 'admin@barong.io',
      password: '0lDHd9ufs9t@' }
  end
  let!(:connection) { Faraday.new(url: 'http://www.app.local') }
  let!(:login) {connection.post url, request_params}

  it 'login as admin@barong.io' do
    expect(login.status).to eq(200)
  end

  it 'get /api/v2/barong/resource/users/me' do
    url = '/api/v2/barong/resource/users/me'
    request = connection.get(url, {}, {'Cookie' => login['set-cookie']})
    expect(request.status).to eq(200)
  end

  it 'get /api/v2/peatio/account/balances' do
    url = '/api/v2/peatio/account/balances'
    request = connection.get(url, {}, {'Cookie' => login['set-cookie']})
    expect(request.status).to eq(200)
  end
end
