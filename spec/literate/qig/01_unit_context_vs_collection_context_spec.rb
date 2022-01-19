# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  context 'unit-context vs collection-context' do
    # When working with qig, it's useful to bring in a concept of "unit-context" vs "collection-context".
    # That is: whether qig treats the input to each navigation step as a unit, or as a collection.
    #
    # qig needs this to resolve a fundamental operating difference between dig and jq:
    # dig operates purely on single elements, while jq operates purely on collections of elements.
    # - even when dig is operating on an array, it can index into that array,
    #   but can't map an indexing operation across the underlying elements. It's treating
    #   the array as a single element.
    # - jq's collection is the top-level element stream (as opposed to any individual array).
    #   By the nature of streaming, even when jq is just working with a single element we can
    #   consider it to be working with a collection of one element.
    #
    # This puts peculiar constraints on qig's return type and navigation operations:
    # - jq-like usages require results wrapped in a collection to allow multiple values,
    #   whereas dig-like usages benefit from the ability to return a single value
    #   without a pesky enclosing collection.
    # - when working with arrays, dig-like usages must apply navigation to the top-level
    #   array, whereas jq-like usages need a way to map navigation across a collection.
    #
    # qig solves this by keeping track internally of "unit-context" vs "collection-context".
    # - In unit context, qig treats the input to each step as a _unit_ subject, and uses
    #   dig-like behavior:
    #   - navigation operations apply directly to the top-level
    #   - return value is a unit: its the raw value we dug up, unencpsulated
    # - In collection context, qig treats the input to each step as a _collection_ of subjects, and uses
    #   jq-like behavior:
    #   - navigation operations map across the elements of the top-level collection, one level deep
    #   - return values are encapsulated in a collection (even if there is only one return value)
    #
    # Qig follows simple rules to determine context:
    # - qig always starts in unit-context (always start off assuming the input is an atomic subject)
    # - qig switches to collection-context upon [] (read: "value iteration").
    #
    # This strives for good balance between flexibility and usability:
    # - unit-context retains the intuitive feel of dig-like usage
    # - switching to collection-context is short, explicit, and sticks to jq semantics.

    context 'qig always starts in unit context' do
      it 'treats initial input as a unit, even when that input is an array' do
        expect(Qig.qig([[1, 2], [3, 4]], 0)).to eq([1, 2])
        expect(Qig.qig([[1, 2], [3, 4]], 0)).to eq([1, 2])
      end
    end

    context 'qig switches to collection context upon first invocation of []' do
      # this can produce some counterintuitive results

      specify 'first [] looks like a no-op' do
        expect(Qig.qig([1, 2, 3], [])).to eq([1, 2, 3])
      end

      specify 'multi-navigation always requires a leading []'

      # but this provides low-cost flexibility, and provides the caller explicit control.

      specify 'first [] looks like a no-op in isolation, but qig updated its internal state' do
        # these look the same on the surface...

        expect(Qig.qig([[1, 2], [3, 4]])).to eq([[1, 2], [3, 4]])
        expect(Qig.qig([[1, 2], [3, 4]], [])).to eq([[1, 2], [3, 4]])

        # but the difference is apparent one step further in

        expect(Qig.qig([[1, 2], [3, 4]], 0)).to eq([1, 2])
        expect(Qig.qig([[1, 2], [3, 4]], [], 0)).to eq([1, 3])
      end

      specify 'the leading [] explicitly disambiguates multi-navigation vs direct-indexing'

      # additionally...

      specify 'qig will preserve the type of the outer collection if possible'
    end

    # TODO: move to Decision Record
    #
    # # Alternatives
    #
    # Qig could decide to act like jq, and just treat all inputs as collections and always return
    # a collection. This has two downsides:
    # 1. It makes the dig-like usages less ergonomic (though arguably callers could just switch to dig in those cases)
    # 2. It likely eliminates the ability to dig into top-level arrays, since we'd probably assume these are top-level.
  end
end
