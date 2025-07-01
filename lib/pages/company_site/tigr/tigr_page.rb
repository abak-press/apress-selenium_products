# frozen_string_literal: true

module CompanySite
  class TigrPage < Page
    button(:add_new_group, css: '.button-add')
    div(:group_description, xpath: '//*[@class="e-table-cell-placeholder"][contains(text(),"Заполнить описание")]')
    span(:last_created_group, css: '.e-table-cell-text')
    div(:checkbox, xpath: "//*[@class='e-table-body']//*[@class='e-checkbox']")
    button(:yes_button, xpath: "//*[@class='rc-dialog-full-width']//*[contains(text(), 'Да')]")
    span(:img_activation, css: '.e-table-img-empty')
    text_field(:file, xpath: '//*[@class="rc-dialog-body"]//input[@type="file"]')
    image(:group_image, css: '.preview > img')
    button(:save_image, xpath: "//*[contains(text(), 'Сохранить и продолжить')]")
    div(:save_status, css: '.status-text')
    button(:manage_group, css: '.e-header-nav-groups-manage__title')
    link(:delete_selected_groups, link_text: 'Удалить выбранные группы')

    def set_group_name(text, previous_value)
      Page.div(:group_name, xpath: "//*[@class='e-table-cell-placeholder'][contains(text(),'#{previous_value}')]")

      browser
        .action
        .move_to(group_name_element.element)
        .double_click
        .send_keys(text)
        .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
        .perform
    end

    def rename_group(text, previous_value)
      Page.div(:old_group_name,
               xpath: "//*[@class='row-wrapper']/div[contains(@class,'is-name')]/div/div[contains(text(),
                '#{previous_value}')]")

      browser
        .action
        .move_to(old_group_name_element.element)
        .double_click
        .perform

      clear_field

      browser
        .action
        .send_keys(text)
        .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
        .perform

      wait_until(30) { save_status == 'Все изменения сохранены' }
    end

    def set_group_description(text)
      browser
        .action
        .move_to(group_description_element.element)
        .double_click
        .send_keys(text)
        .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
        .perform
    end

    def load_group_image(path)
      browser
        .action
        .move_to(img_activation_element.element)
        .double_click
        .perform

      upload_file(file_element, path)
      wait_until { group_image_loaded? }
      save_image_element.click
      wait_until(30) { save_status == 'Все изменения сохранены' }
    end

    def delete_group
      manage_group
      delete_selected_groups
    end
  end
end
