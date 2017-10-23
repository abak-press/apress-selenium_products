module CompanySite
  class MiniEtiPage < Page
    def delete_first_product
      Page.button(:delete_product_button, css: '.js-delete-product')
      confirm(true) { delete_product_button }
      CompanySite::EtiPage.new.wait_saving
    end

    ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/mini_eti_page', self)
  end
end
