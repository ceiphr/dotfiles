// Add smooth over-scrolling similar to Mac OS
user_pref('apz.overscroll.enabled', true);

// Reduce scroll-speed -> Intended for GNOME/Wayland
user_pref('mousewheel.min_line_scroll_amount', 100);
user_pref('mousewheel.default.delta_multiplier_x', 40);
user_pref('mousewheel.default.delta_multiplier_y', 40);

// Improve performance
user_pref('gfx.webrender.all', true);

// Disable Pocket
user_pref('extensions.pocket.enabled', false);

// Enable userChrome.css/userContent.css
user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);

// GNOME theme-specific settings
user_pref('gnomeTheme.bookmarksToolbarUnderTabs', true);
user_pref('gnomeTheme.hideSingleTab', true);
user_pref('gnomeTheme.hideWebrtcIndicator', true);
user_pref('gnomeTheme.normalWidthTabs', false);
user_pref('gnomeTheme.spinner', true);
