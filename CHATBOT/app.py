from flask import Flask, request, jsonify
from flask_cors import CORS
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import GPT4AllEmbeddings
from langchain.chains import RetrievalQA
from langchain_community.llms import GPT4All
import json
import random

app = Flask(__name__)
CORS(app)

# Load your dataset into a dictionary for exact match fallback
dataset_path = "./Datasets/sprint_datasets.jsonl"
prompt_completion_map = {}

with open(dataset_path, "r", encoding="utf-8") as f:
    for line in f:
        entry = json.loads(line)
        prompt_completion_map[entry["prompt"].strip().lower()] = entry["completion"]

# Load LangChain-compatible GPT4All model
model = GPT4All(
    model="./models/orca-mini-3b-gguf2-q4_0.gguf",
    backend="llama",
    verbose=True
)

# Load FAISS vector store for RAG
embedding_model = GPT4AllEmbeddings()
db = FAISS.load_local("localdocs_index", embedding_model, allow_dangerous_deserialization=True)

qa = RetrievalQA.from_chain_type(
    llm=model,
    retriever=db.as_retriever(search_kwargs={"k": 5}),
    return_source_documents=False
)

@app.route('/generate-plan', methods=['POST'])
def generate_plan():
    try:
        data = request.json
        user_prompt = data.get("prompt", "").strip()
        print("[Request]", user_prompt)

        lower_prompt = user_prompt.lower()

        # Friendly prefix
        interactive_openers = [
            "Sure thing! Here’s a plan:",
            "Alright champ, check this out:",
            "No worries, I got you:",
            "Yes, of course. Here's what I suggest:",
            "Here you go, this might help:"
        ]
        prefix = random.choice(interactive_openers)

        # Exact-match fallback
        if lower_prompt in prompt_completion_map:
            matched_response = prompt_completion_map[lower_prompt]
            print("[Matched from dataset]")
            return jsonify({"response": f"{prefix}\n\n{matched_response}"})

        # Scope guard: only allow track & field queries
        allowed_keywords = [
            "sprint", "training", "run", "athlete", "plan", 
            "track", "field", "gym", "workout", "strength", 
            "endurance", "hurdle", "400m", "100m", "200m"
        ]
        if not any(keyword in lower_prompt for keyword in allowed_keywords):
            return jsonify({
                "response": "Sorry, I specialize in track and field training. "
                            "Please ask something related to sprinting, hurdling, or workouts."
            })

        # Fallback to RAG
        print("[Falling back to RAG]")
        response = qa.run(user_prompt)
        print("[Model Output]", response)

        # Normalize and analyze response
        response = response.strip()

        # If no useful answer
        if not response or len(response) < 10:
            fallback_msg = "Sorry, I’m not trained on that yet — but I’m learning fast!"
            return jsonify({"response": fallback_msg})

        # If LLM apologizes
        if "i'm sorry" in response.lower():
            return jsonify({"response": response})

        # Otherwise return friendly, augmented response
        return jsonify({"response": f"{prefix}\n\n{response}"})

    except Exception as e:
        print("[ERROR]", str(e))
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")
