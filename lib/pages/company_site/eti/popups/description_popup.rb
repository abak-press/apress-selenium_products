module CompanySite
  module ETI
    class Table
      class DescriptionPopup < self
        div(:popup, css: '.js-edit-description')

        text_area(:text, css: '.js-edit-description .cke_textarea_inline')
        button(:save, css: '.js-edit-description [title="Сохранить (Ctrl + Enter)"]')
        button(:cancel, css: '.js-edit-description [title="Отменить (Esc)"]')

        def wait_for_visible
          popup_element.when_visible
        end
      end
    end
  end
end
