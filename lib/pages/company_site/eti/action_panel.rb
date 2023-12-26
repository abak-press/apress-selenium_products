# frozen_string_literal: true

module CompanySite
  module ETI
    class ActionPanel < Page
      include CompanySite::ETI

      button(:undo_button, css: '.js-undo')
      button(:redo_button, css: '.js-redo')

      def undo
        undo_button
        wait_saving
      end

      def redo
        redo_button
        wait_saving
      end

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/action_panel', self)
    end
  end
end
