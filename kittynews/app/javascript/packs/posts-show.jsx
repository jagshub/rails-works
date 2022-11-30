import * as React from 'react';
import gql from "graphql-tag";
import {useMutation, useQuery} from "react-apollo";
import renderComponent from './utils/renderComponent';
import Post from "./post";
import {useState} from "react";


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
      commentsCount
      votesCount
    }
  }
`;

const ADDCOMMENT = gql`
mutation ($postId: ID!, $userId: ID!, $text: String!) {
        addComment (postId: $postId, userId: $userId, text: $text) {
            post{
                title
                comments{
                  createdAt,
                  text,
                  user {
                    name
                  }
                }
            }
        }
}
`;

const PostsShow = (props) => {
    const [comment_text, setComment] = useState("");
    const [mutated_comments_count, setCount] = useState(0);
    const {loading, error, data} = useQuery(QUERY, {
        variables: {post_id: parseInt(props.postId)},
    });
    const [comments, setComments] = useState("");

    const [createComment, {comment_data}] = useMutation(ADDCOMMENT, {
        onCompleted: data => {
            setComments(data.addComment.post.comments);
            setCount(data.addComment.post.comments.length)
            console.log("mutation response comments" + JSON.stringify(data.addComment.post.comments));
        },
        onError: e => {
            console.log("Failed to comment" + e.message);
        }
    });

    if (loading) return null;
    if (error) return `Error! ${error}`;

    let p = data.postDetail;
    let all_comments = comments == "" ? p.comments : comments;

    const handleChange = (e) => {
        setComment(e.target.value);
    }

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!props.signed_in) {
            window.location.href = "/users/sign_in";
        }
        createComment({variables: {postId: p.id, userId: props.current_user, text: comment_text}});
    }

    return (
        <React.Fragment>
            <Post signed_in={props.signed_in} post={p}/>
            <div className="box">
                <footer>
                    {mutated_comments_count > 0 ? mutated_comments_count :  p.comments.count} comments | author:{' '}
                    {p.user.name}
                </footer>
            </div>
            <form onSubmit={handleSubmit}>
                <div>
                    <h2>Add Comment</h2>
                    <label>Comment text*:</label>
                    <input type="hidden" name="postid" value={p.id}/>
                    <textarea type="text" name="comment" onChange={handleChange} placeholder="enter comment" />
                </div>
                <br/>
                <button name="submit" id="submit" type="submit">Submit</button>
            </form>
            <div className="box">
                {all_comments.map((comment) => (
                    <div className="container mt-5">
                        <div className="row d-flex justify-content-center">
                            <div>
                                <div className="card p-3">
                                    <br></br>
                                    <div className="d-flex justify-content-between align-items-center">
                                        <div className="user d-flex flex-row align-items-center">
                  <span><small className="font-weight-bold text-primary">{comment.user.name} | </small> <small
                      className="font-weight-bold">{comment.text}</small></span></div>
                                        <div className="align-right">
                                            <br></br>
                                            <small>{new Date(comment.createdAt).toLocaleString()} </small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

        </React.Fragment>
    );
};

renderComponent(PostsShow);
