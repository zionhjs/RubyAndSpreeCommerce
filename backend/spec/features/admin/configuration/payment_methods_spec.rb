require 'spec_helper'

describe 'Payment Methods', type: :feature do
  stub_authorization!

  let!(:store_1) { create(:store) }
  let!(:store_2) { create(:store) }
  let!(:store_3) { create(:store) }

  before do
    visit spree.admin_payment_methods_path
  end

  context 'admin visiting payment methods listing page' do
    it 'displays existing payment methods' do
      create(:check_payment_method)
      refresh

      within('table#listing_payment_methods') do
        expect(all('th')[1].text).to eq('Name')
        expect(all('th')[2].text).to eq('Provider')
        expect(all('th')[3].text).to eq('Display')
        expect(all('th')[4].text).to eq('Active')
      end

      within('table#listing_payment_methods') do
        expect(page).to have_content('Check')
      end
    end
  end

  context 'admin creating a new payment method', js: true do
    it 'is able to create a new payment method' do
      within find('#contentHeader') do
        click_link 'admin_new_payment_methods_link'
      end

      expect(page).to have_content('New Payment Method')
      fill_in 'payment_method_name', with: 'check90'
      fill_in 'payment_method_description', with: 'check90 desc'
      select 'PaymentMethod::Check', from: 'gtwy-type'
      click_button 'Create'
      expect(page).to have_content('successfully created!')
    end

    it 'is able to create a new payment method with 2 stores' do
      within find('#contentHeader') do
        click_link 'admin_new_payment_methods_link'
      end

      expect(page).to have_content('New Payment Method')
      fill_in 'payment_method_name', with: 'check90'
      fill_in 'payment_method_description', with: 'check90 desc'
      select 'PaymentMethod::Check', from: 'gtwy-type'

      select2 store_1.unique_name, from: 'Stores'
      select2 store_3.unique_name, from: 'Stores'

      click_button 'Create'
      expect(page).to have_content('successfully created!')
      expect(page).to have_selector('li.select2-selection__choice', text: store_1.unique_name)
      expect(page).not_to have_selector('li.select2-selection__choice', text: store_2.unique_name)
      expect(page).to have_selector('li.select2-selection__choice', text: store_3.unique_name)
    end
  end

  context 'admin editing a payment method', js: true do
    before do
      create(:check_payment_method)
      refresh

      within('table#listing_payment_methods') do
        click_icon(:edit)
      end
    end

    it 'is able to edit an existing payment method' do
      fill_in 'payment_method_name', with: 'Payment 99'
      click_button 'Update'
      expect(page).to have_content('successfully updated!')
      expect(page).to have_field('payment_method_name', with: 'Payment 99')
    end

    it 'displays validation errors' do
      fill_in 'payment_method_name', with: ''
      click_button 'Update'
      expect(page).to have_content("Name can't be blank")
    end
  end
end
