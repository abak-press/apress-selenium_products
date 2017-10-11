require 'spec_helper'

describe 'ЕТИ' do
  cs_eti_page = CompanySite::EtiPage.new
  cs_main_page = CompanySite::MainPage.new

  before(:all) do
    log_in_as(:user)
    navigate_to_eti
    cs_main_page.close_banner
  end

  describe 'Создание товара' do
    context 'когда товар без рубрики' do
      before(:all) do
        @name = Faker::Number.number(5)
        cs_eti_page.add_product
        cs_eti_page.set_name(@name)
        cs_eti_page.wait_until { cs_eti_page.save_status == 'Все изменения сохранены' }
        cs_eti_page.refresh
        cs_eti_page.wait_until { cs_eti_page.save_status == 'Все изменения сохранены' }
        cs_eti_page.search_product(@name)
      end

      it 'введенное имя отображается' do
        expect(cs_eti_page.product_name?(@name)).to be true
      end

      it 'товар не опубликован' do
        expect(cs_eti_page.product_unpublished?(@name)).to be true
      end

      after(:all) { cs_eti_page.delete_product(@name) }
    end

    context 'когда товар с рубрикой' do
      before(:all) do
        @name = Faker::Number.number(5)
        cs_eti_page.add_product
        cs_eti_page.set_rubric(CONFIG['eti']['rubric'])
        cs_eti_page.set_name(@name)
        cs_eti_page.wait_until { cs_eti_page.first_product_status_element.attribute('title') == 'Опубликованные' }
        cs_eti_page.refresh
        cs_eti_page.wait_until { cs_eti_page.save_status == 'Все изменения сохранены' }
        cs_eti_page.search_product(@name)
      end

      it 'введенное имя отображается' do
        expect(cs_eti_page.product_name?(@name)).to be true
      end

      it 'рубрика привязана' do
        expect(cs_eti_page.product_rubric_tree(@name)).to include CONFIG['eti']['rubric']
      end

      it 'товар опубликован' do
        expect(cs_eti_page.product_published?(@name)).to be true
      end

      after(:all) { cs_eti_page.delete_product(@name) }
    end
  end
end
