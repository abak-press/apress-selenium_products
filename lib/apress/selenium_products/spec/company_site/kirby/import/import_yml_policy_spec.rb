# frozen_string_literal: true

require 'spec_helper'

describe 'Кирби: политики доступа страницы импорта YML', feature: 'Кирби: политики доступа страницы импорта YML' do
  before(:all) do
    @import_yml_page = CompanySite::ImportYMLPage.new
    @upload_tab      = CompanySite::ImportYMLPage::UploadTab.new
    @settings_tab    = CompanySite::ImportYMLPage::SettingsTab.new
  end

  shared_examples 'общие элементы страницы' do
    it 'присутствует title в формате "Загрузка товаров из YML/YRL - %название компании% - %основной регион%"' do
      expect(@import_yml_page.has_expected_title?).to be true
    end

    it 'присутствует заголовок страницы "Загрузить товары в формате Яндекс.Маркет (YML/YRL)"' do
      expect(@import_yml_page.header).to eq 'Загрузить товары в формате Яндекс.Маркет (YML/YRL)'
    end

    it 'присутствуют вкладки "Загрузить товары" и "Расширенные настройки"' do
      expect(@import_yml_page.upload_tab?).to be true
      expect(@import_yml_page.settings_tab?).to be true
    end
  end

  shared_examples 'все элементы страницы для роли с повышенными правами' do |role|
    context 'когда на вкладке "Загрузить товары"' do
      before(:all) { @import_yml_page.upload_tab }

      it('присутствует текстовая зона') { expect(@upload_tab.text_zone?).to be true }

      it 'присутствует активный блок "Формат" со значениями YML, YRL и EDIFACT' do
        expect(@upload_tab.source_type_label?).to be true
        expect(@upload_tab.source_type_options).to eq %w[YML YRL EDIFACT]
      end

      it('доступен режим "Товаров нет"') { expect(@upload_tab.moving_no?).to be true }

      context 'когда выбран режим "Товары есть"' do
        before(:all) { @upload_tab.moving_yes }

        it('доступен режим "Оставить опубликованными"') { expect(@upload_tab.moving_keep?(2)).to be true }
        it('доступен режим "Удалить"') { expect(@upload_tab.moving_delete?(2)).to be true }
        it('доступен режим "Перенести в архив"') { expect(@upload_tab.moving_archive?(2)).to be true }

        it('присутствует кнопка "Загрузить"') { expect(@upload_tab.upload_price?).to be true }
      end

      # TODO: Раскипать после того, как обновят образ ножа для ПЦ,
      # тест пропускается так как файла по пути /test_files/pulscen пока нет.
      xcontext 'когда источник - Файл' do
        before(:all) do
          @upload_tab.switch_to_source_file
          @upload_tab.upload_yml(YAML_FILE_PATH)
          @import_yml_page.settings_tab
          @settings_tab.save_settings
          @import_yml_page.upload_tab
        end

        it('присутствует поле с названием выбранного файла') { expect(@upload_tab.source_file?).to be true }
        it('присутствует псевдо-ссылка выбора файла') { expect(@upload_tab.file_upload_element.exists?).to be true }
        it('присутствует ссылка на скачивание прайса') { expect(@upload_tab.download_last_price?).to be true }
      end

      context 'когда источник - Ссылка' do
        before(:all) { @upload_tab.switch_to_source_url }

        it('присутствует поле ввода источника прайса') { expect(@upload_tab.source_url?).to be true }
      end
    end

    context 'когда на вкладке "Расширенные настройки"' do
      before(:all) { @import_yml_page.settings_tab }

      it('присутствует заголовок "Выборочное обновление полей"') { expect(@settings_tab.selected_fields?).to be true }

      it 'присутствует заголовок "Выборочное обновление товаров"' do
        expect(@settings_tab.selected_products?).to be true
      end
      it('присутствует заголовок "Отчет"') { expect(@settings_tab.notification_label?).to be true }

      it('присутствует заголовок "Загрузка характеристик для фильтров по товарам на вашем сайте"') do
        expect(@settings_tab.company_traits_label?).to be true
      end

      it 'присутствует активный чекбокс "Загружать характеристики"' do
        expect(@settings_tab.company_traits).to eq 'Загружать характеристики'
        expect(@settings_tab.company_traits_element.checkbox_element.enabled?).to be true
      end

      it 'все чекбоксы выбора статусов обновляемых товаров активные' do
        expect(@settings_tab.update_archived).to eq 'Обновлять товары в статусе «Архивный»'
        expect(@settings_tab.update_archived_element.checkbox_element.enabled?).to be true
        expect(@settings_tab.update_unpublished).to eq 'Обновлять товары в статусе «Опубликованный на сайте»'
        expect(@settings_tab.update_unpublished_element.checkbox_element.enabled?).to be true
      end

      it 'все чекбоксы в блоке "Выборочное обновление полей" активные' do
        CompanySite::ImportYMLPage::SettingsTab::TAGS.each do |field|
          expect(@settings_tab.send("#{field}_element").enabled?).to be true
        end
      end

      it 'все чекбоксы в блоке "Настройка названия товара" активные' do
        CompanySite::ImportYMLPage::SettingsTab::NAME_TAGS.each do |field|
          expect(@settings_tab.send("tag_#{field}_element").enabled?).to be true
        end
      end

      it 'чекбокс "Получать отчёт о загрузке товаров и услуг" в блоке "Отчет" активный' do
        expect(@settings_tab.notification).to eq 'Получать отчёт о загрузке товаров и услуг'
        expect(@settings_tab.notification_element.checkbox_element.enabled?).to be true
      end

      context 'когда источник - Ссылка' do
        before(:all) do
          @import_yml_page.upload_tab
          @upload_tab.switch_to_source_url
          @import_yml_page.settings_tab
        end

        it 'отобразится активный чекбокс "Включить автоматическое обновление" в блоке "Автообновление"' do
          expect(@settings_tab.autoupdate_label).to eq 'Автообновление'
          expect(@settings_tab.autoupdate_element.checkbox_element.enabled?).to be true
        end

        context 'когда отмечен чекбокс "Включить автоматическое обновление"' do
          before(:all) { @settings_tab.autoupdate_element.checkbox_element.check }

          it 'отобразится блок с полями "Интервал обновления" и "Точное время обновления (MSK)"' do
            expect(@settings_tab.autoupdate_period_label?).to be true
            expect(@settings_tab.autoupdate_period?).to be true
            expect(@settings_tab.autoupdate_start_date_label?).to be true
            expect(@settings_tab.autoupdate_start_date).to be_truthy
          end
        end
      end
    end
  end

  shared_context 'роль с повышенными правами' do |role, name|
    context "когда роль - #{name}" do
      before(:all) do
        log_in_as(role)
        navigate_to(@import_yml_page.page_url_value, subdomain: CONFIG['kirby']['import']['paid_company']['subdomain'])
      end
      after(:all) { log_out }

      include_examples 'общие элементы страницы'
      include_examples 'все элементы страницы для роли с повышенными правами', role
    end
  end

  context 'когда роль - Владелец' do
    before(:all) { log_in_as(:user) }
    after(:all) { log_out }

    context 'когда своя компания с бесплатным пакетом' do
      before(:all) do
        navigate_to(@import_yml_page.page_url_value,
                    subdomain: CONFIG['kirby']['import']['unpaid_company']['subdomain'])
      end

      include_examples 'общие элементы страницы'

      context 'когда на вкладке "Загрузка товаров"' do
        before(:all) { @import_yml_page.upload_tab }

        it('присутствует текстовая зона') { expect(@upload_tab.text_zone?).to be true }
        it 'присутствует активный блок "Формат" со значениями YML, YRL и EDIFACT' do
          expect(@upload_tab.source_type_label?).to be true
          expect(@upload_tab.source_type_options).to eq %w[YML YRL EDIFACT]
        end

        it('доступен режим "Товаров нет"') { expect(@upload_tab.moving_no?).to be true }

        context 'когда выбран режим "Товары есть"' do
          before(:all) { @upload_tab.moving_yes }

          it('доступен режим "Оставить опубликованными"') { expect(@upload_tab.moving_keep?(2)).to be true }
          it('доступен режим "Удалить"') { expect(@upload_tab.moving_delete?(2)).to be true }
          it('не доступен режим "Перенести в архив"') { expect(@upload_tab.moving_archive_not_exists?(2)).to be true }
          it 'присутствует НЕактивный блок "Сайт магазина"' do
            expect(@upload_tab.store_url_label?).to be true
            expect(@upload_tab.store_url_element.disabled?).to be true
          end

          it 'отсутствуют кнопки "Сохранить" и "Загрузить группы"' do
            expect(@upload_tab.upload_groups_not_exists?).to be true
            expect(@upload_tab.save_not_exists?).to be true
          end

          it('присутствует кнопка "Загрузить"') { expect(@upload_tab.upload_price?).to be true }
        end

        # TODO: Аналогично, раскипать после того, как обновят образ ножа для ПЦ
        xcontext 'когда источник - Файл' do
          before(:all) do
            @upload_tab.switch_to_source_file
            @upload_tab.upload_yml(YAML_FILE_PATH)
            @import_yml_page.settings_tab
            @settings_tab.save_settings
            @import_yml_page.upload_tab
          end

          it('присутствует поле с названием выбранного файла') { expect(@upload_tab.source_file?).to be true }
          it('присутствует псевдо-ссылка выбора файла') { expect(@upload_tab.file_upload_element.exists?).to be true }
          it('присутствует ссылка на скачивание прайса') { expect(@upload_tab.download_last_price?).to be true }
        end

        context 'когда источник - Ссылка' do
          before(:all) { @upload_tab.switch_to_source_url }

          it('присутствует поле ввода источника прайса') { expect(@upload_tab.source_url?).to be true }
        end
      end

      context 'когда на вкладке "Расширенные настройки"' do
        before(:all) { @import_yml_page.settings_tab }

        it('присутствует заголовок "Выборочное обновление полей"') { expect(@settings_tab.selected_fields?).to be true }

        it 'присутствует заголовок "Выборочное обновление товаров"' do
          expect(@settings_tab.selected_products?).to be true
        end

        it('присутствует заголовок "Отчет"') { expect(@settings_tab.notification_label?).to be true }

        it('присутствует заголовок "Загрузка характеристик для фильтров по товарам на вашем сайте"') do
          expect(@settings_tab.company_traits_label?).to be true
        end

        it 'присутствует активный чекбокс "Загружать характеристики"' do
          expect(@settings_tab.company_traits).to eq 'Загружать характеристики'
          expect(@settings_tab.company_traits_element.checkbox_element.enabled?).to be true
        end

        it 'все чекбоксы выбора статусов обновляемых товаров активные' do
          expect(@settings_tab.update_archived).to eq 'Обновлять товары в статусе «Архивный»'
          expect(@settings_tab.update_archived_element.checkbox_element.enabled?).to be true
          expect(@settings_tab.update_unpublished).to eq 'Обновлять товары в статусе «Опубликованный на сайте»'
          expect(@settings_tab.update_unpublished_element.checkbox_element.enabled?).to be true
        end

        context 'когда источник - Ссылка' do
          before do
            @import_yml_page.upload_tab
            @upload_tab.switch_to_source_url
            @import_yml_page.settings_tab
          end

          it 'не отобразится блок "Автообновление"' do
            expect(@settings_tab.autoupdate_label_not_exists?).to be true
            expect(@settings_tab.autoupdate_not_exists?).to be true
          end
        end

        it 'все чекбоксы в блоке "Выборочное обновление полей" НЕактивные' do
          CompanySite::ImportYMLPage::SettingsTab::TAGS.each do |field|
            expect(@settings_tab.send("#{field}_element").disabled?).to be true
          end
        end

        it 'все чекбоксы в блоке "Настройка названия товара" НЕактивные' do
          CompanySite::ImportYMLPage::SettingsTab::NAME_TAGS.each do |field|
            expect(@settings_tab.send("tag_#{field}_element").disabled?).to be true
          end
        end

        it 'чекбокс "Получать отчёт о загрузке товаров и услуг" в блоке "Отчет" НЕактивный' do
          expect(@settings_tab.notification).to eq 'Получать отчёт о загрузке товаров и услуг'
          expect(@settings_tab.notification_element.checkbox_element.disabled?).to be true
        end
      end
    end

    context 'когда своя компания с платным пакетом' do
      before(:all) do
        navigate_to(@import_yml_page.page_url_value, subdomain: CONFIG['kirby']['import']['paid_company']['subdomain'])
      end

      include_examples 'общие элементы страницы'

      context 'когда на вкладке "Загрузить товары"' do
        before(:all) { @import_yml_page.upload_tab }

        it('присутствует текстовая зона') { expect(@upload_tab.text_zone?).to be true }
        it 'присутствует активный блок "Формат" со значениями YML, YRL и EDIFACT' do
          expect(@upload_tab.source_type_label?).to be true
          expect(@upload_tab.source_type_options).to eq %w[YML YRL EDIFACT]
        end

        it('доступен режим "Товаров нет"') { expect(@upload_tab.moving_no?).to be true }

        context 'когда выбран режим "Товары есть"' do
          before(:all) { @upload_tab.moving_yes }

          it('доступен режим "Оставить опубликованными"') { expect(@upload_tab.moving_keep?(2)).to be true }
          it('доступен режим "Удалить"') { expect(@upload_tab.moving_delete?(2)).to be true }
          it('не доступен режим "Перенести в архив"') { expect(@upload_tab.moving_archive_not_exists?(2)).to be true }
          it 'присутствует активный блок "Сайт магазина"' do
            expect(@upload_tab.store_url_label?).to be true
            expect(@upload_tab.store_url_element.enabled?).to be true
          end

          it('присутствует кнопка "Загрузить"') { expect(@upload_tab.upload_price?).to be true }
        end

        # TODO: Аналогично, раскипать после того, как обновят образ ножа для ПЦ
        xcontext 'когда источник - Файл' do
          before(:all) do
            @upload_tab.switch_to_source_file
            @upload_tab.upload_yml(YAML_FILE_PATH)
            @import_yml_page.settings_tab
            @settings_tab.save_settings
            @import_yml_page.upload_tab
          end

          it('присутствует поле с названием выбранного файла') { expect(@upload_tab.source_file?).to be true }
          it('присутствует псевдо-ссылка выбора файла') { expect(@upload_tab.file_upload_element.exists?).to be true }
          it('присутствует ссылка на скачивание прайса') { expect(@upload_tab.download_last_price?).to be true }
        end

        context 'когда источник - Ссылка' do
          before(:all) { @upload_tab.switch_to_source_url }

          it('присутствует поле ввода источника прайса') { expect(@upload_tab.source_url?).to be true }
        end
      end

      context 'когда на вкладке "Расширенные настройки"' do
        before(:all) { @import_yml_page.settings_tab }

        it('присутствует заголовок "Выборочное обновление полей"') { expect(@settings_tab.selected_fields?).to be true }

        it 'присутствует заголовок "Выборочное обновление товаров"' do
          expect(@settings_tab.selected_products?).to be true
        end
        it('присутствует заголовок "Отчет"') { expect(@settings_tab.notification_label?).to be true }

        it('присутствует заголовок "Загрузка характеристик для фильтров по товарам на вашем сайте"') do
          expect(@settings_tab.company_traits_label?).to be true
        end

        it 'присутствует активный чекбокс "Загружать характеристики"' do
          expect(@settings_tab.company_traits).to eq 'Загружать характеристики'
          expect(@settings_tab.company_traits_element.checkbox_element.enabled?).to be true
        end

        it 'все чекбоксы выбора статусов обновляемых товаров активные' do
          expect(@settings_tab.update_archived).to eq 'Обновлять товары в статусе «Архивный»'
          expect(@settings_tab.update_archived_element.checkbox_element.enabled?).to be true
          expect(@settings_tab.update_unpublished).to eq 'Обновлять товары в статусе «Опубликованный на сайте»'
          expect(@settings_tab.update_unpublished_element.checkbox_element.enabled?).to be true
        end

        context 'когда источник - Ссылка' do
          before do
            @import_yml_page.upload_tab
            @upload_tab.switch_to_source_url
            @import_yml_page.settings_tab
          end

          it 'не отобразится блок "Автообновление"' do
            expect(@settings_tab.autoupdate_label_not_exists?).to be true
            expect(@settings_tab.autoupdate_not_exists?).to be true
          end
        end

        it 'все чекбоксы в блоке "Выборочное обновление полей" активные' do
          CompanySite::ImportYMLPage::SettingsTab::TAGS.each do |field|
            expect(@settings_tab.send("#{field}_element").enabled?).to be true
          end
        end

        it 'все чекбоксы в блоке "Настройка названия товара" активные' do
          CompanySite::ImportYMLPage::SettingsTab::NAME_TAGS.each do |field|
            expect(@settings_tab.send("tag_#{field}_element").enabled?).to be true
          end
        end

        it 'чекбокс "Получать отчёт о загрузке товаров и услуг" в блоке "Отчет" активный' do
          expect(@settings_tab.notification).to eq 'Получать отчёт о загрузке товаров и услуг'
          expect(@settings_tab.notification_element.checkbox_element.enabled?).to be true
        end
      end
    end
  end
  
  # TODO: Раскипать после обновления дампа на ПЦ.
  xcontext 'когда авторизованный пользователь' do
    before do
      log_in_as(:empty_user)
      navigate_to(@import_yml_page.page_url_value, subdomain: CONFIG['kirby']['import']['paid_company']['subdomain'])
    end
    after { log_out }

    it('нет доступа к просмотру и редактированию - 403 код') do
      expect(error_403?).to be true
      expect(@import_yml_page.text).to include 'У Вас недостаточно прав для просмотра данной страницы.'
    end
  end

  # TODO: Аналогично, раскипать после обновления дампа на ПЦ.
  xcontext 'когда неавторизованный пользователь' do
    before do
      navigate_to(@import_yml_page.page_url_value, subdomain: CONFIG['kirby']['import']['paid_company']['subdomain'])
    end

    it('произойдет редирект на страницу авторизации') { expect(Page.current_url).to include '/users/session/new' }
  end

  include_context 'роль с повышенными правами', :admin, 'Супер-юзер'
  include_context 'роль с повышенными правами', :editor, 'Редактор СК'
  include_context 'роль с повышенными правами', :franchise_ru, 'Франшиза (регион компании)'

  context 'когда роль - Франшиза (из другого региона)' do
    before(:all) do
      log_in_as(:franchise_kz)
      navigate_to(@import_yml_page.page_url_value, subdomain: CONFIG['kirby']['import']['paid_company']['subdomain'])
    end
    after(:all) { log_out }

    context 'когда на вкладке "Загрузить товары"' do
      before(:all) { @import_yml_page.upload_tab }

      it 'не отобразятся кнопки сохранения и загрузки' do
        expect(@upload_tab.save_not_exists?).to be true
        expect(@upload_tab.upload_price_not_exists?).to be true
        expect(@upload_tab.upload_groups_not_exists?).to be true
      end
    end
  end
end
