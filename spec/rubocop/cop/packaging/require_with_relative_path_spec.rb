# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RequireWithRelativePath, :config do
  let(:message) { RuboCop::Cop::Packaging::RequireWithRelativePath::MSG }

  let(:project_root) { RuboCop::ConfigLoader.project_root }

  context "when `require` call lies outside spec/" do
    let(:filename) { "#{project_root}/spec/foo_spec.rb" }
    let(:source) { "require '../lib/foo.rb'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require` call after using `unshift` lies outside spec/" do
    let(:filename) { "#{project_root}/tests/foo/bar.rb" }
    let(:source) { <<~RUBY.chomp }
      $:.unshift('../../lib')
      require '../../lib/foo/bar'
    RUBY

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * 27} #{message}
      RUBY
    end
  end

  context "when `require` call uses File#expand_path method with __FILE__" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { "require File.expand_path('../../lib/foo', __FILE__)" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require` call uses File#expand_path method with __dir__" do
    let(:filename) { "#{project_root}/test/foo/bar/qux_spec.rb" }
    let(:source) { "require File.expand_path('../../../lib/foo/bar/baz/qux', __dir__)" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require` call uses File#dirname method with __FILE__" do
    let(:filename) { "#{project_root}/specs/baz/qux_spec.rb" }
    let(:source) { "require File.dirname(__FILE__) + '/../../lib/baz/qux'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require` call uses File#dirname method with __dir__" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { "require File.dirname(__dir__) + '/../lib/foo'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when the `require` call doesn't use relative path" do
    let(:filename) { "#{project_root}/spec/bar_spec.rb" }
    let(:source) { "require 'bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require` call lies inside test/" do
    let(:filename) { "#{project_root}/test/bar/foo_spec.rb" }
    let(:source) { "require '../foo'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require` call is made to lib/ but it lies under spec/" do
    let(:filename) { "#{project_root}/spec/lib/baz/qux_spec.rb" }
    let(:source) { "require '../../lib/foo'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require` call uses File#dirname with __FILE__ but lies inside tests/" do
    let(:filename) { "#{project_root}/tests/foo/bar_spec.rb" }
    let(:source) { "require File.dirname(__FILE__) + '/../lib/bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require` call uses File#dirname with __dir__ but lies inside spec/" do
    let(:filename) { "#{project_root}/spec/foo/bar_spec.rb" }
    let(:source) { "require File.dirname(__dir__) + '/../lib/bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end
end
