# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class RubricsBindingPopup < self
        button(:close, css: '.ui-dialog-titlebar-close')

        text_area(:search, css: '.js-input-rubric-search')
        button(:search_submit, css: '.js-button-rubric-search')
        elements(:found_rubrics_names, css: '.js-rubric-found .js-src-link')

        def find(value)
          self.search = value
          search_submit
        end

        def select_result(name)
          found_rubrics_names_elements.find { |rubric_name| rubric_name.text == name }.click
        end
      end
    end
  end
end
