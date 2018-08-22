require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_table          = CompanySite::ETI::Table.new
    @cs_eti_table_products = CompanySite::ETI::Table::Products.new
    @cs_eti_header         = CompanySite::ETI::Header.new
    @cs_main_page          = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_table.close_support_contacts if @cs_eti_table.close_support_contacts?(2)
  end

  describe 'Создание товара' do
    context 'когда товар без рубрики' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name)
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      after(:all) { @cs_eti_table_products.delete_product(@product) }

      it('введенное имя отображается') { expect(@cs_eti_table_products.name(@product)).to eq(@name) }
      it('товар не опубликован') { expect(@cs_eti_table_products.public_state(@product)).to eq(:unpublished) }
    end

    context 'когда товар с рубрикой' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name, rubric: CONFIG['eti']['rubric'])
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      after(:all) { @cs_eti_table_products.delete_product(@product) }

      it('введенное имя отображается') { expect(@cs_eti_table_products.name(@product)).to eq(@name) }
      it('рубрика привязана') { expect(@cs_eti_table_products.rubric(@product)).to include(CONFIG['eti']['rubric']) }
      it('товар опубликован') { expect(@cs_eti_table_products.public_state(@product)).to eq(:published) }
    end

    context 'когда копируем товар' do
      before(:all) do
        @fields = {
          name: Faker::Number.number(10),
          rubric: CONFIG['eti']['rubric'],
          exists: :available,
          announce: Faker::Hobbit.quote[0..254],
          description: Faker::Hobbit.quote,
          price: {
            type: :range,
            price: Faker::Number.number(3),
            price_max: Faker::Number.number(4)
          },
          wholesale_price: {
            price: Faker::Number.number(2),
            min_qty: Faker::Number.number(2)
          },
          traits: {
            CONFIG['eti']['portal_traits']['trait_1'] => CONFIG['eti']['portal_traits']['trait_value_1'],
            CONFIG['eti']['portal_traits']['trait_2'] => CONFIG['eti']['portal_traits']['trait_value_2']
          }
        }

        @product = @cs_eti_table_products.add_product(@fields)
        @cs_eti_table_products.copy_product(@product)
        @cs_eti_header.search_product(@fields[:name], exact: true)
      end

      it 'отобразится 2 идентичных товара' do
        expect(@cs_eti_table_products.products_elements.size).to eq(2)
        expect(@cs_eti_table_products.products_elements[0].text).to eq(@cs_eti_table_products.products_elements[1].text)
      end
    end
  end
end
