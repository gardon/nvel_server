# Nvel

This is a project to create a powerful delivery tool for digital graphic novels by leveraging a decoupled Drupal 8 as the content backend and an ELM frontend app.

The goals for this system are:
- Provide a system that can be used to quickly publish simple comics (images) as a backward compatibility while providing a more extense system of breaking the structure into individual panels with text data.
- Provide optimal experience for mobile readers
- Be accessible (vision-impaired etc). Indivudal panels with "alt" text and text bubbles with actual text in the markup will make content readable in the most various forms.
- Be fast. By rendering panels individually and lazy loading them while using SVG libraries to render text baloons (with real text) it is possible to process images to smaller size while reading is not compromised. It also can be better styled for mobiles.
