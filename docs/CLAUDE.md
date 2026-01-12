# Lucid Framework Documentation

## Project Scope
We are creating comprehensive user guide/book content for the Lucid Ruby web application framework. The goal is to produce website content that helps developers:
- Learn about Lucid's novel framework concepts and architecture
- Understand how Lucid differs from traditional Ruby web frameworks
- Be guided through building applications with the framework

The content should be engaging, easy to understand, and accessible. This project focuses solely on content creation - not website markup or scripting.

Lucid has a unique design and architecture that differs significantly from most other Ruby web frameworks, requiring careful explanation of new concepts and mental models.

## Lucid Framework Overview

### What is Lucid?
Lucid is a specialized Ruby framework for building interactive web UIs using a hypermedia-driven approach. It sits on top of traditional web frameworks (Rails, Sinatra) to implement the View/Controller layer, focusing specifically on making web-based GUIs easy to build.

**Key Positioning:**
- Specialized UI framework (not general-purpose web framework)
- Sits on top of existing Ruby frameworks 
- No data-access layer (bring your own)
- Not for APIs or general endpoints - focused on interactive UIs

### Novel Architecture Features

**1. Message-Driven Architecture**
- User interactions generate messages (Commands via POST, Links via GET)
- Messages encode intent and decouple UI from business logic
- Dynamic dispatch replaces static controller/route binding
- No URL management needed - developers work with message types only

**2. Server-Side Component Model** 
- Ruby classes with Papercraft DSL for HTML generation
- Components declare their own URL parameters and types
- Component hierarchy rebuilt from URL state on each request
- Lazy signal evaluation for efficient database queries
- Private component params with data flowing via signals

**3. Automatic Updates via Message Flow**
- Commands → Handlers → Events → UI Components
- Links dispatch directly to UI components for navigation
- Dirty tracking identifies changed components
- HTMX integration provides seamless DOM patching
- Only changed components re-render

**4. State-Based URL Routing**
- URL represents complete UI state (query params + path segments)
- Components serialize/deserialize state to/from URL
- Eliminates session management complexity
- Perfect browser navigation (back/forward buttons work naturally)

### Mental Model Shifts for Developers

**From Traditional MVC:**
- Routes & Controllers → Messages & Components  
- Request/Response → Reactive Component Hierarchy
- Session State → URL-as-State
- API Design → Message Design
- Manual Updates → Automatic Patching
- Tight Coupling → Message-based Decoupling

### Key Benefits
- Eliminates coupling between views, controllers, and routes
- Makes refactoring dramatically easier
- Automatic UI updates without complex state management
- No API versioning or state synchronization needed
- Efficient rendering with lazy evaluation
- Seamless browser navigation experience

## Book Structure Considerations

**Target Audience:** Ruby developers familiar with Rails/Sinatra who need to understand Lucid's novel approach

**Core Challenge:** Teaching fundamentally different mental model while making concepts accessible

**Key Success Metrics:** 
- Developers understand when/why to use Lucid
- Clear grasp of message-driven architecture benefits
- Ability to build components that respond to messages
- Understanding of URL-as-state concept

## Proposed User Guide Outline

### Part I: Foundations
**1. Why Lucid? The Problem with Traditional Web UI**
- Coupling in MVC architectures
- URL management complexity  
- State synchronization challenges
- The refactoring nightmare

**2. Hello World - Your First Lucid Component**
- Installation and setup
- A simple component with basic HTML
- Running and seeing it work
- *Goal: Get the "feel" before diving deep*

**3. The Three Feedback Loops**
- The Command Loop (POST → Handler → Event → UI)
- The Navigation Loop (GET → Component state update)  
- The Acknowledgement Loop (client-side micro-interactions)
- How these loops work together
- *Core mental model for understanding Lucid*

**4. Messages: The Language of Intent**
- Mental model shift from routes to messages
- Command messages vs Link messages
- Message types and parameters
- Dynamic dispatch vs static binding
- Simple interactive example

**5. The Component Model**
- Server-side components as Ruby classes
- Papercraft DSL basics
- Component parameters and types
- State serialization to URLs
- *Building on Hello World example*

**6. Handlers and Dispatch**
- Command handlers for business logic
- Event emission and handling
- Handler organization and patterns
- Separation of concerns
- Error handling in handlers

**7. Project Structure and Organization**
- Lucid's approach to project layout
- Component organization
- Handler organization  
- Message type definitions
- Integration with Rails/Sinatra structure

### Part II: Building Interactive UIs
**8. Handling User Interactions**
- `on()` and `to()` message handlers in components
- The `update()` method
- Component state management
- Complete message flow walkthrough

**9. Component Communication**
- Parent-child data flow with signals
- Lazy evaluation benefits
- Passing data models through hierarchy
- When to use signals vs parameters

**10. Building a Complete Feature**
- Extended example (todo list? simple CRUD?)
- Multiple components working together
- Commands, events, and UI updates
- Seeing automatic DOM patching in action

### Part III: Advanced Concepts
**11. Complex State Management**
- Nested component hierarchies
- Managing complex URL parameters
- State validation and type safety
- Error handling patterns

**12. Integration Patterns**
- Working with Rails/Sinatra
- Database queries and performance
- Authentication and authorization
- API integration (when needed)

**13. Production Considerations**
- Performance optimization
- Debugging techniques
- Testing strategies
- Deployment patterns

### Appendices
- API Reference
- Migration guides
- Troubleshooting
- Community resources

## Working Notes

**Current Focus:** Establishing the Three Feedback Loops as the core organizing concept for understanding Lucid's approach to web interactions.

**Key Insights Discovered:**
- Three distinct patterns: Command Loop (eventual), Navigation Loop (fast), Micro-feedback Loop (instant)
- Each loop has different timing expectations and implementation approaches
- Lucid + Stimulus.js provides clean separation between server-side message handling and client-side micro-feedback
- "Delete Post" button example effectively demonstrates all three loops working together

**Documentation Strategy:**
- Lead with concrete examples before diving into concepts
- Use the Three Feedback Loops as the mental model foundation
- Show how Lucid makes implicit web patterns explicit and manageable

