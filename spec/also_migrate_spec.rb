require "spec_helper"

describe AlsoMigrate do
  
  [ "table doesn't exist yet", "table already exists" ].each do |description|
    describe description do
    
      before(:each) do
        reset_fixture
        
        if description == "table already exists"
          Article.also_migrate :article_archives, :ignore => 'body', :indexes => 'id'
        end
        
        $db.migrate(1)
        $db.migrate(0)
        $db.migrate(1)
        
        if description == "table doesn't exist yet"
          Article.also_migrate :article_archives, :ignore => 'body', :indexes => 'id'
          $db.migrate(1)
        end
      end
    
      it 'should migrate both tables up' do
        migrate_with_state(2)
        (@new_article_columns - @old_article_columns).should == [ 'permalink' ]
        (@new_archive_columns - @old_archive_columns).should == [ 'permalink' ]
      end
      
      it 'should migrate both tables down' do
        $db.migrate(2)
        migrate_with_state(1)
        (@old_article_columns - @new_article_columns).should == [ 'permalink' ]
        (@old_archive_columns - @new_archive_columns).should == [ 'permalink' ]
      end
    
      it "should ignore the body column" do
        (columns('articles') - columns('article_archives')).should == [ 'body' ]
        connection.remove_column(:articles, :body)
        (columns('articles') - columns('article_archives')).should == []
      end
      
      it "should only add an index for id" do
        indexed_columns('articles').should == [ 'id', 'read' ]
        indexed_columns('article_archives').should == [ 'id' ]
      end
      
      describe 'no index config' do

        before(:each) do
          reset_fixture
          
          if description == "table already exists"
            Article.also_migrate :article_archives
          end

          $db.migrate(0)
          $db.migrate(1)

          if description == "table doesn't exist yet"
            Article.also_migrate :article_archives
            $db.migrate(1)
          end
        end

        it "should add all indexes" do
          indexed_columns('articles').should == [ 'id', 'read' ]
          indexed_columns('article_archives').should == [ 'id', 'read' ]
        end
      end
    end
  end
end