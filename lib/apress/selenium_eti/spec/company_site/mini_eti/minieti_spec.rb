# frozen_string_literal: true

require 'spec_helper'

describe 'Мини-ЕТИ' do
  before(:all) do
    @cs_eti_table           = CompanySite::ETI::Table.new
    @cs_eti_action_panel    = CompanySite::ETI::ActionPanel.new
    @cs_eti_table_products  = CompanySite::ETI::Table::Products.new
    @cs_eti_header          = CompanySite::ETI::Header.new
    @cs_mini_eti_pagination = CompanySite::MiniETI::Pagination.new
    @cs_main_page           = CompanySite::MainPage.new

    log_in_as(:user)
    navigate_to_minieti
    @cs_main_page.close_banner
    @cs_eti_table.close_support_contacts if @cs_eti_table.close_support_contacts?(2)
  end

  describe 'Поля' do
    context 'когда заполняем имя' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name)
        @product = @cs_eti_table_products.product(name: @name)
      end

      it 'введенное имя отображается' do
        expect(@cs_eti_table_products.name(@product)).to eq(@name)
      end

      context 'когда добавляем картинку', skip: !RUN_CONFIG.fetch('local_running', false).to_b do
        before(:all) do
          @battery = @cs_eti_table_products.battery(@product)
          @image = @cs_eti_table_products.image(@product)
          @cs_eti_table_products.upload_image(@product, type: :local, path: IMAGE_PATH)
        end

        it 'картинка появляется' do
          expect(@cs_eti_table_products.image(@product)[:url]).to be_truthy
        end

        it 'счетчик изображений увеличится на 1' do
          expect(@cs_eti_table_products.image(@product)[:counts]).to eq(@image[:counts] + 1)
        end

        it 'увеличивается заряд батарейки' do
          expect(@cs_eti_table_products.battery(@product)[:level])
            .to eq(@battery[:level] + CONFIG['battery_percents']['image'])
        end
      end
    end

    context 'когда заполняем цену' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name)
        @product = @cs_eti_table_products.product(name: @name)
        @battery = @cs_eti_table_products.battery(@product)
        @price = {type: :exact, price: Faker::Number.number(3)}
        @cs_eti_table_products.set_price(@product, @price)
      end

      it('введенная цена отображается') { expect(@cs_eti_table_products.price(@product)).to include(@price[:price]) }

      it 'увеличивается заряд батарейки' do
        expect(@cs_eti_table_products.battery(@product)[:level])
          .to eq(@battery[:level] + CONFIG['battery_percents']['price'])
      end
    end

    context 'когда заполняем цену от и до' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name)
        @product = @cs_eti_table_products.product(name: @name)
        @battery = @cs_eti_table_products.battery(@product)
        @price_range = {type: :range, price: Faker::Number.number(2), price_max: Faker::Number.number(3)}

        @cs_eti_table_products.set_price(@product, @price_range)
      end

      it 'введенная цена отображается' do
        expect(@cs_eti_table_products.price(@product)).to include @price_range[:price], @price_range[:price_max]
      end
    end

    context 'когда заполняем цену со скидкой' do
      before(:all) do
        @name = Faker::Number.number(5)
        @cs_eti_table_products.add_product(name: @name)
        @product = @cs_eti_table_products.product(name: @name)
        @battery = @cs_eti_table_products.battery(@product)
        @discount_price = {
          type: :discount,
          price: Faker::Number.number(3),
          new_price: Faker::Number.number(2),
          expires_at: Time.now.strftime('%d.%m.%Y'),
        }

        @cs_eti_table_products.set_price(@product, @discount_price)
      end

      it 'введенные цены и дата окончания скидки отображаются' do
        expect(@cs_eti_table_products.price(@product)).to include(@discount_price[:price], @discount_price[:new_price])
      end
    end

    context 'когда заполняем наличие' do
      before do
        @product = @cs_eti_table_products.add_product(name: Faker::Number.number(5), exists: :available)
      end

      it 'для товара отобразится статус "В наличии"' do
        expect(@cs_eti_table_products.exists(@product)).to match(/[Вв] наличии/)
      end
    end

    context 'когда заполняем рубрику' do
      before(:all) do
        @product = @cs_eti_table_products.add_product(name: Faker::Number.number(5), rubric: CONFIG['eti']['rubric'])
      end

      it 'привязывается рубрика' do
        expect(@cs_eti_table_products.rubric(@product)).to include CONFIG['eti']['rubric']
      end

      context 'когда отменяем действие' do
        before(:all) { @cs_eti_action_panel.undo }

        it 'рубрика исчезает' do
          expect(@cs_eti_table_products.rubric(@product)).not_to include CONFIG['eti']['rubric']
        end

        context 'когда повторяем отмененное действие' do
          before(:all) { @cs_eti_action_panel.redo }

          it 'привязывается рубрика' do
            expect(@cs_eti_table_products.rubric(@product)).to include CONFIG['eti']['rubric']
          end
        end
      end
    end
  end

  describe 'Пагинатор' do
    context 'когда переходим на следующую страницу' do
      before(:all) { @cs_mini_eti_pagination.next_page }

      it 'открывается следующая страница' do
        expect(no_page_errors?).to be true
        expect(@cs_mini_eti_pagination.current_page.to_i).to eq(2)
      end

      context 'когда возвращаемся на предыдущую страницу' do
        before(:all) { @cs_mini_eti_pagination.previous_page }

        it 'открывается предыдущая страница' do
          expect(no_page_errors?).to be true
          expect(@cs_mini_eti_pagination.current_page.to_i).to eq(1)
        end
      end
    end

    context 'когда выбираем количество товаров на странице' do
      before { @cs_mini_eti_pagination.per_page = 50 }

      it 'количество товаров на странице равно выбранному значению' do
        expect(@cs_eti_table_products.products_elements.size.between?(21, 50)).to be true
      end
    end
  end

  describe 'Удаление товара' do
    before do
      name = Faker::Number.number(5)
      @product = @cs_eti_table_products.add_product(name: name)
    end

    it 'товар удаляется' do
      expect { @cs_eti_table_products.delete_product(@product) } .to change { @product.visible? }.from(true).to(false)
    end
  end

  describe 'Копирование товара' do
    before do
      @fields = {
        name: Faker::Number.number(5),
        price: {
          type: :exact,
          price: Faker::Number.number(5),
        },
      }
      @product = @cs_eti_table_products.add_product(@fields)
      @cs_eti_table_products.copy_product(@product)
    end

    it 'товар скопирован' do
      expect(@cs_eti_table_products.products_elements[0].text).to eq(@cs_eti_table_products.products_elements[1].text)
    end
  end
end
