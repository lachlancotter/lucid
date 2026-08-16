# Add Cards

Introduce the first command workflow by letting users add cards to a column.

## Goal

Create cards through a form and render them in the selected column.

## Outline

- Introduce the cards feature
- Define the add-card command message
- Handle card creation
- Render the add-card form
- Show validation errors

## Example

The card handler should not own storage directly. Put the board API behind a
small service and provide that service through the request container.

```ruby
require "securerandom"

class BoardRepository
  def initialize
    @cards = Hash.new { |cards, column_id| cards[column_id] = [] }
  end

  def add_card(column_id:, title:)
    card = { id: SecureRandom.uuid, title: title }
    @cards[column_id] << card
    card
  end

  def cards_for(column_id)
    @cards[column_id]
  end
end

BOARD_REPOSITORY = BoardRepository.new

class KanbanContainer < Lucid::App::Container
  provide(:board_repository) { BOARD_REPOSITORY }
end

class AddCard < Lucid::Command
  validate do
    required(:column_id).filled(:string)
    required(:title).filled(:string)
  end
end

class CardHandler < Lucid::Handler
  use :board_repository, Types.instance(BoardRepository)

  perform AddCard do |message|
    board_repository.add_card(
      column_id: message.column_id,
      title: message.title
    )
  end
end

class KanbanApp < Lucid::App
  set :container_class, KanbanContainer
  set :handler_class, CardHandler
end
```

The important boundary is that `AddCard` names the user's intent,
`CardHandler` coordinates the effect, and `BoardRepository` owns the storage
API. The container connects those pieces for each request.
