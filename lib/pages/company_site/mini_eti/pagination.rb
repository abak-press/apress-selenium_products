# frozen_string_literal: true

module CompanySite
  module MiniETI
    class Pagination < Page
      include CompanySite::MiniETI

      div(:current_page, css: '.js-eti-pagination-root .b-pagination_listItemCurrent')
      button(:previous_page_link, css: '.js-eti-pagination-root .b-pagination_headItemPrevious')
      button(:next_page_link, css: '.js-eti-pagination-root .b-pagination_headItemNext')
      elements(:per_page_value, css: '.js-eti-filter-options-per_page')
      button(:per_page_button, css: '.ptrfap-choose-amount-wrapper .js-eti-filter-per_page')

      def next_page
        wait_until_table_update { next_page_link }
      end

      def previous_page
        wait_until_table_update { previous_page_link }
      end

      def per_page
        current_per_page
      end

      def per_page=(value)
        wait_until_table_update do
          per_page_button
          per_page_value_elements.find { |element| element.text.strip.to_i == value }.click
        end
      end

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/mini_eti/pagination', self)
    end
  end
end
