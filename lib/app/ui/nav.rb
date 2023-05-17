



class Index < Lucid::View
  state do
    symbol :sort_by, in: [:name, :age]
    string :filter, default: ""
  end

  config do

  end

  source :records, class: RecordSource

  # link :sort_by_name do |state|
  #   state.sort_by = :name
  # end
  #
  # link :sort_by_age do |state|
  #   state.sort_by = :age
  # end


  def sort_by_name
    mutate do |state|
      state.sort_by = :name
      state.filter = "bar"
    end
  end

  def complex_change
    mutate { |state| state.sort_by = :age } + child_view.change
  end

  def render
    [
       sort_by_name.link("Sort by name"),
       sort_by_age.link("Sort by age"),
       form.render do |builder|
         builder.filter.text_field
       end
    ]
  end
end

