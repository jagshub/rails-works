ryan = User.create!(
  email: 'ryan@example.com',
  name: 'Ryan',
  password: 'password',
  password_confirmation: 'password',
)

rado = User.create!(
  name: 'Rado',
  email: 'rado@example.com',
  password: 'password',
  password_confirmation: 'password',
)

bob = User.create!(
  name: 'Bob',
  email: 'bob@example.com',
  password: 'password',
  password_confirmation: 'password',
)

UserAssociation.create!(
  followed_by_user: bob,
  following_user: ryan,
)

producthunt = Post.create!(
  title: 'Product Hunt',
  tagline: 'The best new products in tech',
  url: 'https://www.producthunt.com',
  user: ryan,
)

angellist = Post.create!(
  title: 'AngelList',
  tagline: 'Invest in Startups',
  url: 'https://angel.co',
  user: rado,
)

Post.create!(
  title: 'iPhone X',
  tagline: 'It’s all screen',
  url: 'https://www.apple.com/iphone-x/',
  user: bob,
)

Comment.create!(
  text: 'Introducing a new experiment...',
  post: producthunt,
  user: ryan,
)

Comment.create!(
  text: 'I cannot stop browsing!',
  post: producthunt,
  user: rado,
)

Comment.create!(
  text: 'Wow, just discovered a new app!',
  post: producthunt,
  user: rado,
)

Comment.create!(
  text: 'Time to start investing!',
  post: angellist,
  user: rado,
)
