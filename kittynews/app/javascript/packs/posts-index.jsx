import * as React from 'react';
import gql from 'graphql-tag';
import {useQuery} from 'react-apollo';
import renderComponent from './utils/renderComponent';
import Post from "./post";

const QUERY = gql`
  query PostsPage {
    viewer {
      id
    }
    postsAll {
      id
      title
      tagline
      url
      commentsCount
      votesCount
    }
  }
`;

const PostsIndex = (user_info) => {

  const {loading, error, data} = useQuery(QUERY);

  if (loading) return 'Loading...';
  if (error) return `Error! ${error.message}`;

  return (
      <div className="box">
        {data.postsAll.map((post) => (
            <React.Fragment>
              <Post signed_in={user_info.signed_in} post={post}/>
            </React.Fragment>
        ))}
      </div>
  );
};

renderComponent(PostsIndex);
