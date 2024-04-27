import google.cloud.bigquery as bq
from langchain_google_community import BigQueryLoader
import os
import config
from langchain_community.utilities import SQLDatabase
from langchain_community.agent_toolkits import create_sql_agent
import pymysql

from langchain_openai import ChatOpenAI
from langchain.prompts import PromptTemplate
from langchain.schema import format_document
#import pybigquery

############ Connect to Database ############
# Set credentials
#os.environ["GOOGLE_CLOUD_PROJECT"] = "aouagent"
creds_file = '/home/cnaughton7/.config/gcloud/application_default_credentials.json'
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = '/home/cnaughton7/.config/gcloud/application_default_credentials.json'

# Connect to TCGA BigQuery database
#TODO: Allow BQ db to persist (currently very slow.
# You may need to set packages to these versions to get to work
#pip install SQLAlchemy==1.4.11
#pip install sqlalchemy-bigquery==1.9.0)
#db_location = f'bigquery://isb-cgc-bq/TCGA'
pymysql.install_as_MySQLdb()
db_location = config.mnt_location
db = SQLDatabase.from_uri(db_location) # Required creating remote account and allowing access


############ Choose LLM ############
# Initialize llm parameters
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0) 
#llm = ChatOpenAI(model="gpt-4", temperature=0)


############ Initialize Agent ############
from langchain_community.agent_toolkits import create_sql_agent
# Initialize llm agent
agent_executor = create_sql_agent(llm, db=db, agent_type="openai-tools", verbose=True)

# Have agent execute query
agent_executor.invoke(
    'How many patients are represented?'
)