# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module User
        class Users
          def dispatch(&response)
            success(&response)
          end

          private

          def success
            http_code = 200
            data = {
              status: 'ok',
              message: 'Sucessfully retrieved users',
              data: {
                users: users
              }
            }

            yield http_code, data
          end

          def users
            return @users if instance_variable_defined?(:@users)

            @users = ::User.all
          end
        end
      end
    end
  end
end
