module CompanySite
  module ETI
    class Table < Page
      include CompanySite::ETI

      div(:load_process, css: '.js-load-process')

      button(:close_support_contacts, css: '.js-support-contacts-close')

      ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti/table', self)
    end
  end
end
