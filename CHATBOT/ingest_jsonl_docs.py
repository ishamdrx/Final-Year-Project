# ingest_jsonl_docs.py
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import GPT4AllEmbeddings
from langchain.docstore.document import Document
import json
import os

# Load your JSONL
dataset_path = "./Datasets/sprint_datasets.jsonl"
documents = []

with open(dataset_path, "r", encoding="utf-8") as f:
    for line in f:
        entry = json.loads(line)
        prompt = entry["prompt"]
        completion = entry["completion"]
        full_text = f"Prompt: {prompt}\nCompletion: {completion}"
        documents.append(Document(page_content=full_text))

# Save FAISS index
embedding = GPT4AllEmbeddings()
db = FAISS.from_documents(documents, embedding)
db.save_local("localdocs_index")

print("FAISS vector store created from JSONL.")
