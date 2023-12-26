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
        @name = Faker::Number.leading_zero_number(digits: 5).to_s
        @cs_eti_table_products.add_product(name: @name)
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      after(:all) { @cs_eti_table_products.delete_product(@product) }

      it('введенное имя отображается') { expect(@cs_eti_table_products.name(@product)).to eq(@name) }

      # Определяется через локатор какой проект, и в зависимости
      # от этого ожидаемый результат. Если ни один из локаторов
      # проектов не найден, то выводится ошибка 'locator not found'
      it 'товар не опубликован на портале' do
        if @cs_eti_table.project_pulscen?
          expect(@cs_eti_table_products.public_state(@product)).to eq(:archived)
        elsif @cs_eti_table.project_blizko?
          expect(@cs_eti_table_products.public_state(@product)).to eq(:unpublished)
        else
          raise ArgumentError, 'locator not found'
        end
      end
    end

    context 'когда товар с рубрикой' do
      before(:all) do
        @name = Faker::Number.leading_zero_number(digits: 5).to_s
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
          name: Faker::Number.leading_zero_number(digits: 10).to_s,
          rubric: CONFIG['eti']['rubric'],
          traits: {
            CONFIG['eti']['portal_traits']['trait_1'] => CONFIG['eti']['portal_traits']['trait_value_1'],
            CONFIG['eti']['portal_traits']['trait_2'] => CONFIG['eti']['portal_traits']['trait_value_2'],
          },
          announce: Faker::Movies::Hobbit.quote,
          description: Faker::Movies::Hobbit.quote,
          price: {
            type: :range,
            price: Faker::Number.number(digits: 3),
            price_max: Faker::Number.number(digits: 4),
          },
          wholesale_price: {
            price: Faker::Number.number(digits: 2),
            min_qty: Faker::Number.number(digits: 2),
          },
          exists: :available,
        }

        @product = @cs_eti_table_products.add_product(@fields)
        @cs_eti_table_products.copy_product(@product)
        @cs_eti_header.search_product(@fields[:name], exact: true)
      end

      it 'отобразится 2 идентичных товара' do
        expect(@cs_eti_table_products.products_elements.size).to eq(2)
        expect(@cs_eti_table_products.products_elements[0].text).to eq(@cs_eti_table_products.products_elements[1].text)
      end

      after(:all) do
        2.times do
          @cs_eti_header.search_product(@fields[:name], exact: true)
          product = @cs_eti_table_products.product(name: @fields[:name])
          @cs_eti_table_products.delete_product(product)
        end
      end
    end
  end
end
