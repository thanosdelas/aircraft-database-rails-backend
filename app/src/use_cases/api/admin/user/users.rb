# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module User
        class Users < ::UseCases::API::Base
          def dispatch(&response)
            @http_code = 200
            @response_data = users
            @message = 'Sucessfully retrieved users'

            success(&response)
          end

          private

          def users
            return @users if instance_variable_defined?(:@users)

            @users = ::User.all
          end
        end
      end
    end
  end
end
