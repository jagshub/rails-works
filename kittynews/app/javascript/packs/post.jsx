import * as React from 'react';
import {useState} from 'react';
import gql from "graphql-tag";
import {useMutation, useQuery} from "react-apollo";
import renderComponent from './utils/renderComponent';

const QUERY = gql`
  query PostDetail ($post_id: Int!) {
    postDetail (postId: $post_id) {
      id
      title
      tagline
      url
      user{
        name
      }
      comments{
        createdAt,
        text,
        user {
          name
        }
      }
      votes {
        user {
          name
        }
      }
      votesCount
    }
  }
`;

const UPVOTE = gql`
mutation ($post_id: ID!) {
  upVote (postId: $post_id) {
    post {
     id
     votesCount
    }
  }
}
`;

const DOWNVOTE = gql`
mutation ($post_id: ID!) {
  downVote (postId: $post_id) {
    post {
     id
     votesCount
    }
  }
}
`;

const Post = (props) => {
    const post = props.post;
    const [selectedPost, setSelectedPost] = useState('');
    const [btnName, setButtonName] = useState('');
    const {loading, error, data} = useQuery(QUERY, {
        variables: {post_id: parseInt(post.id)},
    });
    const [downVote, {downvote_data}] = useMutation(DOWNVOTE, {
        onError: e => {
            console.log("Failed to downvote")
        }
    });
    const [upVote, {upvote_data}] = useMutation(UPVOTE, {
        onError: e => {
            if (e.message == "GraphQL error: Invalid input: Post already voted") {
                downVote({variables: {post_id: selectedPost}});
            }
        }
    });

    if (loading) return null;
    if (error) return `Error! ${error}`;

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!props.signed_in) {
            window.location.href = "/users/sign_in";
        }
        if(btnName == "vote") {
            upVote({variables: {post_id: selectedPost}});
        }
    }

    const handleInput = (el) => {
        setButtonName(el.target.name)
        setSelectedPost(el.target.value)
    }

    return (
        <>
            <form onSubmit={handleSubmit} className="my-3">
                <div className="box">
                    <article className="post" key={post.id}>
                        <h2>
                            <a href={`/posts/${post.id}`}>{post.title}</a>
                        </h2>
                        <div className="url">
                            <a href={post.url}>{post.url}</a>
                        </div>
                        <div className="tagline">{post.tagline}</div>
                        <footer>
                            <button name="vote" value={post.id}
                                    onClick={e => handleInput(e, "value")}>🔼 {post.votesCount}</button>
                            <button name="comment" value={post.commentsCount} onClick={e => handleInput(e, "value")}>💬 {post.commentsCount}</button>
                        </footer>
                    </article>
                </div>
            </form>
        </>
    );
}

export default Post;

renderComponent(Post);
