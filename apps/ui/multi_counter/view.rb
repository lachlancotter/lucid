require_relative "store"

module MultiCounter
  # ===================================================== #
  #    Events
  # ===================================================== #

  class CounterCreated < Lucid::Event
    params do
      attribute :name
      validate do
        required(:name).filled(:string)
      end
    end
  end

  class CounterChanged < Lucid::Event
    params do
      attribute :new_count
      validate do
        required(:new_count).filled(:integer)
      end
    end
  end

  # ===================================================== #
  #    Sub
  # ===================================================== #

  class CounterView < Lucid::View
    # store :counters, Store

    config do
      option :counter, nil
    end

    # delegate :counter, to: :config

    post :inc do
      def call
        raise "invalid counter" unless counter
        counter.inc
      end
    end

    post :dec do
      def call
        raise "invalid counter" unless counter
        counter.dec
        # counters.dec(params[:id])
      end
    end

    template do
      h2 "#{counter.name}: #{counter.count}"
      div { emit action(:inc).button('Inc') }
      div { emit action(:dec).button('Dec') }
    end
  end

  # ===================================================== #
  #    Main
  # ===================================================== #

  class CounterApp < Lucid::View
    
    # ===================================================== #
    #    Data
    # ===================================================== #
    
    store :counters, Store

    # ===================================================== #
    #    Action
    # ===================================================== #

    post :create do
      store :counters, Store

      params do
        attribute :name
        validate do
          required(:name).filled(:string)
        end
      end

      def call
        counters.create(params.name)
        CounterCreated.notify(name: params.name)
      end
    end

    # ===================================================== #
    #    Events
    # ===================================================== #

    on(CounterCreated) do |event|
      # Rerender...
    end

    # ===================================================== #
    #    Subviews
    # ===================================================== #

    nest :counter_view, CounterView, in: :counters, as: :counter

    # ===================================================== #
    #    Template
    # ===================================================== #

    template do
      head { title 'Multi Counter' }
      body {
        h1 'Multi Counter'
        if counters.none?
          p "No Counters"
        else
          counters.all.each_with_index do |counter, index|
            subview counter_view(index)
          end
        end
        fragment :form
      }
    end

    template :form do
      emit create.form({ name: "Test" }) do |f|
        h2 'Inside Form'
        f.label(:name)
        f.text(:name)
        f.submit('Create Counter')
      end
    end
  end
end