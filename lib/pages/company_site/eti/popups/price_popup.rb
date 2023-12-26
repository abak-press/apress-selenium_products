# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class PricePopup < self
        div(:popup, css: '.popup-price')
        radio_button_group(:price_type, css: '.js-select-type-price')
        text_area(:price_value, css: '.pv-wrapper:not([style*="display: none"]) [name="price"]')
        text_area(:price_max_value, css: '.pv-wrapper:not([style*="display: none"]) [name="price_max"]')
        text_area(:discount_price_value, css: '.pv-wrapper:not([style*="display: none"]) [name="discount_price"]')
        text_area(:discount_percent, css: '.pv-wrapper:not([style*="display: none"]) [name="product_discount_percent"]')
        select_list(:measure, css: '.pv-wrapper:not([style*="display: none"]) #product_measure_unit_id')
        select_list(:currency, css: '.pv-wrapper:not([style*="display: none"]) #currency')
        text_area(:expires_at, css: '.pv-wrapper:not([style*="display: none"]) .js-discount-expires-at')

        button(:save, xpath: '//*[@class="ui-button-text" and text()="Сохранить"]/..')
        button(:cancel, xpath: '//*[@class="ui-button-text" and text()="Отменить"]/..')

        def exact_price(options = {})
          select_price_type('exact')
          self.price_value = options[:price] if options[:price]
          self.currency = options[:currency] if options[:currency]
          self.measure = options[:measure] if options[:measure]
        end

        def range_price(options = {})
          select_price_type('range')
          self.price_value = options[:price] if options[:price]
          self.price_max_value = options[:price_max] if options[:price_max]
          self.currency = options[:currency] if options[:currency]
          self.measure = options[:measure] if options[:measure]
        end

        def discount_price(options = {})
          select_price_type('discount')
          self.price_value = options[:price] if options[:price]
          self.discount_price_value = options[:new_price] if options[:new_price]
          self.discount_percent = options[:discount_percent] if options[:discount_percent]
          execute_script("arguments[0].value='#{options[:expires_at]}'", expires_at_element) if options[:expires_at]
          self.currency = options[:currency] if options[:currency]
          self.measure = options[:measure] if options[:measure]
        end

        def wait_for_visible
          popup_element.when_visible
        end
      end
    end
  end
end
