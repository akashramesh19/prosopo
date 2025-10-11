Prosopo — Persona Manager for iOS 

Prosopo helps users create, manage, and reuse AI personas with clean prompts. Built in SwiftUI with MVVM, SwiftData (local) + Firebase (cloud), plus networking, custom gestures, tests, DocC, widget etc.

Team & Repo:
- Student: Akash Ramesh — s4097941
- Repo
  URL: https://github.com/rmit-iPSE-s2-2025/a2-s4097941
- Miro Board: https://miro.com/app/board/uXjVJFPLrQU=/?share_link_id=224630235893

Data Overview:
SwiftData
- Draft Persona
  
UserDefault
- Favourite Persona
  
Firebase (The Google Info Plist is not committed to the repo)
- Users
- Persona

Using Public REST API:
In the context of the application, OpenAI API is used to generate prompts and JSONs for Creating a suggested persona.
The OpenAIClient in the app is used to map the response and gather the required elements based on OpenAI Developer specifications.
The API Key is hidden in the Secret.plist which is not commited to the Repo.

Simultaneous Gesture:
The below simultaneous gesture is applied to the application Persona tiles.
- The long press -> Brings dropdown menu to either copy prompt directly without opening the persona or set it as favourite.
- The double tap -> Brings Edit Persona Page directly.
- The triple tap -> Deletes the Persona with confirmation.

Widget:
The widget is work in progress still. The app group is not configurable due to lack of apple developer account.
The widget and the backend functionalities have been set up.
Widget working:
- Shows the favourite persona tile.
- When clicked copies the prompt to clipboard.

UIKit + SwiftUI Integration:
Share Sheet is introduced for this specification. Within the context of the application, this seemed the most logical use of UIKit.
The user is able to share personas using the Share Sheet that can be viewed in other IOS native apps.
Why this requires UIKit and not just SwiftUI:
- SwiftUI does not have an API that calls the native share sheet used in IOS apps. 
- To do this, UIActivityViewController (Part of UIKit) is required, hence why UIKit integration is required for this.

Moment to Shine Functionalities:
Use of LLM to suggest persona fields to the user based on user description.
Why this is not a simple call and response from ChatGPT:
- The response contains a JSON object.
- This is mapped to individual persona fields.
- The persona fields are then used to create the object and show the suggested fields to the user.
- When the user creates the persona, the persona object is created and stored to firebase cloud storage.
