*   Extend cross-site request forgery (CSRF) protection to GET requests with
    JavaScript responses, protecting apps from cross-origin `<script>` tags.

    *Jeremy Kemper*

*   Fix generating a path for engine inside a resources block.

    Fixes #8533.

    *Piotr Sarnacki*

*   Add `Mime::Type.register "text/vcard", :vcf` to the default list of mime types.

    *DHH*

*   Remove deprecated `ActionController::RecordIdentifier`, use
    `ActionView::RecordIdentifier` instead.

    *kennyj*

*   Fix regression when using `ActionView::Helpers::TranslationHelper#translate` with
    `options[:raise]`.

    This regression was introduced at ec16ba75a5493b9da972eea08bae630eba35b62f.

    *Shota Fukumori (sora_h)*

*   Introducing Variants

    We often want to render different html/json/xml templates for phones,
    tablets, and desktop browsers. Variants make it easy.

    The request variant is a specialization of the request format, like `:tablet`,
    `:phone`, or `:desktop`.

    You can set the variant in a `before_action`:

        request.variant = :tablet if request.user_agent =~ /iPad/

    Respond to variants in the action just like you respond to formats:

        respond_to do |format|
          format.html do |html|
            html.tablet # renders app/views/projects/show.html+tablet.erb
            html.phone { extra_setup; render ... }
          end
        end

    Provide separate templates for each format and variant:

        app/views/projects/show.html.erb
        app/views/projects/show.html+tablet.erb
        app/views/projects/show.html+phone.erb

    You can also simplify the variants definition using the inline syntax:

        respond_to do |format|
          format.js         { render "trash" }
          format.html.phone { redirect_to progress_path }
          format.html.none  { render "trash" }
        end

    *Łukasz Strzałkowski*

*   Fix header `Content-Type: #<Mime::NullType:...>` in localized template.

    When localized template has no format in the template name,
    the response now has the default and correct `content-type`.

    Fixes #13064.

    *Angelo Capilleri*

*   Try to escape each part of a url correctly when using a redirect route.

    Fixes #13110.

    *Andrew White*

*   Better error message for typos in assert_response argument.

    When the response type argument to `assert_response` is not a known
    response type, `assert_response` now throws an ArgumentError with a clear
    message. This is intended to help debug typos in the response type.

    *Victor Costan*

*   Fix formatting for `rake routes` when a section is shorter than a header.

    *Sıtkı Bağdat*

*   Take a hash with options inside array in `#url_for`.

    Example:

        url_for [:new, :admin, :post, { param: 'value' }]
        # => http://example.com/admin/posts/new?param=value

    *Andrey Ognevsky*

*   Add `session#fetch` method

    fetch behaves like [Hash#fetch](http://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch).
    It returns a value from the hash for the given key.
    If the key can’t be found, there are several options:

      * With no other arguments, it will raise an KeyError exception.
      * If a default value is given, then that will be returned.
      * If the optional code block is specified, then that will be run and its result returned.

    *Damien Mathieu*

*   Don't let strong parameters mutate the given hash via `fetch`

    Create a new instance if the given parameter is a `Hash` instead of
    passing it to the `convert_hashes_to_parameters` method since it is
    overriding its default value.

    *Brendon Murphy*, *Doug Cole*

*   Add `params` option to `button_to` form helper, which renders the given hash
    as hidden form fields.

    *Andy Waite*

*   Make assets helpers work in the controllers like it works in the views.

    Example:

        # config/application.rb
        config.asset_host = 'http://mycdn.com'

        ActionController::Base.helpers.asset_path('fallback.png')
        # => http://mycdn.com/assets/fallback.png

    Fixes #10051.

    *Tima Maslyuchenko*

*   Respect `SCRIPT_NAME` when using `redirect` with a relative path

    Example:

        # application routes.rb
        mount BlogEngine => '/blog'

        # engine routes.rb
        get '/admin' => redirect('admin/dashboard')

    This now redirects to the path `/blog/admin/dashboard`, whereas before it would've
    generated an invalid url because there would be no slash between the host name and
    the path. It also allows redirects to work where the application is deployed to a
    subdirectory of a website.

    Fixes #7977.

    *Andrew White*

*   Fixing repond_with working directly on the options hash
    This fixes an issue where the respond_with worked directly with the given
    options hash, so that if a user relied on it after calling respond_with,
    the hash wouldn't be the same.

    Fixes #12029.

    *bluehotdog*

*   Fix `ActionDispatch::RemoteIp::GetIp#calculate_ip` to only check for spoofing
    attacks if both `HTTP_CLIENT_IP` and `HTTP_X_FORWARDED_FOR` are set.

    Fixes #10844.

    *Tamir Duberstein*

*   Strong parameters should permit nested number as key.

    Fixes #12293.

    *kennyj*

*   Fix regex used to detect URI schemes in `redirect_to` to be consistent with
    RFC 3986.

    *Derek Prior*

*   Fix incorrect `assert_redirected_to` failure message for protocol-relative
    URLs.

    *Derek Prior*

*   Fix an issue where router can't recognize downcased url encoding path.

    Fixes #12269.

    *kennyj*

*   Fix custom flash type definition. Misusage of the `_flash_types` class variable
    caused an error when reloading controllers with custom flash types.

    Fixes #12057.

    *Ricardo de Cillo*

*   Do not break params filtering on `nil` values.

    Fixes #12149.

    *Vasiliy Ermolovich*

*   Development mode exceptions are rendered in text format in case of XHR request.

    *Kir Shatrov*

*   Fix an issue where :if and :unless controller action procs were being run
    before checking for the correct action in the :only and :unless options.

    Fixes #11799.

    *Nicholas Jakobsen*

*   Fix an issue where `assert_dom_equal` and `assert_dom_not_equal` were
    ignoring the passed failure message argument.

    Fixes #11751.

    *Ryan McGeary*

*   Allow REMOTE_ADDR, HTTP_HOST and HTTP_USER_AGENT to be overridden from
    the environment passed into `ActionDispatch::TestRequest.new`.

    Fixes #11590.

    *Andrew White*

*   Fix an issue where Journey was failing to clear the named routes hash when the
    routes were reloaded and since it doesn't overwrite existing routes then if a
    route changed but wasn't renamed it kept the old definition. This was being
    masked by the optimised url helpers so it only became apparent when passing an
    options hash to the url helper.

    *Andrew White*

*   Skip routes pointing to a redirect or mounted application when generating urls
    using an options hash as they aren't relevant and generate incorrect urls.

    Fixes #8018.

    *Andrew White*

*   Move `MissingHelperError` out of the `ClassMethods` module.

    *Yves Senn*

*   Fix an issue where rails raise exception about missing helper where it
    should throw `LoadError`. When helper file exists and only loaded file from
    this helper does not exist rails should throw LoadError instead of
    `MissingHelperError`.

    *Piotr Niełacny*

*   Fix `ActionDispatch::ParamsParser#parse_formatted_parameters` to rewind body input stream on
    parsing json params.

    Fixes #11345.

    *Yuri Bol*, *Paul Nikitochkin*

*   Ignore spaces around delimiter in Set-Cookie header.

    *Yamagishi Kazutoshi*

*   Remove deprecated Rails application fallback for integration testing, set
    `ActionDispatch.test_app` instead.

    *Carlos Antonio da Silva*

*   Remove deprecated `page_cache_extension` config.

    *Francesco Rodriguez*

*   Remove deprecated constants from Action Controller:

        ActionController::AbstractRequest  => ActionDispatch::Request
        ActionController::Request          => ActionDispatch::Request
        ActionController::AbstractResponse => ActionDispatch::Response
        ActionController::Response         => ActionDispatch::Response
        ActionController::Routing          => ActionDispatch::Routing
        ActionController::Integration      => ActionDispatch::Integration
        ActionController::IntegrationTest  => ActionDispatch::IntegrationTest

    *Carlos Antonio da Silva*

*   Fix `Mime::Type.parse` when bad accepts header is looked up. Previously it
    was setting `request.formats` with an array containing a `nil` value, which
    raised an error when setting the controller formats.

    Fixes #10965.

    *Becker*

*   Merge `:action` from routing scope and assign endpoint if both `:controller`
    and `:action` are present. The endpoint assignment only occurs if there is
    no `:to` present in the options hash so should only affect routes using the
    shorthand syntax (i.e. endpoint is inferred from the path).

    Fixes #9856.

    *Yves Senn*, *Andrew White*

*   Action View extracted from Action Pack.

    *Piotr Sarnacki*, *Łukasz Strzałkowski*

*   Fix removing trailing slash for mounted apps.

    Fixes #3215.

    *Piotr Sarnacki*

Please check [4-0-stable](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) for previous changes.
