# frozen_string_literal: true

module UseCases
  class Base
    attr_reader :data, :errors

    def initialize
      @data = nil
      @errors = []
    end

    private

    def success(status: :success)
      yield status, @data
    end

    def error
      raise 'Cannot fail without errors' if @errors.length == 0

      status = @errors.map { |error| error[:code] }.pop

      yield status, @errors
    end

    def add_error(code:, message:, field: nil)
      error = {
        code: code,
        message: message
      }

      error[:field] = field unless field.nil?

      @errors.push(error)
    end

    def errors?
      !@errors.empty?
    end
  end
end
