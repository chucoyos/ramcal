require "application_system_test_case"

class PayablesTest < ApplicationSystemTestCase
  setup do
    @payable = payables(:one)
  end

  test "visiting the index" do
    visit payables_url
    assert_selector "h1", text: "Payables"
  end

  test "should create payable" do
    visit payables_url
    click_on "New payable"

    fill_in "Payment concept", with: @payable.payment_concept
    fill_in "Payment date", with: @payable.payment_date
    fill_in "Payment means", with: @payable.payment_means
    fill_in "Payment type", with: @payable.payment_type
    fill_in "Supplier", with: @payable.supplier_id
    fill_in "User", with: @payable.user_id
    click_on "Create Payable"

    assert_text "Payable was successfully created"
    click_on "Back"
  end

  test "should update Payable" do
    visit payable_url(@payable)
    click_on "Edit this payable", match: :first

    fill_in "Payment concept", with: @payable.payment_concept
    fill_in "Payment date", with: @payable.payment_date
    fill_in "Payment means", with: @payable.payment_means
    fill_in "Payment type", with: @payable.payment_type
    fill_in "Supplier", with: @payable.supplier_id
    fill_in "User", with: @payable.user_id
    click_on "Update Payable"

    assert_text "Payable was successfully updated"
    click_on "Back"
  end

  test "should destroy Payable" do
    visit payable_url(@payable)
    click_on "Destroy this payable", match: :first

    assert_text "Payable was successfully destroyed"
  end
end
