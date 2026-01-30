# frozen_string_literal: true

require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_table          = CompanySite::ETI::Table.new
    @cs_eti_table_products = CompanySite::ETI::Table::Products.new
    @cs_eti_header         = CompanySite::ETI::Header.new
    @cs_main_page          = CompanySite::MainPage.new

    log_in_as(:admin)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_table.close_support_contacts if @cs_eti_table.close_support_contacts?(2)
  end

  describe 'Служебная метка' do
    before(:all) do
      @cs_eti_header.setting_columns
      @name = Faker::Number.leading_zero_number(digits: 5).to_s
      @cs_eti_table_products.add_product(name: @name)
      @product = @cs_eti_table_products.product(name: @name)
    end

    context 'когда добавляем служебную метку' do
      before do
        @service_labels = 'short_desc'
        @cs_eti_table_products.set_service_labels(@product, @service_labels)
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      it 'отобразится служебная метка' do
        expect(@cs_eti_table_products.service_labels(@product)).to eq @service_labels
      end
    end

    context 'когда изменяем служебную метку' do
      before do
        @product = @cs_eti_table_products.product(name: @name)
        @service_labels = 'long_desc'
        @cs_eti_table_products.set_service_labels(@product, @service_labels)
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      it 'отобразится новая служебная метка' do
        expect(@cs_eti_table_products.service_labels(@product)).to eq @service_labels
      end
    end

    context 'когда удаляем служебную метку' do
      before do
        @product = @cs_eti_table_products.product(name: @name)
        @service_labels = ''
        @cs_eti_table_products.set_service_labels(@product, @service_labels)
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      it 'отобразится плейсхолдер "Выбрать служебную метку"' do
        expect(@cs_eti_table_products.service_labels(@product)).to eq 'Выбрать служебную метку'
      end
    end

    after(:all) do
      product = @cs_eti_table_products.product(name: @name)
      @cs_eti_table_products.delete_product(product)
      @cs_eti_header.reset_search
    end
  end
end
