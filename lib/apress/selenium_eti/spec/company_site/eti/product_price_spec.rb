require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_page = CompanySite::EtiPage.new
    @cs_main_page = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_page.close_support_contacts if @cs_eti_page.close_support_contacts?(2)
  end

  describe 'Установка цен', feature: 'company_site/eti/product_price_spec: Установка цен' do
    before do
      @name = Faker::Number.number(5)
      @cs_eti_page.add_product
      @cs_eti_page.set_name(@name)
    end

    context 'когда цена точная', story: 'когда цена точная' do
      before do
        @price = Faker::Number.number(2)
        @cs_eti_page.set_price(@price)
        @cs_eti_page.wait_saving
        @cs_eti_page.search_product(@name)
      end

      it 'введеная цена отображается' do
        expect(@cs_eti_page.product_price(@name)).to eq @price + ' руб.'
      end
    end

    context 'когда цена от и до', story: 'когда цена от и до' do
      context 'когда только "от"' do
        before do
          @price_from = {from: Faker::Number.number(2)}
          @cs_eti_page.set_price_from_to(@price_from)
          @cs_eti_page.wait_saving
          @cs_eti_page.search_product(@name)
        end

        it 'введеная цена отображается' do
          expect(@cs_eti_page.product_price(@name)).to eq 'от ' + @price_from[:from] + ' руб.'
        end
      end

      context 'когда только "до"' do
        before do
          @price_to = {to: Faker::Number.number(2)}
          @cs_eti_page.set_price_from_to(@price_to)
          @cs_eti_page.wait_saving
          @cs_eti_page.search_product(@name)
        end

        it 'введеная цена отображается' do
          expect(@cs_eti_page.product_price(@name)).to eq 'до ' + @price_to[:to] + ' руб.'
        end
      end

      context 'когда заполняем "от" и "до"' do
        before do
          @price_from_to = {from: Faker::Number.number(2), to: Faker::Number.number(3)}
          @cs_eti_page.set_price_from_to(@price_from_to)
          @cs_eti_page.wait_saving
          @cs_eti_page.search_product(@name)
        end

        it 'введеная цена отображается' do
          expect(@cs_eti_page.price_value).to include @price_from_to[:from], @price_from_to[:to]
        end
      end
    end

    context 'когда цена со скидкой', story: 'когда цена со скидкой' do
      before do
        @discount_price = {previous: Faker::Number.number(3), discount: Faker::Number.number(2)}
        @cs_eti_page.set_discount_price(@discount_price)
        @cs_eti_page.wait_saving
        @cs_eti_page.search_product(@name)
      end

      it 'введеная цена отображается' do
        expect(@cs_eti_page.discount_price_value).to include @discount_price[:discount]
        expect(@cs_eti_page.previous_price_value).to include @discount_price[:previous]
      end
    end

    context 'когда цена оптовая', story: 'когда цена оптовая' do
      before do
        @price = {wholesale_price: Faker::Number.number(2), wholesale_number: Faker::Number.number(1)}
        @cs_eti_page.set_wholesale_price(@price)
        @cs_eti_page.wait_saving
        @cs_eti_page.search_product(@name)
      end

      it 'введеная цена отображается' do
        expect(@cs_eti_page.price_value).to eq @price[:wholesale_price] + ' руб. /шт.'
        expect(@cs_eti_page.wholesale_count_element.text).to eq 'от ' + @price[:wholesale_number] + ' шт.'
      end
    end
  end
end
