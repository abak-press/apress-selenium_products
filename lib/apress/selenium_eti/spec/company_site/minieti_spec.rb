require 'spec_helper'

describe 'Мини-ЕТИ' do
  before(:all) do
    @cs_eti_page = CompanySite::EtiPage.new
    @cs_main_page = CompanySite::MainPage.new
    @cs_mini_eti_page = CompanySite::MiniEtiPage.new

    log_in_as(:user)
    navigate_to_minieti
    @cs_main_page.close_banner
    @cs_eti_page.close_support_contacts if @cs_eti_page.close_support_contacts?
  end

  describe 'Поля' do
    before(:all) { @cs_eti_page.add_product }

    context 'когда заполняем имя' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_page.set_name(@name)
      end

      it 'введенное имя отображается' do
        expect(@cs_eti_page.product_name?(@name)).to be true
      end

      context 'когда добавляем картинку', skip: !RUN_CONFIG.fetch('local_running', false).to_b do
        before(:all) do
          @thermometer_value = @cs_eti_page.thermometer_value
          @cs_eti_page.set_image(IMAGE_PATH)
        end

        it 'картинка появляется' do
          expect(@cs_eti_page.image_loaded?).to be true
        end

        it 'увеличивается градус на термометре' do
          @cs_eti_page.wait_saving
          expect(@cs_eti_page.thermometer_value).to be @thermometer_value + CONFIG['battery_percents']['image']
        end

        after(:all) { @cs_eti_page.close_image_uploader }
      end
    end

    context 'когда заполняем цену' do
      before(:all) do
        @thermometer_value = @cs_eti_page.thermometer_value
        @price = Faker::Number.number(3)

        @cs_eti_page.set_price(@price)
      end

      it 'введенная цена отображается' do
        expect(@cs_eti_page.price_value).to include @price
      end

      it 'увеличивается градус на термометре' do
        expect(@cs_eti_page.thermometer_value.to_i).to be @thermometer_value + CONFIG['battery_percents']['price']
      end
    end

    context 'когда заполняем цену от и до' do
      before(:all) do
        @cs_eti_page.add_product

        @thermometer_value = @cs_eti_page.thermometer_value
        @price_from_to = {from: Faker::Number.number(2), to: Faker::Number.number(3)}

        @cs_eti_page.set_price_from_to(@price_from_to)
      end

      it 'введенная цена отображается' do
        expect(@cs_eti_page.price_value).to include @price_from_to[:from], @price_from_to[:to]
      end
    end

    context 'когда заполняем цену со скидкой' do
      before(:all) do
        @cs_eti_page.add_product

        @thermometer_value = @cs_eti_page.thermometer_value
        @discount_price = {previous: Faker::Number.number(3), discount: Faker::Number.number(2)}

        @cs_eti_page.set_discount_price(@discount_price)
      end

      it 'введенные цены и дата окончания скидки отображаются' do
        expect(@cs_eti_page.discount_price_value).to include @discount_price[:discount]
        expect(@cs_eti_page.previous_price_value).to include @discount_price[:previous]
        expect(@cs_eti_page.discount_expires_at_date_value).to include Time.now.strftime("%d.%m.%Y")
      end
    end

    context 'когда заполняем наличие' do
      before { @cs_eti_page.set_exists(CONFIG['eti']['exists']['in stock']) }

      it 'для товара отобразится статус "В наличии"' do
        expect(@cs_eti_page.exists_value).to match(/[Вв] наличии/)
      end
    end

    context 'когда заполняем рубрику' do
      before(:all) { @cs_eti_page.set_rubric(CONFIG['eti']['rubric']) }

      it 'привязывается рубрика' do
        expect(@cs_eti_page.rubric_cell).to include CONFIG['eti']['rubric']
      end

      context 'когда отменяем действие' do
        before(:all) { @cs_eti_page.operation_undo }

        it 'рубрика исчезает' do
          expect(@cs_eti_page.rubric_cell).to include 'Указать рубрику'
        end

        context 'когда повторяем отмененное действие' do
          before(:all) { @cs_eti_page.operation_redo }

          it 'привязывается рубрика' do
            expect(@cs_eti_page.rubric_cell).to include CONFIG['eti']['rubric']
          end
        end
      end
    end
  end

  describe 'Пагинатор' do
    context 'когда переходим на вторую страницу' do
      before(:all) { @cs_eti_page.page_2 }

      it 'открывается вторая страница' do
        expect(no_page_errors?).to be true
        expect(@cs_eti_page.page_2_not_exists?).to be true
        expect(@cs_eti_page.page_1?).to be true
      end

      context 'когда возвращаемся на первую страницу' do
        before(:all) { @cs_eti_page.page_1 }

        it 'открывается первая страница' do
          expect(no_page_errors?).to be true
          expect(@cs_eti_page.page_1_not_exists?).to be true
          expect(@cs_eti_page.page_2?).to be true
        end
      end
    end
  end

  describe 'Удаление товара' do
    before do
      @cs_eti_page.add_product
      @name = Faker::Number.number(5)
      @cs_eti_page.set_name(@name)
      @cs_mini_eti_page.delete_first_product
    end

    it 'товар удаляется' do
      expect(@cs_eti_page.product_name?(@name)).to be false
    end
  end

  describe 'Копирование товара' do
    before do
      @cs_eti_page.add_product
      @name = Faker::Pokemon.name
      @cs_eti_page.set_name(@name)
      @cs_eti_page.set_price(@price = Faker::Number.number(5))
      @cs_eti_page.wait_saving

      @cs_mini_eti_page.copy_product
      @cs_eti_page.wait_saving
    end

    it 'товар копируется' do
      expect(@cs_eti_page.price_values_elements[0].text).to eq @cs_eti_page.price_values_elements[1].text
    end
  end

  context 'когда выбираем количество товаров на странице' do
    before do
      @cs_eti_page.choose_amount_of_products_on_page = '50'
      @cs_eti_page.wait_saving
    end

    it 'количество товаров на странице равно выбранному значению' do
      expect((@cs_eti_page.product_elements.size <= 50) && (@cs_eti_page.product_elements.size > 20))
    end
  end
end
