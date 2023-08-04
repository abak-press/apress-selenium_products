require 'spec_helper'

describe 'ЕТИ' do
  before(:all) do
    @cs_eti_page = CompanySite::EtiPage.new
    @cs_main_page = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_eti
    @cs_main_page.close_banner
  end

  describe 'Добавление групп' do
    context 'когда привязываем группу к товару' do
      before(:all) do
        @product = {name: Faker::Number.leading_zero_number(digits: 5).to_s}
        @cs_eti_page.create_and_set_product_fields(@product)
        @cs_eti_page.navigate_to_groups_element.click
        sleep 2
        @cs_eti_page.set_group(CONFIG['product_creation']['group'])
        @cs_eti_page.wait_saving
        @cs_eti_page.refresh
        @cs_eti_page.search_product(@product[:name])
      end

      it 'группа привязывается' do
        expect(@cs_eti_page.group_cell).to eq CONFIG['product_creation']['group']
      end

      context 'когда выбираем другую группу' do
        before do
          @cs_eti_page.set_group(CONFIG['product_creation']['group_2'])
          @cs_eti_page.wait_saving
          @cs_eti_page.refresh
        end

        it 'группа меняется на новую' do
          expect(@cs_eti_page.group_cell).to eq CONFIG['product_creation']['group_2']
        end
      end

      after(:all) { @cs_eti_page.delete_product(@product[:name]) }
    end
  end
end
