module Todoable

  #Possible HTTP errors

  UnauthorizedError = Class.new(StandardError)
  NotFoundError = Class.new(StandardError)
  UnprocessableEntityError = Class.new(StandardError)
  InternalServerError = Class.new(StandardError)

  #Only used if there is an error when contacting todoable server with a request

  class ErrorParser

    attr_reader :response

    def initialize(response)
      @response = response
    end

    def self.parse_error(response)
      parser = new(response)
      parser.response_result
    end

    #Raises error based on http error code
    #When UnprocessableEntityError, also provides actual validation errors

    def response_result
      code = response.code
      case code
      when 401
        raise Todoable::UnauthorizedError.new
      when 404
        raise Todoable::NotFoundError.new
      when 422
        raise Todoable::UnprocessableEntityError.new(validation_errors)
      when 500
        raise Todoable::InternalServerError.new
      end
    end

    def validation_errors
      JSON.parse(response.body)
    end
  end
end
