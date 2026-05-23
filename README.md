# EPBBCode

*Expanding how RichText is used in Polytoria.*

## What is EPBBCode?

EPBBCode stands for "Expanded Polytoria BBCode", meant to be an expansion of what you can do with RichText in Polytoria.

EPBBCode is written purely in Luau, follows an OOP paradigm for ease of use, and aims to reduce complexity for the developer as much as possible.

## What does EPBBCode do?

EPBBCode is primarily designed for making unique dialogue boxes from NPCs, *(which is the main purpose as to why I started this project)*, but also can be used to display text in a way that you originally wouldn't be able to.

Some things that EPBBCode can do, which regular BBCode cannot:
- Display images from Polytoria's Community Creations.
- Display images in sequence, with arguments to enable / disable looping.
- Make specific letters or chunks of text tween to specified Vector2s, with arguments to enable looping and such.
- Apply gradients to letters or chunks of text.

Some extra things that EPBBCode supports and allows you to do:
- Add a string of text that has format tags to a UILabel's textbox in a stream, similar to how story-based games append text letter-by-letter *(this is called "Typewriter Output")*. Typewriter output has some extra tags that it supports, which isn't allowed to regular EPBBCode.
  - Attach functions and events to a piece of text.
  - Abruptly clearing text but continuing appending.
  - Pausing and starting streaming.
  - Slowing down text streaming for a specific segment.
  - Playing a sound when a letter is output.
  - Outputting all text when pressing a specific key *(for skipping dialogue)*.

## EPBBCode Progress

- [x] Class Framework
- [ ] Typewriter & Regular output to a UILabel
- [ ] Custom tag parsing
- [ ] Event & Function tags
- [ ] Gradient colors for letters & text
- [ ] Animation tags for letters & text
- [ ] Image tags in regular & Typewriter output

## Notes

PRs are not yet supported. After I finish adding custom tag parsing I'll add a contributing guide to the repository.

A wiki is in the works.

Note that this is my first open-source polytoria project, and that Luau is not my area of expertise, so if you find any performance issues or any bugs that I can fix, please open an issue on the issue tracker.

---
*Artificial Intelligence / LLM (Large Language Model) generated content was not used in the making of this project.*