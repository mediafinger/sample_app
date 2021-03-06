require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    before :each do
      get :new
    end

    it "should be successful" do
      response.should be_success
    end

    it "should have the right 'title'" do
      response.should have_selector('title', :content => 'Sign up')
    end

    it "should have a name field" do
      response.should have_selector("input", :name => "user[name]", :type => "text")
    end

    it "should have an email field" do
      response.should have_selector("input", :name => "user[email]", :type => "text")
    end

    it "should have a password field" do
      response.should have_selector("input", :name => "user[password]", :type => "password")
    end

    it "should have a password confirmation field" do
      response.should have_selector("input", :name => "user[password_confirmation]", :type => "password")
    end
  end

  describe "GET 'show'" do
    describe "for non-signed-in users" do
      it "should deny access" do
        @user = Factory(:user)
        get :show, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed_in users" do
      before :each do
        @user = Factory(:user)
        test_sign_in(@user)
      end

      it "should be successful" do
        get :show, :id => @user
        response.should be_success
      end

      it "should find the correct user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end

      it "should have the correct title" do
        get :show, :id => @user
        response.should have_selector("title", :content => @user.name)
      end

      it "should have the name in the heading" do
        get :show, :id => @user
        response.should have_selector('h2', :content => @user.name)
      end

      it "should have a profile image in the heading" do
        get :show, :id => @user
        response.should have_selector("h2>img", :class => "gravatar")
      end

      it "should show the user's microposts" do
        mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
        mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
        get :show, :id => @user
        response.should have_selector("span.content", :content => mp1.content)
        response.should have_selector("span.content", :content => mp2.content)
      end
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before :each do
        @attr = { :name => '',
                  :email => '',
                  :password => '',
                  :password_confirmation => ''
        }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template(:new)
      end
    end

    # SUCCESS
    describe "success" do
      before :each do
        @attr = { :name => 'Hans Meier',
                  :email => 'example@railstutorial.org',
                  :password => 'foobar23',
                  :password_confirmation => 'foobar23'
        }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should fill a flash with a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome/i
      end

      it "should render the show user page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
        #response.should render_template(:show)
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end


  # EDIT your own profile
  describe "GET 'edit'" do
    before :each do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should display the edit profile page" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the correct title" do
      get :edit, :id => @user
      response.should render_template(:edit)
      response.should have_selector("title", :content => "Edit")
    end

    it "should contain the gravatar link" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end
  end

   # save your updated profile
  describe "PUT 'update'" do
    before :each do
      @user = Factory(:user)
      test_sign_in(@user)
      get :edit, :id => @user
    end

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", :password => "", :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template(:edit)
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit")
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "New Name",
                  :email => "user@example.org",
                  :password => "foobar23",
                  :password_confirmation => "foobar23" }
      end

      it "should display the profile page after updating" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should display the changed user data" do
        put :update, :id => @user, :user => @attr
        @user.reload                                # reloads the (updated) user form the database
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should contain the flash success message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/i
      end
    end
  end

  describe "authentication of edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end

      it "should show flash message" do
        put :edit, :id => @user
        flash[:notice].should =~ /access/i
      end
    end

    describe "for other signed-in users" do
      before :each do
        other_user = Factory(:user, :email => "user@example.net")
        test_sign_in(other_user)
      end

      it "should deny access to other 'edit' pages" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "GET index" do
    describe "for non-signed-in users" do
      it "should display all users on an index page" do
        get :index
        response.should be_success
      end

# Just in case that access to users:index will be restricted:
#      it "should deny access" do
#        get :index
#        response.should redirect_to(signin_path)
#        flash[:notice].should =~ /sign in/i
#      end
    end

    describe "for signed-in users" do
      before :each do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "another@example.com")
        third  = Factory(:user, :email => "another@example.net")
        @users = [@user, second, third]
        33.times do
          @users[@users.length] = Factory(:user, :email => Factory.next(:email))
          # @users << Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should display all users on an index page" do
        get :index
        response.should be_success
        response.should render_template(:index)
      end

       it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2", :content => "2")
        response.should have_selector("a", :href => "/users?page=2", :content => "Next")
      end

      it "should have a second (and third) pagination page" do
        get :index, :page => 2
        response.should have_selector("div.pagination")
        response.should_not have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=3", :content => "3")
        response.should have_selector("a", :href => "/users?page=3", :content => "Next")
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end

      it "should not display delete links on users index" do
        test_sign_in(@user)
        get :index
        response.should_not have_selector("a", :'data-method' => "delete", :content => "delete user")
      end
    end

    describe "as an admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should display delete links on users index" do
        get :index
        response.should have_selector("a", :'data-method' => "delete", :content => "delete user")
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end

