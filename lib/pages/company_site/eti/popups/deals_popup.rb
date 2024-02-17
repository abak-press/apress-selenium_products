# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class DealsPopup < self
        checkbox(:deal_checkbox, css: '.js-input-deals')
        checkbox(:deal_product_checkbox, xpath: "//*[text()[contains(., \'#{CONFIG['offer_with_product']}\')]]/input")
        button(:save_deals, css: 'div.ui-dialog div > button:nth-child(1)')
      end
    end
  end
end
