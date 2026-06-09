# Complaint Manager

A Flutter Complaint Management Module built as a single-screen application with search, filters, offline support, pagination, and detail view.

## Project Structure

```
lib/
  main.dart                              -- Entry point, MaterialApp setup
  core/
    task_repo.dart                       -- Repository pattern for API + cache
  models/
    task_model.dart                      -- Data model with mock fields
  presentation/
    providers/
      task_provider.dart                 -- Riverpod state management
    screens/
      task_manage_screen.dart            -- List with search, filters, pagination
      task_detail_screen.dart            -- Detail view for a single complaint
    widgets/
      task_card.dart                     -- Card widget + shimmer skeleton
      status_badge.dart                  -- Reusable status chip
      priority_badge.dart                -- Reusable priority chip
```

## State Management Used

Riverpod (flutter_riverpod)

Providers used:
- taskRepositoryProvider         -- Gives access to TaskRepository
- taskNotifierProvider           -- AsyncNotifier that loads tasks and handles refresh
- taskDebouncedSearchProvider    -- Debounced search query (400ms)
- taskSelectedFilterProvider     -- Active filter chip value
- taskDisplayCountProvider       -- Pagination count (loads 20 at a time)
- filteredTasksProvider          -- Derived state: search + filter combined
- paginatedTasksProvider         -- Derived state: takes first N filtered tasks
- hasMoreTasksProvider           -- Derived state: checks if more tasks exist

No setState used for business logic. Only setState is used inside main.dart for a BottomNavigationBar when present, which is purely UI-level.

## Offline Strategy

SharedPreferences is used for caching.

Flow:
1. On app start, check SharedPreferences for cached data under key "tasks".
2. If cache exists and is not empty, show it immediately on screen.
3. In background, fetch fresh data from API.
4. Write fresh data back to SharedPreferences.
5. If API fails and cache exists, silently keep showing cached data.
6. If API fails and no cache exists, show retry button.

## Assumptions

- API: https://jsonplaceholder.typicode.com/posts provides id, title, body fields.
- Mock fields (status, priority, assignedTo) are generated deterministically using id modulo list length so the same record always gets the same values.
- Status values: Open, In Progress, Resolved.
- Priority values: Low, Medium, High.
- Assigned engineers: John, Meera, Dev, Riya, Alex.
- Search matches both Complaint ID and Title in a case-insensitive way.
- Pagination is implemented with a "Load More" button that adds 20 records each time.
- Pull-to-refresh refreshes API data while keeping current search and filter state.

