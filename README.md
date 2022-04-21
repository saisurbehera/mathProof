mathproof
==============================

We explore the application of transformer-based Language Models (LM) to automated theorem proving. We specifically use a GPT-3 based neural network fine-tuned on mathlib code to generate math sequences. Our LMs acts as an automated prover and proof assistant. We further combine couple of language models and re-ranker to select for the best results. Overall this improves the results from 0.322 to 0.3627 for out GPT-3 based ADA model and 0.4592 for our combined GPT-3 and GPT-NEO model. Our github code is on.

# Data


A large part of our code involves and build upon the work done at OpenAI. We further go a  step ahead and add all the packages heres. 

You can download the files with the proceesed data from the link below.

```
https://drive.google.com/file/d/1rD1GC8OLTKimUiatjFWhCwsh_DaZGur6/view?usp=sharing
```

We use the following Libraries to help us with out code. All our data is prepared in the  folder and processed. All the data can be downloaded with the link above. The code takes a while to run therefore download it from the link above.

The libraries which help our code are:
```
https://github.com/leanprover-community/mathlib.git
https://github.com/openai/miniF2F.git
https://github.com/jasonrute/lean_proof_recording.git
https://github.com/jesse-michael-han/lean-gptf.git
https://github.com/jesse-michael-han/lean-step-public.git
https://github.com/jesse-michael-han/lean-tpe-public.git
```


# Model

As discussed in the model, we have three different models. The first is the GPT-3 model which is a fine-tuned model on the mathlib code. The second is the GPT-NEO model which is a model which is trained on the mathlib code. The third is the combined model which is a combination of the GPT-3 and GPT-NEO model and reranked. The combined model is the best model for our project. 

Please check the GPT-3 Folder under src/gpt3/ for how to train the model.





Project Organization
------------

    ├── LICENSE
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── README.md          <- The top-level README for developers using this project.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── docs               <- A default Sphinx project; see sphinx-doc.org for details
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── setup.py           <- makes project pip installable (pip install -e .) so src can be imported
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   │
    │   ├── data           <- Scripts to download or generate data
    │   │   └── make_dataset.py
    │   │
    │   ├── features       <- Scripts to turn raw data into features for modeling
    │   │   └── build_features.py
    │   │
    │   ├── models         <- Scripts to train models and then use trained models to make
    │   │   │                 predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │   │
    │   └── visualization  <- Scripts to create exploratory and results oriented visualizations
    │       └── visualize.py
    │
    └── tox.ini            <- tox file with settings for running tox; see tox.readthedocs.io


--------

<p><small>Project based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>. #cookiecutterdatascience</small></p>
