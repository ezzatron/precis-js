fs = require 'fs'
UnicodeTrie = require 'unicode-trie'

CodepointPropertyReader = require '../../src/unicode/CodepointPropertyReader'
InvalidCodepointError = require '../../src/error/InvalidCodepointError'
Precis = require '../../src/constants'
PrecisPreparer = require '../../src/PrecisPreparer'

describe 'PrecisPreparer', ->

    before ->
        data = fs.readFileSync __dirname + '/../../data/properties.trie'
        @trie = new UnicodeTrie data

    beforeEach ->
        @propertyReader = new CodepointPropertyReader @trie
        @subject = new PrecisPreparer @propertyReader

    describe 'prepare()', ->

        it 'supports custom prepare logic', ->
            @profile = prepare: sinon.spy()
            @subject.prepare @profile, 'ab'

            sinon.assert.calledWith @profile.prepare, 'ab'

        it 'throws an error if the string class is not implemented', ->
            assert.throws (=> @subject.prepare stringClass: 111, ''), 'PRECIS string class not implemented.'

        describe 'for FreeformClass string class profiles', ->

            beforeEach ->
                @profile = stringClass: Precis.STRING_CLASS.FREEFORM

            it 'allows characters in the FreeformClass string class', ->
                assert.deepEqual @subject.prepare(@profile, ' !'), [0x0020, 0x0021]

            it 'rejects characters outside the FreeformClass string class', ->
                assert.throws (=> @subject.prepare @profile, "\u0000"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u007F"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u00B7"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u0378"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u200C"), InvalidCodepointError

        describe 'for IdentifierClass string class profiles', ->

            beforeEach ->
                @profile = stringClass: Precis.STRING_CLASS.IDENTIFIER

            it 'allows characters in the IdentifierClass string class', ->
                assert.deepEqual @subject.prepare(@profile, '!'), [0x0021]

            it 'rejects characters outside the IdentifierClass string class', ->
                assert.throws (=> @subject.prepare @profile, "\u0000"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u0020"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u007F"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u00B7"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u0378"), InvalidCodepointError
                assert.throws (=> @subject.prepare @profile, "\u200C"), InvalidCodepointError
