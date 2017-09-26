require 'spec_helper'

describe 'Мини-ЕТИ' do
  cs_mini_eti_page = CompanySite::MiniEtiPage.new
  cs_main_page = CompanySite::MainPage.new

  before(:all) do
    log_in_as(:user)
    navigate_to_company_catalog
    cs_main_page.close_banner
  end

  describe 'Поля' do
    before(:all) { cs_mini_eti_page.add_product }

    context 'когда заполняем имя' do
      before(:all) do
        @name = Faker::Number.number(5)
        cs_mini_eti_page.name = @name
      end

      it 'введенное имя отображается' do
        expect(cs_mini_eti_page.product_name).to include @name
      end

      context 'когда добавляем картинку' do
        before(:all) do
          @thermometer_value = cs_mini_eti_page.thermometer_value
          cs_mini_eti_page.load_image(IMAGE_PATH)
        end

        it 'картинка появляется' do
          expect(cs_mini_eti_page.image_loaded?).to be true
        end

        it 'увеличивается градус на термометре' do
          cs_mini_eti_page.wait_until { cs_mini_eti_page.save_status == 'Все изменения сохранены' }
          expect(cs_mini_eti_page.thermometer_value).to be @thermometer_value + CONFIG['battery_percents']['image']
        end

        after(:all) do
          cs_mini_eti_page.close_image_uploader
        end
      end
    end

    context 'когда заполняем цену' do
      before(:all) do
        @thermometer_value = cs_mini_eti_page.thermometer_value
        @price = Faker::Number.number(3)
        cs_mini_eti_page.price = @price
      end

      it 'введенная цена отображается' do
        expect(cs_mini_eti_page.price_value).to include @price
      end

      it 'увеличивается градус на термометре' do
        cs_mini_eti_page.wait_until { cs_mini_eti_page.save_status == 'Все изменения сохранены' }
        expect(cs_mini_eti_page.thermometer_value.to_i).to be @thermometer_value + CONFIG['battery_percents']['price']
      end
    end

    context 'когда заполняем цену от и до' do
      before(:all) do
        cs_mini_eti_page.add_product
        @thermometer_value = cs_mini_eti_page.thermometer_value
        @price_from = Faker::Number.number(2)
        @price_to = Faker::Number.number(3)
        cs_mini_eti_page.set_price_from_to(@price_from, @price_to)
      end

      it 'введенная цена отображается' do
        expect(cs_mini_eti_page.price_value).to include @price_from
        expect(cs_mini_eti_page.price_value).to include @price_to
      end
    end

    context 'когда заполняем цену со скидкой' do
      before(:all) do
        cs_mini_eti_page.add_product
        @thermometer_value = cs_mini_eti_page.thermometer_value
        @price = Faker::Number.number(3)
        @discount_price = Faker::Number.number(2)
        cs_mini_eti_page.set_discount_price(@price, @discount_price)
      end

      it 'введенные цены и дата окончания скидки отображаются' do
        expect(cs_mini_eti_page.discount_price_value).to include @discount_price
        expect(cs_mini_eti_page.previous_price_value).to include @price
        expect(cs_mini_eti_page.discount_expires_at_date_value).to include Time.now.strftime("%d.%m.%Y")
      end
    end

    context 'когда заполняем наличие' do
      before { cs_mini_eti_page.exists = true }

      it 'введенная цена отображается' do
        expect(cs_mini_eti_page.exists_value).to include 'в наличии'
      end
    end

    context 'когда заполняем рубрику' do
      before(:all) { cs_mini_eti_page.set_rubric(CONFIG['mini_eti']['rubric']) }

      it 'привязывается рубрика' do
        expect(cs_mini_eti_page.rubric_cell).to include CONFIG['mini_eti']['rubric']
      end

      context 'когда отменяем действие' do
        before(:all) { cs_mini_eti_page.operation_undo }

        it 'рубрика исчезает' do
          expect(cs_mini_eti_page.rubric_cell).to include 'Указать рубрику'
        end

        context 'когда повторяем отмененное действие' do
          before(:all) { cs_mini_eti_page.operation_redo }

          it 'привязывается рубрика' do
            expect(cs_mini_eti_page.rubric_cell).to include CONFIG['mini_eti']['rubric']
          end
        end
      end
    end
  end

  describe 'Пагинатор' do
    context 'когда переходим на вторую страницу' do
      before(:all) { cs_mini_eti_page.page_2 }

      it 'открывается вторая страница' do
        expect(no_page_errors?).to be true
        expect(cs_mini_eti_page.page_2_not_exists?).to be true
        expect(cs_mini_eti_page.page_1?).to be true
      end

      context 'когда возвращаемся на первую страницу' do
        before(:all) { cs_mini_eti_page.page_1 }

        it 'открывается первая страница' do
          expect(no_page_errors?).to be true
          expect(cs_mini_eti_page.page_1_not_exists?).to be true
          expect(cs_mini_eti_page.page_2?).to be true
        end
      end
    end
  end

  describe 'Удаление товара' do
    before do
      cs_mini_eti_page.add_product
      @name = Faker::Number.number(5)
      cs_mini_eti_page.name = @name
      cs_mini_eti_page.delete
    end

    it 'товар удаляется' do
      expect(cs_mini_eti_page.product_name).not_to eq @name
    end
  end

  describe 'Копирование товара' do
    before do
      cs_mini_eti_page.add_product

      cs_mini_eti_page.name = @name = Faker::Pokemon.name
      cs_mini_eti_page.price = @price = Faker::Number.number(5)
      cs_mini_eti_page.wait_until(45) { cs_mini_eti_page.save_status == 'Все изменения сохранены' }

      cs_mini_eti_page.copy_product
      cs_mini_eti_page.wait_until(45) { cs_mini_eti_page.save_status == 'Все изменения сохранены' }
    end

    it 'товар копируется' do
      expect(cs_mini_eti_page.price_values_elements[0].text).to eq cs_mini_eti_page.price_values_elements[1].text
    end
  end

  context 'когда выбираем количество товаров на странице' do
    before do
      cs_mini_eti_page.choose_amount_of_products_on_page = '50'
      cs_mini_eti_page.wait_until { cs_mini_eti_page.save_status == 'Все изменения сохранены' }
    end

    it 'количество товаров на странице равно выбранному значению' do
      expect((cs_mini_eti_page.product_elements.size <= 50) && (cs_mini_eti_page.product_elements.size > 20))
    end
  end
end
