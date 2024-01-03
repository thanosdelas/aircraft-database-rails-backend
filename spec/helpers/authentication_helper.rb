# frozen_string_literal: true

module AuthenticationHelper
  def authenticate_admin_user
    user = ::User.new(id: 9999, email: 'test@example.com', password: 'test', user_group_id: 100)
    payload = { sub: user.id }
    private_key = OpenSSL::PKey::EC.new(File.read(Rails.root.join('tmp/openssl_keys/jwt-private.pem')))
    access_token = JWT.encode payload, private_key, 'ES256'

    header('Authorization', "Bearer #{access_token}")
  end
end
