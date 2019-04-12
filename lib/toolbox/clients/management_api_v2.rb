module Toolbox
  module Clients
    class ManagementApiV2
      def initialize(root_url, jwt_private_key, jwt_algorithm, jwt_signer)
        @root_url = root_url
        @jwt_private_key = jwt_private_key
        @jwt_algorithm = jwt_algorithm
        @jwt_signer = jwt_signer
      end

      def post(path, data:)
        keychain   = {@jwt_signer => @jwt_private_key }
        algorithms = {@jwt_signer => @jwt_algorithm }
        payload    = { iat:  Time.now.to_i,
                       exp:  5.minutes.from_now.to_i,
                       jti:  SecureRandom.uuid,
                       iss:  @jwt_signer,
                       data: data }
        jwt = JWT::Multisig.generate_jwt(payload, keychain, algorithms)
        url = URI.join(@root_url, path)
        Faraday.post(url, jwt.to_json, 'Content-Type' => 'application/json').assert_success!
      end

      def create_deposit(uid:, currency:, amount: 1_000_000_000)
        data = { uid: uid, currency: currency, amount: amount, state: :accepted }
        post('management/deposits/new', data: data)
      end
    end
  end
end
