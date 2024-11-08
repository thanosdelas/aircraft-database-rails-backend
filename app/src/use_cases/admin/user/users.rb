# frozen_string_literal: true

module UseCases
  module Admin
    module User
      class Users < ::UseCases::Base
        def dispatch(&response)
          @data = users

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
