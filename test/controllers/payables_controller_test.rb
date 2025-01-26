require "test_helper"

class PayablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payable = payables(:one)
  end

  test "should get index" do
    get payables_url
    assert_response :success
  end

  test "should get new" do
    get new_payable_url
    assert_response :success
  end

  test "should create payable" do
    assert_difference("Payable.count") do
      post payables_url, params: { payable: { payment_concept: @payable.payment_concept, payment_date: @payable.payment_date, payment_means: @payable.payment_means, payment_type: @payable.payment_type, supplier_id: @payable.supplier_id, user_id: @payable.user_id } }
    end

    assert_redirected_to payable_url(Payable.last)
  end

  test "should show payable" do
    get payable_url(@payable)
    assert_response :success
  end

  test "should get edit" do
    get edit_payable_url(@payable)
    assert_response :success
  end

  test "should update payable" do
    patch payable_url(@payable), params: { payable: { payment_concept: @payable.payment_concept, payment_date: @payable.payment_date, payment_means: @payable.payment_means, payment_type: @payable.payment_type, supplier_id: @payable.supplier_id, user_id: @payable.user_id } }
    assert_redirected_to payable_url(@payable)
  end

  test "should destroy payable" do
    assert_difference("Payable.count", -1) do
      delete payable_url(@payable)
    end

    assert_redirected_to payables_url
  end
end
