# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class SettingColumnsPopup < self
        div(:popup, css: '.js-toggle-settings')
        checkbox(:all_columns, css: '[name="allCheck"]')
        button(:save, css: '.js-save-settings')

        def wait_for_visible
          popup_element.when_visible
        end

        def select_all_columns
          check_all_columns
          save
        end
      end
    end
  end
end
