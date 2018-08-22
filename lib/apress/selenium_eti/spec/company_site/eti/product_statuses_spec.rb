require 'spec_helper'

describe 'ЕТИ. Редактирование товара. Статусы' do
  before(:all) do
    @cs_eti_table          = CompanySite::ETI::Table.new
    @cs_eti_table_products = CompanySite::ETI::Table::Products.new
    @cs_eti_header         = CompanySite::ETI::Header.new
    @cs_main_page          = CompanySite::MainPage.new
    @admin_menu            = Admin::Menu.new
    @admin_products_page   = Admin::ProductsPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_table.close_support_contacts if @cs_eti_table.close_support_contacts?(2)

    @product1_fields = {
      name: Faker::Job.title,
      rubric: CONFIG['eti']['rubric']
    }

    @product2_fields = {
      name: Faker::Job.title,
      rubric: CONFIG['eti']['rubric']
    }

    @product3_fields = {
      name: Faker::Job.title,
      rubric: CONFIG['eti']['rubric']
    }

    @product4_fields = {
      name: Faker::Job.title,
      rubric: CONFIG['eti']['rubric']
    }

    @cs_eti_table_products.add_product(@product1_fields)
    @cs_eti_table_products.add_product(@product2_fields)
    @cs_eti_table_products.add_product(@product3_fields)
    @cs_eti_table_products.add_product(@product4_fields)

    navigate_to_admin_page
    @admin_menu.products
    @admin_products_page.accept_product(@product1_fields[:name])
    @admin_products_page.accept_product(@product2_fields[:name])
    @admin_products_page.reject_product(@product3_fields[:name])
    @admin_products_page.reject_product(@product4_fields[:name])

    navigate_to_eti
    log_in_as(:user)
    navigate_to_eti

    @cs_eti_header.search_product(@product2_fields[:name], exact: true)
    product2 = @cs_eti_table_products.product(name: @product2_fields[:name])
    @cs_eti_table_products.set_public_state(product2, :archived)

    @cs_eti_header.search_product(@product4_fields[:name], exact: true)
    product4 = @cs_eti_table_products.product(name: @product4_fields[:name])
    @cs_eti_table_products.set_public_state(product4, :archived)
  end

  context 'когда товары подтверждены' do
    before do
      @cs_eti_header.search_product(fields[:name], exact: true)
      @product = @cs_eti_table_products.product(name: fields[:name])

      @cs_eti_table_products.set_public_state(@product, public_state)
      @cs_eti_header.search_product(fields[:name], exact: true)
      @product = @cs_eti_table_products.product(name: fields[:name])
    end

    context 'когда исходный статус "Опубликованный"' do
      let(:fields) { @product1_fields }

      context 'когда меняем статус на архивный' do
        let(:public_state) { :archived }

        it 'статус изменится на архивный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end

      context 'когда меняем статус с архивного на опубликованный' do
        let(:public_state) { :published }

        it 'статус изменится на опубликованный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end
    end

    context 'когда исходный статус "Архивный"' do
      let(:fields) { @product2_fields }

      context 'когда меняем статус на опубликованный' do
        let(:public_state) { :published }

        it 'статус изменится на опубликованный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end

      context 'когда меняем статус с опубликованного на архивный' do
        let(:public_state) { :archived }

        it 'статус изменится на архивный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end
    end
  end

  context 'когда товары отклонены' do
    before do
      @cs_eti_header.search_product(fields[:name], exact: true)
      @product = @cs_eti_table_products.product(name: fields[:name])

      @cs_eti_table_products.set_public_state(@product, public_state)
      @cs_eti_header.search_product(fields[:name], exact: true)
      @product = @cs_eti_table_products.product(name: fields[:name])
    end

    context 'когда исходный статус "Отклоненный"' do
      let(:fields) { @product3_fields }

      context 'когда меняем статус на архивный' do
        let(:public_state) { :archived }

        it 'статус изменится на архивный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end

      context 'когда меняем статус с архивного на опубликованный' do
        let(:public_state) { :published }

        it 'статус изменится на отклоненный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end
    end

    context 'когда исходный статус "Архивный"' do
      let(:fields) { @product4_fields }

      context 'когда меняем статус на опубликованный' do
        let(:public_state) { :published }

        it 'статус изменится на отклоненный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end

      context 'когда меняем статус с отклоненного на архивный' do
        let(:public_state) { :archived }

        it 'статус изменится на архивный' do
          expect(@cs_eti_table_products.public_state(@product)).to eq(public_state)
        end
      end
    end
  end
end
