# Tests and Challenges

Inputs in PreTeXt converted to human readable forms (LaTeX, PDF, HTML)

Outputs as BRF and Unicode braille, labeled with software versions and dates

## Input format

All files are derived from PreTeXt source with skeleton structure

>    article
>      p
>        ol
>          li m LaTeX-here

Each piece of math is its own line: e.g. `<li><m>x^2</m></li>`.  No newlines, no extraneous spaces.

## IMPORTANT

When using PreTeXt to process these files, normally a solo "m" in an "li" will earn an automatic \displaystyle.  Since we would rather be explicit about that behavior, we have a `debug.displaystyle` undocumented string parameter which **must** be set to `no` for desired results.

### `aata-hard-math-201`

201 one-line expressions from Judson's [Abstract Algebra](http://abstract.ups.edu/), curated by Alexei Kolesnikov to avoid repetition and stress translation.

### `aata-unique-177`

177 one-line expressions from Judson's [Abstract Algebra](http://abstract.ups.edu/), algorithmically created by Alexei Kolesnikov to have each symbol once, avoid repetition, and keep expressions small.

### `acs-115`

115 one-line expressions from [Active Calculus (Single)](https://activecalculus.org/), algorithmically created by Alexei Kolesnikov to have each symbol once, avoid repetition, and keep expressions small.
