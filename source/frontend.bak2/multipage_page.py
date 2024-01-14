import streamlit as st
import streamlit_authenticator as stauth
import yaml
from yaml.loader import SafeLoader

st.set_page_config(
        page_title="Hello",
        page_icon="👋",
    )

if 'clicked' not in st.session_state:
    st.session_state.clicked = {
        'register':False,
        'forgot_password':False,
        'menu1':False,
        'menu2':False,
        }

def clicked(button):
    st.session_state.clicked[button] = True


st.title("Authentication Demo")

with open('config.yaml') as file:
    config = yaml.load(file, Loader=SafeLoader)

authenticator = stauth.Authenticate(
    config['credentials'],
    config['cookie']['name'],
    config['cookie']['key'],
    config['cookie']['expiry_days'],
    config['preauthorized']
)

name, authentication_status, username = authenticator.login('Login', 'main')
st.session_state["authentication_status"] = authentication_status

if st.session_state["authentication_status"] is False:
    st.error('Username/password is incorrect')
elif st.session_state["authentication_status"] is None:
    st.warning('Please enter your username and password')


if st.session_state["authentication_status"]:
    with st.sidebar :
        authenticator.logout('Logout', 'main', key='unique_key')
    