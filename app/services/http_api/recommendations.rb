module HttpApi
  class Recommendations < HttpApi::BaseService
    attr_reader :user_id
    BASE_URL = "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json"

    class << self
      def fetch(*args)
        new(*args).fetch
      end
    end

    def initialize user_id: nil
      @user_id = user_id
    end

    def fetch 
      key = "recomended_cars_#{user_id}"
      cached = Rails.cache.read key
      return cached if cached

      result = api_request do
        query = { user_id: user_id }
        HTTParty.get BASE_URL, query: query, timeout: 20
      end
      return {} if result.failure?

      result = JSON.parse(result.data.response.body).reduce({}) do |memo, res|
        memo[res["car_id"]] = res["rank_score"]
        memo
      end
      Rails.cache.write key, result, expires_in: 2.hours
      return result
    end
  end
end