# frozen_string_literal: true

module CompanySite
  module ETI
    class Table
      class ImagesUploadPopup < self
        div(:popup, css: '.js-popup-photo')

        button(:close, css: '.ui-dialog:not([style*="display: none"]) .ui-dialog-titlebar-close')
        file_field(:upload_image_input, css: '.js-popup-photo [type="file"]')
        text_area(:image_url, css: '.js-popup-photo .js-download-input')
        button(:image_url_submit, css: '.js-popup-photo .js-download-button')
        elements(:uploaded_images, css: '.js-popup-photo .js-img')
        elements(:delete_images, css: '.js-popup-photo .js-delete-photo')

        def wait_for_visible
          popup_element.when_visible
        end

        def upload_from_file(file_path)
          self.upload_image_input = file_path

          wait_until_loaded
        end

        def upload_from_url(url)
          self.image_url = url
          image_url_submit

          wait_until_loaded
        end

        def images
          result = []
          uploaded_images_elements.each do |image|
            result.push(url: image.attribute('src'))
          end

          result
        end

        private

        def wait_until_loaded
          Page.div(:loading, css: '.js-item.loading')
          wait_until? { loading? }
          wait_until? { loading_not_exists? }
        end
      end
    end
  end
end
