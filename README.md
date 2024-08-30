Межпроектные автотесты с товарами: ЕТИ, мини-ЕТИ
=====================

Представляет собой гем apress-selenium_products, который подключается в проекты Pulscen и Blizko.
Код тестов пишется в этом геме, а на проектах эти тесты запускаются.

! Автотесты из этого гема запускаются в проектах !

## Настройка гема и проектов
- Установить ruby 2.4.10, bunlder 1.17.3. Для linux желательно использовать менеджер версий rvm.
- Форкнуть репозиторий apress-selenium_products на github.
- Форкнуть репозиторий проекта Pulscen на github (если еще не сделано) https://github.com/abak-press/pulscen
- Форкнуть репозиторий проекта Blizko на github (если еще не сделано) https://github.com/abak-press/blizko
- Склонировать на локальную машину форкнутые репозитории:
```
git clone git@github.com:{login_на_github}/apress-selenium_products.git
git clone git@github.com:{login_на_github}/pulscen.git
git clone git@github.com:{login_на_github}/blizko.git
```

- добавить ссылку на upstream репозиторий:
```
git remote add upstream git@github.com:abak-press/apress-selenium_products
git remote add upstream git@github.com:abak-press/pulscen
git remote add upstream git@github.com:abak-press/blizko
```
- проверить, что ссылки на origin и upstream репозитории верные:
```
git remote -v
```

- Переименовать файл `run_example.yml` в `run.yml`. Выставить в нем опции запуска тестов.

## Запуск тестов
1. Подтянуть свежую версию гема apress-selenium_products.
```
git checkout master
git pull upstream master
```

2. Создать локально ветку в геме.
```
git checkout –b <имя ветки>
```

3. Подтянуть свежую версию проекта.
```
git checkout master
git pull upstream master
```

4. Создать локально ветку в проекте.
```
git checkout –b <имя_ветки>
```

5. В файле Gemfile проекта указать локальный путь до гема.
```
gem 'apress-selenium_products', path: '/home/galiulin/autotests/apress-selenium_products'
```
где /home/galiulin/autotests - локальный путь

6. Установить зависимые гемы в проекте.
```
bundle install
```
7. Находясь в директории проекта запустить спек, код тестов которого написаны в геме (в проекте найти одноименный спек).
```
bundle exec rspec spec/company_site/eti/product_statuses_spec.rb
```
или
```
rspec spec/company_site/eti/product_statuses_spec.rb
```
где spec/company_site/eti/product_statuses_spec.rb - путь в проекте до нужного спека

8. Запуск тестов, которые находятся в одной папке.
```
bundle exec rspec --pattern spec/company_site/eti/*_spec.rb
```
где spec/company_site/eti - путь в проекте до папки с нужными спеками

## Подключение дебаггера

Для подключения дебаггера нужно в _run.yml_ прописать:
```
debug: true
```
И поставить в нужном месте кода `binding.pry` (перед строкой, из-за которой падает тест)

Вместо добавления опции в конфиг можно перед `binding.pry` прописать:
```
require 'pry'
```
Тогда можно подключить дебаггер сразу в нужном месте одной строчкой (также перед строкой, из-за которой падает тест):
```
require 'pry'; binding.pry
```