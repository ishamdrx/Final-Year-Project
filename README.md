# URCoach 🏃‍♂️📊
URCoach is a Flutter-based training and performance management system designed specifically for Universiti Putra Malaysia (UPM) athletes, particularly the B10 athletics team. It helps streamline communication between athletes and coaches, automate training plans via chatbot, and manage records efficiently.



**🔧 Features**
For Athletes:
-Role-based login and registration
-Submit training records
-Get automated training plans via chatbot
-View coach feedback and history

For Coaches:
-View athlete progress
-Provide feedback
-Generate training programs using AI
-Archive and restore athlete records

Admin Panel:
-Manage users
-Reset access
-Monitor system records

**🧠 Chatbot**
-Built with Python using a Retrieval-Augmented Generation (RAG) approach:
-Matches athlete prompts with local indexed documents for relevant replies
-Falls back to model-generated output for unmatched prompts (e.g., unrelated queries)
-Extremely fast and context-aware

**🚫 Not Included**
-orca-mini model weights
-urcoach-venv folder (Python virtual environment)

**📜 License**
_This project is licensed under the MIT License._
