module HttpApi
  class Error < StandardError
    attr_reader :message, :response

    def initialize(message, response)
      @response = response
    end
  end
end
