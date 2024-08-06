# frozen_string_literal: true

module CompanySite
  module ETI
    class Header < Page
      include CompanySite::ETI

      button(:exact_search, css: 'span[for="search-checkbox-exact"]')
      text_area(:search_string, xpath: "//*[@id='product-bindings-search']")
      button(:search_button, css: '.js-eti-search-submit')
      div(:search_type, css: '.search-type-toggler')
      label(:full_search, css: 'label[data-name="По названию, кр. описанию, артикулу"]')
      label(:search_by_name, css: 'label[data-name="По названию"]')

      def search_product(name, params = {})
        exact_search if params[:exact] == true
        self.search_type = params[:search_type]
        self.search_string = name
        search_button
        wait_render_table

        # Костыль для достоверности после sleep 3, который выполняет поиск до тех пор, пока не появится товар
        # Событие создания товара может не успеть записаться в эластик => товар не выведется после первого поиска
        table_products = CompanySite::ETI::Table::Products.new
        max_attempts = 10

        max_attempts.times do
          break unless table_products.string_no_products?

          search_button
          wait_render_table
        end

        raise "Exceeded maximum attempts to find products" if table_products.string_no_products?
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

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/header', self)
    end
  end
end
