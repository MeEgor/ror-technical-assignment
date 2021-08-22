module Api
  module Cars
    class Fetcher
      DEFAULT_PER_PAGE = 20
      attr_reader :user, :query, :price_min, :price_max, :page, :recommendations

      class << self
        def fetch(*args)
          new(*args).fetch
        end
      end

      def initialize user: nil, query: nil, price_min: nil, price_max: nil, page: 1, recommendations: {}
        @user = user
        @query = query
        @price_min = price_min
        @price_max = price_max
        @page = page
        @recommendations = recommendations
      end

      def fetch
        Car.preload(:brand).where(id: car_ids).order("price asc")
      end

      private

      def car_ids
        filters = []
        filters << "c.price >= :price_min" if price_min
        filters << "c.price <= :price_max" if price_max
        filters << 'lower(b.name) ILIKE :query' if query

        preferred_filters_sql = ["(b.id IN (:preferred_brand_ids) OR c.id IN (:recommended_car_ids))"].concat(filters).join(" AND ")
        other_filters_sql =  ["1 = 1"].concat(filters).join(" AND ")

        raw_sql = <<-SQL
          SELECT id
          FROM (
            SELECT c.id, c.price, 1 AS sort_order
            FROM cars AS c 
            INNER JOIN brands AS b ON b.id = c.brand_id
            WHERE #{preferred_filters_sql}
            UNION
            SELECT c.id, c.price, 0 AS sort_order
            FROM cars AS c 
            INNER JOIN brands AS b ON b.id = c.brand_id
            WHERE #{other_filters_sql}
            ORDER BY sort_order DESC, price ASC
          ) AS t
          LIMIT :limit OFFSET :offset
        SQL
        sql = ActiveRecord::Base.send :sanitize_sql_for_conditions, [raw_sql, {
          price_min: price_min,
          price_max: price_max,
          query: "%#{query}%".downcase,
          preferred_brand_ids: user.preferred_brand_ids,
          recommended_car_ids: recommended_car_ids,
          limit: DEFAULT_PER_PAGE,
          offset: (page - 1) * DEFAULT_PER_PAGE
        }]
        rows = ActiveRecord::Base.connection.execute sql

        return rows.map{ |r| r["id"] }
      end

      def recommended_car_ids
        recommendations.sort{ |a, b| b[1] <=> a[1] }.first(5).map{ |a| a[0] }
      end
    end
  end
end
