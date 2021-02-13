require_relative 'script'
require_relative 'menu'
require_relative 'dish_lister'
require 'twilio-ruby'

class Order
  include DishLister
  account_sid = ENV['TWILIO_ACCOUNT_SID']
  auth_token = ENV['TWILIO_AUTH_TOKEN']
  @client = Twilio::REST::Client.new(account_sid, auth_token)

  attr_reader :menu, :balance, :dishes, :complete
  def initialize(menu)
    @menu = menu
    @dishes = []
    @balance = 0
    @complete = false
  end

  def add_item(item)
    order_closed_error
    @dishes << @menu.pick(item)
    @balance += @dishes.last[:price]
    @balance.round(2)
  end

  def total
    "£ %.2f" % @balance
  end

  def check_balance
    list_dishes
    sum = 0
    @dishes.each { |dish| sum += dish[:price] }
    puts "Total: £" + "%.2f" % sum
  end

  def complete_order
    @complete = true
  end

  def finalize
    complete_order
    client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: ENV['CUSTOMER_PHONE_NUMBER'],
      body: 'Thank you! Your order has been placed and will be delivered when I feel like it.'
    )
  end

private

  def order_closed_error
    fail "this order is closed" if @complete == true
  end

end
