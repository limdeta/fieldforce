// Shared constants for facet filter and side menu timings

// Default timings — use a moderate duration to avoid flicker across devices.
// Delay before requesting focus back to the search field after a menu sheet is closed.
// Keep a reasonable delay to avoid overlapping the OS keyboard animation.
const Duration kFacetFilterFocusDelay = Duration(milliseconds: 180);
// Default animation duration for the facet menu - short but visible. Set to zero
// when an instant show/hide behavior is desired.
const Duration kFacetFilterAnimationDuration = Duration(milliseconds: 180);
