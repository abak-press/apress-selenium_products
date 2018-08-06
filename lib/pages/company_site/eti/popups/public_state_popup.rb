module CompanySite
  module ETI
    class Table
      class PublicStatePopup < self
        div(:popup, css: '.js-dialog-status')
        elements(:public_states, :button, css: '.js-dialog-status .js-state')

        def wait_for_visible
          popup_element.when_visible
        end

        def public_state=(value)
          public_states_elements.find { |state| state.attribute('data-state') == value.to_s }.click
        end
      end
    end
  end
end
