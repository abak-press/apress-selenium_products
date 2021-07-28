require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_page = CompanySite::EtiPage.new
    @cs_main_page = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_page.close_support_contacts if @cs_eti_page.close_support_contacts?
  end

  describe 'Создание товара' do
    context 'когда товар без рубрики' do
      before(:all) do
        @name = Faker::Number.leading_zero_number(digits: 5)
        @cs_eti_page.add_product
        @cs_eti_page.set_name(@name)
        @cs_eti_page.wait_saving
        @cs_eti_page.refresh
        @cs_eti_page.search_product(@name)
      end

      it 'введенное имя отображается' do
        expect(@cs_eti_page.product_name?(@name)).to be true
      end

      it 'товар не опубликован' do
        expect(@cs_eti_page.product_unpublished?(@name)).to be true
      end

      after(:all) { @cs_eti_page.delete_product(@name) }
    end

    context 'когда товар с рубрикой' do
      before(:all) do
        @name = Faker::Number.number(digits: 5)
        @cs_eti_page.add_product
        @cs_eti_page.set_name(@name)
        @cs_eti_page.wait_saving
        @cs_eti_page.set_rubric(CONFIG['eti']['rubric'])
        @cs_eti_page.wait_until { @cs_eti_page.first_product_status_element.attribute('title') == 'Опубликованные на портале' }
        @cs_eti_page.refresh
        @cs_eti_page.search_product(@name)
      end

      it 'введенное имя отображается' do
        expect(@cs_eti_page.product_name?(@name)).to be true
      end

      it 'рубрика привязана' do
        expect(@cs_eti_page.product_rubric_tree(@name)).to include CONFIG['eti']['rubric']
      end

      it 'товар опубликован' do
        expect(@cs_eti_page.product_published?(@name)).to be true
      end

      after(:all) { @cs_eti_page.delete_product(@name) }
    end

    context 'когда копируем товар' do
      before(:all) do
        @product = {
          name: Faker::Number.leading_zero_number(digits: 5),
          rubric: CONFIG['eti']['rubric'],
          exists: CONFIG['eti']['exists']['in stock'],
          short_description: CONFIG['product_creation']['short_description']['valid'],
          description: 'description',
          price_from_to: {from: Faker::Number.number(digits: 3), to: Faker::Number.number(digits: 4)},
          wholesale_price: {wholesale_price: Faker::Number.number(digits: 2), wholesale_number: Faker::Number.number(digits: 2)}
        }

        @portal_traits = {
          trait_1: CONFIG['eti']['portal_traits']['trait_value_1'],
          trait_2: CONFIG['eti']['portal_traits']['trait_value_2']
        }

        @cs_eti_page.create_and_set_product_fields(@product)
        @cs_eti_page.refresh
        @cs_eti_page.search_product(@product[:name])
        @cs_eti_page.set_portal_traits(@product[:name], @portal_traits)
        @cs_eti_page.copy_product(@product[:name])

        @cs_eti_page.refresh
        @cs_eti_page.search_product(@product[:name])
      end

      it 'отобразится 2 идентичных товара' do
        @first_product = @cs_eti_page.product_rows_elements[0].text

        expect(@cs_eti_page.product_rows_elements.length).to eq 2
        expect(@cs_eti_page.product_rows_elements[1].text).to eq @first_product
      end
    end
  end
end
