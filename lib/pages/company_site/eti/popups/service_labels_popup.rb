# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class ServiceLabelsPopup < self
        div(:popup, css: '.eti-service-label-popup')
        elements(:service_labels, css: '.eti-service-label-popup-options-item')

        button(:save, css: '.eti-service-label-popup-buttons-save')
        button(:close, css: '.eti-service-label-popup-close')

        def wait_for_visible
          popup_element.when_visible
        end

        def select_service_labels(service_label)
          service_labels_elements.each do |element|
            checkbox = element.checkbox_element(css: 'input[type="checkbox"]')
            checkbox_value = checkbox.attribute('value')

            if checkbox_value == service_label
              checkbox.click unless checkbox.checked?
              break
            elsif checkbox.checked?
              checkbox.click
            end
          end
          save
        end
      end
    end
  end
end
