# Literate Specs

Specs under this folder are an experiment in literate specs: a series of essays, interspersed with tests,
that range from design documentation, to usage documentation, to functional probing both of Qig itself
and of downstream dependencies.

## Purpose / Audience

Each section starts off as a scratchpad for design exploration, and then matures towards documentation
as concepts crystalize to tame experimental chaos.

The audience in the design phase is clearly the feature designer (probably me; no outside contributors yet).

Who is the audience in the documentation phase? Is it users? Is it outside contributors? Is it future me?
I think ideally the audience is primarily users and sometimes outside contributors. Future me is a member
of both those audiences.

## Organizational Structure

As such they are structured differently than conventional rspec
- broken up by essay topic
  - trying to stick all the Qig-related essays in a single qig_spec.rb is unwieldy, so break this up
  - Some essay topics might be crosscutting concerns when viewed from a per-file perspective.
    (though this is more a theoretical concern at since the main Qig source is currently just one file.)
- loosely organized like chapters in a manual (and numbered to enable non-alphabetic ordering)
- all currently organized under the main qig module-- I don't expect literate specs to fully match source
  file structuring, but I don't expect them to fully mismatch either. Agreement at the module level feels
  like a happy and healthy balance.
  - Given the organization under the qig module, `qig_spec.rb` is the entry point or introductory chapter,
    and `qig/**_spec.rb` fill in the details on subtopics.

TODO: maybe I should look into cucumber's organizational conventions?
