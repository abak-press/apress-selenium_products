# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class TraitsPopup < self
        div(:popup, css: '.js-popup-traits')
        elements(:trait_names, :div, css: '.js-popup-traits .trait-name')
        elements(:trait_values, :text_area, css: '.js-popup-traits .js-trait-value')
        button(:save, css: '.js-popup-traits-wrapper .ck-button.js-check[title="Сохранить"]')
        button(:cancel, css: '.js-popup-traits-wrapper .ck-button.js-times[title="Отменить"]')

        def wait_for_visible
          popup_element.when_visible
        end

        def set_trait_value(name, value)
          browser
            .action
            .click(trait_values_elements[trait_index(name)].element)
            .perform

          sleep 1
          Page.elements(:available_trait_values, :link, css: '.js-ul-traits li.js-item-trait[data-value] > span')
          available_trait_values_elements.find { |trait_value| trait_value.text == value }.click
        end

        private

        def trait_index(name)
          trait_names_elements.index { |element| element.text == name }
        end
      end
    end
  end
end
