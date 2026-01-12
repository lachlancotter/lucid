# Chapter 3: The Three Feedback Loops

**Core Concept:** Every web interaction falls into one of three patterns, each with different timing and purpose.

## The Command Loop (Eventual Consistency)

**Pattern:** User submits intent → Server processes → Result communicated back
**Examples:** "Delete this post", "Save my changes", "Send this email"
**Flow:** POST → Handler → Event → UI Update
**Timing:** Slower (database operations, business logic)
**User Expectation:** Confirmation of success/failure

The Command Loop handles actions that change the world. When a user clicks "Delete Post," they're expressing intent to modify data. This requires server processing, validation, database operations, and potentially complex business logic. The user understands this takes time and expects clear feedback about the outcome.

## The Navigation Loop (State Transitions)

**Pattern:** User expresses navigation intent → UI reconfigures to new state
**Examples:** "Show me the edit form", "Filter by category", "Go to page 2"
**Flow:** GET → Component state update → URL change
**Timing:** Fast (state changes, no business logic)
**User Expectation:** Immediate state change

The Navigation Loop handles UI state changes. When a user clicks "Edit" or changes a filter, they're asking to see a different view of the same data. This shouldn't require complex server processing - it's about reconfiguring the interface to show different information or controls.

## The Micro-feedback Loop (Immediate Response)

**Pattern:** User gestures → Immediate visual acknowledgment 
**Examples:** Button press states, form validation, loading spinners
**Flow:** Client-side only (Stimulus.js)
**Timing:** Instant (<100ms)
**User Expectation:** "I see you clicked that"

The Micro-feedback Loop provides immediate acknowledgment of user gestures. When someone hovers over a button or clicks it, they need instant visual feedback that the interface received their input. This happens entirely client-side to avoid any network latency.

## Why These Patterns Matter

**Traditional Problem:** Most web frameworks blur these patterns together. A single "controller action" might handle immediate feedback, navigation, and business logic all in one place. This creates:
- Inconsistent response times
- Complex, coupled code
- Poor user experience
- Difficult testing and maintenance

**Lucid Solution:** By making these patterns explicit, Lucid ensures:
- Each pattern uses the appropriate implementation approach
- Response times match user expectations
- Clear separation of concerns
- Easier testing and refactoring

## Concrete Example: The "Delete Post" Button

A single user interaction can trigger all three loops in sequence:

1. **Hover/Click → Button visual feedback (Micro-feedback)**
   - Button changes color instantly
   - User knows their gesture was received
   - Handled by Stimulus.js

2. **Click → Delete confirmation dialog appears (Navigation)** 
   - UI state changes to show confirmation dialog
   - URL might update to reflect dialog state
   - Fast server response updates component hierarchy

3. **Confirm → Post deletion + success message (Command)**
   - Business logic processes the deletion
   - Database is updated
   - Success message appears
   - List of posts updates to reflect deletion

Each loop serves a different purpose and uses different implementation strategies, but they work together to create a smooth, predictable user experience.

## Key Insight

Understanding these three patterns is fundamental to building effective Lucid applications. Every user interaction should be designed with awareness of which loop(s) it involves and what implementation approach is most appropriate.