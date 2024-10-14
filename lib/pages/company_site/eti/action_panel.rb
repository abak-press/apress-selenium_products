# frozen_string_literal: true

module CompanySite
  module ETI
    class ActionPanel < Page
      include CompanySite::ETI

      button(:undo_button, css: '.js-undo')
      button(:redo_button, css: '.js-redo')
      button(:products, css: '.js-eti-action-panel__button_products')
      button(:add_to_deal, css: '.js-deals-config')


      def undo
        undo_button
        wait_saving
      end

      def redo
        redo_button
        wait_saving
      end

      def open_deals_popup
        products
        add_to_deal
      end

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/action_panel', self)
    end
  end
end
