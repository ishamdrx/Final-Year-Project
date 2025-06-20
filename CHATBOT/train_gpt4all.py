from gpt4all import GPT4All
import json

# Load model (adjust name and device as needed)
model = GPT4All(model_name="orca-mini-3b-gguf2-q4_0.gguf", model_path="./models", device="gpu")

# Load dataset
dataset_path = "./Datasets/sprint_datasets.jsonl"
with open(dataset_path, "r", encoding="utf-8") as f:
    samples = [json.loads(line) for line in f]

# Start training session
with model.chat_session():
    for i, sample in enumerate(samples):
        prompt = sample["prompt"]
        completion = sample["completion"]

        print(f"\n[Training sample {i+1}] Prompt: {prompt}")
        model.train(prompt=prompt, completion=completion)
        print(f"[✓] Trained on sample {i+1}")
