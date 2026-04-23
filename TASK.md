# Aufgabenstellung

Der Vertrieb hat eine Anfrage erhalten, dazu ein kurzes Telefonat mit dem
Kunden geführt, die angesprochenen Punkte notiert (s. u.) und an dich
geschickt.

Basierend auf diesen Informationen ist ein Kundentermin (max. 15–20 min)
geplant, den du abhalten sollst. Ob du eine fertige/ausbaufähige Lösung,
ein Mock, ein Vorgehensmodell o. Ä. vorstellst, kann von dir entschieden
und gestaltet werden. Im Interview befinden wir uns im letzten Dry-Run
vor dem Kundentermin, in dem du uns deinen Lösungsansatz vorstellst.

## Aufgabe

Es soll ein **KFZ-Konfigurator** (Webapplikation) entwickelt werden,
welcher die Konfiguration eines Autos mit den folgenden Optionen
ermöglicht:

- Motorleistung
- Lackierung
- Felgen
- Sonderausstattungen (max. 5 Stück, z. B. Klimaanlage, Soundsystem,
  Fahrsicherheitssysteme etc.)

## Funktionale Anforderungen

1. Jede Veränderung an der Konfiguration soll sich **unmittelbar** und
   ohne einen Page-Refresh auf den angezeigten Preis auswirken.
2. Am Ende der Konfiguration soll eine **Zusammenfassung** angezeigt und
   die **Bestellung abgesendet** werden können.
3. Es soll eine **URL** generiert werden, mit der der Benutzer jederzeit
   Zugriff auf die gewählte Konfiguration hat.
4. Sowohl die Konfigurationseigenschaften als auch die Bestellungen sind
   in einer **Datenbank** zu speichern.

Als Hilfestellung zum Design und zur Benutzerführung können die
zahlreichen am Markt verfügbaren Konfiguratoren als Orientierung dienen.
Die Implementierung einer Authentifizierungs- bzw. Autorisierungslogik
für Anwender ist **nicht erforderlich**.

## Technischer Rahmen

- **Frontend** auf Basis von wahlweise Vue.js, React oder Angular
- **Backend** (Services) auf Basis von .NET oder Java
- **Betrieb** wahlweise Serverless, Container oder Webserver, gerne
  auch in der Cloud

## CI/CD

Gerne würde der Kunde eine **funktionierende CI/CD-Pipeline** sehen,
die einen Code-Change auf das Zielsystem deployed.

## Umsetzung

### 1. Avoiding Page Refresh

- Reactive computation in `frontend/src/pages/Configurator.vue`
  (lines 245–272) — the total price is a Vue computed property
  derived from the already-loaded catalog data.
- No network traffic on every click (verifiable via Chrome DevTools
  → Network tab).
- Once the user presses **Continue to Summary**, the backend
  recomputes the authoritative total in
  `backend/src/main/java/com/configurator/service/ConfiguratorService.java`.

### 2. Click on *Continue to Summary*

- `Configurator.vue` → `saveAndContinue()`
  (`frontend/src/pages/Configurator.vue`, lines 361–364).
- Calls `saveConfiguration()` in `frontend/src/services/api.js`
  (lines 13–20), which issues
  `POST /api/configurations`.
- Backend `ConfiguratorService.saveConfiguration()` persists the
  configuration with a generated **UUID**.
- Frontend router navigates to `/summary/:id`, which renders
  `Summary.vue`.
- The UUID in the URL is the shareable link to the configuration
  (Requirement 3).

### 3. Click on *Submit Order*

- `Summary.vue` → `submitOrder()` (lines 179–186).
- Calls `createOrder()` in `frontend/src/services/api.js`
  (lines 28–35), which issues `POST /api/orders`.
- Backend `ConfiguratorService.createOrder()` (lines 146–158)
  **recomputes the price server-side** and persists the order in a
  single `@Transactional` unit.

### 4. Database Design

- `configurations` — separate MySQL table holding the chosen options
  per configuration (UUID primary key, FKs to each catalog table).
- `configuration_equipment` — join table for the N:M relation to
  special equipment.
- `orders` — separate MySQL table referencing a configuration plus
  customer data and the price snapshot at submission time.
