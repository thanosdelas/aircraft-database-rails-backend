module Services
  class Authentication
    attr_reader :access_token

    def generate_jwt(user_id:)
      payload = { sub: user_id }

      JWT.encode payload, private_key, 'ES256'
    end

    def verify_access_token(access_token)
      payload, _header = JWT.decode access_token, private_key, true, { algorithm: 'ES256' }

      payload
    end

    private

    def private_key
      OpenSSL::PKey::EC.new(File.read(Rails.root.join('tmp/openssl_keys/jwt-private.pem')))
    end
  end
end
