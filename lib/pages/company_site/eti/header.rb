module CompanySite
  module ETI
    class Header < Page
      include CompanySite::ETI

      checkbox(:exact_search, css: '#exact_search')
      text_area(:search_string, xpath: "//*[@id='product-bindings-search']")
      button(:search_button, css: '.js-search-submit')
      div(:search_type, css: '.selected-search-type')
      label(:full_search, css: 'label[data-name="По названию, кр. описанию, артикулу"]')
      label(:search_by_name, css: 'label[data-name="По названию"]')

      def search_product(name, params = {})
        params[:exact] == true ? check_exact_search : uncheck_exact_search

        self.search_type = params[:search_type]
        self.search_string = name
        search_button
        wait_render_table
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
