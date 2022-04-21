

# OpenAI Training 


OpenAI uses their own platform for fine tuning. We use command line application called `openai` to train the model. The command line application is available in the link below.


We will first have to download the package
```
pip install openai
```

Then set your OPENAI_API_KEY environment variable by adding the following line into your shell initialization script (e.g. .bashrc, zshrc, etc.) or running it in the command line before the fine-tuning command:
```
export OPENAI_API_KEY=<your_api_key>
```


Unzip the folder in data/processed/ for the data. We will have the prepare the data in the following way:
```
openai tools fine_tunes.prepare_data -f data/processed/files_upload/data_test.jsonl
openai tools fine_tunes.prepare_data -f data/processed/files_upload/data_train.jsonl
openai tools fine_tunes.prepare_data -f data/processed/files_upload/data_valid.jsonl
```

It will generate the following files:
* data_test_prepared.jsonl
* data_train_prepared.jsonl
* data_valid_prepared.jsonl


We finally train our model using the following command:
```
fine_tunes.create  -t  data/processed/data_train_prepared.jsonl -v data/processed/data_valid_prepared.jsonl -m  ada 
```
The code will train an model and give you a fine tuning id. Store the finetune id and use it to get the model.
```

We train an ada model feel free to change your model to babbage, curie or davinci.

Check your results of the fine  tuning by running the following command:
```
openai api fine_tunes.follow -i <finetuneid>
```

Our resuls were:

```
openai api fine_tunes.follow -i <finetuneid>
```
[2022-04-14 15:38:19] Created fine-tune: <finetuneid>
[2022-04-14 15:39:29] Fine-tune costs $66.57
[2022-04-14 15:39:29] Fine-tune enqueued. Queue number: 1
[2022-04-14 15:41:02] Fine-tune is in the queue. Queue number: 0
[2022-04-14 15:43:39] Fine-tune started
[2022-04-15 13:03:02] Completed epoch 2/4
[2022-04-15 23:30:17] Completed epoch 3/4
[2022-04-16 09:57:36] Completed epoch 4/4
[2022-04-16 09:58:10] Uploaded model: ada:<name>
[2022-04-16 09:58:26] Uploaded result file: file-vsW2IzVozGU4dQ6IAWOzZgLl
[2022-04-16 09:58:26] Fine-tune succeeded

Job complete! Status: succeeded 🎉
Try out your fine-tuned model:

openai api completions.create -m ada:ft-personal-<name> -p <YOUR_PROMPT>
```