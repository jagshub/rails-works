import * as React from 'react';
import {useState} from 'react';
import renderComponent from './utils/renderComponent';
import {useMutation} from "react-apollo";
import gql from "graphql-tag";

const UPDATE = gql`
mutation ($name: String!) {
   userUpdate (name: $name) {
    user {
     name
    }
  }
}
`;

const UserEdit = (props) => {

    const user = props.user;

    const [updateUser, {data}] = useMutation(UPDATE);
    const [username, setName] = useState(user.name);

    const handleChange = (e) => {
        console.log(e.target.value)
        setName(e.target.value);
    }

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!props.signed_in) {
            window.location.href = "/users/sign_in";
        }
        updateUser({variables: {name: username}});
        window.location.href = "/";
    }

    return (
        <React.Fragment>
            <div className="box">
                <article className="user" key={user.id}>
                    <form onSubmit={handleSubmit}>
                        <div>
                            <h2>Edit name</h2>
                            <label>Name*:</label>
                            <input type="text" name="name" value={username} onChange={handleChange}/>
                        </div>
                        <br/>
                        <div>
                            <label>Email:</label>
                            <label> {user.email}</label>

                        </div>
                        <br/>
                        <button name="submit" id="submit" type="submit">Submit</button>
                    </form>
                </article>
            </div>
        </React.Fragment>
    );
};

renderComponent(UserEdit);
