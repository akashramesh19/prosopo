# ``ProsopoApp``

Prosopo helps you create, edit, and use reusable AI personas in a SwiftUI app.  
It is structured with **Data**, **Model**, **Service**, **View**, and **ViewModel** layers for clarity.

## Overview

Prosopo centralizes persona prompts and keeps tone/temperature consistent across views.  
The app uses SwiftUI for presentation and Firestore for persistence.

### Architecture

- **Data**  
  Utility classes such as ``BaseTemperatureMap`` and ``DraftRepository``.

- **Model**  
  Core data models like ``Persona`` and ``PersonaTone`` that represent the persona entity.

- **Service**  
  Business logic and integration, including ``OpenAIClient``, ``PersonaService``, and ``PromptService``.

- **View**  
  SwiftUI views that render UI: ``HomeView``, ``PersonaView``, ``EditPersonaView``, ``AddPersonaView``, and ``DrawerMenuView``.

- **ViewModel**  
  State management and bindings for the views, e.g. ``AuthViewModel``, ``AddPersonaModel``, ``EditPersonaModel``, and ``HomeListModel``.

### Topics
- <doc:PersonasOverview>
- ``Persona``
- ``PersonaTone``
- ``DraftPersona``
- ``BaseTemperatureMap``
- ``OpenAIClient``
- ``PersonaService``
- ``PromptService``
- ``AuthViewModel``
- ``AddPersonaModel``
- ``EditPersonaModel``
- ``HomeListModel``
- ``HomeView``
- ``PersonaView``
- ``EditPersonaView``
- ``AddPersonaView``
- ``DrawerMenuView``
