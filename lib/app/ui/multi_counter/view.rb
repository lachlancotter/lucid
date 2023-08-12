require_relative "store"

module MultiCounter
  class View < Lucid::View
    store :counters, Store

    post :create do
      store :counters, Store

      params do
        attribute :name
        validate do
          required(:name).filled(:string)
        end
      end

      def call
        counters.create(params[:name])
      end
    end

    def template
      view             = self
      form_template    = self.form_template
      counter_template = self.counter_template
      
      Papercraft.html do
        head { title 'Multi Counter' }
        body {
          h1 'Multi Counter'
          if view.counters.all.empty?
            p "No Counters"
          else
            view.counters.all.each do |counter|
              emit counter_template.apply(counter)
            end
          end
          emit form_template
        }
      end
    end

    def counter_template
      Papercraft.html do |counter|
        h2 "#{counter.name} Count: #{counter.count}"
      end
    end

    def form_template
      create.form({ name: "Test" }) { |f|
        h2 'Inside Form'
        emit f.label(:name)
        emit f.text(:name)
        emit f.submit('Create Counter')
      }
    end
  end
end