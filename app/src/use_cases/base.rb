# frozen_string_literal: true

module UseCases
  class Base
    attr_reader :http_code, :response_data, :message, :errors

    def initialize
      @http_code = nil
      @response_data = nil
      @errors = []
      @message = nil
    end

    private

    def success
      response = { status: 'success', message: @message, data: @response_data }

      yield @http_code, response
    end

    def error
      response = { status: 'error', errors: @errors }

      yield @http_code, response
    end

    def add_error(code:, message:, field: nil)
      error = { code: code, message: message }
      error[:field] = field unless field.nil?

      @errors.push(error)
    end

    def errors?
      !@errors.empty?
    end
  end
end
