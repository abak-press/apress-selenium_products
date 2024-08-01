# frozen_string_literal: true

require 'spec_helper'

describe 'Новая форма создания товара', feature: 'Создание товара' do
  before(:all) do
    @product_page          = ProductPage.new
    @product_creation_page = CompanySite::ProductCreationPage.new

    log_in_as(:admin)
  end

  after(:all) { log_out }

  context 'Когда переходим по урлу .../products/new' do
    before do
      navigate_to_product_creation_page
      wait_until { @product_creation_page.page_title? }
    end

    it 'выводится заголовок Создание товара или услуги' do
      expect(@product_creation_page.page_title?).to be_truthy
    end
  end

  describe 'Когда заполняем поля и создаем товар' do
    before(:all) { navigate_to_product_creation_page }

    context 'когда ни одно поле не заполнено' do
      before { @product_creation_page.save }

      it 'отобразится ошибка сохранения под полем Название' do
        expect(@product_creation_page.name_error?).to be_truthy
      end
    end

    context 'когда все поля заполнены максимальными значениями' do
      before(:all) do
        @options = {
          name: Faker::Lorem.paragraph_by_chars(number: 120),
          article: Faker::Lorem.paragraph_by_chars(number: 128),
          exists: CONFIG['product_creation']['exists']['in_stock'],
          qty_in_stock: 'Точное значение',
          qty_exact: Faker::Number.number(digits: 10),
          price: Faker::Number.number(digits: 10),
          currency: CONFIG['product_creation']['currency']['usd'],
          measure: CONFIG['product_creation']['measure']['box'],
          wholesale_price: Faker::Number.number(digits: 10),
          wholesale_qty: Faker::Number.number(digits: 6),
          short_description: Faker::Lorem.paragraph_by_chars(number: 255),
          description: CONFIG['product_creation']['full_description'],
          tag_title: Faker::Lorem.characters(number: 255),
          rubric: CONFIG['rubrics_names_by_level'][5],
          priority_lvl4: true,
          priority_lvl5: true,
          company_traits: {
            CONFIG['product_creation']['company_traits'][1] => CONFIG['product_creation']['company_trait_values'][1],
            CONFIG['product_creation']['company_traits'][2] => CONFIG['product_creation']['company_trait_values'][2]
          },
          portal_traits: {
            CONFIG['product_creation']['portal_traits'][1] => CONFIG['product_creation']['portal_trait_values'][1],
            CONFIG['product_creation']['portal_traits'][2] => CONFIG['product_creation']['portal_trait_values'][2]
          },
          path_to_image: IMAGE_PATH,
          qty_of_images: 4, # на самом деле будет загружено 10 изображений
          description_of_photo: Faker::Lorem.paragraph_by_chars(number: 255),
          group: CONFIG['product_creation']['group'],
          path_to_doc: IMAGE_PATH,
          qty_of_doc: 3, # на самом деле будет загружено 5 документов - это максимум
          soputka: CONFIG['product_creation']['soputka'],
          qty_of_soputka: 4
        }

        # На БЛ нет этого поля, только на ПЦ
        if @product_creation_page.min_qty_input?
          @options[:min_qty] = Faker::Number.number(digits: 10)
        end

        @product_creation_page.fill_attributes(@options)
        wait_until { @product_page.product_name? }
      end

      it 'товар сохранился с заполненными полями. Открывается КТ' do
        expect(Page.browser.current_url).to match Regexp.new(
          CONFIG['eti_company_subdomain'] + '.' + CONFIG['portal_page_url'] + CONFIG['url_intermediate_kt'] + '/')
      end

      it 'Название содержит 120 символов и совпадает с тем что вводили' do
        expect(@product_page.product_name).to eq(@options[:name])
        expect(@product_page.product_name.size).to eq 120
      end

      it 'Розничная цена в usd/ящик совпадает с тем что вводили' do
        expect(@product_page.product_price)
          .to include "#{@options[:price].to_s.reverse.scan(/(\d{1,3})/).join(' ').reverse} usd/ящик"
      end

      it 'Оптовая цена в usd/ящик совпадает с тем что вводили' do
        expect(@product_page.product_wholesale_price).to include "от #{@options[:wholesale_qty]} ящик"
        expect(@product_page.product_wholesale_price)
          .to include "#{@options[:wholesale_price].to_s.reverse.scan(/(\d{1,3})/).join(' ').reverse} usd/ящик"
      end

      it 'Наличие со статусом - В наличии' do
        expect(@product_page.product_exists).to match(/[Вв] наличии/)
      end

      it 'Артикул содержит 128 символов и совпадает с тем что вводили' do
        expect(@product_page.product_article).to eq(@options[:article])
        expect(@product_page.product_article.size).to eq 128
      end

      it 'Изображения выводятся в количестве 10' do
        expect(@product_page.product_images_elements.size).to eq 10
      end

      it 'Компанейские характеристики совпадают с тем что вводили' do
        expect(@product_page.product_traits).to include 'Автотест комп хар-ка 1: max 30'
      end

      it 'Полное описание совпадает с тем что вводили' do
        expect(@product_page.product_description).to eq 'Текст для полного описания'
      end

      it 'Документы выводятся в количестве 5' do
        expect(@product_page.product_docs_elements.size).to eq 5
      end

      it 'товары Сопутки выводятся в количестве 4' do
        expect(@product_page.product_soputka_elements.size).to eq 4
      end
    end
  end

  describe 'Когда проверяется одно из полей' do
    before { navigate_to_product_creation_page }

    describe 'с отправкой формы' do
      before { @product_creation_page.fill_attributes(options) }

      describe 'Цена розничная' do
        context 'когда тип цены - Точная' do
          let(:options) do
            {
              name: CONFIG['product_creation']['name']['valid'],
              price: CONFIG['product_creation']['price']['exact']
            }
          end

          it 'на КТ отобразится цена 500 руб.' do
            expect(@product_page.product_price).to include '500'
          end
        end

        context 'когда тип цены - От-До' do
          let(:options) do
            {
              name: CONFIG['product_creation']['name']['valid'],
              price_from: CONFIG['product_creation']['price']['exact'],
              price_to: CONFIG['product_creation']['price']['range_to']
            }
          end

          # Проверка в 2 строчки, т.к. на ПЦ цена выводится в 1 строку, на БЛ в 2 строки
          it 'на КТ отобразится цена от 500 до 800 руб.' do
            expect(@product_page.product_price).to include 'от 500'
            expect(@product_page.product_price).to include 'до 800'
          end
        end

        context 'когда тип цены - Со скидкой и без срока действия (10 лет)' do
          let(:options) do
            {
              name: CONFIG['product_creation']['name']['valid'],
              price_old: CONFIG['product_creation']['price']['exact'],
              price_new: CONFIG['product_creation']['price']['after_discount']
            }
          end

          # Проверка в 2 строчки, т.к. на ПЦ цена выводится в 1 строку, на БЛ в 2 строки
          it 'на КТ отобразится цена со скидкой и старая цена' do
            expect(@product_page.product_price).to include '300'
            expect(@product_page.product_price).to include '500'
          end
        end
      end
    end

    describe 'до отправки формы' do
      describe 'Рубрика' do
        let(:options) { {rubric: CONFIG['rubrics_names_by_level'][5]} }

        context 'когда привязывается через выбор в дереве рубрик' do
          before do
            @product_creation_page.rubric_level1
            @product_creation_page.rubric_level2
            @product_creation_page.rubric_level3
            @product_creation_page.rubric_level4
            @product_creation_page.rubric_level5
          end

          it 'отобразится превью привязки к рубрике' do
            expect(@product_creation_page.check_rubric).to be_truthy
          end
        end

        context 'когда привязывается через поиск' do
          before { @product_creation_page.fill_rubric(options) }

          it 'отобразится превью привязки к рубрике' do
            expect(@product_creation_page.check_rubric).to be_truthy
          end
        end

        context 'когда перевыбираем рубрику' do
          before do
            @product_creation_page.fill_rubric(options)
            options[:rubric] = CONFIG['rubric_2'] # переустанока в переменную другой рубрики
            @product_creation_page.fill_rubric(options)
          end

          it 'отобразится вторая рубрика' do
            expect(@product_creation_page.check_rubric).to include(options[:rubric])
          end
        end
      end

      describe 'Краткое описание' do
        context 'когда введено < 50 символов' do
          let(:options) { {short_description: CONFIG['product_creation']['short_description']['less_than_50']} }

          before { @product_creation_page.short_description = options[:short_description] }

          it 'под полем КО выводится предупреждение, что товар будет без КО, т.к. < 50 символов' do
            expect(@product_creation_page.short_description_error).to include '- менее 50 символов'
          end
        end

        context 'когда текст из КО совпадает с Названием' do
          let(:options) do
            {
              name: CONFIG['product_creation']['name']['valid'],
              short_description: CONFIG['product_creation']['short_description']['as_the_name']
            }
          end

          before do
            @product_creation_page.name_input = options[:name]
            @product_creation_page.short_description = options[:short_description]
          end

          it 'под полем КО выводится предупреждение, что товар будет без КО, т.к. слова из названия' do
            expect(@product_creation_page.short_description_error).to include '- слова из названия'
          end
        end

        context 'когда введено > 50 символов и не совпадает с названием' do
          let(:options) do
            {
              name: CONFIG['product_creation']['name']['valid'],
              short_description: CONFIG['product_creation']['short_description']['valid']
            }
          end

          before do
            @product_creation_page.name_input = options[:name]
            @product_creation_page.short_description = options[:short_description]
          end

          it 'под полем КО нет предупреждения' do
            expect(@product_creation_page.short_description_error?).to be false
          end
        end
      end

      # TODO: расскипать (см. ниже)
      describe 'Фото', :skip => 'Вернуть проверки после применения нового образа на ноже для БЛ' do
        context 'когда загружается изображение более 10 Мб' do
          let(:options) { {path_to_image: Constants::MORE_10MB_IMAGE} }

          before { @product_creation_page.load_image(options) }

          it 'появится предупреждение о max размере 10 Мб' do
            expect(@product_creation_page.image_error)
              .to include 'Размер файла не должен превышать 10 Мб'
          end
        end

        context 'когда загружается изображение недопустимого формата' do
          let(:options) { {path_to_image: Constants::NOT_IMAGE_PATH} }

          before { @product_creation_page.load_image(options) }

          it 'появится предупреждение о некорректном формате' do
            expect(@product_creation_page.image_error)
              .to include 'Файл должен быть корректным изображением jpg, png, gif, webp'
          end
        end
      end
    end
  end

  # Одинаковые поля в БЛ и ПЦ заполняют батарейку на разные проценты
  describe 'Когда проверяется батарейка' do
    before { navigate_to_product_creation_page }

    context 'когда выполняется клик по "Все параметры" в плашке с батарейкой' do
      before { @product_creation_page.thermometer_degree_popup_link }

      it 'откроется попап со справочной информацией о рассчете батарейки' do
        expect(@product_creation_page.thermometer_degree_popup?).to be_truthy
      end
    end

    context 'когда заполнена Цена' do
      let(:options) { {price: CONFIG['product_creation']['price']['exact']} }

      before { @product_creation_page.fill_price(options) }

      it "значение батарейки #{CONFIG['battery_percents']['price']}%" do
        expect(@product_creation_page.thermometer_degree).to eq "#{CONFIG['battery_percents']['price']}%"
      end
    end

    context 'когда загружено Изображение' do
      let(:options) { {path_to_image: IMAGE_PATH} }

      before { @product_creation_page.load_image(options) }

      it "значение батарейки #{CONFIG['battery_percents']['image']}%" do
        expect(@product_creation_page.thermometer_degree).to eq "#{CONFIG['battery_percents']['image']}%"
      end
    end

    context 'когда заполнено Краткое описание' do
      let(:options) { {short_description: CONFIG['product_creation']['short_description']['valid']} }

      before { @product_creation_page.short_description = options[:short_description] }

      it "значение батарейки #{CONFIG['battery_percents']['short_description']}%" do
        expect(@product_creation_page.thermometer_degree).to eq "#{CONFIG['battery_percents']['short_description']}%"
      end
    end

    context 'когда заполнено Полное описание' do
      let(:options) { {description: CONFIG['product_creation']['full_description']} }

      before { @product_creation_page.description = options[:description] }

      it "значение батарейки #{CONFIG['battery_percents']['description']}%" do
        expect(@product_creation_page.thermometer_degree).to eq "#{CONFIG['battery_percents']['description']}%"
      end
    end

    context 'когда заполнено Наличие' do
      let(:options) { {exists: CONFIG['product_creation']['exists']['in_stock']} }

      before { @product_creation_page.exists_select = options[:exists] }

      it "значение батарейки #{CONFIG['battery_percents']['exists']}%" do
        expect(@product_creation_page.thermometer_degree).to eq "#{CONFIG['battery_percents']['exists']}%"
      end
    end

    context 'когда заполнены все основные поля' do
      let(:options) do
        {
          price: CONFIG['product_creation']['price']['exact'],
          path_to_image: IMAGE_PATH,
          short_description: CONFIG['product_creation']['short_description']['valid'],
          description: CONFIG['product_creation']['full_description'],
          exists: CONFIG['product_creation']['exists']['in_stock']
        }
      end

      before do
        @product_creation_page.fill_price(options)
        @product_creation_page.load_image(options)
        @product_creation_page.short_description = options[:short_description]
        @product_creation_page.description = options[:description]
        @product_creation_page.exists_select = options[:exists]
      end

      it 'значение батарейки 100%' do
        expect(@product_creation_page.thermometer_degree).to eq '100%'
      end
    end
  end

  describe 'Редактирование товара' do
    context 'когда изменяем название и цену' do
      before(:all) do
        @options = {
          name: CONFIG['product_creation']['name']['valid'],
          price: CONFIG['product_creation']['price']['exact']
        }

        navigate_to_product_creation_page
        @product_creation_page.fill_attributes(@options)
        @product_page.product_edit_link
        @product_creation_page.clear_string(@options)
        @options[:name] = 'Новое название товара'
        @options[:price] = '200'
        @product_creation_page.fill_attributes(@options)
      end

      it 'на карточке товара отобразится новое название' do
        expect(@product_page.product_name).to eq 'Новое название товара'
      end

      it 'на карточке товара отобразится новая цена' do
        expect(@product_page.product_price).to include '200'
      end
    end
  end

  describe 'Модерация товара' do
    context 'когда товар одобренный' do
      before(:all) do
        @options = {name: 'Автотест, модерация: одобрен'}
        navigate_to_product_creation_page
        @product_creation_page.fill_attributes(@options)
        @product_page.product_edit_link
      end

      after do
        @product_creation_page.accept
        reload_page
      end

      context 'когда отклоняем товар по выбранной причине' do
        before do
          @product_creation_page.decline
          @product_creation_page.cause_select = 'Доработать контенту'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации выводится сообщение об отклонении' do
          expect(@product_creation_page.moderation_message)
            .to include CONFIG['product_creation']['moderation']['message']['declined']
          expect(@product_creation_page.moderation_message).to include 'Доработать контенту'
        end
      end

      context 'когда отклоняем товар по кастомной причине' do
        before do
          @product_creation_page.decline
          @product_creation_page.cause_input = 'Кастомная причина отклонения'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации выводится сообщение об отклонении' do
          expect(@product_creation_page.moderation_message)
            .to include CONFIG['product_creation']['moderation']['message']['declined']
          expect(@product_creation_page.moderation_message).to include 'Кастомная причина отклонения'
        end
      end

      context 'когда отправляем на рассмотрение товар по выбранной причине' do
        before do
          @product_creation_page.postpone
          @product_creation_page.cause_select = 'Доработать контенту'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации выводится сообщение о рассмотрении' do
          expect(@product_creation_page.moderation_message)
            .to include CONFIG['product_creation']['moderation']['message']['postponed']
          expect(@product_creation_page.moderation_message).to include 'Доработать контенту'
        end
      end
    end

    context 'когда товар отклоненный' do
      before(:all) do
        @options = {name: 'Автотест, модерация: отклонен'}
        navigate_to_product_creation_page
        @product_creation_page.fill_attributes(@options)
        @product_page.product_edit_link
        @product_creation_page.decline
        @product_creation_page.cause_select = 'Доработать контенту'
        @product_creation_page.moderation_submit
        @product_creation_page.wait_moderation_message
      end

      context 'когда одобряем товар' do
        before do
          @product_creation_page.accept
          reload_page
        end

        after do
          @product_creation_page.decline
          @product_creation_page.cause_select = 'Доработать контенту'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации не выводится сообщение об отклонении' do
          expect(@product_creation_page.moderation_message?).to be false
        end
      end

      context 'когда отправляем на рассмотрение товар по кастомной причине' do
        before do
          @product_creation_page.postpone
          @product_creation_page.cause_input = 'Кастомная причина для отправки на рассмотрение'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации выводится сообщение о рассмотрении' do
          expect(@product_creation_page.moderation_message)
            .to include CONFIG['product_creation']['moderation']['message']['postponed']
          expect(@product_creation_page.moderation_message).to include 'Кастомная причина для отправки на рассмотрение'
        end
      end
    end

    context 'когда товар на рассмотрении' do
      before(:all) do
        @options = {name: 'Автотест, модерация: на рассмотрении'}
        navigate_to_product_creation_page
        @product_creation_page.fill_attributes(@options)
        @product_page.product_edit_link
        @product_creation_page.postpone
        @product_creation_page.cause_select = 'Доработать контенту'
        @product_creation_page.moderation_submit
        @product_creation_page.wait_moderation_message
      end

      context 'когда одобряем товар' do
        before do
          @product_creation_page.accept
          reload_page
        end

        after do
          @product_creation_page.postpone
          @product_creation_page.cause_select = 'Доработать контенту'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации не выводится сообщение о рассмотрении' do
          expect(@product_creation_page.moderation_message?).to be false
        end
      end

      context 'когда отклоняем товар по кастомной причине' do
        before do
          @product_creation_page.decline
          @product_creation_page.cause_input = 'Кастомная причина для отклонения'
          @product_creation_page.moderation_submit
          @product_creation_page.wait_moderation_message
        end

        it 'над блоком основной информации выводится сообщение о рассмотрении' do
          expect(@product_creation_page.moderation_message)
            .to include CONFIG['product_creation']['moderation']['message']['declined']
          expect(@product_creation_page.moderation_message).to include 'Кастомная причина для отклонения'
        end
      end
    end
  end

  describe 'Удаление товара' do
    before(:all) do
      @options = {name: 'Автотест, редактирование'}
      navigate_to_product_creation_page
      @product_creation_page.fill_attributes(@options)
    end

    context 'когда выходим из редактирования и сохраняем изменения' do
      before do
        @product_page.product_edit_link
        @product_creation_page.clear_string(@options)
        @options = {name: 'Автотест, выход с сохранением'}
        @product_creation_page.name_input = @options[:name]
        @product_creation_page.quit
        @product_creation_page.edit_yes
      end

      it 'на карточке товара отобразится новое название' do
        expect(@product_page.product_name).to eq 'Автотест, выход с сохранением'
      end
    end

    context 'когда выходим из редактирования без сохранения изменений' do
      before do
        @product_page.product_edit_link
        @product_creation_page.clear_string(@options)
        @options = {name: 'Автотест, выход без сохранения'}
        @product_creation_page.name_input = @options[:name]
        @product_creation_page.quit
        @product_creation_page.edit_no
      end

      it 'на карточке товара отобразится старое название' do
        expect(@product_page.product_name).to eq 'Автотест, выход с сохранением'
      end
    end

    context 'когда нажимаем Удалить товар и оставляем товар' do
      before(:all) do
        @product_page.product_edit_link
        @product_creation_page.delete
        @product_creation_page.edit_no
      end

      it 'попап закрывается' do
        expect(@product_creation_page.edit_popup?).to be false
      end

      it 'остается страница редактирования товара' do
        expect(@product_creation_page.page_title?).to be_truthy
      end
    end

    context 'когда нажимаем Удалить товар и подтверждаем выбор' do
      before do
        @product_creation_page.delete
        @product_creation_page.edit_yes
        @end_url = CONFIG['url_catalog_sk']
      end

      it 'открывается каталог СК' do
        expect(Page.browser.current_url).to end_with @end_url
      end
    end
  end
end
