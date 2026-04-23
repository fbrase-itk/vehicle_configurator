<template>
  <div id="app">
    <header>
      <h1>Vehicle Configurator</h1>
      <div id="header-actions" class="header-actions"></div>
    </header>
    <main>
      <router-view />
    </main>
  </div>
</template>

<style>
/* ---------------------------------------------------------------- */
/* Design tokens — light-green / dark-green theme                   */
/* ---------------------------------------------------------------- */
:root {
  /* Raw palette */
  --color-app-bg:            #E3F9E5; /* light green page background */
  --color-app-bg-2:          #B0EAB3; /* darker light green accent */
  --color-menu-bg:           #052E16; /* dark forest header / menu */
  --color-button-primary:    #0F8A2B; /* emerald CTA */
  --color-white:             #FFFFFF;
  --color-icon-active:       #2F9E44; /* active/icon green */
  --color-status-ok:         #00FF01; /* bright lime status dot */
  --color-green-dark:        #27AE60; /* success UI (checkmarks) */
  --color-red:               #E74C3C; /* error / destructive */

  /* Deep-forest companion for the primary "emerald → forest" gradient */
  --color-accent-deep:       #14532D;

  /* Semantic tokens (derived) — use these in component styles */
  --color-text:              #0F172A;
  --color-text-muted:        #475569;
  --color-text-on-dark:      var(--color-white);
  --color-text-on-dark-mute: rgba(255, 255, 255, 0.72);

  --surface-card:            var(--color-white);
  --surface-card-hover:      #F1FBF2;
  --surface-selected:        var(--color-app-bg-2);
  --surface-selected-soft:   rgba(176, 234, 179, 0.45);
  --surface-input-dark:      rgba(255, 255, 255, 0.08);

  --border-subtle:           rgba(5, 46, 22, 0.10);
  --border-strong:           rgba(5, 46, 22, 0.22);
  --border-selected:         var(--color-button-primary);
  --border-on-dark:          rgba(255, 255, 255, 0.12);

  --shadow-card:             0 2px 8px rgba(5, 46, 22, 0.08);
  --shadow-card-hover:       0 6px 20px rgba(5, 46, 22, 0.15);
  --shadow-header:           0 2px 14px rgba(5, 46, 22, 0.35);

  /* Primary gradient: emerald → deep forest.
     Use `--gradient-primary` on light surfaces (cards, light body bg)
     and `--gradient-primary-on-dark` on the dark forest header/menu,
     where the emerald would otherwise blend into the background. */
  --gradient-primary:         linear-gradient(90deg, var(--color-button-primary), var(--color-accent-deep));
  --gradient-primary-soft:    linear-gradient(90deg, rgba(15, 138, 43, 0.18), rgba(20, 83, 45, 0.18));
  --gradient-primary-on-dark: linear-gradient(90deg, #B0EAB3, #6EE7B7);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
  background: var(--color-app-bg);
  min-height: 100vh;
  color: var(--color-text);
}

#app {
  min-height: 100vh;
}

header {
  background: var(--color-menu-bg);
  padding: 0.85rem 2rem;
  border-bottom: 1px solid var(--border-on-dark);
  box-shadow: var(--shadow-header);
  display: flex;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
  position: sticky;
  top: 0;
  z-index: 50;
  color: var(--color-text-on-dark);
}

header h1 {
  font-size: 1.25rem;
  font-weight: 600;
  background: var(--gradient-primary-on-dark);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  flex-shrink: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-left: auto;
  flex-wrap: wrap;
}

main {
  padding: 2rem;
  max-width: 1600px;
  margin: 0 auto;
}
</style>
