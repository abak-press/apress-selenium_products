# frozen_string_literal: true

module CompanySite
  class ImportYMLPage < Page
    page_url '/admin/import_yml/edit'
    expected_title %r{Загрузка товаров из YML/YRL - .+-.+}

    h1(:header, css: '.company-admin-page-header h1')
    link(:upload_tab, css: 'a[href="#upload"]')
    link(:settings_tab, css: 'a[href="#settings"]')
    link(:warnings_tab, css: 'a[href="#errors"]')

    class UploadTab < ImportYMLPage
      MOVING = %i[none keep delete archive].freeze

      div(:text_zone, css: '.yml-import-textzone')
      label(:source_label, css: '.yml-import-label-required')

      # Элементы источника - Ссылка
      link(:switch_to_source_url, css: 'a[href="#switcher-tabs-1"]')
      text_field(:source_url, css: '.js-url-field')
      div(:source_url_validation_message, css: '#switcher-tabs-1 .js-validation-message')

      # Элементы источника - Файл
      link(:switch_to_source_file, css: 'a[href="#switcher-tabs-2"]')
      text_field(:source_file, css: '.yml-file-name')
      span(:file_upload, xpath: '//*[@type="file"]')
      link(:download_last_price, css: '.custom-yml-link')

      # Тип источника (формат)
      div(:source_type_label, xpath: '//label[contains(text(), "Формат:")]')
      select_list(:source_type, css: '#online_store_source_type')
      link(:warnings_link, css: '.js-open-errors-tab')

      # Сайт магазина
      label(:store_url_label, xpath: '//label[contains(text(), "Сайт магазина:")]')
      text_field(:store_url, css: '#online_store_store_url')

      # Тип магазина
      label(:store_type_label, xpath: '//label[contains(text(), "Тип магазина:")]')
      select_list(:store_type, css: '#online_store_store_type')

      # Выбор режима загрузки
      div(:care_about_products, css: '.form-item-input-box .notice')
      link(:moving_no, css: 'a[href="#switcher-tabs-3"]')
      link(:moving_yes, css: 'a[href="#switcher-tabs-4"]')

      MOVING.each do |type|
        select("moving_#{type}", xpath: "//select[@id='moving']//option[@value='#{type}']")
      end

      # Блок кнопок (Сохранение, загрузка прайса и товаров)
      button(:save, css: '.js-yml-import-button.js-yml-save')
      button(:upload_price, css: '.js-yml-import-button.js-yml-upload')
      button(:upload_groups, css: '.js-yml-import-button.js-yml-groups-upload')

      def upload_yml(file_path)
        upload_file(file_upload_element, file_path)
      end
    end

    class SettingsTab < ImportYMLPage
      TAGS      = %w[name image_urls announce description price wholesale_price exists product_group].freeze
      NAME_TAGS = %w[name typePrefix vendor model].freeze

      label(:selected_fields, xpath: '//label[text()="Выборочное обновление полей"]')
      label(:selected_products, xpath: '//label[text()="Выборочное обновление товаров"]')

      div(:update_archived, xpath: '//div[child::*[@id="online_store_update_archived"]]')
      div(:update_unpublished, xpath: '//div[child::*[@id="online_store_update_unpublished"]]')

      # Автообновление
      label(:autoupdate_label, xpath: '//label[text()="Автообновление"]')
      div(:autoupdate, xpath: '//div[child::*[@id="online_store_updating_settings_attributes_enabled"]]')
      label(:autoupdate_period_label, xpath: '//label[text()="Интервал обновления"]')
      text_field(:autoupdate_period, css: '#online_store_updating_settings_attributes_period')
      label(:autoupdate_start_date_label, xpath: '//label[text()="Точное время обновления (MSK)"]')
      text_field(:autoupdate_start_date, css: '#online_store_updating_settings_attributes_start_date')

      # Отчет
      label(:notification_label, xpath: '//label[text()="Отчет"]')
      div(:notification, xpath: '//div[child::*[@id="online_store_send_notifications"]]')

      # Пользовательские характеристики
      label(:company_traits_label,
            xpath: '//label[contains(text(), "Загрузка характеристик") and contains(@class, "tab-title")]')
      div(:company_traits, xpath: '//div[child::*[@id="online_store_update_company_traits"]]')
      label(:name_tags, xpath: '//label[text()="Настройка названия товара"]')
      button(:save, css: '.yml-import-button.js-yml-save')
      button(:save_settings, xpath: '//div[contains(@class, "js-yml-settings-buttons")]//input[@value="Сохранить"]')
      
      # Теги для обновления
      TAGS.each do |field|
        checkbox(field, css: "#online_store_selected_fields_#{field}")
      end

      # Теги, попадающие в название
      NAME_TAGS.each do |field|
        checkbox("tag_#{field}", css: "#online_store_product_name_tags_#{field}")
      end
    end
  end
end
