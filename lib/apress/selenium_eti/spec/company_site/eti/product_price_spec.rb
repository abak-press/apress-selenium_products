require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_table          = CompanySite::ETI::Table.new
    @cs_eti_header         = CompanySite::ETI::Header.new
    @cs_eti_table_products = CompanySite::ETI::Table::Products.new
    @cs_main_page          = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_table.close_support_contacts if @cs_eti_table.close_support_contacts?(2)
  end

  describe 'Установка цен', feature: 'company_site/eti/product_price_spec: Установка цен' do
    before do
      @name = Faker::Number.number(5)
      @cs_eti_table_products.add_product(name: @name, price: price)
      @cs_eti_header.search_product(@name, exact: true)
      @product = @cs_eti_table_products.product(name: @name)
    end

    context 'когда цена точная', story: 'когда цена точная' do
      let(:price) { {type: :exact, price: Faker::Number.number(2)} }

      it 'введеная цена отображается' do
        expect(@cs_eti_table_products.price(@product)).to eq(price[:price] + ' руб.')
      end
    end

    context 'когда цена от и до', story: 'когда цена от и до' do
      context 'когда только "от"' do
        let(:price) { {type: :range, price: Faker::Number.number(2)} }

        it 'введеная цена отображается' do
          expect(@cs_eti_table_products.price(@product)).to eq('от ' + price[:price] + ' руб.')
        end
      end

      context 'когда только "до"' do
        let(:price) { {type: :range, price_max: Faker::Number.number(2)} }

        it 'введеная цена отображается' do
          expect(@cs_eti_table_products.price(@product)).to eq('до ' + price[:price_max] + ' руб.')
        end
      end

      context 'когда заполняем "от" и "до"' do
        let(:price) { {type: :range, price: Faker::Number.number(2), price_max: Faker::Number.number(3)} }

        it 'введеная цена отображается' do
          expect(@cs_eti_table_products.price(@product)).to include(price[:price], price[:price_max])
        end
      end
    end

    context 'когда цена со скидкой', story: 'когда цена со скидкой' do
      let(:price) do
        {
          type: :discount,
          price: Faker::Number.number(3),
          new_price: Faker::Number.number(2),
          expires_at: Time.now.strftime('%d.%m.%Y')
        }
      end

      it 'введеная цена отображается' do
        expect(@cs_eti_table_products.price(@product)).to include(price[:price], price[:new_price])
      end
    end
  end

  describe 'Установка оптовых цен', feature: 'company_site/eti/product_price_spec: Установка оптовых цен' do
    before do
      @name = Faker::Number.number(5)
      @cs_eti_table_products.add_product(name: @name, wholesale_price: wholesale_price)
      @cs_eti_header.search_product(@name, exact: true)
      @product = @cs_eti_table_products.product(name: @name)
    end

    context 'когда точная оптовая цена', story: 'когда точная оптовая цена' do
      let(:wholesale_price) { {price: Faker::Number.number(2), min_qty: Faker::Number.number(1)} }

      it 'введеная цена отображается' do
        expect(@cs_eti_table_products.wholesale_price(@product))
          .to eq(wholesale_price[:price] + ' руб. /шт.' + ' от ' + wholesale_price[:min_qty] + ' шт.')
      end
    end

    context 'когда оптовая цена "от"', story: 'когда оптовая цена "от"' do
      let(:wholesale_price) { {price: Faker::Number.number(2), min_qty: Faker::Number.number(1), not_exact: true} }

      it 'введеная цена отображается' do
        expect(@cs_eti_table_products.wholesale_price(@product))
          .to eq('от ' + wholesale_price[:price] + ' руб. /шт.' + ' от ' + wholesale_price[:min_qty] + ' шт.')
      end
    end
  end
end
