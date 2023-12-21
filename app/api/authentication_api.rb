class AuthenticationAPI < Grape::API
  #
  # Refactor this into a service
  #
  helpers do
    def generate_jwt(user)
      payload = { sub: user.id }

      JWT.encode payload, private_key, 'ES256'
    end

    def private_key
      OpenSSL::PKey::EC.new(File.read("#{Rails.root}/tmp/openssl_keys/jwt-private.pem"))
    end
  end

  resource :authentication do
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post 'login' do
      user = User.find_by(email: params[:email])

      if user && user.authenticate(params[:password])
        return { status: 'ok', message: 'Authentication was successfull', data: { access_token: generate_jwt(user) } }
      end

      status 401
      { status: 'failed', message: 'Authentication failed' }
    end

    params do
      requires :access_token, type: String
    end
    post 'verify_token' do
      payload, _header = JWT.decode params[:access_token], private_key, true, { algorithm: 'ES256' }

      user = User.find_by(id: payload['sub'])

      unless user.nil?
        return { status: 'ok', message: 'Successfully verified token and user' }
      end

      status 422
      { status: 'failed', message: 'Could not verify provided token' }
    rescue JWT::DecodeError
      status 422
      { status: 'failed', message: 'Could not verify provided token' }
    rescue JWT::VerificationError
      status 422
      { status: 'failed', message: 'Could not verify provided token' }
    end
  end
end
