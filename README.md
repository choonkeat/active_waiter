# ActiveWaiter

A simple mechanism allowing your users to wait for the completion of your `ActiveJob`

## Scenario

You have an export PDF feature that you've implemented directly in the controller action.

As data grows, your HTTP request takes longer and starts timing out. So you decide to move the PDF generating code into a background job.

``` ruby
def index
  respond_to do |format|
    format.html
    format.pdf {
      ExportPdfJob.perform_later(@things, current_user)
      redirect_to :back, notice: "We'll email your PDF when it's done!"
    }
  end
end
```


But how do you get that PDF into the hands of your users now? Email? Push notification? Manual reload?

> You have no PDF ready for download (yet). Please reload.


## Solution

Let `ActiveWaiter` enqueue that job instead and redirect to it's progress tracking page.

``` ruby
def index
  respond_to do |format|
    format.html
    format.pdf {
      # yay ActiveWaiter.enqueue
      redirect_to active_waiter_path(ActiveWaiter.enqueue(ExportPdfJob, @things, current_user))
    }
  end
end
```

``` ruby
# routes.rb
mount ActiveWaiter::Engine => "/active_waiter(/:id)"
```

![active_waiter mov](https://cloud.githubusercontent.com/assets/473/7785141/c4667734-01b4-11e5-8974-3a3b00b3a4b6.gif)

And we need to add a bit of code into your `ActiveJob` class

- 1) add `include ActiveWaiter::Job`
- 2) return a `url` from your `perform` method to link to the result page (or file)

``` ruby
class ExportPdfJob < ActiveJob::Base
  queue_as :default

  # (1)
  include ActiveWaiter::Job

  def perform(things, current_user)
    count = things.count.to_f
    files = []
    things.each_with_index do |thing, index|
      files << generate_pdf(thing)

      # (a)
      update_active_waiter percentage: (100 * (index+1) / count)
    end

    # (2)
    upload(combine(files)).s3_url
  rescue Exception => e

    # (b)
    update_active_waiter error: e.to_s
  end

  # (c)
  def self.download?
    true
  end
end
```

Optionally, you can also

- a) report progress while your job runs, using `update_active_waiter(percentage:)`
- b) report if there were any errors, using `update_active_waiter(error:)`
- c) indicate if you want the user to "download" the url manually or be redirected there automatically (default: redirect)
