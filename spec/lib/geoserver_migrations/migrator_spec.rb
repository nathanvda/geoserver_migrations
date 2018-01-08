require 'spec_helper'

RSpec.describe GeoserverMigrations::Migrator do
  before do
    @migrator = GeoserverMigrations::Migrator.new
  end

  context "migrations_paths" do
    context "default" do
      before do
        @migrator.migrations_paths = nil
      end
      it "default is geoserver/migrate" do
        expect(@migrator.migrations_paths).to eq(["geoserver/migrate"])
      end
    end
    context "can be set" do
      before do
        @migrator.migrations_paths = "geo_server_XXX/migrate"
      end
      it "default is geoserver/migrate" do
        expect(@migrator.migrations_paths).to eq(["geo_server_XXX/migrate"])
      end
    end
  end

  context "any_migrations?" do
    context "in an empty folder" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/empty_migrate'
      end
      it "returns array of length 2" do
        expect(@migrator.any_migrations?).to eq false
      end
    end
    context "in a folder with migrations" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/migrate_1'
      end
      it "returns array of length 2" do
        expect(@migrator.any_migrations?).to eq true
      end
    end
  end

  context "migrations" do
    context "regular folder" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/migrate_1'
        @migrations = @migrator.migrations(@migrator.migrations_paths)
      end
      it "returns array of length 2" do
        expect(@migrations.size).to eq(2)
      end
      it "contains MigrationProxy" do
        expect(@migrations.first.class.name).to eq("GeoserverMigrations::MigrationProxy")
      end
      it "contains the correct names" do
        expect(@migrations.map(&:name)).to eq(["FirstMigration", "OtherMigration"])
      end
      it "contains the correct versions" do
        expect(@migrations.map(&:version)).to eq([1,4])
      end
    end

    # how can we ever get illegal file names?
    # context "folder with illegal migration files" do
    #   before do
    #     @migrator.migrations_paths = 'spec/fixtures/migrate_examples/illegal_migrate'
    #   end
    #   it "throws an exception" do
    #     expect { @migrator.migrations(@migrator.migrations_paths) }.to raise_exception GeoserverMigrations::IllegalMigrationNameError
    #   end
    # end
  end


  describe ".current_version" do
    context "if there are no migrations in db" do
      it "returns zero" do
        expect(@migrator.current_version).to eq(0)
      end
    end
    context "if there is 1 migrations in db" do
      before do
        GeoserverMigration.create!(version: 1)
      end
      it "returns 1" do
        expect(@migrator.current_version).to eq(1)
      end
    end
    context "if there is 3 migrations in db" do
      before do
        GeoserverMigration.create!(version: 1)
        GeoserverMigration.create!(version: 12)
        GeoserverMigration.create!(version: 5)
      end
      it "returns the largest number" do
        expect(@migrator.current_version).to eq(12)
      end
    end
  end

  describe ".needs_migration?" do
    context "with an empty migrate folder" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/empty_migrate'
      end
      context "if there are no migrations in db" do
        it "returns false" do
          expect(@migrator.needs_migration?).to eq false
        end
      end
    end
    context "in a migrate folder with migrations" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/migrate_1'
      end
      context "if there are no migrations in db" do
        it "returns true" do
          expect(@migrator.needs_migration?).to eq true
        end
      end
      context "if there is 1 migration in db" do
        before do
          GeoserverMigration.create!(version: 1)
        end
        it "returns true" do
          expect(@migrator.needs_migration?).to eq true
        end
      end
      context "if all migrations are in db" do
        before do
          GeoserverMigration.create!(version: 1)
          GeoserverMigration.create!(version: 4)
        end
        it "returns false" do
          expect(@migrator.needs_migration?).to eq false
        end
      end
    end
  end


  describe ".pending_migrations" do
    context "with an empty migrate folder" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/empty_migrate'
      end
      context "if there are no migrations in db" do
        it "returns false" do
          expect(@migrator.pending_migrations.size).to eq 0
        end
      end
    end
    context "in a migrate folder with migrations" do
      before do
        @migrator.migrations_paths = 'spec/fixtures/migrate_examples/migrate_1'
      end
      context "if there are no migrations in db" do
        it "returns true" do
          expect(@migrator.pending_migrations.size).to eq 2
        end
      end
      context "if there is 1 migration in db" do
        before do
          GeoserverMigration.create!(version: 1)
        end
        it "returns true" do
          expect(@migrator.pending_migrations.size).to eq 1
        end
      end
      context "if all migrations are in db" do
        before do
          GeoserverMigration.create!(version: 1)
          GeoserverMigration.create!(version: 4)
        end
        it "returns false" do
          expect(@migrator.pending_migrations.size).to eq 0
        end
      end
    end
  end




end