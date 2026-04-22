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
/* Design tokens (from PRD "Prefered Colors")                       */
/* ---------------------------------------------------------------- */
:root {
  /* Raw palette names as-defined in PRD */
  --color-app-bg:            #DDF3FE; /* light blue background */
  --color-app-bg-2:          #A7E2FF; /* darker light blue */
  --color-menu-bg:           #000233; /* dark navy menu/header */
  --color-button-blue:       #0049B0; /* deep blue CTA */
  --color-white:             #FFFFFF;
  --color-icon-active:       #2980b9; /* active/icon blue */
  --color-status-ok:         #00FF01; /* status dot bright green */
  --color-green-dark:        #27ae60; /* success UI */
  --color-red:               #e74c3c; /* error / destructive */

  /* Lila companion for the "blue → lila" gradient that the PRD likes */
  --color-lila:              #7c3aed;

  /* Semantic tokens (derived) — use these in component styles */
  --color-text:              #0F172A;
  --color-text-muted:        #475569;
  --color-text-on-dark:      var(--color-white);
  --color-text-on-dark-mute: rgba(255, 255, 255, 0.72);

  --surface-card:            var(--color-white);
  --surface-card-hover:      #F1F9FF;
  --surface-selected:        var(--color-app-bg-2);
  --surface-selected-soft:   rgba(167, 226, 255, 0.45);
  --surface-input-dark:      rgba(255, 255, 255, 0.08);

  --border-subtle:           rgba(0, 36, 80, 0.10);
  --border-strong:           rgba(0, 36, 80, 0.22);
  --border-selected:         var(--color-button-blue);
  --border-on-dark:          rgba(255, 255, 255, 0.12);

  --shadow-card:             0 2px 8px rgba(0, 36, 80, 0.08);
  --shadow-card-hover:       0 6px 20px rgba(0, 36, 80, 0.15);
  --shadow-header:           0 2px 14px rgba(0, 2, 51, 0.35);

  /* Primary gradient: deep blue → lila (PRD preference).
     Use `--gradient-primary` on light surfaces (cards, light body bg)
     and `--gradient-primary-on-dark` on the dark navy header/menu,
     where the deep blue would otherwise blend into the background. */
  --gradient-primary:         linear-gradient(90deg, var(--color-button-blue), var(--color-lila));
  --gradient-primary-soft:    linear-gradient(90deg, rgba(0, 73, 176, 0.18), rgba(124, 58, 237, 0.18));
  --gradient-primary-on-dark: linear-gradient(90deg, #A7E2FF, #B79CFF);
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
