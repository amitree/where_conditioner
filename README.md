where\_conditioner
==================

Here at Amitree, we've found that some of our controllers end up with a lot of
duplication stemming from the fact that `where` is being invoked conditionally:

```ruby
purchases = Purchase.all
purchases = purchases.where('start_date > ?', params[:start_date])
  if params[:start_date].present?
```

The **where\_conditioner** gem allows us to write more simply:

```ruby
purchases = Purchase.all
  .where_if_present('start_date > ?', params[:start_date])
```

See more details on our blog: [http://thesource.amitree.com/2014/04/where-conditioner.html](http://thesource.amitree.com/2014/04/where-conditioner.html).

Installation
-----

Simply add to your Gemfile:

```ruby
gem 'where_conditioner'
```

Usage
----

### where\_if\_present

#### ...with a parameterized SQL string

Apply the conditions if **all** parameters are non-`nil`:

```ruby
start_date = Date.yesterday
end_date = nil
Purchase.all.where_if_present('date BETWEEN ? and ?', start_date, end_date)
 # => Purchase.all

start_date = Date.yesterday
end_date = Date.today
Purchase.all.where_if_present('date BETWEEN ? and ?', start_date, end_date)
 # => Purchase.where('date BETWEEN ? and ?', start_date, end_date)
```

#### ...with a hash

Apply only those conditions where the value is non-`nil`:

```ruby
status = 'shipped'
customer_id = nil
Purchase.all.where_if_present(status: status, customer_id: customer_id)
 # => Purchase.all.where(status: 'shipped')
```

### if

```ruby
show_pending = false
Purchase.all
  .if(!show_pending)
    .where(status: 'shipped')
 # => Purchase.all.where(status: 'shipped')

show_pending = true
Purchase.all
  .if(!show_pending)
    .where(status: 'shipped')
 # => Purchase.all
```

### unless

Like `if`, but the opposite! :)

```ruby
show_pending = false
Purchase.all
  .unless(show_pending)
    .where(status: 'shipped')
 # => Purchase.all.where(status: 'shipped')

show_pending = true
Purchase.all
  .unless(show_pending)
    .where(status: 'shipped')
 # => Purchase.all
```

### else

```ruby
wacky_order = false
Purchase.all
  .if(wacky_order)
    .order(customer_id: :desc)
  .else
    .order(:date)
 # => Purchase.all.order(:date)
```

### Passing blocks

If the result of a condition is more than one method call, you can pass in a
block instead:

```ruby
recent = false
Purchase.all
  .if(recent) { where('date > ?', 30.days.ago).order(date: :desc) }
  .else { where.not('date > ?', 30.days.ago).order(:date) }
```
