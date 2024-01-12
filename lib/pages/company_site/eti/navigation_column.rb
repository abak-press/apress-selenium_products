# frozen_string_literal: true

module CompanySite
  module ETI
    class NavigationColumn < Page
      include CompanySite::ETI

      button(:rubricator_groups, css: '[for=rubricator_type_groups]')
      button(:rubricator_rubrics, css: '[for=rubricator_type_rubrics]')

      def navigate_to_groups
        rubricator_groups
        wait_render_table
      end

      def navigate_to_rubrics
        rubricator_rubrics
        wait_render_table
      end
    end
  end
end
