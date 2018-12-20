# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Barong account api', order: :defined do
  let(:public_host) do
    Faraday.new(url: TOOLBOX_HOST + '/api/v2/barong/identity') do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  EMAIL = Faker::Internet.email
  PASSWORD = Faker::Internet.password(10, 20, true)

  context 'user creation' do
    let(:create_user) do
      public_host.post do |req|
        req.url 'users'
        req.headers['Content-Type'] = 'application/json'
        req.body = { email: EMAIL, password: PASSWORD }.to_json
      end
    end

    let(:verify_email) do
      public_host.post do |req|
        req.url 'users/email/confirm_code'
        req.headers['Content-Type'] = 'application/json'
        req.body = { token: @token }.to_json
      end
    end

    let(:consumer) do
      EventConsumingHelper::Consumer.new(
        'barong.events.system',
        'user.email.confirmation.token'
      )
    end

    it 'creates an account and verifies email' do
      Thread.new { consumer.call }

      until consumer.state == :started
        pp 'waiting'
        sleep 1
        pp '...'
        sleep 1
      end

      pp 'Creating an account...'
      expect(create_user.status).to eq(201)
      pp 'Account created!'

      until consumer.state == :finished
        pp 'waiting'
        sleep 1
        pp '...'
        sleep 1
      end

      expect(consumer.state).to eq(:finished)
      @token = consumer.response[:payload][:event][:token]
      expect(verify_email.status).to eq(201)
    end
  end

  context 'password reset' do
    let(:reset_password_instructions) do
      public_host.post do |req|
        req.url 'users/password/generate_code'
        req.headers['Content-Type'] = 'application/json'
        req.body = { email: EMAIL }.to_json
      end
    end

    let(:reset_password) do
      PASSWORD = Faker::Internet.password(10, 20, true)
      public_host.post do |req|
        req.url 'users/password/confirm_code'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          reset_password_token: @token,
          password: PASSWORD,
          confirm_password: PASSWORD
        }.to_json
      end
    end

    let(:consumer) do
      EventConsumingHelper::Consumer.new(
        'barong.events.system',
        'user.password.reset.token'
      )
    end

    it 'sends instructions and resets password' do
      Thread.new { consumer.call }

      until consumer.state == :started
        pp 'waiting'
        sleep 1
        pp '...'
        sleep 1
      end

      expect(reset_password_instructions.status).to eq(201)

      until consumer.state == :finished
        pp 'waiting'
        sleep 1
        pp '...'
        sleep 1
      end

      expect(consumer.state).to eq(:finished)
      @token = consumer.response[:payload][:event][:token]
      expect(reset_password.status).to eq(201)
    end
  end
end
