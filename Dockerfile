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