module CompanySite
  module ETI
    class Table
      class StatusBar < self
        div(:status, css: '.js-status-bar-content')

        ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/table_status_bar', self)
      end
    end
  end
end
