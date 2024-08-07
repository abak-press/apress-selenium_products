# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class PricePopup < self
        div(:popup, css: '.popup-price')
        text_area(:price_value, css: '.js-popup-price__tab-content:not(.dn) [name="price"]')
        text_area(:price_max_value, css: '.js-popup-price__tab-content:not(.dn) [name="price_max"]')
        text_area(:discount_price_value, css: '.js-popup-price__tab-content:not(.dn) [name="discount_price"]')
        text_area(:discount_percent, css: '.js-popup-price__tab-content:not(.dn) [name="product_discount_percent"]')
        text_area(:expires_at, css: '.js-popup-price__tab-content:not(.dn) .js-discount-expires-at')

        button(:save, css: '.price-dialog__save-button')

        def exact_price(options = {})
          select_price_type('exact')
          self.price_value = options[:price] if options[:price]
          select_currency(options) if options[:currency]
          select_measure(options) if options[:measure]
        end

        def range_price(options = {})
          select_price_type('range')
          self.price_value = options[:price] if options[:price]
          self.price_max_value = options[:price_max] if options[:price_max]
          select_currency(options) if options[:currency]
          select_measure(options) if options[:measure]
        end

        def discount_price(options = {})
          select_price_type('discount')
          self.price_value = options[:price] if options[:price]
          self.discount_price_value = options[:new_price] if options[:new_price]
          self.discount_percent = options[:discount_percent] if options[:discount_percent]
          execute_script("arguments[0].value='#{options[:expires_at]}'", expires_at_element) if options[:expires_at]
          select_currency(options) if options[:currency]
          select_measure(options) if options[:measure]
        end

        def wait_for_visible
          popup_element.when_visible
        end

        def select_price_type(type)
          Page.button(:type_price, css: ".js-popup-price__tabs-tab[data-type='#{type}']")
          type_price
        end

        def select_currency(options)
          Page.link(:currency, xpath:
            "//div[@class='popup-price__tab-content js-popup-price__tab-content']
            //div[normalize-space()='#{options[:currency]}']")
          currency
        end

        def select_measure(options)
          Page.link(:measure, xpath:
            "//div[@class='popup-price__tab-content js-popup-price__tab-content']
            //div[normalize-space()='#{options[:measure]}']")
          measure
        end
      end
    end
  end
end
