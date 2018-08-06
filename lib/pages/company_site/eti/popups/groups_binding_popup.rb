module CompanySite
  module ETI
    class Table
      class GroupsBindingPopup < self
        div(:popup, css: '.js-product-groups-form')

        elements(:groups, css: '.js-product-groups-form .js-product-groups-tree a')
        button(:save, css: '.js-product-groups-form [value="Выбрать"]')
        button(:cancel, xpath: '//*[contains(@class, "js-product-groups-form")]//*[text()="отменить"]')

        def wait_for_visible
          popup_element.when_visible
        end

        def select_group(name)
          groups_elements.find { |group| group.text.strip == name }.click
        end
      end
    end
  end
end
