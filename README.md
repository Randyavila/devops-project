# Devsu DevOps Project

This is a test project for devsu company for the Devops Engineer rol.

## Deliverables

[Github Randy Avila Repository ](https://github.com/Randyavila/devops-project).

[Docker Hub Repository](https://hub.docker.com/r/randyavs/devops-project-devsu/tags): Docker Images compiled for the Kubernetes testing process.

[Github Action Pipeline ]( https://github.com/Randyavila/devops-project/actions/workflows/deploy-3.yml ): This was the CI/CD tool.

[Documen workflow](https://docs.google.com/document/d/1z-mbMDBNpIacKjxjHEqAdQXSlA00p9RO6SJiSyEf9Dk/edit?usp=sharing).

[Diagrams](https://drive.google.com/file/d/1nSF8Nu5jr8GcM3E2w4aHfyRm4WjN6lGe/view?usp=share_link): Here explain all the workflow context and the pipeline process.


[Dockerfile](https://github.com/Randyavila/devops-project/blob/main/Dockerfile):

```dockerfile
# Use an official Python runtime as a parent image
FROM python:3.11.3

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

#Validate and run migrations on docker images
RUN python manage.py makemigrations
RUN python manage.py migrate

# Make port 8000 available to the world outside this container
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

[Docker Compose Scenario](https://github.com/Randyavila/devops-project/blob/main/docker-compose.yml):

```dockerfile
version: '3'

services:
 web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    ports:
      - "8000:8000"
```

[Pipeline Document](https://github.com/Randyavila/devops-project/blob/main/.github/workflows/deploy-3.yml):

```yml
name: CI/CD Pipeline to Kubernetes

on:
    push:
       branches: [ "main" ]
    pull_request:
       branches: [ "main" ]

jobs:
    #Unit Testing Step
 unit-test:
    runs-on: ubuntu-latest
    steps:
      #Git Checkout to get tha main brach code
    - name: Checkout repository
      uses: actions/checkout@v3
      #Set Up the Python 3.11.3 environment
    - name: Set up Python 3.11.3
      uses: actions/setup-python@v3
      with:
        python-version: '3.11.3'
      #Install dependencies and running migration
    - name: Install dependencies and run migrations
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        python manage.py makemigrations
        python manage.py migrate
      #Runnig Unit Testing
    - name: Run unit tests
      run: |
        python manage.py test

 build:
      #Build Step
    runs-on: ubuntu-latest
    steps:
      #Git Checkout to get tha main brach code
    - name: Checkout repository
      uses: actions/checkout@v3
      #Build Docker Images to push to the docker hub registry
    - name: Build Docker image
      run: |
        docker build -t devops-project-devsu .
      #Login DockerHub Registry
    - name: Login to DockerHub
      uses: docker/login-action@v3
      with:
        username: ${{secrets.DOCKER_HUB_USERNAME}}
        password: ${{secrets.DOCKER_HUB_PASSWORD }}
      #Pushing Docker Images
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{secrets.DOCKER_HUB_USERNAME}}/devops-project-devsu:latest

 code-analysis:
      #Code Analysis and Code Coverage Step
    runs-on: ubuntu-latest
    steps:
      #Git Checkout to get tha main brach code
      - uses: actions/checkout@v3
      #Set Up the Python 3.11.3 environment
      - uses: actions/setup-python@v3
        with:
          python-version: 3.11.3
      #Set Up cache into the pipeline for the scan a coverage
      - uses: actions/cache@v3
        with:
          key: pip-cache
          path: ~/.cache/pip
      #Install depencdencies
      - run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      #Install Dependencies for Code Static Analysis and Coverage
      - run: pip install pylint flake8 coverage pytest-cov
      #Running Flake8 command to get Stylus and scan code
      - run: flake8 -v --output-file=flake8-report.txt --max-complexity=15 --max-line-length=127 --statistics  ./**/*.py
      #Cating flake8 report
      - run: cat flake8-report.txt
      #Running Pylint command to get Scan Project
      - run: pylint ./**/*.py --output-format=text -r y > pylint_output.txt || true
      #Cating Pylint report
      - run: cat pylint_output.txt
      #Runnig Code Coverage
      - run: coverage run manage.py test
      #Geting Coverage Report
      - run: coverage report -m

 deploy:
  #Deploy Step
    runs-on: ubuntu-latest
    steps:
         #Git Checkout to get tha main brach code
        - name: Checkout repository
          uses: actions/checkout@v3
        #Running a minikue cluster
        - name: start minikube
          id: minikube
          uses: medyagh/setup-minikube@latest
        # Running kubectl command to put on kubernetes commands
        - name: kubectl commands
          run: |
            minikube addons enable heapster
            kubectl apply -f ./kubernetes/
            kubectl get all -n devsu
```


