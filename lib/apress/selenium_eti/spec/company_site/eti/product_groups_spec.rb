require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_table                = CompanySite::ETI::Table.new
    @cs_eti_header               = CompanySite::ETI::Header.new
    @cs_eti_table_products       = CompanySite::ETI::Table::Products.new
    @cs_main_page                = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
    @cs_eti_table.close_support_contacts if @cs_eti_table.close_support_contacts?(2)

    @group1 = CONFIG['product_creation']['group']
    @group2 = CONFIG['product_creation']['group_2']
  end

  describe 'Добавление групп' do
    context 'когда привязываем группу к товару' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name, group: @group1)
        @cs_eti_header.search_product(@name, exact: true)
        @product = @cs_eti_table_products.product(name: @name)
      end

      it 'группа привязывается' do
        expect(@cs_eti_table_products.group(@product)).to eq @group1
      end

      context 'когда выбираем другую группу' do
        before do
          @cs_eti_table_products.set_group(@product, @group2)
          @cs_eti_header.search_product(@name, exact: true)
          @product = @cs_eti_table_products.product(name: @name)
        end

        it 'группа меняется на новую' do
          expect(@cs_eti_table_products.group(@product)).to eq @group2
        end
      end

      after(:all) do
        product = @cs_eti_table_products.product(name: @name)
        @cs_eti_table_products.delete_product(product)
      end
    end
  end
end
