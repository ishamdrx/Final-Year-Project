from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForCausalLM, Trainer, TrainingArguments, DataCollatorForLanguageModeling
import torch

# Load your dataset
dataset = load_dataset('json', data_files='Datasets/sprint_datasets.jsonl', split='train')

# Load model and tokenizer
model_name = "EleutherAI/gpt-neo-125M"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name)

# Tokenize the data
def tokenize_function(example):
    prompt = example["prompt"]
    completion = example["completion"]
    text = f"{prompt}\n{completion}"
    return tokenizer(text, truncation=True, padding='max_length', max_length=512)

tokenized_dataset = dataset.map(tokenize_function, batched=False)
data_collator = DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False)

# Training arguments
training_args = TrainingArguments(
    output_dir="./sprint_model",
    per_device_train_batch_size=2,
    num_train_epochs=3,
    save_steps=100,
    save_total_limit=1,
    logging_dir='./logs',
    logging_steps=10,
    fp16=torch.cuda.is_available(),
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset,
    tokenizer=tokenizer,
    data_collator=data_collator,
)

trainer.train()
