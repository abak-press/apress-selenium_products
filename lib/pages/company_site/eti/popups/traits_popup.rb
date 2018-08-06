module CompanySite
  module ETI
    class Table
      class TraitsPopup < self
        div(:popup, css: '.js-popup-traits')
        elements(:trait_names, :div, css: '.js-popup-traits .trait-name')
        elements(:trait_values, :text_area, css: '.js-popup-traits .js-trait-value')
        button(:save, css: '.js-popup-traits [title="Сохранить"]')
        button(:cancel, css: '.js-popup-traits [title="Отменить"]')

        def wait_for_visible
          popup_element.when_visible
        end

        def set_trait_value(name, value)
          trait_values_elements[trait_index(name)].click
          Page.elements(:available_trait_values, :link, css: '.js-product-traits[style*="display: block"] li > *')
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
