---
title: "Orders"
section: core
---

## Overview

The `Order` model is one of the key models in Spree. It provides a central place around which to collect information about a customer order - including line items, adjustments, payments, addresses, return authorizations, and shipments.

Orders have the following attributes:

* `number`: The unique identifier for this order. It begins with the letter R and ends in a 9-digit number. This number is shown to the users, and can be used to find the order by calling `Spree::Order.find_by(number: number)`.
* `item_total`: The sum of all the line items for this order.
* `adjustment_total`: The sum of all adjustments on this order.
* `total`: The result of the sum of the `item_total` and the `adjustment_total`.
* `payment_total`: The total value of all finalized payments.
* `shipment_total`: The total value of all shipments' costs.
* `additional_tax_total`: The sum of all shipments' and line items' `additional_tax`.
* `included_tax_total`: The sum of all shipments' and line items' `included_tax`.
* `promo_total`: The sum of all shipments', line items' and promotions' `promo_total`.
* `state`: The current state of the order. To read more about the states an order goes through, read [The Order State Machine](#the-order-state-machine) section of this guide.
* `email`: The email address for the user who placed this order. Stored in case this order is for a guest user.
* `user_id`: The ID for the corresponding user record for this order. Stored only if the order is placed by a signed-in user.
* `completed_at`: The timestamp of when the order was completed.
* `bill_address_id`: The ID for the related `Address` object with billing address information.
* `ship_address_id`: The ID for the related `Address` object with shipping address information.
* `shipping_method_id`: The ID for the related `ShippingMethod` object.
* `created_by_id`: The ID of object that created this order.
* `shipment_state`: The current shipment state of the order. It takes into account all shipments. Described below in [Order Shipment states section](#order-shipment-states).
* `payment_state`: The current payment state of the order. It takes into account all payments. Described below in [Order Payment states section](#order-payment-states).
* `special_instructions`: Any special instructions for the store to do with this order. Will only appear if `Spree::Config[:shipping_instructions]` is set to `true`.
* `currency`: The currency for this order. Determined by the `Store#default_currency` currency in which this order was created
* `last_ip_address`: The last IP address used to update this order in the frontend.
* `channel`: The channel specified when importing orders from other stores. e.g. amazon.
* `item_count`: The total value of line items' quantity.
* `approver_id`: The ID of user that approved this order.
* `confirmation_delivered`: Boolean value indicating that confirmation email was delivered.
* `token`: The token stored corresponding to token stored in cookies. In older Spree versions this attribute was called `guest_token`
* `canceler_id`: The ID of user that canceled this order.
* `store_id`: The ID of `Store` in which this order was created.

Some methods you may find useful:

* `outstanding_balance`: The outstanding balance for the order, calculated by taking the `total` and subtracting `payment_total`.
* `display_item_total`: A "pretty" version of `item_total`. If `item_total` was `10.0`, `display_item_total` would be `$10.00`.
* `display_adjustment_total`: Same as above, except for `adjustment_total`.
* `display_total`: Same as above, except for `total`.
* `display_outstanding_balance`: Same as above, except for `outstanding_balance`.

## The Order State Machine

Orders flow through a state machine, beginning at a `cart` state and ending up at a `complete` state. The intermediary states can be configured using the [Checkout Flow API](/developer/customization/checkout.html).

The default states are as follows:

* `cart` - initial state
* `address` - Cart moved to Checkout
* `delivery` - buyer has added Shipping and Billing addresses
* `payment` - buyer selected delivery option
* `confirm` - buyer added payment option (if required)
* `complete` - order was placed

The `payment` state will only be triggered if `payment_required?` returns `true`.

The `confirm` state will only be triggered if `confirmation_required?` returns `true`.

The `complete` state can only be reached in one of two ways:

1. No payment is required on the order.
2. Payment is required on the order, and at least the order total has been received as payment.

Assuming that an order meets the criteria for the next state, you will be able to transition it to the next state by calling `next` on that object. If this returns `false`, then the order does *not* meet the criteria. To work out why it cannot transition, check the result of an `errors` method call.

### Order Shipment states

Alongside the global Order state there's also `shipment_state` column which indicates the state of all shipments. Order can have multiple shipments.

* `shipped` - all Shipments are in the `shipped` state
* `partial` - at least one Shipment has a state of `shipped` and there is another Shipment with a state other than `shipped` or there are [InventoryUnits](/developer/core/inventory.html) associated with the order that have a state of `sold` but are not associated with a Shipment
* `ready` - all Shipments are in the `ready` state
* `backorder` - there is backordered inventory associated with an order
* `pending` - all Shipments are in the `pending` state

For more on this please go to [Shipment States page](developer/core/shipments.html#overview).

### Order Payment states

Alongside the global Order state there's also `payment_state` column which indicates the state of all payments. Order can have multiple payments.

* `paid` - `payment_total` is equal to `total`
* `balance_due` - `payment_total` is less than `total`
* `credit_owed` - `payment_total` is greater than `total`
* `failed` - most recent payment is in the `failed` state
* `void` - order is canceled and `payment_total` isequal to `zero`

For more on this please go to [Payment States page](/developer/core/payments.html#overview).

### Order Shipment states

## Line Items

Line items are used to keep track of items within the context of an order. These records provide a link between orders, and [Variants](products#variants).

When a variant is added to an order, the price of that item is tracked along with the line item to preserve that data. If the variant's price were to change, then the line item would still have a record of the price at the time of ordering.

## Addresses

An order can link to two `Address` objects. The shipping address indicates where the order's product(s) should be shipped to. This address is used to determine which shipping methods are available for an order.

The billing address indicates where the user who's paying for the order is located. This can alter the tax rate for the order, which in turn can change how much the final order total can be.

For more information about addresses, please read the [Addresses](/developer/core/addresses.html) guide.

## Adjustments

Adjustments are used to affect an order's final cost, either by decreasing it ([Promotions](/developer/core/promotions.html)) or by increasing it ([Shipping](/developer/core/shipments.html), [Taxes](/developer/core/taxation.html)).

For more information about adjustments, please see the [Adjustments](/developer/core/adjustments.html) guide.

## Payments

Payment records are used to track payment information about an order. For more information, please read the [Payments](/developer/core/payments.html) guide.

## Return Authorizations

An order can have many `ReturnAuthorization` objects. These records keeps track of which items have been authorized for return and how the user will be compensated -- either via exchanging the item(s) or a reimbursement.

## Updating an Order

If you change any aspect of an `Order` object within code and you wish to update the order's totals -- including associated adjustments and shipments -- call the `update_with_updater!` method on that object, which calls out to the `OrderUpdater` class.

For example, if you create or modify an existing payment for the order which would change the order's `payment_state` to a different value, calling `update_with_updater!` will cause the `payment_state` to be recalculated for that order.

Another example is if a `LineItem` within the order had its price changed. Calling `update_with_updater!` will cause the totals for the order to be updated, the adjustments for the order to be recalculated, and then a final total to be established.
