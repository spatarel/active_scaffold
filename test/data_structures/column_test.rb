require 'test_helper'

class ColumnTest < ActiveSupport::TestCase
  def setup
    @column = ActiveScaffold::DataStructures::Column.new(:a, ModelStub)
    @association_col = ActiveScaffold::DataStructures::Column.new(:b, ModelStub)
    @association_col.stubs(:polymorphic_association?).returns(false)
    @association_col.stubs(association: stub(polymorphic?: false))
  end

  def test_column
    assert @column.column.is_a?(ActiveRecord::ConnectionAdapters::Column)
    assert_equal @column.column.name, 'a'
  end

  def test_basic_properties
    # test that it was set during initialization
    assert_equal @column.name, :a

    # label
    @column.label = 'foo'
    assert_equal 'foo', @column.label

    # description
    @column.description = 'hello world'
    assert_equal 'hello world', @column.description

    # css class
    @column.css_class = 'style_me'
    assert_equal 'style_me', @column.css_class

    # required
    assert_not @column.required?, 'default is false'
    @column.required = true
    assert @column.required?, 'can be changed'

    # calculation
    assert_not @column.calculation?, 'default is nil'
    @column.calculate = :sum
    assert @column.calculation?, 'can be changed'
  end

  def test_field
    assert_equal '"model_stubs"."a"', @column.send(:field)
  end

  def test_table
    assert_equal 'model_stubs', @column.send(:table)
  end

  def test_equality
    # create a separate columns object, and make sure it's not ==
    columns = ActiveScaffold::DataStructures::Columns.new(ModelStub, :a, :b)
    assert_not_equal columns, @column

    # create a separate action_columns object, and make sure it's not ==
    columns = ActiveScaffold::DataStructures::ActionColumns.new(:a, :b)
    assert_not_equal columns, @column

    # identity
    assert_equal @column, @column

    # string comparison
    assert_equal @column, 'a'
    assert_not_equal @column, 'fake'

    # symbol comparison
    assert_equal @column, :a
    assert_not_equal @column, :fake

    # comparison with different object of same type
    column2 = ActiveScaffold::DataStructures::Column.new(:fake, ModelStub)
    assert_not_equal @column, column2
    column2 = ActiveScaffold::DataStructures::Column.new(:a, ModelStub)
    assert_equal @column, column2

    # special comparisons
    assert_not @column.nil?
    assert_not_equal @column, ''
    assert_not_equal @column, 0
  end

  def test_ui
    assert_nil @column.form_ui
    assert_nil @column.list_ui
    assert_nil @column.search_ui
    assert_equal :select, @association_col.search_ui

    @column.form_ui = :calendar
    assert_equal :calendar, @column.form_ui
    assert_equal :calendar, @column.list_ui
    assert_equal :calendar, @column.search_ui

    @association_col.form_ui = :record_select
    assert_equal :record_select, @association_col.form_ui
    assert_equal :record_select, @association_col.search_ui

    @column.search_ui = :record_select
    @column.list_ui = :checkbox
    assert_equal :calendar, @column.form_ui
    assert_equal :checkbox, @column.list_ui
    assert_equal :record_select, @column.search_ui
  end

  def test_searchable
    @column.search_sql = nil
    assert_not @column.searchable?
    @column.search_sql = true
    assert @column.searchable?
  end

  def test_sortable
    @column.sort = nil
    assert_not @column.sortable?
    @column.sort = true
    assert @column.sortable?
  end

  def test_custom_search
    @column.search_sql = true
    assert_equal ['"model_stubs"."a"'], @column.search_sql
    @column.search_sql = 'foobar'
    assert_equal ['foobar'], @column.search_sql
    assert @column.searchable?
  end

  def test_custom_sort
    @column.sort = true
    hash = {sql: '"model_stubs"."a"'}
    assert_equal hash, @column.sort
    @column.sort_by sql: 'foobar'
    hash = {sql: 'foobar'}
    assert_equal hash, @column.sort

    some_proc = proc { 'foobar' }
    @column.sort_by method: some_proc
    hash = {method: some_proc}
    assert_equal hash, @column.sort
    assert @column.sortable?
  end

  def test_custom_sort__should_assert_keys
    assert_raises(ArgumentError) { @column.sort_by proc: 'invalid config'  }
    assert_raises(ArgumentError) { @column.sort = {proc: 'invalid config'} }
    assert_equal({method: 'method'}, @column.sort_by(method: 'method'))
    assert_equal({sql: 'method'}, @column.sort_by(sql: 'method'))
  end

  def test_config_block
    @column.configure do |config|
      # we can use the config object
      config.form_ui = :select
      # or not
      self.label = 'hello'
    end

    assert_equal :select, @column.form_ui
    assert_equal 'hello', @column.label
  end

  def test_action_link
    link = ActiveScaffold::DataStructures::ActionLink.new('foo/bar')
    @column.set_link link
    assert_equal link, @column.link

    @column.set_link 'hello_world'
    assert_equal 'hello_world', @column.link.action
    assert_equal @column.label, @column.link.label
  end

  def test_includes
    assert_nil @column.includes

    # make sure that when a non-array comes in, an array comes out
    @column.includes = :column_name
    assert_equal([:column_name], @column.includes)

    # make sure that when a non-array comes in, an array comes out
    @column.includes = [:column_name]
    assert_equal([:column_name], @column.includes)

    # make sure that when a non-array comes in, an array comes out
    @column.includes = nil
    assert_nil @column.includes
  end
end
