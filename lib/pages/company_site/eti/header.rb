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

      def search_product(name, options = {})
        exact_search if options[:exact] == true
        self.search_type = options[:search_type] if options[:search_type]
        self.search_string = name
        search_button
        wait_render_table

        table_products = CompanySite::ETI::Table::Products.new
        max_attempts = 10

        case options [:operation]
        when :copy
          max_attempts.times do
            break if table_products.products_elements.size >= 2

            search_button
            wait_render_table
            # Для синхронизации в среднем требуется около 1 минуты,
            # чтобы товар после создания появился в индексе эластика
            # Для достоверности увеличили слип до 10 секунд после каждой попытки повторного поиска,
            # чтобы скопированный товар точно появился в ЕТИ
            sleep 10
          end
          raise "Товары не отобразились после #{max_attempts} повторных поисков" if
            table_products.string_no_products? || table_products.products_elements.size < 2
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
