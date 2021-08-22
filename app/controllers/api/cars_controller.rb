module Api
  class CarsController < ApplicationController
    def index

      collection = Api::Cars::Fetcher.fetch(
        user: user, 
        query: query, 
        price_min: price_min, 
        price_max: price_max, 
        page: page, 
        recommendations: recommendations
      )
      
      render json: Api::Cars::Sorter.sort(
        user: user, 
        collection: collection, 
        recommendations: recommendations
      )
    end

    private

    def user
      @user = User.eager_load(:preferred_brands).find params[:user_id]
    end

    def recommendations
      @recommendations = ::HttpApi::Recommendations.fetch(user_id: user.id)
    end 

    def query
      params[:query] || nil
    end

    def price_min
      params[:price_min] ? params[:price_min].to_i : nil
    end

    def price_max
      params[:price_max] ? params[:price_max].to_i : nil
    end

    def page
      params[:page] ? params[:page].to_i : 1
    end
  end
end