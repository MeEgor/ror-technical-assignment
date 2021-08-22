module Api
  module Cars
    class Sorter
      attr_reader :user, :collection, :recommended_car_ids, :recommendations

      class << self
        def sort(*args)
          new(*args).sort
        end
      end

      def initialize user: nil, collection: [], recommendations: {}
        @user = user
        @collection = collection
        @recommendations = recommendations
        @recommended_car_ids = recommendations.sort{ |a, b| b[1] <=> a[1] }.first(5).map{ |a| a[0] }
      end
  
      def sort
        cars = {
          perfect_match: [],
          good_match: [],
          recomended: [],
          other: []
        }
        collection.each do |car|
          car_obj = build_car(car, recommendations[car.id] , label(car, user))

          if car_obj[:label] == :perfect_match 
            cars[:perfect_match].push(car_obj)
          elsif car_obj[:label] == :good_match
            cars[:good_match].push(car_obj)
          elsif recommended_car_ids.include?(car_obj[:id])
            cars[:recomended].push(car_obj)
          else 
            cars[:other].push(car_obj)
          end
        end

        return cars[:perfect_match].sort{ |c1, c2| sort_rank_score(c1, c2) } +
          cars[:good_match].sort{ |c1, c2| sort_rank_score(c1, c2) } +
          cars[:recomended].sort{ |c1, c2| sort_rank_score(c1, c2) } +
          cars[:other]
      end

      private

      def sort_rank_score c1, c2
        c2[:rank_score].to_f <=> c1[:rank_score].to_f
      end

      def label car, user
        return :perfect_match if user.preferred_brands.include?(car.brand) && user.preferred_price_range.include?(car.price)
        return :good_match if user.preferred_brands.include?(car.brand)
        return nil
      end

      def build_car car, rank_score, label
        {
          id: car.id,
          brand: {
            id: car.brand.id,
            name: car.brand.name
          },
          price: car.price,
          rank_score: rank_score,
          model: car.model,
          label: label
        }
      end
    end
  end
end