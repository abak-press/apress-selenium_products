# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class WholesalePricePopup < self
        div(:popup, css: '.js-popup-wholesale')
        text_area(:price_value, css: '.js-popup-wholesale .js-wholesale-price')
        select_list(:currency, css: '.js-popup-wholesale #wholesale_currency')
        select_list(:measure, css: '.js-popup-wholesale #product_measure_wholesale_measure_unit_id')
        text_area(:min_qty, css: '.js-popup-wholesale .js-wholesale-min-qty')
        checkbox(:not_exact, css: '.js-popup-wholesale .js-wholesale-checkbox')

        button(:save, css: '.js-popup-wholesale .js-save-wholesale')
        button(:cancel, css: '.js-popup-wholesale [title="Отменить"]')
      end

      def wait_for_visible
        popup_element.when_visible
      end
    end
  end
end
