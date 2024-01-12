# frozen_string_literal: true

module CompanySite
  module MiniETI
    def wait_until_table_update
      products_page = CompanySite::ETI::Table::Products.new
      previous_table_state = products_page.products_elements
      yield
      wait_until { previous_table_state != products_page.products_elements }
    end
  end
end
