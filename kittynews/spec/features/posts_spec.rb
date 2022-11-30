require 'rails_helper'

feature 'Posts' do
  scenario 'Displaying the posts on the homepage', js: true do
    post_1 = create :post
    post_2 = create :post
    user = create :user
    create :vote, user: user, post: post_1
    create :vote, user: user, post: post_2

    visit root_path

    expect(page).to have_content post_1.title
    expect(page).to have_content post_2.title
  end

  scenario 'Click by an unlogged user should redirect to the login page', js: true do
    user = create :user
    post = create :post
    create :vote, user: user, post: post
    create :comment, text: "awesome post", user: user, post: post

    visit root_path
    page.find('button', text: '🔼 1')
    click_on "vote"
    expect(page).to have_link(href: '/users/sign_in')
    page.has_content?('Log in')
  end

  scenario 'Login and Upvote/Downvote as 2 different users', js: true do
    user1 = create :user
    user2 = create :user
    post = create :post
    create :vote, user: user1, post: post
    create :comment, text: "awesome post", user: user1, post: post

    visit root_path
    click_on "Login"
    fill_in 'user_email', :with => user1.email
    fill_in 'user_password', :with => user1.password
    click_on "Log in"
    page.find('button', text: '💬 1')
    page.find('button', text: '🔼 1')
    click_on "vote"
    page.find('button', text: '🔼 0')
    click_on "vote"
    page.find('button', text: '🔼 1')

    click_on "Logout"

    create :comment, text: "awesome post", user: user2, post: post

    click_on "Login"
    fill_in 'user_email', :with => user2.email
    fill_in 'user_password', :with => user2.password
    click_on "Log in"
    click_on "vote"
    page.find('button', text: '🔼 2')
    page.find('button', text: '💬 2')
  end

  scenario 'Displaying the post detail page with all comments', js: true do
    user = create :user
    post = create :post, user: user
    create :vote, user: user, post: post
    comment1 = create :comment, text: "awesome post", user: user, post: post
    comment2 = create :comment, text: "product of the week", user: user, post: post
    comment3 = create :comment, text: "most downloaded this year", user: user, post: post

    visit root_path
    click_on post.title

    expect(page).to have_content 'comments'
    expect(page).to have_content post.title
    expect(page).to have_content post.tagline
    expect(page).to have_content "author: #{user.name}"
    expect(page).to have_content comment1.text
    expect(page).to have_content comment2.text
    expect(page).to have_content comment3.text
    expect(page).to have_content post.votes_count
  end


  scenario 'Edit user and change name', js: true do
    user = create :user
    post = create :post, user: user
    create :vote, user: user, post: post

    visit root_path

    click_on "Login"
    fill_in 'user_email', :with => user.email
    fill_in 'user_password', :with => user.password
    click_on "Log in"
    click_on user.name
    fill_in 'name', :with => "John Rambo"
    click_on "Submit"
    visit root_path
    expect(page).to have_content "Hi John Rambo"
  end
end
