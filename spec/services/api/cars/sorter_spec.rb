require 'rails_helper'

RSpec.describe Api::Cars::Sorter do
  let!(:brand1) { Brand.new id: 1, name: "brand 1" }
  let!(:brand2) { Brand.new id: 2, name: "brand 2" }
  # originaly sorted by DB
  let!(:collection) do
    [
      Car.new(id: 1, model: 'model 1', brand: brand1, price: 200),
      Car.new(id: 2, model: 'model 2', brand: brand1, price: 150),
      Car.new(id: 3, model: 'model 3', brand: brand1, price: 100),
      Car.new(id: 4, model: 'model 4', brand: brand2, price: 300),
      Car.new(id: 5, model: 'model 5', brand: brand2, price: 250),
      Car.new(id: 6, model: 'model 6', brand: brand2, price: 200),
  ].sort{|c1, c2| c1.price <=> c2.price}
  end
  let!(:preferred_brands){ [] }
  let!(:preferred_price_range){ 0...100 }
  let(:user) do 
    User.new(
      id: 1,
      email: 'example@mail.com',
      preferred_price_range: preferred_price_range,
      preferred_brands: preferred_brands,
    )
  end
  let(:recommendations) do
    {}
  end

  describe '#sort' do
    
    it 'sort collection of cars by price asc' do
      res = ::Api::Cars::Sorter.sort user: user, collection: collection, recommendations: recommendations
      expect(res.map{|c| c[:id]}).to eq([3, 2, 1, 6, 5, 4])
    end


    context 'user has preferred brand' do
      let(:preferred_brands){ [brand2] }

      it 'sort collection of cars and add good_match label' do
        res = ::Api::Cars::Sorter.sort user: user, collection: collection, recommendations: recommendations
        expect(res.map{|c| c[:id]}).to eq([6, 5, 4, 3, 2, 1])
        expect(res[0][:label]).to eq(:good_match)
        expect(res[1][:label]).to eq(:good_match)
        expect(res[2][:label]).to eq(:good_match)
      end

      context 'with preferred price range intersection' do
        let!(:preferred_price_range){ 290...310 }

        it 'sort collection of cars and add perfect_match label' do
          res = ::Api::Cars::Sorter.sort user: user, collection: collection, recommendations: recommendations
          expect(res.map{|c| c[:id]}).to eq([4, 6, 5, 3, 2, 1])
          expect(res[0][:label]).to eq(:perfect_match)
        end

        context 'with recommendations' do
          let(:recommendations) { Hash[[[1, 0.7]]] }
          
          it 'it sets car_id=1 to position 4' do
            res = ::Api::Cars::Sorter.sort user: user, collection: collection, recommendations: recommendations
            expect(res.map{|c| c[:id]}).to eq([4, 6, 5, 1, 3, 2])
          end
        end
      end
    end
  end
end