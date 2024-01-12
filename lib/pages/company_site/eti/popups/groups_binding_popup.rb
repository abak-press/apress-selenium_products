# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class GroupsBindingPopup < self
        div(:popup, css: '.groups-popup__title')
        elements(:groups_tree, css: '.groups-popup__tree li')
        button(:save, css: '.groups-popup__save-button')

        def wait_for_visible
          popup_element.when_visible
        end

        # TODO: Надо бы пофиксить, чтобы с другими спеками было идентично
        # С методом find не проходит. Кажется не видит элементы из списка
        def select_group(name)
          # groups_tree_elements.find { |group| group.text.strip == name }.click
          Page.button(:product_group, xpath: "//*[@id='popup-content']//*[contains(text(), '#{name}')]")
          product_group
          save
        end
      end
    end
  end
end
