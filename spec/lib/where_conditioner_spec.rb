require 'spec_helper'

describe WhereConditioner do
  let(:relation) { ActiveRecord::Relation.new }

  describe '#where_if_present' do
    context 'with a parameterized SQL string' do
      it 'calls where() if all values are present' do
        expect(relation).to receive(:where).with('version BETWEEN ? AND ?', 1, 2)
        relation.where_if_present('version BETWEEN ? AND ?', 1, 2)
      end

      it 'does not call where(), and returns self, if some values are missing' do
        expect(relation).not_to receive(:where)
        expect(relation.where_if_present('version BETWEEN ? AND ?', nil, 2)).to eq relation
      end
    end

    context 'with a hash' do
      it 'calls where() with all non-nil values' do
        expect(relation).to receive(:where).with(key1: '', key3: 'value', key4: 0)
        relation.where_if_present(key1: '', key2: nil, key3: 'value', key4: 0)
      end

      it 'filters out nils in nested hashes' do
        expect(relation).to receive(:where).with(table1: { key1: '', key3: 'value', key4: 0 }, table3: { key6: 'value' })
        relation.where_if_present(table1: {key1: '', key2: nil, key3: 'value', key4: 0}, table2: {key5: nil}, table3: {key6: 'value'})
      end

      it 'does not call where(), and returns self, if all values are nil' do
        expect(relation).not_to receive(:where)
        relation.where_if_present(key1: nil, key2: nil)
      end
    end
  end

  describe '#if' do
    context 'chained' do
      context 'with true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:foo, :bar)
          relation.if(true).foo.bar
        end
      end

      context 'with false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:bar)
          relation.if(false).foo.bar
        end
      end
    end

    context 'with a block' do
      context 'with true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:foo, :bar, :baz)
          relation.if(true) { foo.bar }.baz
        end
      end

      context 'with false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:baz)
          relation.if(false) { foo.bar }.baz
        end
      end
    end
  end

  describe '#unless' do
    context 'chained' do
      context 'with true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:bar)
          relation.unless(true).foo.bar
        end
      end

      context 'with false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:foo, :bar)
          relation.unless(false).foo.bar
        end
      end
    end

    context 'with a block' do
      context 'with true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:baz)
          relation.unless(true) { foo.bar }.baz
        end
      end

      context 'with false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:foo, :bar, :baz)
          relation.unless(false) { foo.bar }.baz
        end
      end
    end
  end

  describe '#else' do
    context 'chained' do
      context 'with true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:baz)
          relation.if(true).foo.else.bar.baz
        end
      end

      context 'with false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:bar, :baz)
          relation.if(false).foo.else.bar.baz
        end
      end
    end

    context 'with a block' do
      context 'with true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:moop)
          relation.if(true).foo.else { bar.baz }.moop
        end
      end

      context 'with false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:bar, :baz, :moop)
          relation.if(false).foo.else { bar.baz }.moop
        end
      end
    end
  end

  describe '#elsif' do
    context 'chained' do
      context 'with true, true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:baz)
          relation.if(true).foo.elsif(true).bar.baz
        end
      end

      context 'with false, true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:bar, :baz)
          relation.if(false).foo.elsif(true).bar.baz
        end
      end

      context 'with false, false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:baz)
          relation.if(false).foo.elsif(false).bar.baz
        end
      end

      context 'with true, false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:baz)
          relation.if(true).foo.elsif(false).bar.baz
        end
      end

      context 'with multiple elsifs' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:bar)
          relation.if(true).foo.elsif(false).bad.elsif(true).other_bad.else.really_bad.bar
        end
      end

      context 'with an else clause' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:bar)
          relation.if(true).foo.elsif(false).bad.elsif(false).other_bad.else.really_bad.bar
        end
      end
    end

    context 'with a block' do
      context 'with true, true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:moop)
          relation.if(true).foo.elsif(true) { bar.baz }.moop
        end
      end

      context 'with false, true condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive_message_chain(:bar, :baz, :moop)
          relation.if(false).foo.elsif(true) { bar.baz }.moop
        end
      end

      context 'with false, false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:moop)
          relation.if(false).foo.elsif(false) { bar.baz }.moop
        end
      end

      context 'with true, false condition' do
        it 'passes method calls to relation' do
          expect(relation).to receive(:foo).and_return(relation)
          expect(relation).to receive(:moop)
          relation.if(true).foo.elsif(false) { bar.baz }.moop
        end
      end
    end
  end
end
