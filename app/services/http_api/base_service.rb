module HttpApi
  class BaseService
    include ServiceResultMethods

    def api_request
      begin
        response = yield
        if response.success?
          success_result data: { response: response }
        else
          api_error_result response: response
        end
      rescue HTTParty::ResponseError, HttpApi::Error => e
        api_error_result response: e.response, exception: e
      rescue Timeout::Error, Errno::ETIMEDOUT => e
        api_timeout_result exception: e
      end
    end

    def api_error_result(response: , exception: nil)
      message = I18n.t 'http_api.errors.response_error', code: response.code, message: response.message
      error_result status: :http_api_error, message: message, data: { response: response, exception: exception }
    end

    def api_timeout_result(exception: )
      message = I18n.t 'http_api.errors.request_timeout'
      error_result status: :http_api_unavailable, message: message, data: { exception: exception }
    end
  end
end
