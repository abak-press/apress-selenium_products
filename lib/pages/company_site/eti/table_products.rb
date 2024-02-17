# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class Products < self
        # Кнопка добавления нового товара
        button(:add_new_product, css: '.new-row-product')

        # Плейсхолдер у названия нового пустого товара
        span(:empty_product_name, xpath: "//*[text()[contains(., 'Указать название')]]")

        # Ячейки товара
        elements(:products, :row, css: '*[id^="product-item"]')
        elements(:names, :cell, css: '.js-eti-name')
        elements(:rubrics, :cell, css: '.js-eti-rubric')
        elements(:images, :cell, css: '*[id^="product-item"] *[class*="ibb"]')
        elements(:images_counters, :div, css: '*[id^="product-item"] *[class="saved-images-count"]')
        elements(:public_state_icon, :cell, css: '.js-eti-status')
        elements(:battery_level, :cell, css: '.js-battery-wrapper')
        elements(:battery_title, :cell, css: '.battery')
        elements(:rubric_link, :cell, css: '.js-rubric-preview-link')
        elements(:exists_link, :cell, css: '.js-eti-exists .dashed-span')
        elements(:announces, :cell, css: '.js-eti-announce')
        elements(:prices, :cell, css: '.js-eti-price [title="Изменить цену"]')
        elements(:wholesale_prices, :cell, css: '.js-eti-wholesaleprice [title="Указать оптовую цену"]')
        elements(:traits_link, :cell, css: '.js-eti-traits > div')
        elements(:descriptions, :cell, css: '.js-eti-description')
        elements(:groups, :cell, css: '.js-group-preview-link')

        # Окно редактирования краткого описания
        div(:edit_box, css: '.editbox')

        # Кнопки в плашке, появляющейся при наведении на строку товара
        button(:delete_product_icon, css: '.js-delete-product')
        elements(:copy_product_icon, css: '.js-copy-product')

        # Чекбокс у строки товара
        checkbox(:product_checkbox, css: '.js-check-product')

        # Массовое действие "Добавить к акции"
        button(:add_products_to_deal, css: '.js-deals-config')

        # @return элемент строки товара и таблицы Selenium::WebDriver::Element
        #
        # @example
        #   product(name: 'Мяч')
        #   product(index: 0)
        #
        # @param [hash]
        #  * :name - String
        #  * :index - Fixnum
        #
        def product(param = {})
          if param.key? :name
            name_element = names_elements.select { |n| n.text == param[:name] }.first
            products_elements[names_elements.index(name_element)]
          elsif param.key? :index
            products_elements[param[:index]]
          end
        end

        # @return элемент строки товара и таблицы Selenium::WebDriver::Element
        # Поля заполняются в том порядке, в котором переданы в параметрах
        #
        # @example
        #   add_product(name: 'Мяч', exists: :available, group: 'Спортивный инвентарь')
        #
        # @param [Hash]
        #
        def add_product(params = {})
          add_new_product
          wait_until { products_elements[0].attribute('class').include?('new') }

          params.each do |key, value|
            send("set_#{key}", products_elements[0], value)
          end

          products_elements[0]
        end

        def copy_product(product)
          products = products_elements

          browser
            .action
            .move_to(products_elements[product_index(product)].element)
            .perform

          copy_product_icon_elements[product_index(product)].click
          wait_until { products_elements.size > products.size }
        end

        def delete_product(product)
          browser
            .action
            .move_to(products_elements[product_index(product)].element)
            .perform

          confirm(true) { delete_product_icon }

          wait_saving
        end

        # @return nothing
        #
        # @example
        #   set_name(@product1, 'Футболка')
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String]
        #
        def set_name(product, text)
          click_on_cell(names_elements[product_index(product) || 0])

          browser
            .action
            .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
            .key_down(:control)
            .send_keys('a')
            .key_up(:control)
            .send_keys(Selenium::WebDriver::Keys::KEYS[:clear])
            .send_keys(text)
            .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
            .perform

          wait_saving
        end

        def name(product)
          names_elements[product_index(product)].element.text
        end

        def battery(product)
          {
            level: battery_level_elements[product_index(product)].text.strip.to_i,
            title: battery_title_elements[product_index(product)].attribute('title'),
          }
        end

        # @return nothing
        #
        # @example
        #   set_public_state(@product1, :published)
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String], [Symbol]
        #
        def set_public_state(product, public_state)
          click_on_cell(public_state_icon_elements[product_index(product)].i_element)

          public_state_popup = PublicStatePopup.new
          public_state_popup.wait_for_visible

          public_state_popup.public_state = public_state

          wait_saving
        end

        def public_state(product)
          public_state_icon_elements[product_index(product)].attribute('data-public_state').to_sym
        end

        # @return nothing
        #
        # @example
        #   set_rubric(@product1, 'Спортивный инвентарь')
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String]
        #
        def set_rubric(product, rubric)
          click_on_cell(rubric_link_elements[product_index(product)])

          rubrics_binding_popup = RubricsBindingPopup.new
          rubrics_binding_popup.find(rubric)
          rubrics_binding_popup.select_result(rubric)

          wait_saving
        end

        def rubric(product)
          rubric_link_elements[product_index(product)].element.text
        end

        # @return nothing
        #
        # @example
        #   set_exists(@product1, :available)
        #
        # @param [Selenium::WebDriver::Element]
        # @param [Hash] - ключ из константы CompanySite::ETI::Table::Products::EXISTS
        #
        def set_exists(product, value)
          click_on_cell(exists_link_elements[product_index(product)])

          exists_popup = ExistsPopup.new
          exists_popup.select_exists(value)

          wait_saving
        end

        def exists(product)
          exists_link_elements[product_index(product)].element.text
        end

        # @return nothing
        #
        # @example
        #   set_announce(@product1, 'Краткое описание товара')
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String]
        #
        def set_announce(product, text)
          click_on_cell(announces_elements[product_index(product)])

          browser
            .action
            .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
            .perform

          browser.switch_to.frame(1)
          wait_until?(2) { edit_box? }

          browser
            .action
            .key_down(:control)
            .send_keys('a')
            .key_up(:control)
            .send_keys(Selenium::WebDriver::Keys::KEYS[:clear])
            .send_keys(text)
            .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
            .perform

          browser.switch_to.default_content

          wait_saving
        end

        def announce(product)
          announces_elements[product_index(product)].element.text
        end

        # @return nothing
        #
        # @example
        #   exact_price = {type: :exact, price: 10, currency: 'usd', measure: 'мешок'}
        #
        #   range_price = {type: :range, price: 10, price_max: 20, currency: 'у.е.', measure: 'рулон'}
        #
        #   discount_price = {
        #     type: :discount, price: 50,
        #     new_price: 25,
        #     discount_percent: 50,
        #     expires_at: '21.08.2020'.
        #     currency: 'руб.',
        #     measure: 'шт.'
        #   }
        #
        #   set_price(@product1, exact_price)
        #
        # @param [Selenium::WebDriver::Element]
        # @param [Hash]
        #
        def set_price(product, options = {})
          click_on_cell(prices_elements[product_index(product)])
          price_popup = PricePopup.new
          price_popup.wait_for_visible

          case options[:type].to_sym
          when :exact
            price_popup.exact_price(options)
          when :range
            price_popup.range_price(options)
          when :discount
            price_popup.discount_price(options)
          end
          price_popup.save

          wait_saving
        end

        def price(product)
          prices_elements[product_index(product)].element.text
        end

        # @return nothing
        #
        # @example
        #   price_fields = {
        #     price: 12
        #     currency: 'usd',
        #     measure: 'шт.',
        #     not_exact: false,
        #     min_qty: 10
        #   }
        #
        #   set_wholesale_price(@product1, price)
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String]
        #
        def set_wholesale_price(product, options = {})
          click_on_cell(wholesale_prices_elements[product_index(product)])

          wholesale_price_popup = WholesalePricePopup.new
          wholesale_price_popup.wait_for_visible
          wholesale_price_popup.price_value = options[:price] if options[:price]
          wholesale_price_popup.currency = options[:currency] if options[:currency]
          wholesale_price_popup.measure = options[:measure] if options[:measure]
          wholesale_price_popup.check_not_exact if options[:not_exact]
          wholesale_price_popup.min_qty = options[:min_qty] if options[:min_qty]
          wholesale_price_popup.save

          wait_saving
        end

        def wholesale_price(product)
          wholesale_prices_elements[product_index(product)].element.text
        end

        # @return nothing
        #
        # @example
        #   traits = {'Бренд' => 'Adidas', 'Страна-производитель' => 'Китай'}
        #
        #   set_traits(product1, traits)
        #
        # @param [Selenium::WebDriver::Element]
        # @param [Hash]
        #
        def set_traits(product, traits)
          sleep 3
          click_on_cell(traits_link_elements[product_index(product)])

          traits_popup = TraitsPopup.new
          traits_popup.wait_for_visible

          traits.each { |k, v| traits_popup.set_trait_value(k, v) }
          traits_popup.save

          wait_saving
        end

        # @return nothing
        #
        # @example
        #   set_description(@product1, 'Полное описание товара или услуги')
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String]
        #
        def set_description(product, text)
          click_on_cell(descriptions_elements[product_index(product)])

          browser
            .action
            .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
            .perform

          description_popup = DescriptionPopup.new
          description_popup.wait_for_visible
          description_popup.text_element.click

          browser
            .action
            .key_down(:control)
            .send_keys('a')
            .key_up(:control)
            .send_keys(Selenium::WebDriver::Keys::KEYS[:clear])
            .perform

          description_popup.text_element.send_keys(text)
          description_popup.save

          wait_saving
        end

        # @return nothing
        #
        # @example
        #   set_group(@product1, 'Спортивный инвентарь')
        #
        # @param [Selenium::WebDriver::Element]
        # @param [String]
        #
        def set_group(product, group)
          click_on_cell(groups_elements[product_index(product)])

          groups_binding_popup = GroupsBindingPopup.new
          groups_binding_popup.wait_for_visible
          groups_binding_popup.select_group(group)

          wait_saving
        end

        def group(product)
          groups_elements[product_index(product)].element.text.strip
        end

        # @return nothing
        #
        # @example
        #   upload_image(@product1, type: :local, path: 'C:/images/picture.png')
        #   upload_image(@product1, type: :remote, url: 'http://site.ru/images/picture.png')
        #
        # @param [Selenium::WebDriver::Element]
        # @param [Hash] - тип источника
        #   * :remote - удаленный сервер (http/https протокол)
        #   * :local - локальная файловая система
        # @param [Hash]
        #  * :url - ссылка на изображение (при type: :remote)
        #  * :path - путь к файлу (при type: :local)
        #
        def upload_image(product, options = {})
          click_on_cell(images_elements[product_index(product)])

          images_upload_popup = ImagesUploadPopup.new
          images_upload_popup.wait_for_visible

          case options[:type].to_sym
          when :remote
            images_upload_popup.upload_from_url(options[:url])
          when :local
            images_upload_popup.upload_from_file(options[:path])
          end

          images = images_upload_popup.images
          images_upload_popup.close
          images
        end

        def image(product)
          {
            url: images_elements[product_index(product)].attribute('src'),
            counts: images_counters_elements[product_index(product)].text.to_i,
          }
        end

        ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/table_products', self)

        private

        def product_index(product)
          products_elements.index(product)
        end

        def click_on_cell(element)
          scroll_into_view(element)

          browser
            .action
            .move_to(element.element)
            .click
            .perform
        end
      end
    end
  end
end
