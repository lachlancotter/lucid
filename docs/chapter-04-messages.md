# Chapter 4: Messages - The Language of Intent

## From Routes to Messages: A Mental Model Shift

Traditional web frameworks organize around **routes** - mappings from URLs to controller actions. Routes answer the question "where should this request go?" But routes create coupling problems:

- Views must know specific URLs to link to
- Controllers are tightly bound to URL patterns  
- Refactoring requires updating routes, controllers, AND views
- URL structure becomes part of your API contract

Lucid organizes around **messages** instead. Messages answer the question "what does the user want to accomplish?" This subtle shift eliminates coupling and makes your application much more flexible.

## Routes Say "Where" - Messages Say "What"

**Traditional Route Thinking:**
```ruby
# Route definition
get '/posts/:id/edit', to: 'posts#edit'

# View code
<%= link_to "Edit", edit_post_path(@post) %>

# Controller
class PostsController < ApplicationController
  def edit
    @post = Post.find(params[:id])
  end
end
```

**Lucid Message Thinking:**
```ruby
# Message definition  
class ShowEditForm < Link
  param :post_id, Integer
end

# View code (no URLs!)
<%= link_to "Edit", ShowEditForm.new(post_id: @post.id) %>

# Component handles the message
class PostComponent < Lucid::Component
  to ShowEditForm do |msg|
    update(editing: true, post_id: msg.post_id)
  end
end
```

## Message Types: Commands vs Links

Lucid defines two fundamental message types that correspond to the first two feedback loops:

### Commands (POST requests - Command Loop)

Commands express intent to **change something**. They trigger business logic, modify data, and emit events.

```ruby
class DeletePost < Command
  param :post_id, Integer
  param :confirm, Boolean, default: false
end

class CreateComment < Command
  param :post_id, Integer
  param :content, String
  param :author_email, String
end
```

Commands are dispatched to handlers that contain your business logic:

```ruby
class PostHandler
  on DeletePost do |msg|
    post = Post.find(msg.post_id)
    post.destroy!
    emit PostDeleted.new(post_id: msg.post_id)
  end
end
```

### Links (GET requests - Navigation Loop)

Links express intent to **navigate somewhere** or **see something different**. They update component state and change the UI configuration.

```ruby
class ShowEditForm < Link
  param :post_id, Integer
end

class FilterByCategory < Link 
  param :category, String
end

class ShowPage < Link
  param :page, Integer, default: 1
end
```

Links are handled directly by components:

```ruby
class PostListComponent < Lucid::Component
  to FilterByCategory do |msg|
    update(filter: msg.category, page: 1)
  end
  
  to ShowPage do |msg|
    update(page: msg.page)
  end
end
```

## The Power of Dynamic Dispatch

The magic happens when messages are dispatched. Unlike routes that have static bindings to controller actions, messages are dispatched dynamically to any component or handler that declares interest in them.

**Multiple Handlers Example:**
```ruby
# Business logic handler
class PostHandler
  on DeletePost do |msg|
    Post.find(msg.post_id).destroy!
    emit PostDeleted.new(post_id: msg.post_id)
  end
end

# Audit log handler  
class AuditHandler
  on DeletePost do |msg|
    AuditLog.create!(
      action: "delete_post", 
      post_id: msg.post_id,
      user: current_user
    )
  end
end

# Analytics handler
class AnalyticsHandler
  on PostDeleted do |event|
    Analytics.track("post_deleted", post_id: event.post_id)
  end
end
```

All three handlers respond to the same message automatically. You can add or remove handlers without changing any view code.

## Automatic URL Management

With messages, you never write URLs manually. Lucid generates URLs automatically based on message parameters and current component state.

**What you write:**
```ruby
<%= link_to "Delete", DeletePost.new(post_id: @post.id) %>
```

**What Lucid generates:**
```html
<a href="/messages/delete_post?post_id=123&_state=current_ui_state">Delete</a>
```

The URL contains everything needed to:
1. Identify the message type (`delete_post`)
2. Provide message parameters (`post_id=123`) 
3. Rebuild the current UI state (`_state=...`)

## Stimulus Integration: The Missing Piece

Messages handle server communication beautifully, but what about immediate client-side feedback? That's where Stimulus.js fits in:

```html
<!-- Lucid handles the server message -->
<%= button_to "Save", SavePost.new(post_id: @post.id), 
    data: { 
      controller: "form-submit",
      action: "form-submit#showSpinner" 
    } %>
```

```javascript
// Stimulus handles immediate feedback
class FormSubmitController extends Controller {
  showSpinner() {
    this.element.classList.add("loading")
    this.element.disabled = true
  }
}
```

This creates a clean separation:
- **Lucid messages:** Handle server communication and business logic
- **Stimulus controllers:** Handle immediate user feedback and micro-interactions
- **Together:** Create responsive, professional-feeling interfaces

## Key Benefits

1. **Decoupling:** Views don't know about URLs or handlers
2. **Flexibility:** Add new handlers without changing existing code  
3. **Maintainability:** Refactoring is isolated to individual components
4. **Testability:** Messages can be tested independently
5. **Expressiveness:** Code reads like the user's intent

Messages transform your codebase from a collection of URL endpoints into a vocabulary of user intentions. This makes your application easier to understand, modify, and extend.