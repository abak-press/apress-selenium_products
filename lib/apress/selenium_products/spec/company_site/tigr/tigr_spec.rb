# frozen_string_literal: true

require 'spec_helper'

describe 'ТИГР' do
  before(:all) do
    @tigr_page = CompanySite::TigrPage.new

    log_in_as(:user)
    navigate_to_tigr
  end

  context 'когда добавляем группу' do
    before(:all) do
      @group_name = "#{Faker::Movies::LordOfTheRings.location}#{Faker::Number.number(digits: 2)}"
      @tigr_page.add_new_group
      @tigr_page.set_group_name(@group_name, 'Название группы')
      @tigr_page.set_group_description('description')
      @tigr_page.load_group_image(IMAGE_PATH)
    end

    it 'появляется созданная группа' do
      expect(@tigr_page.last_created_group).to include @group_name
    end

    context 'когда редактируем группу' do
      before do
        @edited_group_name = "#{@group_name}_edited"
        @tigr_page.rename_group(@edited_group_name, @group_name)
      end

      it 'меняется имя группы' do
        expect(@tigr_page.last_created_group).to include @edited_group_name
      end
    end

    context 'когда удаляем группу' do
      before do
        @edited_group_name = "#{@group_name}_edited"
        @tigr_page.checkbox_element.click
        @tigr_page.delete_group
        @tigr_page.yes_button
        @tigr_page.wait_until { @tigr_page.last_created_group.exclude?(@edited_group_name) }
      end

      it 'группа исчезает' do
        expect(@tigr_page.last_created_group.exclude?(@edited_group_name)).to be true
      end
    end
  end
end
