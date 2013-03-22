require File.expand_path('../../test_helper', __FILE__)

module Stripe
  class CustomerTest < Test::Unit::TestCase
    should "customers should be listable" do
      @mock.expects(:get).once.returns(test_response(test_customer_array))
      c = Stripe::Customer.all.data
      assert c.kind_of? Array
      assert c[0].kind_of? Stripe::Customer
    end

    should "customers should be deletable" do
      @mock.expects(:delete).once.returns(test_response(test_customer({:deleted => true})))
      c = Stripe::Customer.new("test_customer")
      c.delete
      assert c.deleted
    end

    should "customers should be updateable" do
      @mock.expects(:get).once.returns(test_response(test_customer({:mnemonic => "foo"})))
      @mock.expects(:post).once.returns(test_response(test_customer({:mnemonic => "bar"})))
      c = Stripe::Customer.new("test_customer").refresh
      assert_equal c.mnemonic, "foo"
      c.mnemonic = "bar"
      c.save
      assert_equal c.mnemonic, "bar"
    end

    should "customers should have Card objects associated with their active_ard property" do
      @mock.expects(:get).once.returns(test_response(test_customer))
      c = Stripe::Customer.retrieve("test_customer")
      assert c.active_card.kind_of?(Stripe::StripeObject) && c.active_card.object == 'card'
    end

    should "create should return a new customer" do
      @mock.expects(:post).once.returns(test_response(test_customer))
      c = Stripe::Customer.create
      assert_equal "c_test_customer", c.id
    end

    should "be able to update a customer's subscription" do
      @mock.expects(:get).once.returns(test_response(test_customer))
      c = Stripe::Customer.retrieve("test_customer")

      @mock.expects(:post).once.with do |url, api_key, params|
        url == "#{Stripe.api_base}/v1/customers/c_test_customer/subscription" && api_key.nil? && CGI.parse(params) == {'plan' => ['silver']}
      end.returns(test_response(test_subscription('silver')))
      s = c.update_subscription({:plan => 'silver'})

      assert_equal 'subscription', s.object
      assert_equal 'silver', s.plan.identifier
    end

    should "be able to cancel a customer's subscription" do
      @mock.expects(:get).once.returns(test_response(test_customer))
      c = Stripe::Customer.retrieve("test_customer")

      # Not an accurate response, but whatever

      @mock.expects(:delete).once.with("#{Stripe.api_base}/v1/customers/c_test_customer/subscription?at_period_end=true", nil, nil).returns(test_response(test_subscription('silver')))
      s = c.cancel_subscription({:at_period_end => 'true'})

      @mock.expects(:delete).once.with("#{Stripe.api_base}/v1/customers/c_test_customer/subscription", nil, nil).returns(test_response(test_subscription('silver')))
      s = c.cancel_subscription
    end

    should "be able to delete a customer's discount" do
      @mock.expects(:get).once.returns(test_response(test_customer))
      c = Stripe::Customer.retrieve("test_customer")

      @mock.expects(:delete).once.with("#{Stripe.api_base}/v1/customers/c_test_customer/discount", nil, nil).returns(test_response(test_delete_discount_response))
      s = c.delete_discount
      assert_equal nil, c.discount
    end
  end
end