# URCoach 🏃‍♂️📊
URCoach is a Flutter-based training and performance management system designed specifically for Universiti Putra Malaysia (UPM) athletes, particularly the B10 athletics team. It helps streamline communication between athletes and coaches, automate training plans via chatbot, and manage records efficiently.

**PROJECT STRUCTURE**

├── SYSTEM       → Full Flutter app source code (login, signup, dashboards, etc.)
├── CHATBOT      → RAG-based chatbot with dataset and scripts
│   ├── Datasets
│   │   └── sprint_datasets.jsonl
│   ├── localdocs_index/
│   ├── app.py
│   ├── finetune.py
│   ├── ingest_jsonl_docs.py
│   ├── train_gpt4all.py
│   └── requirements.txt
_Note: Due to size limitations, the model (Orca Mini) and virtual environment (urcoach-venv) are not included._

**🔧 Features**
For Athletes:
Role-based login and registration

Submit training records

Get automated training plans via chatbot

View coach feedback and history

For Coaches:
View athlete progress

Provide feedback

Generate training programs using AI

Archive and restore athlete records

Admin Panel:
Manage users

Reset access

Monitor system records

**🧠 Chatbot**
Built with Python using a Retrieval-Augmented Generation (RAG) approach:

Matches athlete prompts with local indexed documents for relevant replies

Falls back to model-generated output for unmatched prompts (e.g., unrelated queries)

Extremely fast and context-aware

**🚫 Not Included**
orca-mini model weights

urcoach-venv folder (Python virtual environment)

**📜 License**
This project is licensed under the MIT License.
