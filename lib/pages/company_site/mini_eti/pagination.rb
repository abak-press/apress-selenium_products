module CompanySite
  module MiniETI
    class Pagination < Page
      div(:current_page, css: '.js-eti-pagination-root .b-pagination_listItemCurrent')
      button(:previous_page, css: '.js-eti-pagination-root .b-pagination_headItemPrevious')
      button(:next_page, css: '.js-eti-pagination-root .b-pagination_headItemNext')
      elements(:per_page_value, css: '.js-choose-amount-combobox a')
      div(:current_per_page, css: '.ptrfap-choose-amount-wrapper .custom-combobox-input')
      button(:per_page_button, css: '.ptrfap-choose-amount-wrapper .custom-combobox-toggle')

      def per_page
        current_per_page
      end

      def per_page=(value)
        per_page_button
        per_page_value_elements.find { |element| element.text.strip.to_i == value }.click
      end

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/mini_eti/pagination', self)
    end
  end
end
