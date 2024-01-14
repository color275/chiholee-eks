import streamlit as st
import time
import numpy as np


# st.write(st.session_state["authentication_status"])
if not st.session_state["authentication_status"] :
    st.error("You need to be an admin to access this page.")
    st.stop()

st.set_page_config(page_title="Page1", page_icon="📈")
st.markdown("# Page1")
st.sidebar.header("Plotting Demo")


