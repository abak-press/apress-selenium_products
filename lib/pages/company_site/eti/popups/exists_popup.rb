# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class ExistsPopup < self
        EXISTS = {
          available: 'В наличии',
          not_available: 'Нет в наличии',
          order: 'Под заказ',
          awaiting: 'Ожидается поступление',
          none: 'Не указано',
        }.freeze

        button(:save, css: '.popup-exists__save-button')
        elements(:exists_values, css: '.js-popup-exists-body .popup-exists__item')

        def select_exists(value)
          exists_values_elements.find { |element| element.text == EXISTS[value] }.click
          save
        end
      end
    end
  end
end
