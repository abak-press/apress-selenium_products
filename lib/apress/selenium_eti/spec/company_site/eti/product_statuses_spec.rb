require 'spec_helper'

describe 'ЕТИ. Редактирование товара. Статусы' do
  before(:all) do
    @cs_eti_page = CompanySite::EtiPage.new
    @cs_main_page = CompanySite::MainPage.new
    @admin_menu = Admin::Menu.new
    @admin_products_page = Admin::ProductsPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_page.close_support_contacts if @cs_eti_page.close_support_contacts?(2)

    @product_1 = {
      name: Faker::Name.name,
      rubric: CONFIG['eti']['rubric']
    }

    @product_2 = {
      name: Faker::Name.name,
      rubric: CONFIG['eti']['rubric']
    }

    @product_3 = {
      name: Faker::Name.name,
      rubric: CONFIG['eti']['rubric']
    }

    @product_4 = {
      name: Faker::Name.name,
      rubric: CONFIG['eti']['rubric']
    }

    @cs_eti_page.create_and_set_product_fields(@product_1)
    @cs_eti_page.create_and_set_product_fields(@product_2)
    @cs_eti_page.create_and_set_product_fields(@product_3)
    @cs_eti_page.create_and_set_product_fields(@product_4)

    navigate_to_admin_page
    @admin_menu.products
    @admin_products_page.accept_product(@product_1[:name])
    @admin_products_page.accept_product(@product_2[:name])
    @admin_products_page.reject_product(@product_3[:name])
    @admin_products_page.reject_product(@product_4[:name])

    navigate_to_eti
    log_in_as(:user)
    navigate_to_eti

    @cs_eti_page.change_status_to_archived(@product_2[:name])
    @cs_eti_page.change_status_to_archived(@product_4[:name])
  end

  context 'когда товары подтверждены' do
    before(:all) { navigate_to_eti }

    context 'когда исходный статус "Опубликованный"' do
      before(:all) { @cs_eti_page.search_product(@product_1[:name]) }

      context 'когда меняем статус на архивный' do
        before(:all) do
          @cs_eti_page.change_status_to_archived(@product_1[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на архивный' do
          expect(@cs_eti_page.product_archived?(@product_1[:name])).to be_truthy
        end
      end

      context 'когда меняем статус с архивного на опубликованный' do
        before(:all) do
          @cs_eti_page.change_status_to_published(@product_1[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на опубликованный' do
          expect(@cs_eti_page.product_published?(@product_1[:name])).to be_truthy
        end
      end
    end

    context 'когда исходный статус "Архивный"' do
      before(:all) { @cs_eti_page.search_product(@product_2[:name]) }

      context 'когда меняем статус на опубликованный' do
        before(:all) do
          @cs_eti_page.change_status_to_published(@product_2[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на опубликованный' do
          expect(@cs_eti_page.product_published?(@product_2[:name])).to be_truthy
        end
      end

      context 'когда меняем статус с опубликованного на архивный' do
        before(:all) do
          @cs_eti_page.change_status_to_archived(@product_2[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на архивный' do
          expect(@cs_eti_page.product_archived?(@product_2[:name])).to be_truthy
        end
      end
    end
  end

  context 'когда товары отклонены' do
    before(:all) { navigate_to_eti }

    context 'когда исходный статус "Отклоненный"' do
      before(:all) { @cs_eti_page.search_product(@product_3[:name]) }

      context 'когда меняем статус на архивный' do
        before(:all) do
          @cs_eti_page.change_status_to_archived(@product_3[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на архивный' do
          expect(@cs_eti_page.product_archived?(@product_3[:name])).to be_truthy
        end
      end

      context 'когда меняем статус с архивного на опубликованный' do
        before(:all) do
          @cs_eti_page.change_status_to_published(@product_3[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на отклоненный' do
          expect(@cs_eti_page.product_declined?(@product_3[:name])).to be_truthy
        end
      end
    end

    context 'когда исходный статус "Архивный"' do
      before(:all) { @cs_eti_page.search_product(@product_4[:name]) }

      context 'когда меняем статус на опубликованный' do
        before(:all) do
          @cs_eti_page.change_status_to_published(@product_4[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на отклоненный' do
          expect(@cs_eti_page.product_declined?(@product_4[:name])).to be_truthy
        end
      end

      context 'когда меняем статус с отклоненного на архивный' do
        before(:all) do
          @cs_eti_page.change_status_to_archived(@product_4[:name])
          Page.browser.navigate.refresh
        end

        it 'статус изменится на архивный' do
          expect(@cs_eti_page.product_archived?(@product_4[:name])).to be_truthy
        end
      end
    end
  end
end
