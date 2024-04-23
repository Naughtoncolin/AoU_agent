import google.cloud.bigquery as bq
from langchain_google_community import BigQueryLoader
import os

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
#TODO: Allow db to persist (currently very slow.
# You may need to set packages to these versions to get to work
#pip install SQLAlchemy==1.4.11
#pip install sqlalchemy-bigquery==1.9.0)
#from langchain_community.utilities import SQLDatabase
#db_location = f'bigquery://isb-cgc-bq/TCGA'
#db = SQLDatabase.from_uri(db_location) # Required creating remote account and allowing access

# Define our query (get table info)
query = f"""
SELECT table_name, ddl
FROM `isb-cgc-bq.TCGA.INFORMATION_SCHEMA.TABLES`
WHERE table_type = 'BASE TABLE'
ORDER BY table_name;
"""

# Load the data
loader = BigQueryLoader(
    query, metadata_columns="table_name", page_content_columns="ddl"
)
data = loader.load()
print(data)

############ Choose LLM ############
# Initialize llm parameters
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0) 
#llm = ChatOpenAI(model="gpt-4", temperature=0)

############ Define the chain ############
chain = (
    {
        "content": lambda docs: "\n\n".join(
            format_document(doc, PromptTemplate.from_template("{page_content}"))
            for doc in docs
        )
    }
    | PromptTemplate.from_template(
        "Suggest a GoogleSQL query that will help me identify European patients:\n\n{content}"
    )
    | llm
)

############## Run the chain ############
'''This code is not working yet. The table names with their accompanying descriptions are too many tokens for gpt-3.5-turbo; it may be possible with gpt4 but the limit would need to be set higher'''
# Invoke the chain with the documents, and remove code backticks
result = chain.invoke(data).strip("```")
print(result)

#Other prompts
#'How many patients are represented?'

