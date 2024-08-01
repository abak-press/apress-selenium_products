# frozen_string_literal: true

module CompanySite
  class ProductCreationPage < Page
    div(:page_title, css: '.company-admin-content-wrap .product')

    # Блок Основная информация (Название товара, Артикул, Наличие)
    text_area(:name_input, css: '.aui-admin-text-input__field.name')
    span(:name_error, css: '.aui-admin-text-invalid__text')
    text_area(:article_input, css: '.main-info__content-wrapper .aui-admin-text-input__field')
    select(:exists_select, css: '.main-info__content-wrapper .aui-admin-select__input')
    select(:qty_in_stock_select, css: '.main-info__qty-in-stock select')
    text_area(:qty_exact_input, css: '.main-info__qty-in-stock input')

    # Блок Цены
    #   Розничная
    #     Точная
    text_area(:price_input, css: 'input[placeholder="Укажите размер цены"]')
    #     От-До
    button(:price_from_to_button, xpath: '//*[@class="product__section price"]//label[2]')
    text_area(:price_from_input, css: 'input[placeholder="Укажите минимальный размер цены"]')
    text_area(:price_to_input, css: 'input[placeholder="Укажите максимальный размер цены"]')
    #     Скидка
    button(:discount_price_button, xpath: '//*[@class="product__section price"]//label[3]')
    text_area(:discount_price_old_input, css: 'input[placeholder="Укажите размер цены"]')
    text_area(:discount_price_new_input, css: 'input[placeholder="Укажите размер цены со скидкой"]')
    div(:activate_calendar_discount, css: '.calendar .price-date-block')
    button(:discount_without_expiration, css: '.calendar__block .without-action-time')
    #     Валюта и Единицы измерения
    select(:currency_select, css: 'div.product__content.product__content_long-bottom div.price__currency select')
    select(:measure_select, css: 'div.product__content.product__content_long-bottom div.product__input select')
    #   Оптовая
    #     Цена
    checkbox(:wholesale_checkbox, css: '[for="is-wholesale-price"]')
    text_area(:wholesale_price_input, css: 'input[placeholder="Укажите размер оптовой цены"]')
    text_area(:wholesale_qty_input, css: 'input[placeholder="Минимальный оптовый заказ"]')
    #     Валюта и Единицы измерения
    select(:wholesale_currency_select, xpath: '//*[@class="product__content"]//*[@class="price__currency"]//select')
    select(:wholesale_measure_select, xpath: '//*[@class="product__content"]//*[@class="product__input"]//select')

    # Блок Описание (КО, ПО, Тэг <title>)
    text_area(:short_description, xpath: '//div[@class="short-description__textarea"]//textarea')
    span(:short_description_error, css: '.aui-admin-text-invalid__text')
    text_area(:product_description, css: 'textarea[name="product_editor"]')
    div(:ckeditor, css: '#cke_product_description')
    text_area(:tag_title_input, css: '.tag-title .aui-admin-text-input__field')

    # Блок Рубрика для публикации на портале (Выбор рубрики, Ранее выбранные рубрики)
    text_area(:rubric_input, css: '.rubricator .aui-admin-search__input')
    button(:rubric_find_button, css: '.rubricator .aui-admin-search__button')
    link(:rubric_level1, xpath: "//*[text()='#{CONFIG['rubrics_names_by_level'][1]}']")
    link(:rubric_level2, xpath: "//*[text()='#{CONFIG['rubrics_names_by_level'][2]}']")
    link(:rubric_level3, xpath: "//*[text()='#{CONFIG['rubrics_names_by_level'][3]}']")
    link(:rubric_level4, xpath: "//*[text()='#{CONFIG['rubrics_names_by_level'][4]}']")
    link(:rubric_level5, xpath: "//*[text()='#{CONFIG['rubrics_names_by_level'][5]}']")
    link(:finded_rubric, xpath: "(//div[@class='aui-admin-rubric-block__link'])[1]")
    span(:check_rubric, css: '.aui-admin-rubric-block_active')
    button(:change_rubric, css: '.aui-admin-edit-button')
    span(:rubricator, css: '.rubric-select-tree-block')

    # Блок Приоритет в рубрике
    checkbox(:priority_lvl4_checkbox, css: '[for="rubric_l4_priority"]')
    checkbox(:priority_lvl5_checkbox, css: '[for="rubric_l5_priority"]')

    # Блок Характеристики товаров
    #   На вашем сайте
    text_area(:user_trait_input, xpath: '(//div[@class="company-trait__item"]//input)[last()]')
    button(:add_user_trait, css: '.company-trait__add .aui-admin-link')
    text_area(:user_trait_value_input, xpath: '(//div[@class="company-trait-value__item"]//input)[last()]')
    button(:add_user_trait_value, css: '.company-trait-value__buttons .aui-admin-link')
    #   На портале
    button(:switch_to_portal_traits, xpath: '//label[contains(text(),"На портале")]')
    elements(:portal_trait_name, xpath: '//div[@class="rubric-trait"]//label')
    elements(:portal_trait_value, css: '.rubric-trait > input')

    # Блок Фото
    button(:load_image_button, xpath: '//div[@class="image-loader__block"]/../..//input[@type="file"]')
    image(:first_mini_image, css: 'img.aui-admin-image-preview__image')
    image(:last_mini_image, xpath: '(//img[@class="aui-admin-image-preview__image"])[last()]')
    text_area(:description_of_photo, css: '.image-block__textarea .aui-admin-textarea__field')
    div(:image_error, css: 'div.image-loader__error-text')

    # Блок Группа товаров
    elements(:groups_tree, css: '.groups__selector-block .aui-admin-rubric-select__title')

    # Блок Документы
    button(:load_file, xpath: '//div[@class="document-loader__block"]/../..//input[@type="file"]')
    elements(:docs, css: '.documents__reorder-block .document-block')

    # Блок Сопутствующие товары
    text_area(:soputka_input, css: '.related-products__search .aui-admin-search__input')
    button(:soputka_find_button, css: '.related-products__search .aui-admin-search__button')
    button(:add_in_soputka_button, css: '.related-products__search-products .aui-admin-related-products__button')

    # Минимальный размер заказа (только для ПЦ)
    text_area(:min_qty_input, css: '.min-quantity .aui-admin-number-input__field')

    # Кнопка сохранения
    button(:save, css: '.aui-admin-button_submit')

    # Удаление и выход из редактирования
    # Открывается попап удаления/выхода с одинаковыми классами у обеих кнопок, но разным текстом
    button(:quit, css: '.product .page-info__edit-product-control-buttons_quit')
    button(:delete, css: '.product .page-info__edit-product-control-buttons_delete')
    span(:edit_popup, css: '.product .page-info-popup__block')
    button(:edit_yes, css: '.page-info-popup__block [type="submit"]')
    button(:edit_no, css: '.page-info-popup__block .page-info-popup__link')

    # Модерация
    #   Кнопки на форме
    button(:accept, css: '.aui-admin-moderation-button_accept')
    button(:decline, css: '.aui-admin-moderation-button_decline')
    button(:postpone, css: '.aui-admin-moderation-button_postpone')
    #   Попап модерации
    span(:moderation_popup, css: '.moderation-popup__block')
    textarea(:cause_input, css: '.moderation-popup__block .moderation-popup__textarea')
    select(:cause_select, css: '.moderation-popup__block .aui-admin-select__input')
    button(:moderation_submit, css: '.moderation-popup__block .aui-admin-button')
    #   Уведомление
    span(:moderation_message, css: 'div.page-info__notice')

    # Батарейка
    span(:thermometer_degree, css: '.aui-admin-battery__percent')
    link(:thermometer_degree_popup_link, css: '.aui-admin-battery__link')
    span(:thermometer_degree_popup, css: '.aui-admin-popup')

    # ОПИСАНИЕ МЕТОДОВ
    #
    # Основной метод последовательного заполнения атрибутов, переданых в переменной options из спека
    # Если атрибут есть в переменной options, то заполняется; если атрибута нет, то пропускается
    def fill_attributes(options)
      fill_main_block(options)
      fill_price(options)
      fill_description_block(options)
      fill_rubric_block(options)
      fill_traits_block(options)

      load_image(options) if options[:path_to_image]
      fill_group(options) if options[:group]
      load_doc(options) if options[:path_to_doc]
      fill_soputka(options) if options[:soputka]
      self.min_qty_input = options[:min_qty] if options[:min_qty]

      save
    end

    # Заполнение блока Основная информация
    def fill_main_block(options)
      self.name_input = options[:name] if options[:name]
      self.article_input = options[:article] if options[:article]
      self.exists_select = options[:exists] if options[:exists]
      self.qty_in_stock_select = options[:qty_in_stock] if options[:qty_in_stock]
      self.qty_exact_input = options[:qty_exact] if options[:qty_exact]
    end

    # Заполнение блока Цены
    def fill_price(options)
      fill_price_exact(options) if options[:price]
      fill_price_range(options) if options[:price_from]
      fill_discount_price(options) if options[:price_old]
      fill_wholesale_price(options) if options[:wholesale_price]
    end

    # Заполнение блока Описание
    def fill_description_block(options)
      self.short_description = options[:short_description] if options[:short_description]
      self.description = options[:description] if options[:description]
    end

    # Заполнение блока Рубрика и ее приоритет
    def fill_rubric_block(options)
      fill_rubric(options) if options[:rubric]
      fill_priority_in_rubric(options) if options[:priority_lvl4 || :priority_lvl5]
    end

    # Заполнение блока Характеристики товара
    def fill_traits_block(options)
      fill_company_traits(options) if options[:company_traits]
      fill_portal_traits(options) if options[:portal_traits]
    end

    # Заполнение розничной цены точной
    def fill_price_exact(options)
      self.price_input = options[:price]
      self.currency_select = options[:currency] if options[:currency]
      self.measure_select = options[:measure] if options[:measure]
    end

    # Заполнение розничной цены от-до
    def fill_price_range(options)
      price_from_to_button
      self.price_from_input = options[:price_from]
      self.price_to_input = options[:price_to]
      self.currency_select = options[:currency] if options[:currency]
      self.measure_select = options[:measure] if options[:measure]
    end

    # Заполнение розничной цены со скидкой с max датой окончания скидки (10 лет)
    def fill_discount_price(options)
      discount_price_button
      self.discount_price_old_input = options[:price_old]
      self.discount_price_new_input = options[:price_new]
      activate_calendar_discount_element.click
      discount_without_expiration
      self.currency_select = options[:currency] if options[:currency]
      self.measure_select = options[:measure] if options[:measure]
    end

    # Заполнение оптовой цены
    def fill_wholesale_price(options)
      check_wholesale_checkbox
      self.wholesale_price_input = options[:wholesale_price]
      self.wholesale_qty_input = options[:wholesale_qty]
      self.wholesale_currency_select = options[:currency] if options[:currency]
      self.wholesale_measure_select = options[:measure] if options[:measure]
    end

    # Вставка текста в полное описание
    def description=(text)
      wait_until { ckeditor? }
      type_to_ck_editor('product_description', text) # метод из модуля apress-selenium_integration
    end

    # Поиск и выбор рубрики
    def fill_rubric(options)
      change_rubric_element.click unless change_rubric_not_exists? # редактирование рубрики, если есть кнопка
      self.rubric_input = options[:rubric]
      rubric_find_button
      finded_rubric
    end

    # Заполнение приоритета у рубрики
    def fill_priority_in_rubric(options)
      options[:priority_lvl4] == true ? check_priority_lvl4_checkbox : uncheck_priority_lvl4_checkbox
      options[:priority_lvl5] == true ? check_priority_lvl5_checkbox : uncheck_priority_lvl5_checkbox
    end

    # Заполнение компанейских характеристик
    def fill_company_traits(options)
      options[:company_traits].each do |trait, value|
        self.user_trait_input = trait
        self.user_trait_value_input = value
        add_user_trait
      end
    end

    # Заполнение портальных характеристик
    def fill_portal_traits(options)
      switch_to_portal_traits
      options[:portal_traits].each { |trait, value| fill_portal_traits_values(trait, value) }
    end

    # Заполнение значений у портальных характеристик
    def fill_portal_traits_values(trait, value)
      browser
        .action
        .click(portal_trait_value_elements[trait_index(trait)].element)
        .perform

      Page.elements(:available_trait_values, :link, css: '.select-options > div')
      available_trait_values_elements.find { |trait_value| trait_value.text == value }.click
    end

    def trait_index(trait)
      portal_trait_name_elements.index { |element| element.text == trait }
    end

    # Загрузка заданных изображений
    def load_image(options)
      if options[:qty_of_images]
        options[:qty_of_images].times do
          upload_file(load_image_button_element, options[:path_to_image])
        end
      else
        upload_file(load_image_button_element, options[:path_to_image])
      end

      last_mini_image_element.when_visible(30) if options[:qty_of_images]
      self.description_of_photo = options[:description_of_photo] if options[:description_of_photo]
    end

    # Выбор группы
    def fill_group(options)
      name_group = options[:group]
      groups_tree_elements.find { |group| group.text.strip == name_group }.click
    end

    # Загрузка заданных документов
    def load_doc(options)
      options[:qty_of_doc].times do
        upload_file(load_file_element, options[:path_to_doc])
      end

      wait_until { docs_elements.size == 5 }
    end

    # Выбор сопутствующих товаров
    def fill_soputka(options)
      self.soputka_input = options[:soputka]
      soputka_find_button
      options[:qty_of_soputka].times do
        add_in_soputka_button
        sleep 1
      end
    end

    # Очистка ТОЛЬКО текстовых строк
    # Название строк которые нужно очистить передаются хэшом в параметр
    #   Например, в спеке объявляется переменная
    #   @options = {
    #     name: CONFIG['product_creation']['name']['valid'],
    #     price: CONFIG['product_creation']['price']['exact']
    #   }
    # Этот метод очистит текстовые строки name и price
    def clear_string(names_strings)
      elements = names_strings.keys.map(&:to_s)

      elements.each do |element_name|
        el = send("#{element_name}_input_element")

        browser
          .action
          .move_to(el.element)
          .click
          .perform

        clear_field
      end
    end

    # Метод для перезагрузки страницы и ожидания отрисовки сообщения модерации
    #   Очень редко может зафейлить. При быстрых действиях может отрисоваться некорректный статус
    #   на странице и неверные кнопки модерации, поэтому при некорректном сообщении перезагружаем страницу
    def wait_moderation_message
      reload_page
      wait_until { moderation_message? }
      reload_page if moderation_message == 'Внимание! Показ на портале остановлен'
    end
  end
end
