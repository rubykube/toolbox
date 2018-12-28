# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Barong protected resouce routes spec' do
  context 'barong/resource/users/me' do
    let(:protected_route) do
      ProtectedRoutesHelper::Connection.new(
        EMAIL,
        PASSWORD
      )
    end

    let(:user_information) do
      protected_route.get('api/v2/barong/resource/users/me')
    end

    it 'returns current user information' do
      expect(user_information.status).to eq(200)
      expect(user_information.body['email']).to eq(EMAIL)
    end
  end
end
