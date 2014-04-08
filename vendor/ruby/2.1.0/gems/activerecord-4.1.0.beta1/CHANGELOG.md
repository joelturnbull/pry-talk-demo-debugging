*   `Relation` no longer has mutator methods like `#map!` and `#delete_if`. Convert
    to an `Array` by calling `#to_a` before using these methods.

    It intends to prevent odd bugs and confusion in code that call mutator
    methods directly on the `Relation`.

    Example:

        # Instead of this
        Author.where(name: 'Hank Moody').compact!

        # Now you have to do this
        authors = Author.where(name: 'Hank Moody').to_a
        authors.compact!

    *Lauro Caetano*

*   Better support for `where()` conditions that use a `belongs_to`
    association name.

    Using the name of an association in `where` previously worked only
    if the value was a single `ActiveRecord::Base` object. e.g.

        Post.where(author: Author.first)

    Any other values, including `nil`, would cause invalid SQL to be
    generated. This change supports arguments in the `where` query
    conditions where the key is a `belongs_to` association name and the
    value is `nil`, an `Array` of `ActiveRecord::Base` objects, or an
    `ActiveRecord::Relation` object.

        class Post < ActiveRecord::Base
          belongs_to :author
        end

    `nil` value finds records where the association is not set:

        Post.where(author: nil)
        # SELECT "posts".* FROM "posts" WHERE "posts"."author_id" IS NULL

    `Array` values find records where the association foreign key
    matches the ids of the passed ActiveRecord models, resulting
    in the same query as `Post.where(author_id: [1,2])`:

        authors_array = [Author.find(1), Author.find(2)]
        Post.where(author: authors_array)
        # SELECT "posts".* FROM "posts" WHERE "posts"."author_id" IN (1, 2)

    `ActiveRecord::Relation` values find records using the same
    query as `Post.where(author_id: Author.where(last_name: "Emde"))`

        Post.where(author: Author.where(last_name: "Emde"))
        # SELECT "posts".* FROM "posts"
        # WHERE "posts"."author_id" IN (
        #   SELECT "authors"."id" FROM "authors"
        #   WHERE "authors"."last_name" = 'Emde')

    Polymorphic `belongs_to` associations will continue to be handled
    appropriately, with the polymorphic `association_type` field added
    to the query to match the base class of the value. This feature
    previously only worked when the value was a single `ActveRecord::Base`.

        class Post < ActiveRecord::Base
          belongs_to :author, polymorphic: true
        end

        Post.where(author: Author.where(last_name: "Emde"))
        # Generates a query similar to:
        Post.where(author_id: Author.where(last_name: "Emde"), author_type: "Author")

    *Martin Emde*

*   Respect temporary option when dropping tables with MySQL.

    Normal DROP TABLE also works, but commits the transaction.

        drop_table :temporary_table, temporary: true

    *Cody Cutrer*

*   Add option to create tables from a query.

        create_table(:long_query, temporary: true,
          as: "SELECT * FROM orders INNER JOIN line_items ON order_id=orders.id")

    Generates:

        CREATE TEMPORARY TABLE long_query AS
          SELECT * FROM orders INNER JOIN line_items ON order_id=orders.id

    *Cody Cutrer*

*   `db:test:clone` and `db:test:prepare` must load Rails environment.

    `db:test:clone` and `db:test:prepare` use `ActiveRecord::Base`. configurations,
    so we need to load the Rails environment, otherwise the config wont be in place.

    *arthurnn*

*   Use the right column to type cast grouped calculations with custom expressions.

    Fixes #13230.

    Example:

        # Before
        Account.group(:firm_name).sum('0.01 * credit_limit')
        # => { '37signals' => '0.5' }

        # After
        Account.group(:firm_name).sum('0.01 * credit_limit')
        # => { '37signals' => 0.5 }

    *Paul Nikitochkin*

*   Polymorphic `belongs_to` associations with the `touch: true` option set update the timestamps of
    the old and new owner correctly when moved between owners of different types.

    Example:

        class Rating < ActiveRecord::Base
          belongs_to :rateable, polymorphic: true, touch: true
        end

        rating = Rating.create rateable: Song.find(1)
        rating.update_attributes rateable: Book.find(2) # => timestamps of Song(1) and Book(2) are updated

    *Severin Schoepke*

*   Improve formatting of migration exception messages: make them easier to read
    with line breaks before/after, and improve the error for pending migrations.

    *John Bachir*

*   Fix `last` with `offset` to return the proper record instead of always the last one.

    Example:

        Model.offset(4).last
        # => returns the 4th record from the end.

    Fixes #7441.

    *kostya*, *Lauro Caetano*

*   `type_to_sql` returns a `String` for unmapped columns. This fixes an error
    when using unmapped array types in PG

    Example:

        change_colum :table, :column, :bigint, array: true

    Fixes #13146.

    *Jens Fahnenbruck*, *Yves Senn*

*   Fix `QueryCache` to work with nested blocks, so that it will only clear the existing cache
    after leaving the outer block instead of clearing it right after the inner block is finished.

    *Vipul A M*

*   The ERB in fixture files is no longer evaluated in the context of the main
    object. Helper methods used by multiple fixtures should be defined on the
    class object returned by `ActiveRecord::FixtureSet.context_class`.

    *Victor Costan*

*   Previously, the `has_one` macro incorrectly accepted the `counter_cache`
    option, but never actually supported it. Now it will raise an `ArgumentError`
    when using `has_one` with `counter_cache`.

    *Godfrey Chan*

*   Implement `rename_index` natively for MySQL >= 5.7.

    *Cody Cutrer*

*   Fix bug when validating the uniqueness of an aliased attribute.

    Fixes #12402.

    *Lauro Caetano*

*   Update counter cache on a `has_many` relationship regardless of default scope.

    Fix #12952.

    *Uku Taht*

*   `rename_index` adds the new index before removing the old one. This allows to
    rename indexes on columns with a foreign key and prevents the following error:

        Cannot drop index 'index_engines_on_car_id': needed in a foreign key constraint

    *Cody Cutrer*, *Yves Senn*

*   Raise `ActiveRecord::RecordNotDestroyed` when a replaced child marked with `dependent: destroy` fails to be destroyed.

    Fix #12812

    *Brian Thomas Storti*

*   Fix validation on uniqueness of empty association.

    *Evgeny Li*

*   Make `ActiveRecord::Relation#unscope` affect relations it is merged in to.

    *Jon Leighton*

*   Use strings to represent non-string `order_values`.

    *Yves Senn*

*   Checks to see if the record contains the foreign key to set the inverse automatically.

    *Edo Balvers*

*   Added `ActiveRecord::Base.to_param` for convenient "pretty" URLs derived from a model's attribute or method.

    Example:

        class User < ActiveRecord::Base
          to_param :name
        end

        user = User.find_by(name: 'Fancy Pants')
        user.id       # => 123
        user.to_param # => "123-fancy-pants"

    *Javan Makhmali*

*   Added `ActiveRecord::Base.no_touching`, which allows ignoring touch on models.

    Example:

        Post.no_touching do
          Post.first.touch
        end

    *Sam Stephenson*, *Damien Mathieu*

*   Prevent the counter cache from being decremented twice when destroying
    a record on a `has_many :through` association.

    Fixes #11079.

    *Dmitry Dedov*

*   Unify boolean type casting for `MysqlAdapter` and `Mysql2Adapter`.
    `type_cast` will return `1` for `true` and `0` for `false`.

    Fixes #11119.

    *Adam Williams*, *Yves Senn*

*   Fix bug where `has_one` association record update result in crash, when replaced with itself.

    Fixes #12834.

    *Denis Redozubov*, *Sergio Cambra*

*   Log bind variables after they are type casted. This makes it more
    transparent what values are actually sent to the database.

        irb(main):002:0> Event.find("im-no-integer")
        # Before: ... WHERE "events"."id" = $1 LIMIT 1  [["id", "im-no-integer"]]
        # After: ... WHERE "events"."id" = $1 LIMIT 1  [["id", 0]]

    *Yves Senn*

*   Fix uninitialized constant `TransactionState` error when `Marshall.load` is used on an Active Record result.

    Fixes #12790.

    *Jason Ayre*

*   `.unscope` now removes conditions specified in `default_scope`.

    *Jon Leighton*

*   Added `ActiveRecord::QueryMethods#rewhere` which will overwrite an existing, named where condition.

    Examples:

        Post.where(trashed: true).where(trashed: false)                       #=> WHERE `trashed` = 1 AND `trashed` = 0
        Post.where(trashed: true).rewhere(trashed: false)                     #=> WHERE `trashed` = 0
        Post.where(active: true).where(trashed: true).rewhere(trashed: false) #=> WHERE `active` = 1 AND `trashed` = 0

    *DHH*

*   Extend `ActiveRecord::Base#cache_key` to take an optional list of timestamp attributes of which the highest will be used.

    Example:

        # last_reviewed_at will be used, if that's more recent than updated_at, or vice versa
        Person.find(5).cache_key(:updated_at, :last_reviewed_at)

    *DHH*

*   Added `ActiveRecord::Base#enum` for declaring enum attributes where the values map to integers in the database, but can be queried by name.

    Example:

        class Conversation < ActiveRecord::Base
          enum status: [:active, :archived]
        end

        Conversation::STATUS # => { active: 0, archived: 1 }

        # conversation.update! status: 0
        conversation.active!
        conversation.active? # => true
        conversation.status  # => "active"

        # conversation.update! status: 1
        conversation.archived!
        conversation.archived? # => true
        conversation.status    # => "archived"

        # conversation.update! status: 1
        conversation.status = :archived

    *DHH*

*   `ActiveRecord::Base#attribute_for_inspect` now truncates long arrays (more than 10 elements).

    *Jan Bernacki*

*   Allow for the name of the `schema_migrations` table to be configured.

    *Jerad Phelps*

*   Do not add to scope includes values from through associations.
    Fixed bug when providing `includes` in through association scope, and fetching targets.

    Example:

        class Vendor < ActiveRecord::Base
          has_many :relationships, -> { includes(:user) }
          has_many :users, through: :relationships
        end

        vendor = Vendor.first

        # Before

        vendor.users.to_a # => Raises exception: not found `:user` for `User`

        # After

        vendor.users.to_a # => No exception is raised

    Fixes #12242, #9517, #10240.

    *Paul Nikitochkin*

*   Type cast json values on write, so that the value is consistent
    with reading from the database.

    Example:

        x = JsonDataType.new tags: {"string" => "foo", :symbol => :bar}

        # Before:
        x.tags # => {"string" => "foo", :symbol => :bar}

        # After:
        x.tags # => {"string" => "foo", "symbol" => "bar"}

    *Severin Schoepke*

*   `ActiveRecord::Store` works together with PG `hstore` columns.

    Fixes #12452.

    *Yves Senn*

*   Fix bug where `ActiveRecord::Store` used a global `Hash` to keep track of
    all registered `stored_attributes`. Now every subclass of
    `ActiveRecord::Base` has it's own `Hash`.

    *Yves Senn*

*   Save `has_one` association when primary key is manually set.

    Fixes #12302.

    *Lauro Caetano*

*    Allow any version of BCrypt when using `has_secure_password`.

     *Mike Perham*

*    Sub-query generated for `Relation` passed as array condition did not take in account
     bind values and have invalid syntax.

     Generate sub-query with inline bind values.

     Fixes #12586.

     *Paul Nikitochkin*

*   Fix a bug where rake db:structure:load crashed when the path contained
    spaces.

    *Kevin Mook*

*   `ActiveRecord::QueryMethods#unscope` unscopes negative equality

    Allows you to call `#unscope` on a relation with negative equality
    operators, i.e. `Arel::Nodes::NotIn` and `Arel::Nodes::NotEqual` that have
    been generated through the use of `where.not`.

    *Eric Hankins*

*   Raise an exception when model without primary key calls `.find_with_ids`.

    *Shimpei Makimoto*

*   Make `Relation#empty?` use `exists?` instead of `count`.

    *Szymon Nowak*

*   `rake db:structure:dump` no longer crashes when the port was specified as `Fixnum`.

    *Kenta Okamoto*

*   `NullRelation#pluck` takes a list of columns

    The method signature in `NullRelation` was updated to mimic that in
    `Calculations`.

    *Derek Prior*

*   `scope_chain` should not be mutated for other reflections.

    Currently `scope_chain` uses same array for building different
    `scope_chain` for different associations. During processing
    these arrays are sometimes mutated and because of in-place
    mutation the changed `scope_chain` impacts other reflections.

    Fix is to dup the value before adding to the `scope_chain`.

    Fixes #3882.

    *Neeraj Singh*

*   Prevent the inversed association from being reloaded on save.

    Fixes #9499.

    *Dmitry Polushkin*

*   Generate subquery for `Relation` if it passed as array condition for `where`
    method.

    Example:

        # Before
        Blog.where('id in (?)', Blog.where(id: 1))
        # =>  SELECT "blogs".* FROM "blogs"  WHERE "blogs"."id" = 1
        # =>  SELECT "blogs".* FROM "blogs"  WHERE (id IN (1))

        # After
        Blog.where('id in (?)', Blog.where(id: 1).select(:id))
        # =>  SELECT "blogs".* FROM "blogs"
        #     WHERE "blogs"."id" IN (SELECT "blogs"."id" FROM "blogs"  WHERE "blogs"."id" = 1)

    Fixes #12415.

    *Paul Nikitochkin*

*   For missed association exception message
    which is raised in `ActiveRecord::Associations::Preloader` class
    added owner record class name in order to simplify to find problem code.

    *Paul Nikitochkin*

*   `has_and_belongs_to_many` is now transparently implemented in terms of
    `has_many :through`.  Behavior should remain the same, if not, it is a bug.

*   `create_savepoint`, `rollback_to_savepoint` and `release_savepoint` accept
    a savepoint name.

    *Yves Senn*

*   Make `next_migration_number` accessible for third party generators.

    *Yves Senn*

*   Objects instantiated using a null relationship will now retain the
    attributes of the where clause.

    Fixes #11676, #11675, #11376.

    *Paul Nikitochkin*, *Peter Brown*, *Nthalk*

*   Fixed `ActiveRecord::Associations::CollectionAssociation#find`
    when using `has_many` association with `:inverse_of` and finding an array of one element,
    it should return an array of one element too.

    *arthurnn*

*   Callbacks on has_many should access the in memory parent if a inverse_of is set.

    *arthurnn*

*   `ActiveRecord::ConnectionAdapters.string_to_time` respects
    string with timezone (e.g. Wed, 04 Sep 2013 20:30:00 JST).

    Fixes #12278.

    *kennyj*

*   Calling `update_attributes` will now throw an `ArgumentError` whenever it
    gets a `nil` argument. More specifically, it will throw an error if the
    argument that it gets passed does not respond to to `stringify_keys`.

    Example:

        @my_comment.update_attributes(nil)  # => raises ArgumentError

    *John Wang*

*   Deprecate `quoted_locking_column` method, which isn't used anywhere.

    *kennyj*

*   Migration dump UUID default functions to schema.rb.

    Fixes #10751.

    *kennyj*

*   Fixed a bug in `ActiveRecord::Associations::CollectionAssociation#find_by_scan`
    when using `has_many` association with `:inverse_of` option and UUID primary key.

    Fixes #10450.

    *kennyj*

*   Fix: joins association, with defined in the scope block constraints by using several
    where constraints and at least of them is not `Arel::Nodes::Equality`,
    generates invalid SQL expression.

    Fixes #11963.

    *Paul Nikitochkin*

*   `CollectionAssociation#first`/`#last` (e.g. `has_many`) use a `LIMIT`ed
    query to fetch results rather than loading the entire collection.

    *Lann Martin*

*   Make possible to run SQLite rake tasks without the `Rails` constant defined.

    *Damien Mathieu*

*   Allow Relation#from to accept other relations with bind values.

    *Ryan Wallace*

*   Fix inserts with prepared statements disabled.

    Fixes #12023.

    *Rafael Mendonça França*

*   Setting a has_one association on a new record no longer causes an empty
    transaction.

    *Dylan Thacker-Smith*

*   Fix `AR::Relation#merge` sometimes failing to preserve `readonly(false)` flag.

    *thedarkone*

*   Re-use `order` argument pre-processing for `reorder`.

    *Paul Nikitochkin*

*   Fix PredicateBuilder so polymorphic association keys in `where` clause can
    accept objects other than direct descendants of `ActiveRecord::Base` (decorated
    models, for example).

    *Mikhail Dieterle*

*   PostgreSQL adapter recognizes negative money values formatted with
    parentheses (eg. `($1.25) # => -1.25`)).
    Fixes #11899.

    *Yves Senn*

*   Stop interpreting SQL 'string' columns as :string type because there is no
    common STRING datatype in SQL.

    *Ben Woosley*

*   `ActiveRecord::FinderMethods#exists?` returns `true`/`false` in all cases.

    *Xavier Noria*

*   Assign inet/cidr attribute with `nil` value for invalid address.

    Example:

        record = User.new
        record.logged_in_from_ip # is type of an inet or a cidr

        # Before:
        record.logged_in_from_ip = 'bad ip address' # raise exception

        # After:
        record.logged_in_from_ip = 'bad ip address' # do not raise exception
        record.logged_in_from_ip # => nil
        record.logged_in_from_ip_before_type_cast # => 'bad ip address'

    *Paul Nikitochkin*

*   `add_to_target` now accepts a second optional `skip_callbacks` argument

    If truthy, it will skip the :before_add and :after_add callbacks.

    *Ben Woosley*

*   Fix interactions between `:before_add` callbacks and nested attributes
    assignment of `has_many` associations, when the association was not
    yet loaded:

    - A `:before_add` callback was being called when a nested attributes
      assignment assigned to an existing record.

    - Nested Attributes assignment did not affect the record in the
      association target when a `:before_add` callback triggered the
      loading of the association

    *Jörg Schray*

*   Allow enable_extension migration method to be revertible.

    *Eric Tipton*

*   Type cast hstore values on write, so that the value is consistent
    with reading from the database.

    Example:

        x = Hstore.new tags: {"bool" => true, "number" => 5}

        # Before:
        x.tags # => {"bool" => true, "number" => 5}

        # After:
        x.tags # => {"bool" => "true", "number" => "5"}

    *Yves Senn* , *Severin Schoepke*

*   Fix multidimensional PG arrays containing non-string items.

    *Yves Senn*

*   Fixes bug when using includes combined with select, the select statement was overwritten.

    Fixes #11773.

    *Edo Balvers*

*   Load fixtures from linked folders.

    *Kassio Borges*

*   Create a directory for sqlite3 file if not present on the system.

    *Richard Schneeman*

*   Removed redundant override of `xml` column definition for PG,
    in order to use `xml` column type instead of `text`.

    *Paul Nikitochkin*, *Michael Nikitochkin*

*   Revert `ActiveRecord::Relation#order` change that make new order
    prepend the old one.

    Before:

        User.order("name asc").order("created_at desc")
        # SELECT * FROM users ORDER BY created_at desc, name asc

    After:

        User.order("name asc").order("created_at desc")
        # SELECT * FROM users ORDER BY name asc, created_at desc

    This also affects order defined in `default_scope` or any kind of associations.

*   Add ability to define how a class is converted to Arel predicates.
    For example, adding a very vendor specific regex implementation:

        regex_handler = proc do |column, value|
          Arel::Nodes::InfixOperation.new('~', column, value.source)
        end
        ActiveRecord::PredicateBuilder.register_handler(Regexp, regex_handler)

    *Sean Griffin & @joannecheng*

*   Don't allow `quote_value` to be called without a column.

    Some adapters require column information to do their job properly.
    By enforcing the provision of the column for this internal method
    we ensure that those using adapters that require column information
    will always get the proper behavior.

    *Ben Woosley*

*   When using optimistic locking, `update` was not passing the column to `quote_value`
    to allow the connection adapter to properly determine how to quote the value. This was
    affecting certain databases that use specific column types.

    Fixes #6763.

    *Alfred Wong*

*   rescue from all exceptions in `ConnectionManagement#call`

    Fixes #11497.

    As `ActiveRecord::ConnectionAdapters::ConnectionManagement` middleware does
    not rescue from Exception (but only from StandardError), the Connection
    Pool quickly runs out of connections when multiple erroneous Requests come
    in right after each other.

    Rescuing from all exceptions and not just StandardError, fixes this
    behaviour.

    *Vipul A M*

*   `change_column` for PostgreSQL adapter respects the `:array` option.

    *Yves Senn*

*   Remove deprecation warning from `attribute_missing` for attributes that are columns.

    *Arun Agrawal*

*   Remove extra decrement of transaction deep level.

    Fixes #4566.

    *Paul Nikitochkin*

*   Reset @column_defaults when assigning `locking_column`.
    We had a potential problem. For example:

      class Post < ActiveRecord::Base
        self.column_defaults  # if we call this unintentionally before setting locking_column ...
        self.locking_column = 'my_locking_column'
      end

      Post.column_defaults["my_locking_column"]
      => nil # expected value is 0 !

    *kennyj*

*   Remove extra select and update queries on save/touch/destroy ActiveRecord model
    with belongs to reflection with option `touch: true`.

    Fixes #11288.

    *Paul Nikitochkin*

*   Remove deprecated nil-passing to the following `SchemaCache` methods:
    `primary_keys`, `tables`, `columns` and `columns_hash`.

    *Yves Senn*

*   Remove deprecated block filter from `ActiveRecord::Migrator#migrate`.

    *Yves Senn*

*   Remove deprecated String constructor from `ActiveRecord::Migrator`.

    *Yves Senn*

*   Remove deprecated `scope` use without passing a callable object.

    *Arun Agrawal*

*   Remove deprecated `transaction_joinable=` in favor of `begin_transaction`
    with `:joinable` option.

    *Arun Agrawal*

*   Remove deprecated `decrement_open_transactions`.

    *Arun Agrawal*

*   Remove deprecated `increment_open_transactions`.

    *Arun Agrawal*

*   Remove deprecated `PostgreSQLAdapter#outside_transaction?`
    method. You can use `#transaction_open?` instead.

    *Yves Senn*

*   Remove deprecated `ActiveRecord::Fixtures.find_table_name` in favor of
    `ActiveRecord::Fixtures.default_fixture_model_name`.

    *Vipul A M*

*   Removed deprecated `columns_for_remove` from `SchemaStatements`.

    *Neeraj Singh*

*   Remove deprecated `SchemaStatements#distinct`.

    *Francesco Rodriguez*

*   Move deprecated `ActiveRecord::TestCase` into the rails test
    suite. The class is no longer public and is only used for internal
    Rails tests.

    *Yves Senn*

*   Removed support for deprecated option `:restrict` for `:dependent`
    in associations.

    *Neeraj Singh*

*   Removed support for deprecated `delete_sql` in associations.

    *Neeraj Singh*

*   Removed support for deprecated `insert_sql` in associations.

    *Neeraj Singh*

*   Removed support for deprecated `finder_sql` in associations.

    *Neeraj Singh*

*   Support array as root element in JSON fields.

    *Alexey Noskov & Francesco Rodriguez*

*   Removed support for deprecated `counter_sql` in associations.

    *Neeraj Singh*

*   Do not invoke callbacks when `delete_all` is called on collection.

    Method `delete_all` should not be invoking callbacks and this
    feature was deprecated in Rails 4.0. This is being removed.
    `delete_all` will continue to honor the `:dependent` option. However
    if `:dependent` value is `:destroy` then the `:delete_all` deletion
    strategy for that collection will be applied.

    User can also force a deletion strategy by passing parameter to
    `delete_all`. For example you can do `@post.comments.delete_all(:nullify)`.

    *Neeraj Singh*

*   Calling default_scope without a proc will now raise `ArgumentError`.

    *Neeraj Singh*

*   Removed deprecated method `type_cast_code` from Column.

    *Neeraj Singh*

*   Removed deprecated options `delete_sql` and `insert_sql` from HABTM
    association.

    Removed deprecated options `finder_sql` and `counter_sql` from
    collection association.

    *Neeraj Singh*

*   Remove deprecated `ActiveRecord::Base#connection` method.
    Make sure to access it via the class.

    *Yves Senn*

*   Remove deprecation warning for `auto_explain_threshold_in_seconds`.

    *Yves Senn*

*   Remove deprecated `:distinct` option from `Relation#count`.

    *Yves Senn*

*   Removed deprecated methods `partial_updates`, `partial_updates?` and
    `partial_updates=`.

    *Neeraj Singh*

*   Removed deprecated method `scoped`.

    *Neeraj Singh*

*   Removed deprecated method `default_scopes?`.

    *Neeraj Singh*

*   Remove implicit join references that were deprecated in 4.0.

    Example:

        # before with implicit joins
        Comment.where('posts.author_id' => 7)

        # after
        Comment.references(:posts).where('posts.author_id' => 7)

    *Yves Senn*

*   Apply default scope when joining associations. For example:

        class Post < ActiveRecord::Base
          default_scope -> { where published: true }
        end

        class Comment
          belongs_to :post
        end

    When calling `Comment.joins(:post)`, we expect to receive only
    comments on published posts, since that is the default scope for
    posts.

    Before this change, the default scope from `Post` was not applied,
    so we'd get comments on unpublished posts.

    *Jon Leighton*

*   Remove `activerecord-deprecated_finders` as a dependency.

    *Łukasz Strzałkowski*

*   Remove Oracle / Sqlserver / Firebird database tasks that were deprecated in 4.0.

    *kennyj*

*   `find_each` now returns an `Enumerator` when called without a block, so that it
    can be chained with other `Enumerable` methods.

    *Ben Woosley*

*   `ActiveRecord::Result.each` now returns an `Enumerator` when called without
     a block, so that it can be chained with other `Enumerable` methods.

    *Ben Woosley*

*   Flatten merged join_values before building the joins.

    While joining_values special treatment is given to string values.
    By flattening the array it ensures that string values are detected
    as strings and not arrays.

    Fixes #10669.

    *Neeraj Singh and iwiznia*

*   Do not load all child records for inverse case.

    currently `post.comments.find(Comment.first.id)` would load all
    comments for the given post to set the inverse association.

    This has a huge performance penalty. Because if post has 100k
    records and all these 100k records would be loaded in memory
    even though the comment id was supplied.

    Fix is to use in-memory records only if loaded? is true. Otherwise
    load the records using full sql.

    Fixes #10509.

    *Neeraj Singh*

*   `inspect` on Active Record model classes does not initiate a
    new connection. This means that calling `inspect`, when the
    database is missing, will no longer raise an exception.
    Fixes #10936.

    Example:

        Author.inspect # => "Author(no database connection)"

    *Yves Senn*

*   Handle single quotes in PostgreSQL default column values.
    Fixes #10881.

    *Dylan Markow*

*   Log the sql that is actually sent to the database.

    If I have a query that produces sql
    `WHERE "users"."name" = 'a         b'` then in the log all the
    whitespace is being squeezed. So the sql that is printed in the
    log is `WHERE "users"."name" = 'a b'`.

    Do not squeeze whitespace out of sql queries. Fixes #10982.

    *Neeraj Singh*

*   Fixture setup no longer depends on `ActiveRecord::Base.configurations`.
    This is relevant when `ENV["DATABASE_URL"]` is used in place of a `database.yml`.

    *Yves Senn*

*   Fix mysql2 adapter raises the correct exception when executing a query on a
    closed connection.

    *Yves Senn*

*   Ambiguous reflections are on :through relationships are no longer supported.
    For example, you need to change this:

        class Author < ActiveRecord::Base
          has_many :posts
          has_many :taggings, through: :posts
        end

        class Post < ActiveRecord::Base
          has_one :tagging
          has_many :taggings
        end

        class Tagging < ActiveRecord::Base
        end

    To this:

        class Author < ActiveRecord::Base
          has_many :posts
          has_many :taggings, through: :posts, source: :tagging
        end

        class Post < ActiveRecord::Base
          has_one :tagging
          has_many :taggings
        end

        class Tagging < ActiveRecord::Base
        end

    *Aaron Patterson*

*   Remove column restrictions for `count`, let the database raise if the SQL is
    invalid. The previous behavior was untested and surprising for the user.
    Fixes #5554.

    Example:

        User.select("name, username").count
        # Before => SELECT count(*) FROM users
        # After => ActiveRecord::StatementInvalid

        # you can still use `count(:all)` to perform a query unrelated to the
        # selected columns
        User.select("name, username").count(:all) # => SELECT count(*) FROM users

    *Yves Senn*

*   Rails now automatically detects inverse associations. If you do not set the
    `:inverse_of` option on the association, then Active Record will guess the
    inverse association based on heuristics.

    Note that automatic inverse detection only works on `has_many`, `has_one`,
    and `belongs_to` associations. Extra options on the associations will
    also prevent the association's inverse from being found automatically.

    The automatic guessing of the inverse association uses a heuristic based
    on the name of the class, so it may not work for all associations,
    especially the ones with non-standard names.

    You can turn off the automatic detection of inverse associations by setting
    the `:inverse_of` option to `false` like so:

        class Taggable < ActiveRecord::Base
          belongs_to :tag, inverse_of: false
        end

    *John Wang*

*   Fix `add_column` with `array` option when using PostgreSQL. Fixes #10432

    *Adam Anderson*

*   Usage of `implicit_readonly` is being removed`. Please use `readonly` method
    explicitly to mark records as `readonly.
    Fixes #10615.

    Example:

        user = User.joins(:todos).select("users.*, todos.title as todos_title").readonly(true).first
        user.todos_title = 'clean pet'
        user.save! # will raise error

    *Yves Senn*

*   Fix the `:primary_key` option for `has_many` associations.
    Fixes #10693.

    *Yves Senn*

*   Fix bug where tiny types are incorrectly coerced as boolean when the length is more than 1.

    Fixes #10620.

    *Aaron Patterson*

*   Also support extensions in PostgreSQL 9.1. This feature has been supported since 9.1.

    *kennyj*

*   Deprecate `ConnectionAdapters::SchemaStatements#distinct`,
    as it is no longer used by internals.

    *Ben Woosley*

*   Fix pending migrations error when loading schema and `ActiveRecord::Base.table_name_prefix`
    is not blank.

    Call `assume_migrated_upto_version` on connection to prevent it from first
    being picked up in `method_missing`.

    In the base class, `Migration`, `method_missing` expects the argument to be a
    table name, and calls `proper_table_name` on the arguments before sending to
    `connection`. If `table_name_prefix` or `table_name_suffix` is used, the schema
    version changes to `prefix_version_suffix`, breaking `rake test:prepare`.

    Fixes #10411.

    *Kyle Stevens*

*   Method `read_attribute_before_type_cast` should accept input as symbol.

    *Neeraj Singh*

*   Confirm a record has not already been destroyed before decrementing counter cache.

    *Ben Tucker*

*   Fixed a bug in `ActiveRecord#sanitize_sql_hash_for_conditions` in which
    `self.class` is an argument to `PredicateBuilder#build_from_hash`
    causing `PredicateBuilder` to call non-existent method
    `Class#reflect_on_association`.

    *Zach Ohlgren*

*   While removing index if column option is missing then raise IrreversibleMigration exception.

    Following code should raise `IrreversibleMigration`. But the code was
    failing since options is an array and not a hash.

        def change
          change_table :users do |t|
            t.remove_index [:name, :email]
          end
        end

    Fix was to check if the options is a Hash before operating on it.

    Fixes #10419.

    *Neeraj Singh*

*   Do not overwrite manually built records during one-to-one nested attribute assignment

    For one-to-one nested associations, if you build the new (in-memory)
    child object yourself before assignment, then the NestedAttributes
    module will not overwrite it, e.g.:

        class Member < ActiveRecord::Base
          has_one :avatar
          accepts_nested_attributes_for :avatar

          def avatar
            super || build_avatar(width: 200)
          end
        end

        member = Member.new
        member.avatar_attributes = {icon: 'sad'}
        member.avatar.width # => 200

    *Olek Janiszewski*

*   fixes bug introduced by #3329. Now, when autosaving associations,
    deletions happen before inserts and saves. This prevents a 'duplicate
    unique value' database error that would occur if a record being created had
    the same value on a unique indexed field as that of a record being destroyed.

    *Johnny Holton*

*   Handle aliased attributes in ActiveRecord::Relation.

    When using symbol keys, ActiveRecord will now translate aliased attribute names to the actual column name used in the database:

    With the model

        class Topic
          alias_attribute :heading, :title
        end

    The call

        Topic.where(heading: 'The First Topic')

    should yield the same result as

        Topic.where(title: 'The First Topic')

    This also applies to ActiveRecord::Relation::Calculations calls such as `Model.sum(:aliased)` and `Model.pluck(:aliased)`.

    This will not work with SQL fragment strings like `Model.sum('DISTINCT aliased')`.

    *Godfrey Chan*

*   Mute `psql` output when running rake db:schema:load.

    *Godfrey Chan*

*   Trigger a save on `has_one association=(associate)` when the associate contents have changed.

    Fix #8856.

    *Chris Thompson*

*   Abort a rake task when missing db/structure.sql like `db:schema:load` task.

    *kennyj*

*   rake:db:test:prepare falls back to original environment after execution.

    *Slava Markevich*

Please check [4-0-stable](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) for previous changes.
