module Toolbox
  module Clients
    class UserApiV2
      def initialize(root_url, jwt_private_key, jwt_algorithm)
        @root_url = root_url
        @jwt_private_key = jwt_private_key
        @jwt_algorithm = jwt_algorithm
      end

      def post(path, data: {}, headers: {}, user: nil)
        jwt = api_v2_jwt_for(user)
        headers['Authorization'] = 'Bearer ' + jwt
        headers['Content-Type']  = 'application/json'
        url = URI.join(@root_url, path.gsub(/\A\/+/, ''))
        Faraday.post(url, data.to_json, headers).assert_success!
      end

      def get(path, query: {}, headers: {}, user: nil)
        jwt = api_v2_jwt_for(user)
        headers['Authorization'] = 'Bearer ' + jwt
        url = URI.join(@root_url, path.gsub(/\A\/+/, ''))
        Faraday.get(url, query, headers).assert_success!
      end

      def create_users(number)
        number.times.map do
          { email: unique_email, uid: unique_uid, level: 3, state: 'active' }.tap do |user|
            # Issue GET /api/v2/account/balances to create user at Peatio DB.
            get('/account/balances', user: user)
          end
        end
      end

      private
      def api_v2_jwt_for(user)
        payload = user.slice(:email, :uid, :level, :state)
        payload.reverse_merge! \
          iat: Time.now.to_i,
          exp: 5.minutes.from_now.to_i,
          jti: SecureRandom.uuid,
          sub: 'session',
          iss: 'barong',
          aud: ['peatio', 'barong'],
          role: :member
        JWT.encode(payload, @jwt_private_key, @jwt_algorithm)
      end

      # TODO: Move to separate module.
      def unique_email
        Faker::Internet.unique.email
      end

      def unique_uid
        @used_uids ||= [].to_set
        loop do
          uid = "UID#{SecureRandom.hex(4).upcase}"
          unless @used_uids.include?(uid)
            @used_uids << uid
            return uid
          end
        end
      end
    end
  end
end
