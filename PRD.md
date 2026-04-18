# Prototyp KFZ Konfigurator

## Überblick

Es soll ein KFZ-Konfigurator (Webapplikation) entwickelt werden, welcher die Konfiguration eines Autos mit den folgenden Optionen ermöglicht:

- Motorleistung
- Lackierung
- Felgen
- Sonderausstattungen (max. 5 Stück, z.B. Klimaanlage, Soundsystem, Fahrsicherheitssysteme etc.)

## Funktionale Anforderungen

Jede Veränderung an der Konfiguration soll sich unmittelbar und ohne einen Page-Refresh auf den angezeigten Preis auswirken.

Am Ende der Konfiguration soll eine Zusammenfassung angezeigt und die Bestellung abgesendet werden können.

Zudem soll eine URL generiert werden, mit der der Benutzer jederzeit Zugriff auf die gewählte Konfiguration hat.

Sowohl die Konfigurationseigenschaften als auch die Bestellungen sind in einer Datenbank zu speichern.

Als Hilfestellung zum Design und zur Benutzerführung können die zahlreichen am Markt verfügbaren Konfiguratoren als Orientierung dienen.

Die Implementierung einer Authentifizierungs- bzw. Authorisierungslogik für Anwender ist nicht erforderlich.

## Technischer Rahmen

- **Frontend:** Vue.js, React oder Angular
- **Backend (Services):** .NET oder Java
- **Betrieb:** Serverless, Container oder Webserver (gerne auch in der Cloud)

## CI/CD

Gerne würde der Kunde eine funktionierende CI/CD-Pipeline sehen, die einen Code-Change auf das Zielsystem deployed.
