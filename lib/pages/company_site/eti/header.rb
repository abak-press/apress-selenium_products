# frozen_string_literal: true

module CompanySite
  module ETI
    class Header < Page
      include CompanySite::ETI

      button(:exact_search, css: 'span[for="search-checkbox-exact"]')
      text_area(:search_string, xpath: "//*[@id='product-bindings-search']")
      button(:search_button, css: '.js-eti-search-submit')
      label(:reset_search_button, css: '.js-eti-search-config__reset')
      div(:search_type, css: '.search-type-toggler')
      label(:full_search, css: 'label[data-name="По названию, кр. описанию, артикулу"]')
      label(:search_by_name, css: 'label[data-name="По названию"]')

      button(:setting_columns_button, css: '.js-toggle-settings')

      def setting_columns
        setting_columns_button

        setting_columns_popup = CompanySite::ETI::Table::SettingColumnsPopup.new
        setting_columns_popup.wait_for_visible
        setting_columns_popup.select_all_columns

        wait_render_table
      end

      def search_product(name, options = {})
        exact_search if options[:exact] == true
        self.search_type = options[:search_type] if options[:search_type]
        self.search_string = name
        search_button
        wait_render_table

        expected_count = options[:expected_count] || 1
        table_products = CompanySite::ETI::Table::Products.new
        max_attempts = 10

        max_attempts.times do
          search_button
          wait_render_table

          break if table_products.products_elements.size >= expected_count

          # Для синхронизации в среднем требуется около 1 минуты,
          # чтобы товар после создания появился в индексе эластика
          # Для достоверности увеличили слип до 10 секунд после каждой попытки повторного поиска,
          # чтобы скопированный товар точно появился в ЕТИ
          sleep 10
        end

        if table_products.string_no_products? || table_products.products_elements.size < expected_count
          raise "Товары не отобразились после #{max_attempts} повторных поисков"
        end
      end

      def search_type=(type)
        case type
        when :full
          search_type_element.click
          full_search_element.click
        when :by_name
          search_type_element.click
          search_by_name_element.click
        end
      end

      def reset_search
        reset_search_button_element.click
        wait_render_table
      end

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/header', self)
    end
  end
end
