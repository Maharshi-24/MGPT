class Changelog {
  final String version;
  final List<String> highlights;

  Changelog({required this.version, required this.highlights});
}

final List<Changelog> changelogData = [
  Changelog(
    version: "1.0.7",
    highlights: [
      "Added the audio recording feature.",
      "Added a bubble which will indicate recording.",
      "Gave permission for audio and battery saver."
      "Added file picker."
    ],
  ),
  Changelog(
    version: "1.0.65",
    highlights: [
      "Replaced the button in the login with the slider.",
      "Added image upload feature."
    ],
  ),
  Changelog(
    version: "1.0.6",
    highlights: [
      "Added Notifications.",
      "Added a manual push notification button.",
      "Added ask permission for notifications.",
      "Added more haptics.",
      "Added scheduled notifications."
    ],
  ),
  Changelog(
    version: "1.0.55",
    highlights: [
      "Added new Font style.",
      "Rendered end point for stop."
    ],
  ),
  Changelog(
    version: "1.0.5",
    highlights: [
      "Updated the texts in the Login Page and Signup Page.",
      "Added the stop button.",
      "Added the stop button logic and stop streaming logic.",
      "Added slide feature for change log.",
      "Added the change log screen for the updates."
    ],
  ),
  Changelog(
    version: "1.0.4",
    highlights: [
      "Added authentication logic.",
      "Applied additional fixes.",
      "Completed the design for login and signup (P-1).",
      "Added custom links functionality.",
      "Implemented haptic feedback.",
      "Fixed issues with the drawer.",
      "Added the logo to the app.",
      "Renamed components for better clarity.",
      "Fixed bugs and various issues."
    ],
  ),
  Changelog(
    version: "1.0.3",
    highlights: [
      "Changed the app name.",
      "Fixed issues related to transparency.",
      "Added a splash screen.",
      "Updated tap animations.",
      "Added enhanced animations for the thinking state.",
      "Fixed various bugs.",
      "Added 'view password' functionality.",
      "Applied justified text formatting.",
      "Updated chat input style to resemble GPT.",
      "Added a settings page.",
      "Changed the icons for improved design.",
      "Added the render route.",
      "Completed P-1 tasks."
    ],
  ),
  Changelog(
    version: "1.0.2",
    highlights: [
      "Created a simple drawer UI.",
      "Added features to the drawer.",
      "Organized the file system.",
      "Completed basic drawer structure.",
      "Removed unnecessary clutter.",
      "Added enhanced animations for the thinking state.",
      "Updated tap animations.",
      "Implemented stream output.",
      "Added animations for streamed output.",
      "Added new scroll logic.",
      "Implemented the triple dots feature.",
      "Perfected the icons.",
      "Added a long press container.",
      "Improved the app's performance.",
      "Created a non-functional edit component.",
      "Fixed the tap effect.",
      "Added internet access functionality."
    ],
  ),
  Changelog(
    version: "1.0.1",
    highlights: [
      "Made the app functional.",
      "Implemented thinking and scroll-to-bottom features.",
      "Added style to the output text.",
      "Made slight improvements to the UI.",
      "Organized the code structure.",
      "Enhanced visuals for the chat bubbles.",
      "Handled most symbols.",
      "Improved the UI to resemble ChatGPT.",
      "Renamed components for better clarity.",
      "Added memory functionality.",
      "Implemented focus feature.",
      "Added a scroll-to-bottom button.",
      "Fixed the logo.",
      "Fixed the chat bubble.",
      "Added text when there is no chat and also included two URLs: one for hotspot and one for home wifi."
    ],
  ),
  Changelog(
    version: "1.0.0",
    highlights: [
      "Created the MGPT",
      "Created the basic UI."
      "Made the app locally functional.",
    ],
  ),
];
