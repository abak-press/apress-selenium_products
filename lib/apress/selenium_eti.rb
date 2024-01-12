# frozen_string_literal: true

# Упорядоченный рекваир. Небходимо сначала подключать неймспейсы, иначе будут ошибки при инициализации.
gem_directory = Gem::Specification.find_by_name("apress-selenium_eti").gem_dir

# ЕТИ
require "#{gem_directory}/lib/pages/company_site/eti/eti"
require "#{gem_directory}/lib/pages/company_site/eti/table"
require "#{gem_directory}/lib/pages/company_site/eti/action_panel"
require "#{gem_directory}/lib/pages/company_site/eti/header"
require "#{gem_directory}/lib/pages/company_site/eti/table_products"
require "#{gem_directory}/lib/pages/company_site/eti/table_status_bar"
require "#{gem_directory}/lib/pages/company_site/eti/navigation_column"

# Попапы
require "#{gem_directory}/lib/pages/company_site/eti/popups/description_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/groups_binding_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/images_upload_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/price_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/public_state_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/rubrics_binding_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/traits_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/wholesale_price_popup"
require "#{gem_directory}/lib/pages/company_site/eti/popups/exists_popup"

# Мини-ЕТИ.
require "#{gem_directory}/lib/pages/company_site/mini_eti/mini_eti"
require "#{gem_directory}/lib/pages/company_site/mini_eti/pagination"
