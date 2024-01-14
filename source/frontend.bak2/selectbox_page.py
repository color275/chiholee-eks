import streamlit as st
import streamlit_authenticator as stauth
import yaml
from yaml.loader import SafeLoader

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


def intro():
    import streamlit as st

    st.write("# Welcome to Streamlit! 👋")

def page1():
    import streamlit as st
    st.write("# page_1! 👋")

def page2():
    import streamlit as st
    st.write("# page_2! 👋")

def page3():
    import streamlit as st
    st.write("# page_3! 👋")

def page4():
    import streamlit as st
    st.write("# page_4! 👋")



if st.session_state["authentication_status"]:

    page_names_to_funcs = {
        "—": intro,
        "page1": page1,
        "page2": page2,
        "page3": page3,
        "page4": page4,
    }

    with st.sidebar :
        authenticator.logout('Logout', 'main', key='unique_key')
        demo_name = st.selectbox("Choose a demo", page_names_to_funcs.keys())
    
    page_names_to_funcs[demo_name]()


    

# col1, col2 = st.columns([1,6])
# with col1 :
#     st.button("회원가입", on_click=clicked, args=['register']) 
# with col2 :
#     st.button("패스워드 찾기", on_click=clicked, args=['forgot_password']) 

# if st.session_state.clicked['register']:
#     try:
#         if authenticator.register_user('Register user', preauthorization=False):
#             st.success('User registered successfully')
#             with open('config.yaml', 'w') as file:
#                 yaml.dump(config, file, default_flow_style=False)
#     except Exception as e:
#         st.error(e)

# if st.session_state.clicked['forgot_password']:
#     try:
#         username_of_forgotten_password, email_of_forgotten_password, new_random_password = authenticator.forgot_password('Forgot password')
#         if username_of_forgotten_password:
#             st.success('New password to be sent securely')
#         else:
#             st.error('Username not found')
#     except Exception as e:
#         st.error(e)





