---
name: LandTrackPK Sovereign System
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1b1b1b'
  on-surface-variant: '#414941'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#717970'
  outline-variant: '#c0c9be'
  surface-tint: '#326a40'
  primary: '#00290f'
  on-primary: '#ffffff'
  primary-container: '#01411c'
  on-primary-container: '#74ae7e'
  inverse-primary: '#99d5a2'
  secondary: '#5d5f5f'
  on-secondary: '#ffffff'
  secondary-container: '#dfe0e0'
  on-secondary-container: '#616363'
  tertiary: '#755b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a84c'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b4f1bc'
  primary-fixed-dim: '#99d5a2'
  on-primary-fixed: '#00210b'
  on-primary-fixed-variant: '#17512a'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c7'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#ffe08f'
  tertiary-fixed-dim: '#e6c364'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#584400'
  background: '#fcf9f8'
  on-background: '#1b1b1b'
  surface-variant: '#e5e2e1'
typography:
  display-lg:
    fontFamily: Source Serif 4
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Source Serif 4
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Source Serif 4
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Public Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Public Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Public Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  edge-margin: 20px
  gutter: 12px
---

## Brand & Style

The design system is engineered to evoke an immediate sense of institutional authority, permanence, and legal validity for the Pakistan Land Revenue department. The brand personality is **Sovereign, Transparent, and Secure**, aiming to transform complex bureaucratic processes into a dignified digital experience.

The design style is a hybrid of **Corporate Modern** and **Tactile Institutional**. It leverages the structural clarity of modern app design while integrating high-fidelity textures reminiscent of physical legal documents:
- **Authority:** Use of official seals, guilloché patterns (fine line-work), and watermark textures to signify authenticity.
- **Trust:** A focus on legibility and structured information hierarchies to reduce user anxiety regarding land titles.
- **Heritage:** Integration of subtle Pakistani geometric motifs and arabesque borders as container decorations to ground the digital product in the national identity.

## Colors

The palette is anchored by **Pakistan Government Green**, representing the state's authority. 
- **Primary (#01411C):** Reserved for headers, primary actions, and official branding elements.
- **Accent Gold (#C9A84C):** Used exclusively for "Verified" statuses, official seals, high-value borders, and certification emblems. It should never be used for primary interaction buttons to maintain its status as a mark of "Value."
- **Deep Charcoal (#1C1C1C):** Used for all primary body text to ensure maximum contrast and readability on mobile screens.
- **Backgrounds:** A very soft off-white/green tint (#F4F7F5) is used for the app canvas to reduce glare and differentiate from pure white "Document" cards.

## Typography

The system utilizes a dual-type approach to balance tradition with utility.
- **Source Serif 4:** Chosen for its authoritative, literary, and sturdy character. It is used for all "Title" and "Statement" elements to replicate the feel of printed official gazettes.
- **Public Sans:** A highly accessible, neutral typeface used for all functional data, forms, and body copy. It ensures clarity in data-heavy land record tables.

**Styling Rules:**
- Titles should use "Sentence case" to remain approachable yet formal.
- Labels for metadata (e.g., Khasra Number, Area) should be uppercase with slightly increased letter spacing to improve scannability.

## Layout & Spacing

The design system follows a **Fixed-Fluid Mobile Grid**. 
- **Grid Model:** 4-column layout for mobile devices with 20px side margins. 
- **Rhythm:** An 8px linear scale drives all padding and margins. 
- **Vertical Spacing:** Content groups (e.g., Land Details vs. Owner Details) are separated by 32px (xl) to ensure the interface feels airy and unhurried.
- **Safe Areas:** Adhere strictly to OS-level safe areas, ensuring primary navigation is always reachable within the "thumb zone."

## Elevation & Depth

Hierarchy in this design system is achieved through **Tonal Layering** and **Structural Outlines** rather than aggressive shadows.
- **The Document Layer:** Primary land records are presented on white cards with a 1px border (#E0E0E0). These cards use a very soft, large-radius shadow (Y: 4, Blur: 20, Opacity: 0.05) to appear as if "sitting" on the green-tinted background.
- **The Seal Layer:** Official stamps and gold "Verified" seals occupy the highest elevation, using a slight "pressed" or "embossed" effect via subtle inner shadows.
- **Backdrop:** Backgrounds should feature a faint, low-contrast watermark of the Government of Pakistan crest or a geometric arabesque pattern to prevent large empty spaces from looking "unfinished."

## Shapes

The shape language is **Structured and Traditional**.
- **Corner Radius:** A standard 4px (Soft) radius is applied to buttons and inputs to maintain a crisp, professional look that mirrors physical paper documents.
- **Certificate Cards:** Use an 8px radius for larger "Land Record" cards to provide a modern mobile feel while maintaining structural integrity.
- **Borders:** Containers for official data should use a "double-line" border style or a subtle geometric arabesque corner accent to reinforce the institutional aesthetic.

## Components

### Buttons
- **Primary:** Solid Pakistan Green (#01411C) with White text. Square or slightly rounded (4px).
- **Secondary:** White background with Green border and text.
- **Tertiary/Ghost:** Clear background with Green text for low-priority actions like "View History."

### Certificate Cards
Specialized containers for land records. They must feature:
- A gold accent border on the left or top.
- A subtle background watermark of the Land Revenue seal.
- A "Status Seal" in the top right corner (Gold for Verified, Red for Disputed).

### Input Fields
- Underlined or fully outlined with 1px Deep Charcoal. 
- Labels always visible above the input field (never floating) to maintain a formal form structure.

### Status Indicators (Stamps)
- Instead of simple chips, use "Stamp" style elements. These are circular or octagonal badges with high-contrast text and a border, resembling physical rubber stamps.

### Navigation
- A clean Bottom Navigation Bar with solid icons. Active states should use the Primary Green color with a small gold dot indicator below the icon.