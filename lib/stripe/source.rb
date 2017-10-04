module Stripe
  class Source < APIResource
    extend Stripe::APIOperations::Create
    include Stripe::APIOperations::Save

    OBJECT_NAME = "source".freeze

    def delete(params = {}, opts = {})
      if !respond_to?(:customer) || customer.nil? || customer.empty?
        raise NotImplementedError,
              "Source objects cannot be deleted, they can only be detached " \
              "from customer objects. This source object does not appear to " \
              "be currently attached to a customer object."
      end

      url = "#{Customer.resource_url}/#{CGI.escape(customer)}/sources/#{CGI.escape(id)}"
      resp, opts = request(:delete, url, params, Util.normalize_opts(opts))
      initialize_from(resp.data, opts)
    end

    def verify(params = {}, opts = {})
      resp, opts = request(:post, resource_url + "/verify", params, Util.normalize_opts(opts))
      initialize_from(resp.data, opts)
    end
  end
end
