# frozen_string_literal: true

module UseCases
  module API
    class Base
      attr_reader :http_code, :response_data, :errors, :messages

      def initialize
        @http_code = nil
        @response_data = nil
        @errors = []
        @messages = []
      end

      private

      def success
        response = { status: 'success', message: @message, data: @response_data }

        yield @http_code, response
      end

      def error
        response = { status: 'error', messages: @messages }

        yield @http_code, response
      end

      def add_error(code:, message:, field: nil)
        @errors.push({ code: code, message: message, field: field })
      end

      def errors?
        @errors.length > 0
      end
    end
  end
end
